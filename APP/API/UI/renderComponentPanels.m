function renderComponentPanels(app, preCheck, root)
%RENDERCOMPONENTPANELS Build the component dropdown panels in the Components tab.
%   renderComponentPanels(app, preCheck, root)
%
%   Creates one panel per component instance with:
%     - Label and description button
%     - Dropdown with valid/missing model items
%     - Open and Param action buttons
%     - Context menu for param link/unlink
%     - Red note label for missing models/params
%
%   Populates app.ComponentDropdowns and app.ComponentButtons.

    % ---- Outer scrollable grid ----
    app.GridLayoutComponent = uigridlayout(app.ComponentsPanel, ...
        'Padding', [5 5 5 5], 'RowSpacing', 10, 'ColumnSpacing', 5);
    app.GridLayoutComponent.Scrollable = 'on';

    rowCount = max(1, numel(preCheck));
    app.GridLayoutComponent.RowHeight   = repmat({'fit'}, 1, rowCount);
    app.GridLayoutComponent.ColumnWidth = {'1x'};

    app.ComponentDropdowns = struct();
    app.ComponentButtons   = struct();

    % ---- One panel per instance ----
    for i = 1:numel(preCheck)
        info = preCheck(i);

        % --- Panel container ---
        panel = uipanel(app.GridLayoutComponent, 'BorderType', 'line');
        panel.Layout.Row    = i;
        panel.Layout.Column = 1;

        % Inner grid: 4 rows (label, dropdown, buttons, red note)
        gl = uigridlayout(panel, ...
            'RowHeight',    {'fit', 'fit', 'fit', 'fit'}, ...
            'ColumnWidth',  {'1x', '0.4x', '1x', '0.4x', 'fit'}, ...
            'Padding',      [5 5 5 5], ...
            'RowSpacing',   5, ...
            'ColumnSpacing', 10);
        gl.BackgroundColor = min(gl.BackgroundColor * 2, [1 1 1]);

        % --- Row 1: instance label + description button ---
        lbl = uilabel(gl, ...
            'Text', info.Label, ...
            'FontWeight', 'bold', ...
            'WordWrap', 'on');
        lbl.Layout.Row    = 1;
        lbl.Layout.Column = [1 3];

        descBtn = uibutton(gl, 'push', ...
            'Text', '?', ...
            'Tooltip', 'Show instance description', ...
            'BackgroundColor', [0.90 0.96 1.00], ...
            'FontColor', [0 0 0], ...
            'ButtonPushedFcn', @(~,~) showInstanceDescription(app, info.Comp, info.Label));
        descBtn.Layout.Row    = 1;
        descBtn.Layout.Column = 5;

        % --- Row 2: model dropdown ---
        compDropDown = buildComponentDropdown(gl, info);
        compDropDown.Layout.Row    = 2;
        compDropDown.Layout.Column = [1 5];

        % Store model folder (used by Open/Param helpers)
        compDropDown.UserData.ModelFolder = info.Folder;

        % --- Row 3: Open and Param buttons ---
        openBtn = uibutton(gl, 'push', ...
            'Text', 'Open', ...
            'Tooltip', 'Open selected model in Simulink', ...
            'ButtonPushedFcn', @(~,~) openInstanceModel(app, info.Comp, info.Label));
        openBtn.Layout.Row    = 3;
        openBtn.Layout.Column = [1 2];

        paramBtn = uibutton(gl, 'push', ...
            'Text', 'Param', ...
            'Tooltip', 'Open parameter script (auto or linked)', ...
            'ButtonPushedFcn', @(~,~) openParamSmart(app, info.Comp, compDropDown, root));
        paramBtn.Layout.Row    = 3;
        paramBtn.Layout.Column = [3 4];

        % --- Wire up UserData references ---
        ud = compDropDown.UserData;
        ud.ParamButton      = paramBtn;
        ud.ParamStatusLabel  = [];
        ud.CompName          = char(info.Comp);
        ud.RootFolder        = char(root);
        compDropDown.UserData = ud;

        % --- Context menu for Link / Unlink ---
        cm = uicontextmenu(app.UIFigure);
        uimenu(cm, 'Text', 'Link Param File...', ...
            'MenuSelectedFcn', @(~,~) paramContextLink(app, paramBtn, compDropDown, root));
        uimenu(cm, 'Text', 'Unlink', ...
            'MenuSelectedFcn', @(~,~) paramContextUnlink(app, paramBtn, compDropDown, root));
        paramBtn.ContextMenu = cm;

        % Initialize tooltip
        updateParamTooltip(paramBtn, compDropDown, root);

        % Disable Open button if no valid model selected
        if isempty(info.Valid) || startsWith(string(compDropDown.Value), "__MISSING__")
            openBtn.Enable = 'off';
        end

        % --- Row 4: red note for missing models/params ---
        renderRedNoteLabel(gl, info, compDropDown, root);

        % --- Store handles ---
        handleKey = matlab.lang.makeValidName([info.Comp '_' info.Label]);
        app.ComponentDropdowns.(handleKey) = compDropDown;
        app.ComponentButtons.(handleKey)   = paramBtn;
    end
end

%% ========================= Local helpers =========================

function dd = buildComponentDropdown(gl, info)
%BUILDCOMPONENTDROPDOWN Create a dropdown with valid items and [missing] markers.
    validItems   = cellfun(@char, info.Valid,   'UniformOutput', false);
    missingItems = cellfun(@char, ...
        strcat(string(info.Missing), " [missing]"), 'UniformOutput', false);

    allItems = [validItems, missingItems];
    allData  = [validItems, ...
        cellfun(@char, strcat("__MISSING__", string(info.Missing)), ...
            'UniformOutput', false)];

    if isempty(allItems)
        dd = uidropdown(gl, ...
            'Items',     {'<no models found in expected folder or config>'}, ...
            'ItemsData', {'<NONE>'}, ...
            'Value',     '<NONE>', ...
            'Enable',    'off');
        return;
    end

    if ~isempty(validItems)
        initialValue = validItems{1};
    else
        initialValue = allData{1};
    end

    dd = uidropdown(gl, ...
        'Items',     allItems, ...
        'ItemsData', allData, ...
        'Value',     initialValue);

    dd.ValueChangedFcn         = @(src, ~) preventMissingSelection(src);
    dd.UserData.LastValidValue = initialValue;
    dd.UserData.InstanceLabel  = char(info.Label);
    dd.UserData.InstanceComp   = char(info.Comp);
end

function renderRedNoteLabel(gl, info, compDropDown, root)
%RENDERREDNOTELABEL Show a red warning label for missing models and/or param files.
    paramNote = computeParamMissingNote(info.Comp, compDropDown, root);

    hasMissingModels = ~isempty(info.MissingNoteStrings);
    hasMissingParam  = ~isempty(paramNote);
    if ~hasMissingModels && ~hasMissingParam
        return;
    end

    % Compose text
    parts = strings(0, 1);
    if hasMissingModels
        parts(end+1) = sprintf("Missing in folder: %s", ...
            strjoin(info.MissingNoteStrings, '  |  '));
    end
    if hasMissingParam
        parts(end+1) = string(paramNote);
    end

    missLbl = uilabel(gl, ...
        'Text',      strjoin(parts, '  |  '), ...
        'FontColor', [0.85 0 0], ...
        'WordWrap',  'on');
    missLbl.Layout.Row    = 4;
    missLbl.Layout.Column = [1 5];

    % Store handle so dropdown callback can update this label
    ud = compDropDown.UserData;
    ud.ParamStatusLabel = missLbl;
    compDropDown.UserData = ud;
end

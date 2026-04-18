function renderComponentPanels(app, availability, root)
%RENDERCOMPONENTPANELS Build component dropdown panels in the Components tab.
%   renderComponentPanels(app, availability, root)
%
%   Creates one panel per component instance with:
%     - Label and description button (row 1)
%     - Dropdown with valid/missing model items (row 2)
%     - Open and Param action buttons (row 3)
%     - Red note label for missing models/params (row 4)
%
%   Populates app.ComponentDropdowns and app.ComponentButtons.

    % ---- Outer scrollable grid ----
    app.GridLayoutComponent = uigridlayout(app.ComponentsPanel, ...
        'Padding',       [5 5 5 5], ...
        'RowSpacing',    10, ...
        'ColumnSpacing', 5);

    app.GridLayoutComponent.Scrollable = 'on';

    rowCount = max(1, numel(availability));
    app.GridLayoutComponent.RowHeight   = repmat({'fit'}, 1, rowCount);
    app.GridLayoutComponent.ColumnWidth = {'1x'};

    app.ComponentDropdowns = struct();
    app.ComponentButtons   = struct();

    % ---- One panel per instance ----
    for i = 1:numel(availability)
        info = availability(i);

        % ---- Panel container ----
        panel = uipanel(app.GridLayoutComponent, ...
            'BorderType', 'line');
        panel.Layout.Row    = i;
        panel.Layout.Column = 1;

        gl = uigridlayout(panel, ...
            'RowHeight',     {'fit', 'fit', 'fit', 'fit'}, ...
            'ColumnWidth',   {'1x', '1x', 'fit'}, ...
            'Padding',       [5 5 5 5], ...
            'RowSpacing',    5, ...
            'ColumnSpacing', 5);
        gl.BackgroundColor = min(gl.BackgroundColor * 2, [1 1 1]);

        % ---- Row 1: instance label + description button ----

        lbl = uilabel(gl, ...
            'Text',       info.Label, ...
            'FontWeight', 'bold', ...
            'WordWrap',   'on');
        lbl.Layout.Row    = 1;
        lbl.Layout.Column = [1 2];

        descBtn = uibutton(gl, 'push', ...
            'Text',            '?', ...
            'Tooltip',         'Show instance description', ...
            'BackgroundColor', [0.90 0.96 1.00], ...
            'FontColor',       [0 0 0], ...
            'ButtonPushedFcn', @(~,~) showInstanceDescription(app, info.Comp, info.Label));
        descBtn.Layout.Row    = 1;
        descBtn.Layout.Column = 3;

        % ---- Row 2: model dropdown ----

        compDropDown = buildComponentDropdown(gl, info);
        compDropDown.Layout.Row    = 2;
        compDropDown.Layout.Column = [1 3];

        % ---- Row 3: action buttons ----

        openBtn = uibutton(gl, 'push', ...
            'Text',            'Open Model', ...
            'Tooltip',         'Open selected model in Simulink', ...
            'ButtonPushedFcn', @(~,~) openInstanceModel(app, info.Comp, info.Label));
        openBtn.Layout.Row    = 3;
        openBtn.Layout.Column = 1;

        paramBtn = uibutton(gl, 'push', ...
            'Text',            'Param File', ...
            'Tooltip',         'Open parameter script (auto or linked)', ...
            'ButtonPushedFcn', @(~,~) openParamSmart(app, info.Comp, compDropDown, root));
        paramBtn.Layout.Row    = 3;
        paramBtn.Layout.Column = 2;

        % ---- Wire UserData references ----

        ud = compDropDown.UserData;
        ud.ModelFolder      = info.Folder;
        ud.ParamButton      = paramBtn;
        ud.ParamStatusLabel = [];
        ud.CompName         = char(info.Comp);
        ud.RootFolder       = char(root);
        compDropDown.UserData = ud;

        % ---- Context menu for param Link / Unlink ----

        cm = uicontextmenu(app.UIFigure);

        uimenu(cm, ...
            'Text',            'Link Param File...', ...
            'MenuSelectedFcn', @(~,~) paramContextLink(app, paramBtn, compDropDown, root));

        uimenu(cm, ...
            'Text',            'Unlink', ...
            'MenuSelectedFcn', @(~,~) paramContextUnlink(app, paramBtn, compDropDown, root));

        paramBtn.ContextMenu = cm;

        if isempty(info.Valid) || startsWith(string(compDropDown.Value), "__MISSING__")
            openBtn.Enable = 'off';
        end

        % ---- Row 4: red note for missing models/params ----
        % computeParamMissingNote (inside renderRedNoteLabel) discovers and
        % sets the default ParamFile in UserData, so tooltip must come AFTER.

        renderRedNoteLabel(gl, info, compDropDown, root);

        % ---- Initialize tooltip (after ParamFile is set) ----

        updateParamTooltip(paramBtn, compDropDown);

        % ---- Store handles ----

        handleKey = matlab.lang.makeValidName([info.Comp '_' info.Label]);
        app.ComponentDropdowns.(handleKey) = compDropDown;
        app.ComponentButtons.(handleKey)   = paramBtn;
    end
end

%% ========================= Local helpers =========================

function dd = buildComponentDropdown(gl, info)
%BUILDCOMPONENTDROPDOWN Create a dropdown with valid items and [missing] markers.

    % Prepare display and data items
    validItems = cellfun(@char, info.Valid, 'UniformOutput', false);

    missingDisplayItems = cellfun(@char, ...
        strcat(string(info.Missing), " [missing]"), ...
        'UniformOutput', false);

    missingDataItems = cellfun(@char, ...
        strcat("__MISSING__", string(info.Missing)), ...
        'UniformOutput', false);

    allItems = [validItems, missingDisplayItems];
    allData  = [validItems, missingDataItems];

    % Handle empty case
    if isempty(allItems)
        dd = uidropdown(gl, ...
            'Items',     {'<no models found in expected folder or config>'}, ...
            'ItemsData', {'<NONE>'}, ...
            'Value',     '<NONE>', ...
            'Enable',    'off');
        return;
    end

    % Select first valid model, or first missing if none valid
    if ~isempty(validItems)
        initialValue = validItems{1};
    else
        initialValue = allData{1};
    end

    % Create dropdown
    dd = uidropdown(gl, ...
        'Items',     allItems, ...
        'ItemsData', allData, ...
        'Value',     initialValue);

    dd.ValueChangedFcn = @(src, ~) preventMissingSelection(src);

    % Initialize UserData
    dd.UserData = struct( ...
        'LastValidValue', initialValue, ...
        'InstanceLabel',  char(info.Label), ...
        'InstanceComp',   char(info.Comp));
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
    missLbl.Layout.Column = [1 3];

    % Store handle so dropdown callback can update this label
    ud = compDropDown.UserData;
    ud.ParamStatusLabel = missLbl;
    compDropDown.UserData = ud;
end

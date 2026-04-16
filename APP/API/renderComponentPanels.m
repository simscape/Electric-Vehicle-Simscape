function renderComponentPanels(app, preCheck, root)
%RENDERCOMPONENTPANELS Build the component dropdown panels in the Components tab.
%   renderComponentPanels(app, preCheck, root)
%
%   Creates one panel per component instance with dropdown, Open/Param
%   buttons, context menu, and red note labels. Populates
%   app.ComponentDropdowns and app.ComponentButtons.
%
%   Inputs:
%     app      — BEVapp handle
%     preCheck — struct array from scanComponentAvailability
%                (.Comp, .Label, .Valid, .Missing, .MissingNoteStrings, .Folder)
%     root     — project root folder (char)

    app.GridLayoutComponent = uigridlayout(app.ComponentsPanel, ...
        'Padding',[5 5 5 5], 'RowSpacing',10, 'ColumnSpacing',5);
    app.GridLayoutComponent.Scrollable = 'on';
    rowCount = max(1, numel(preCheck));
    app.GridLayoutComponent.RowHeight   = repmat({'fit'},1,rowCount);
    app.GridLayoutComponent.ColumnWidth = {'1x'};

    app.ComponentDropdowns = struct();
    app.ComponentButtons =  struct();

    for i = 1:numel(preCheck)
        compDropdowninfo = preCheck(i);

        % Panel per instance
        compPanel = uipanel(app.GridLayoutComponent, 'BorderType','line');
        compPanel.Layout.Row = i; compPanel.Layout.Column = 1;

        % Inner grid (extra row for red note)
        compGridLayout = uigridlayout(compPanel, ...
            'RowHeight',{'fit','fit','fit','fit'}, ...
            'ColumnWidth',{'1x','0.4x','1x','0.4x','fit'}, ...
            'Padding',[5 5 5 5], 'RowSpacing',5, 'ColumnSpacing',10);
        compGridLayout.BackgroundColor = min(compGridLayout.BackgroundColor * 2,[1 1 1]);

        % Row 1: label + buttons
        compLabel = uilabel(compGridLayout,'Text',[compDropdowninfo.Label], ...
            'FontWeight','bold','WordWrap','on');
        compLabel.Layout.Row = 1; compLabel.Layout.Column = [1 3];

        CompDesc = uibutton(compGridLayout,'push','Text','?', ...
            'Tooltip','Show instance description', ...
            'BackgroundColor',[0.90,0.96,1.00], ...
            'FontColor',[0,0,0], ...
            'ButtonPushedFcn',@(~,~) showInstanceDescription(app, compDropdowninfo.Comp, compDropdowninfo.Label));
        CompDesc.Layout.Row = 1; CompDesc.Layout.Column = 5;

        % Compose dropdown items (valid selectable; missing blocked)
        itemsValid   = cellfun(@char, compDropdowninfo.Valid,   'UniformOutput', false);
        itemsMissing = cellfun(@char, strcat(string(compDropdowninfo.Missing), " [missing]"), 'UniformOutput', false);
        itemsAll     = [itemsValid, itemsMissing];
        dataAll      = [itemsValid, cellfun(@char, strcat("__MISSING__", string(compDropdowninfo.Missing)), 'UniformOutput', false)];

        % Row 2: dropdown
        if isempty(itemsAll)
            compDropDown = uidropdown(compGridLayout, ...
                'Items',{'<no models found in expected folder or config>'}, ...
                'ItemsData',{'<NONE>'}, 'Value','<NONE>', 'Enable','off');
        else
            if ~isempty(itemsValid)
                initVal = itemsValid{1};
            else
                initVal = dataAll{1};
            end
            compDropDown = uidropdown(compGridLayout, ...
                'Items',itemsAll, 'ItemsData',dataAll, 'Value',initVal);
            compDropDown.ValueChangedFcn = @(dd,~) preventMissingSelection(dd);
            compDropDown.UserData.LastValidValue = initVal;
            compDropDown.UserData.InstanceLabel    = char(compDropdowninfo.Label);
            compDropDown.UserData.InstanceComp    = char(compDropdowninfo.Comp);
        end
        compDropDown.Layout.Row = 2; compDropDown.Layout.Column = [1 5];

        % Store model folder for this instance (used by Open/Param helpers)
        compDropDown.UserData.ModelFolder = compDropdowninfo.Folder;

        % Row 3: action buttons
        compOpen = uibutton(compGridLayout,'push','Text','Open', ...
            'Tooltip','Open selected model in Simulink', ...
            'ButtonPushedFcn',@(~,~) openInstanceModel(app, compDropdowninfo.Comp, compDropdowninfo.Label));
        compOpen.Layout.Row = 3; compOpen.Layout.Column = [1 2];

        % --- Param button with manual-link support + context menu ---
        compParamOpen = uibutton(compGridLayout,'push','Text','Param', ...
            'Tooltip','Open parameter script (auto or linked)', ...
            'ButtonPushedFcn', @(~,~) openParamSmart(app, compDropdowninfo.Comp, compDropDown, root));
        compParamOpen.Layout.Row = 3; compParamOpen.Layout.Column = [3 4];

        % after creating compParamOpen and (if present) missLbl
        ud = struct();
        if isstruct(compDropDown.UserData), ud = compDropDown.UserData; end
        ud.ParamButton      = compParamOpen;           %  to update tooltip
        ud.ParamStatusLabel = [];
        if exist('missLbl','var') && isvalid(missLbl)
            ud.ParamStatusLabel = missLbl;
        end

        ud.CompName         = char(compDropdowninfo.Comp);
        ud.RootFolder       = char(root);
        compDropDown.UserData = ud;

        % Context menu for Link / Unlink
        cm = uicontextmenu(app.UIFigure);
        uimenu(cm, 'Text','Link Param File...', 'MenuSelectedFcn', @(~,~) paramContextLink(app, compParamOpen, compDropDown, root));
        uimenu(cm, 'Text','Unlink',            'MenuSelectedFcn', @(~,~) paramContextUnlink(app, compParamOpen, compDropDown,root));
        compParamOpen.ContextMenu = cm;

        % Initialize tooltip text now
        updateParamTooltip(compParamOpen, compDropDown, root);

        if isempty(itemsValid) || startsWith(string(compDropDown.Value),"__MISSING__")
            compOpen.Enable = 'off';
        end

        % Row 4: red note label (combine model-missing + param-missing in ONE line)
        paramNote = computeParamMissingNote(compDropdowninfo.Comp, compDropDown, root);
        needRedLine = ~isempty(compDropdowninfo.MissingNoteStrings) || ~isempty(paramNote);

        if needRedLine
            % Compose text: keep your existing missing-model info, append param note if any
            parts = strings(0,1);
            if ~isempty(compDropdowninfo.MissingNoteStrings)
                parts(end+1,1) = sprintf("Missing in folder: %s", strjoin(compDropdowninfo.MissingNoteStrings,'  |  '));
            end
            if ~isempty(paramNote)
                parts(end+1,1) = string(paramNote);
            end

            missLbl = uilabel(compGridLayout, ...
                'Text', strjoin(parts, '  |  '), ...
                'FontColor',[0.85 0 0], 'WordWrap','on');
            missLbl.Layout.Row = 4; missLbl.Layout.Column = [1 5];

            % keep a handle so we can update this line when dropdown changes
            ud = struct(); if isstruct(compDropDown.UserData), ud = compDropDown.UserData; end
            ud.ParamStatusLabel = missLbl;
            compDropDown.UserData = ud;
        end

        % Save handle
        keyDD = matlab.lang.makeValidName([compDropdowninfo.Comp '_' compDropdowninfo.Label]);
        app.ComponentDropdowns.(keyDD) = compDropDown;
        app.ComponentButtons.(keyDD) = compParamOpen;
    end
end

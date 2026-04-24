function ok = ensureParamLinks(app)
% ENSUREPARAMLINKS Validate that every component instance has a valid param file link.
%   ok = ensureParamLinks(app)
%
%   Returns true if all links are valid (already present or user-linked via
%   the modal dialog). Returns false if the user cancelled or links remain
%   incomplete. Missing-model instances (__MISSING__) are skipped.
%
% Copyright 2026 The MathWorks, Inc.

    % ---- Find components with missing param links ----
    [missingLabels, missingKeys, missingSelections] = findMissingParamLinks(app);

    % Remove entries whose selected model is __MISSING__ (can't link those)
    isMissingModel = startsWith(missingSelections, '__MISSING__');
    if any(isMissingModel)
        msg = sprintf("Removed missing component links from export script:\n\n%s", ...
            strjoin(missingSelections(isMissingModel), newline));
        uialert(app.UIFigure, msg, "Missing Links Removed", 'Icon', 'warning');
    end
    missingLabels = missingLabels(~isMissingModel);
    missingKeys   = missingKeys(~isMissingModel);

    % If nothing is missing, all good
    if isempty(missingLabels)
        ok = true;
        return;
    end

    % Otherwise show a link dialog and block until resolved
    ok = showLinkDialog(app, missingLabels, missingKeys);
end

%% ========================= Helpers =========================

function [labels, keys, selections] = findMissingParamLinks(app)
% FINDMISSINGPARAMLINKS Scan all component dropdowns for missing or invalid param links.
    labels     = {};
    keys       = {};
    selections = {};

    compKeys = fieldnames(app.ComponentDropdowns);
    for k = 1:numel(compKeys)
        dd = app.ComponentDropdowns.(compKeys{k});
        paramFile = '';
        if isfield(dd.UserData, 'ParamFile')
            paramFile = dd.UserData.ParamFile;
        end

        if isempty(paramFile) || ~isfile(paramFile)
            labels{end+1}     = dd.UserData.InstanceLabel; %#ok<AGROW>
            keys{end+1}       = compKeys{k}; %#ok<AGROW>
            selections{end+1} = dd.UserData.LastValidValue; %#ok<AGROW>
        end
    end
end

function ok = showLinkDialog(app, missingLabels, missingKeys)
% SHOWLINKDIALOG Display a modal panel for linking missing param files.
%   Returns true if user completed linking, false if cancelled.
    numMissing = numel(missingLabels);
    rowHeight  = 28;
    dlgWidth   = 520;
    dlgHeight  = 90 + numMissing * rowHeight;

    % Center panel inside the app window
    figPos = app.UIFigure.Position;
    dlgX = max(10, round((figPos(3) - dlgWidth) / 2));
    dlgY = max(10, round((figPos(4) - dlgHeight) / 2));

    dlg = uipanel(app.UIFigure, ...
        'Title', 'Missing Param Links', ...
        'Units', 'pixels', ...
        'Position', [dlgX dlgY dlgWidth dlgHeight]);

    % Disable background content for modal-like behavior
    storedStates = disableBackground(app, dlg);

    % Track result via appdata
    setappdata(app.UIFigure, 'ensureParamLinksOK', false);

    % Build grid: one row per missing component + bottom button row
    gridLayout = uigridlayout(dlg, [numMissing + 1, 3]);
    gridLayout.Padding     = [10 10 10 10];
    gridLayout.RowSpacing  = 6;
    gridLayout.ColumnSpacing = 8;
    gridLayout.ColumnWidth = {'1x', 80, 90};
    gridLayout.RowHeight   = [repmat({rowHeight}, 1, numMissing), {'fit'}];

    statusLabels = gobjects(numMissing, 1);
    for i = 1:numMissing
        compKey = missingKeys{i};
        uilabel(gridLayout, 'Text', compKey, 'HorizontalAlignment', 'left');
        statusLabels(i) = uilabel(gridLayout, ...
            'Text', 'Not linked', 'FontColor', [0.85 0.33 0.10]);
        uibutton(gridLayout, 'Text', 'Link...', ...
            'ButtonPushedFcn', @(~, ~) onLinkOne(app, compKey, statusLabels(i), doneBtn));
    end

    % Bottom row: spacer, Done, Cancel
    uilabel(gridLayout, 'Text', '');
    doneBtn = uibutton(gridLayout, 'Text', 'Done', 'Enable', 'off', ...
        'ButtonPushedFcn', @(~, ~) onDone(app, dlg, storedStates));
    uibutton(gridLayout, 'Text', 'Cancel', ...
        'ButtonPushedFcn', @(~, ~) onCancel(app, dlg, storedStates));

    % Update Done button state
    updateDoneButton(app, doneBtn);

    % Resume caller if panel is deleted externally
    dlg.DeleteFcn = @(~, ~) uiresume(app.UIFigure);

    % Block until dialog closes
    uiwait(app.UIFigure);

    % Retrieve result
    ok = getappdata(app.UIFigure, 'ensureParamLinksOK');
end

function onLinkOne(app, compKey, statusLabel, doneBtn)
% ONLINKONE Handle "Link..." button: file picker for one component.
    [fileName, selectedFolder] = uigetfile('*.m', sprintf('Select Param file for %s', compKey));
    if isequal(fileName, 0), return; end

    paramPath = fullfile(selectedFolder, fileName);
    app.ComponentDropdowns.(compKey).UserData.ParamFile = paramPath;

    % Update tooltip and status label
    app.ComponentButtons.(compKey).Tooltip = ...
        "Linked param file:" + newline + string(paramPath);
    app.ComponentDropdowns.(compKey).UserData.ParamStatusLabel.Text = "";

    statusLabel.Text = 'Linked';
    statusLabel.FontColor = [0.00 0.50 0.00];

    updateDoneButton(app, doneBtn);
end

function onDone(app, dlg, storedStates)
% ONDONE Validate all links; if complete, mark success and close.
    compKeys = fieldnames(app.ComponentDropdowns);
    stillMissing = {};
    for j = 1:numel(compKeys)
        dd = app.ComponentDropdowns.(compKeys{j});
        if ~isfield(dd.UserData, 'ParamFile') ...
                || isempty(dd.UserData.ParamFile) ...
                || ~isfile(dd.UserData.ParamFile)
            stillMissing{end+1} = compKeys{j}; %#ok<AGROW>
        end
    end

    if ~isempty(stillMissing)
        uialert(app.UIFigure, ...
            sprintf('Still missing param file for:\n\n%s', ...
                strjoin(stillMissing, ', ')), ...
            'Missing Param', 'Icon', 'warning');
        return;
    end

    setappdata(app.UIFigure, 'ensureParamLinksOK', true);
    closeDialog(dlg, storedStates);
    uiresume(app.UIFigure);
end

function onCancel(app, dlg, storedStates)
% ONCANCEL Close dialog without linking.
    setappdata(app.UIFigure, 'ensureParamLinksOK', false);
    closeDialog(dlg, storedStates);
    uialert(app.UIFigure, ...
        sprintf('Still missing param file for some components.\nAborting export.'), ...
        'Missing Param', 'Icon', 'warning');
    uiresume(app.UIFigure);
end

function updateDoneButton(app, doneBtn)
% UPDATEDONEBTN Enable Done only when all components have valid param links.
    compKeys = fieldnames(app.ComponentDropdowns);
    allLinked = true;
    for j = 1:numel(compKeys)
        dd = app.ComponentDropdowns.(compKeys{j});
        if ~isfield(dd.UserData, 'ParamFile') ...
                || isempty(dd.UserData.ParamFile) ...
                || ~isfile(dd.UserData.ParamFile)
            allLinked = false;
            break;
        end
    end
    if allLinked
        doneBtn.Enable = 'on';
    else
        doneBtn.Enable = 'off';
    end
end

function storedStates = disableBackground(app, dlg)
% DISABLEBACKGROUND Disable top-level children for modal behavior, return prior states.
    topChildren = app.UIFigure.Children;
    storedStates = struct('handle', {}, 'hadEnable', {}, 'priorEnable', {});

    for idx = 1:numel(topChildren)
        h = topChildren(idx);
        if isequal(h, dlg), continue; end
        hasEnable = isprop(h, 'Enable');
        priorEnable = '';
        if hasEnable
            priorEnable = h.Enable;
            h.Enable = 'off';
        end
        storedStates(end+1) = struct( ...
            'handle', h, 'hadEnable', hasEnable, 'priorEnable', priorEnable); %#ok<AGROW>
    end
end

function closeDialog(dlg, storedStates)
% CLOSEDIALOG Delete dialog panel and restore prior Enable states.
    if isvalid(dlg), delete(dlg); end
    for ii = 1:numel(storedStates)
        rec = storedStates(ii);
        if ~isvalid(rec.handle), continue; end
        if rec.hadEnable
            try, rec.handle.Enable = rec.priorEnable; catch, end
        end
    end
end

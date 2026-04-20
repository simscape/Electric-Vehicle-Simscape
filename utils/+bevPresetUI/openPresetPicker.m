function openPresetPicker()
%OPENPRESETPICKER Open the BEV preset picker UI.
%   bevPresetUI.openPresetPicker()
%   Quick-start entry point: pick a ready preset and apply it to the model.

    figKey = 'BEV_PRESET_PICKER_HANDLE';
    existingFig = getappdata(groot, figKey);

    % ---- Reuse existing figure if open ----
    if ~isempty(existingFig) && isvalid(existingFig)
        existingFig.Visible = 'on';
        if isprop(existingFig, 'WindowState')
            existingFig.WindowState = 'normal';
        end
        drawnow;
        figure(existingFig);
        return;
    end

    % ---- Discover presets ----
    presets = bevPresetUI.discoverPresets();

    % ---- Build figure ----
    pickerFig = uifigure( ...
        'Name', 'BEV Preset Picker', ...
        'Position', [200 150 920 600], ...
        'Tag', 'BEV_PRESET_PICKER');

    setappdata(groot, figKey, pickerFig);
    pickerFig.CloseRequestFcn = @(src,~) localCloseFigure(src, figKey);

    mainGrid = uigridlayout(pickerFig, [3 2]);
    mainGrid.RowHeight    = {'fit', '1x', 'fit'};
    mainGrid.ColumnWidth  = {260, '1x'};
    mainGrid.Padding      = [10 10 10 10];
    mainGrid.RowSpacing   = 8;
    mainGrid.ColumnSpacing = 10;

    % ---- Title ----
    titleLabel = uilabel(mainGrid, ...
        'Text', 'Preset Picker', ...
        'FontSize', 18, ...
        'FontWeight', 'bold');
    titleLabel.Layout.Row    = 1;
    titleLabel.Layout.Column = [1 2];

    % ---- Left: preset list ----
    presetListBox = uilistbox(mainGrid, ...
        'Items', {presets.Name}, ...
        'ItemsData', 1:numel(presets), ...
        'FontSize', 14);
    presetListBox.Layout.Row    = 2;
    presetListBox.Layout.Column = 1;
    presetListBox.UserData = presets;

    if isempty(presets)
        presetListBox.Items = {'(no presets found)'};
        presetListBox.ItemsData = [];
    end

    % ---- Right: rendered README ----
    readmePanel = uihtml(mainGrid);
    readmePanel.Layout.Row    = 2;
    readmePanel.Layout.Column = 2;
    readmePanel.HTMLSource = localEmptyHtml();

    % ---- Buttons ----
    buttonGrid = uigridlayout(mainGrid, [1 3]);
    buttonGrid.Layout.Row    = 3;
    buttonGrid.Layout.Column = [1 2];
    buttonGrid.ColumnWidth   = {'1x', '1x', '1x'};
    buttonGrid.Padding       = [0 0 0 0];
    buttonGrid.ColumnSpacing = 8;

    applyButton = uibutton(buttonGrid, ...
        'Text', 'Apply Preset', ...
        'Enable', 'off', ...
        'ButtonPushedFcn', @(~,~) localApplyPreset(presetListBox, pickerFig));

    openFolderButton = uibutton(buttonGrid, ...
        'Text', 'Open Folder', ...
        'Enable', 'off', ...
        'ButtonPushedFcn', @(~,~) localOpenFolder(presetListBox));

    uibutton(buttonGrid, ...
        'Text', 'Refresh', ...
        'ButtonPushedFcn', @(~,~) localRefresh(presetListBox, readmePanel, ...
            applyButton, openFolderButton));

    % ---- Wire selection callback ----
    presetListBox.ValueChangedFcn = @(~,~) localShowDetails( ...
        presetListBox, readmePanel, applyButton, openFolderButton);

    % ---- Auto-select first preset ----
    if ~isempty(presets)
        localShowDetails(presetListBox, readmePanel, applyButton, openFolderButton);
    end
end


%% ========================= Callbacks =========================

function localShowDetails(presetListBox, readmePanel, applyButton, openFolderButton)
%LOCALSHOWDETAILS Update README panel and button states for selected preset.

    selectedIdx = presetListBox.Value;
    presets = presetListBox.UserData;

    if isempty(selectedIdx) || isempty(presets)
        readmePanel.HTMLSource    = localEmptyHtml();
        applyButton.Enable       = 'off';
        openFolderButton.Enable  = 'off';
        return;
    end

    selectedPreset = presets(selectedIdx);

    % Render README as HTML
    if ~isempty(selectedPreset.ReadmePath) && isfile(selectedPreset.ReadmePath)
        readmeText = fileread(selectedPreset.ReadmePath);
        readmePanel.HTMLSource = localMarkdownToHtml(readmeText);
    else
        readmePanel.HTMLSource = localWrapHtml( ...
            '<p style="color:#888;">README not available.</p>');
    end

    % Enable buttons based on available files
    canApply = ~isempty(selectedPreset.ApplyScript) ...
            && isfile(selectedPreset.ApplyScript);

    applyButton.Enable      = localOnOff(canApply);
    openFolderButton.Enable = 'on';
end


function localApplyPreset(presetListBox, pickerFig)
%LOCALAPPLYPRESET Run the selected preset's applyPreset.m script.

    selectedIdx = presetListBox.Value;
    presets = presetListBox.UserData;
    if isempty(selectedIdx) || isempty(presets), return; end

    selectedPreset = presets(selectedIdx);

    try
        run(selectedPreset.ApplyScript);
        uialert(pickerFig, ...
            sprintf('Preset "%s" applied.', selectedPreset.Name), ...
            'Preset Applied', 'Icon', 'success');
    catch applyError
        uialert(pickerFig, applyError.message, ...
            'Apply Failed', 'Icon', 'error');
    end
end


function localOpenFolder(presetListBox)
%LOCALOPENPRESET Open the selected preset folder in the system file browser.

    selectedIdx = presetListBox.Value;
    presets = presetListBox.UserData;
    if isempty(selectedIdx) || isempty(presets), return; end

    selectedPreset = presets(selectedIdx);
    if isfolder(selectedPreset.Folder)
        if ispc
            winopen(selectedPreset.Folder);
        elseif ismac
            system(['open "' selectedPreset.Folder '" &']);
        else
            system(['xdg-open "' selectedPreset.Folder '" &']);
        end
    end
end


function localRefresh(presetListBox, readmePanel, applyButton, openFolderButton)
%LOCALREFRESH Rescan preset folder and reset UI state.

    presets = bevPresetUI.discoverPresets();
    presetListBox.UserData = presets;

    if isempty(presets)
        presetListBox.Items     = {'(no presets found)'};
        presetListBox.ItemsData = [];
    else
        presetListBox.Items     = {presets.Name};
        presetListBox.ItemsData = 1:numel(presets);
    end

    readmePanel.HTMLSource  = localEmptyHtml();
    applyButton.Enable      = 'off';
    openFolderButton.Enable = 'off';
end


function localCloseFigure(pickerFig, figKey)
    if isappdata(groot, figKey)
        rmappdata(groot, figKey);
    end
    delete(pickerFig);
end


function enableState = localOnOff(condition)
    if condition, enableState = 'on'; else, enableState = 'off'; end
end


%% ========================= Markdown to HTML =========================

function htmlSource = localEmptyHtml()
    htmlSource = localWrapHtml( ...
        '<p style="color:#888;">Select a preset to view README.</p>');
end


function htmlSource = localWrapHtml(bodyContent)
    htmlSource = ['<html><head><style>' localCss() ...
        '</style></head><body>' bodyContent '</body></html>'];
end


function htmlSource = localMarkdownToHtml(markdownText)
%LOCALMARKDOWNTOHTML Convert markdown headings and tables to HTML.

    lines = strsplit(markdownText, newline, 'CollapseDelimiters', false);
    htmlParts = {};
    lineIdx = 1;
    numLines = numel(lines);

    while lineIdx <= numLines
        currentLine = strtrim(lines{lineIdx});

        % Skip empty lines
        if isempty(currentLine)
            lineIdx = lineIdx + 1;
            continue;
        end

        % Headings
        if startsWith(currentLine, '### ')
            htmlParts{end+1} = ['<h3>' localEscapeHtml(currentLine(5:end)) '</h3>']; %#ok<AGROW>
            lineIdx = lineIdx + 1;
            continue;
        elseif startsWith(currentLine, '## ')
            htmlParts{end+1} = ['<h2>' localEscapeHtml(currentLine(4:end)) '</h2>']; %#ok<AGROW>
            lineIdx = lineIdx + 1;
            continue;
        elseif startsWith(currentLine, '# ')
            htmlParts{end+1} = ['<h1>' localEscapeHtml(currentLine(3:end)) '</h1>']; %#ok<AGROW>
            lineIdx = lineIdx + 1;
            continue;
        end

        % Table block
        if contains(currentLine, '|')
            [tableHtml, lineIdx] = localParseTable(lines, lineIdx);
            htmlParts{end+1} = tableHtml; %#ok<AGROW>
            continue;
        end

        % Plain text
        htmlParts{end+1} = ['<p>' localEscapeHtml(currentLine) '</p>']; %#ok<AGROW>
        lineIdx = lineIdx + 1;
    end

    htmlSource = localWrapHtml(strjoin(htmlParts, newline));
end


function [tableHtml, lineIdx] = localParseTable(lines, startIdx)
%LOCALPARSETABLE Parse a markdown table block into an HTML table.

    numLines = numel(lines);
    tableRows = {};
    lineIdx = startIdx;

    while lineIdx <= numLines
        currentLine = strtrim(lines{lineIdx});
        if ~contains(currentLine, '|')
            break;
        end
        tableRows{end+1} = currentLine; %#ok<AGROW>
        lineIdx = lineIdx + 1;
    end

    if numel(tableRows) < 2
        tableHtml = ['<p>' localEscapeHtml(strjoin(tableRows, ' ')) '</p>'];
        return;
    end

    tableHtml = '<table>';

    % Header row
    headerCells = localSplitTableRow(tableRows{1});
    tableHtml = [tableHtml '<thead><tr>'];
    for colIdx = 1:numel(headerCells)
        tableHtml = [tableHtml '<th>' ...
            localEscapeHtml(strtrim(headerCells{colIdx})) '</th>']; %#ok<AGROW>
    end
    tableHtml = [tableHtml '</tr></thead>'];

    % Body rows (skip separator row 2)
    tableHtml = [tableHtml '<tbody>'];
    for rowIdx = 3:numel(tableRows)
        bodyCells = localSplitTableRow(tableRows{rowIdx});
        tableHtml = [tableHtml '<tr>'];
        for colIdx = 1:numel(bodyCells)
            tableHtml = [tableHtml '<td>' ...
                localEscapeHtml(strtrim(bodyCells{colIdx})) '</td>']; %#ok<AGROW>
        end
        tableHtml = [tableHtml '</tr>'];
    end
    tableHtml = [tableHtml '</tbody></table>'];
end


function cells = localSplitTableRow(row)
%LOCALSPLITTABLEROW Split a markdown table row on pipe characters.
    row = regexprep(row, '^\||\|$', '');
    cells = strsplit(row, '|');
end


function escapedText = localEscapeHtml(rawText)
%LOCALESCAPEHTML Escape HTML special characters.
    escapedText = strrep(rawText, '&', '&amp;');
    escapedText = strrep(escapedText, '<', '&lt;');
    escapedText = strrep(escapedText, '>', '&gt;');
end


function css = localCss()
    css = [ ...
        'body{font-family:Segoe UI,Helvetica,Arial,sans-serif;font-size:14px;' ...
        'color:#222;margin:8px;padding:0;background:#f3f4f6;}' ...
        'h1{font-size:18px;margin:10px 0 6px 0;color:#d95319;' ...
        'padding:0 0 4px 0;border-bottom:2px solid #d95319;}' ...
        'h2{font-size:15px;margin:14px 0 4px 0;color:#d95319;' ...
        'border-top:1px solid #d9dde3;padding-top:6px;}' ...
        'h3{font-size:14px;margin:8px 0 3px 0;color:#b45309;}' ...
        'table{border-collapse:collapse;width:100%;margin:4px 0 10px 0;}' ...
        'th,td{border:1px solid #d9dde3;padding:5px 10px;text-align:left;font-size:13px;}' ...
        'th{background:#fafafa;color:#111827;font-weight:600;}' ...
        'tr:nth-child(even){background:#f7f9fb;}' ...
        'tr:nth-child(odd){background:#fff;}' ...
        'p{margin:4px 0;line-height:1.5;color:#5f6b7a;}' ...
    ];
end

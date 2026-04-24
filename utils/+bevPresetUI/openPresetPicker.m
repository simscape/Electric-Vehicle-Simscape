function openPresetPicker()
%OPENPRESETPICKER Open the BEV preset picker UI.
%   bevPresetUI.openPresetPicker()
%   Quick-start entry point: pick a ready preset and apply it to the model.
% Copyright 2026 The MathWorks, Inc.

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
            '<p class="placeholder">README not available.</p>');
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
        ssrScript = selectedPreset.SSRScript;
        paramScript = selectedPreset.ParamScript;

        % SSR setup (opens model, changes references)
        evalin('base', sprintf("run('%s');", strrep(ssrScript, '''', '''''')));

        pause(5);

        % Load params into base workspace
        evalin('base', sprintf("run('%s');", strrep(paramScript, '''', '''''')));

        % Bring the model window to the foreground
        evalin('base', 'open_system(topModelName);');

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
        '<p class="placeholder">Select a preset to view README.</p>');
end


function htmlSource = localWrapHtml(bodyContent)
    htmlSource = ['<html><head></head><body>' bodyContent ...
        '<script>' localJs() '</script></body></html>'];
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

        % Plain text — merge consecutive lines into one paragraph
        paraLines = {localEscapeHtml(currentLine)};
        lineIdx = lineIdx + 1;
        while lineIdx <= numLines
            nextLine = strtrim(lines{lineIdx});
            if isempty(nextLine) || startsWith(nextLine, '#') || contains(nextLine, '|')
                break;
            end
            paraLines{end+1} = localEscapeHtml(nextLine); %#ok<AGROW>
            lineIdx = lineIdx + 1;
        end
        htmlParts{end+1} = ['<p>' strjoin(paraLines, ' ') '</p>']; %#ok<AGROW>
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


function js = localJs()
    js = [ ...
        '(function(){' ...
        ... % --- Apply all styles via JS ---
        'var b=document.body;' ...
        'b.style.fontFamily="Segoe UI,Helvetica,Arial,sans-serif";' ...
        'b.style.fontSize="14px";' ...
        'b.style.color="#222";' ...
        'b.style.margin="8px";' ...
        'b.style.padding="0";' ...
        'b.style.background="#f3f4f6";' ...
        'b.style.wordWrap="break-word";' ...
        'b.style.overflowWrap="break-word";' ...
        ... % --- Headings ---
        'document.querySelectorAll("h1").forEach(function(el){' ...
        '  el.style.fontSize="18px";el.style.margin="10px 0 6px 0";' ...
        '  el.style.color="#d95319";el.style.padding="0 0 4px 0";' ...
        '  el.style.borderBottom="2px solid #d95319";' ...
        '});' ...
        'document.querySelectorAll("h2").forEach(function(el){' ...
        '  el.style.fontSize="15px";el.style.margin="14px 0 4px 0";' ...
        '  el.style.color="#d95319";el.style.borderTop="1px solid #d9dde3";' ...
        '  el.style.paddingTop="6px";' ...
        '});' ...
        'document.querySelectorAll("h3").forEach(function(el){' ...
        '  el.style.fontSize="14px";el.style.margin="8px 0 3px 0";' ...
        '  el.style.color="#b45309";' ...
        '});' ...
        ... % --- Tables ---
        'document.querySelectorAll("table").forEach(function(tbl){' ...
        '  tbl.style.borderCollapse="collapse";tbl.style.width="100%";' ...
        '  tbl.style.margin="4px 0 10px 0";tbl.style.tableLayout="fixed";' ...
        '});' ...
        'document.querySelectorAll("th,td").forEach(function(el){' ...
        '  el.style.border="1px solid #d9dde3";el.style.padding="5px 10px";' ...
        '  el.style.textAlign="left";el.style.fontSize="13px";' ...
        '});' ...
        'document.querySelectorAll("th").forEach(function(el){' ...
        '  el.style.background="#fafafa";el.style.color="#111827";' ...
        '  el.style.fontWeight="600";' ...
        '});' ...
        'document.querySelectorAll("tbody tr").forEach(function(tr,i){' ...
        '  tr.style.background=(i%2===0)?"#fff":"#f7f9fb";' ...
        '});' ...
        ... % --- Paragraphs ---
        'document.querySelectorAll("p").forEach(function(el){' ...
        '  el.style.margin="4px 0";el.style.lineHeight="1.5";' ...
        '  el.style.color="#5f6b7a";' ...
        '});' ...
        'document.querySelectorAll(".placeholder").forEach(function(el){' ...
        '  el.style.color="#888";' ...
        '});' ...
        ... % --- Path-aware wrapping: insert <wbr> after / and \ ---
        'document.querySelectorAll("td,th,p").forEach(function(el){' ...
        '  var nodes=el.childNodes;' ...
        '  for(var i=nodes.length-1;i>=0;i--){' ...
        '    if(nodes[i].nodeType===3){' ...
        '      var t=nodes[i].textContent;' ...
        '      if(t.indexOf("/")!==-1||t.indexOf("\\")!==-1){' ...
        '        var span=document.createElement("span");' ...
        '        span.style.wordBreak="break-all";' ...
        '        span.innerHTML=t.replace(/([/\\])/g,"$1<wbr>");' ...
        '        el.replaceChild(span,nodes[i]);' ...
        '      }' ...
        '    }' ...
        '  }' ...
        '});' ...
        '})();' ...
    ];
end

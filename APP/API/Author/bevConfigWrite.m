function bevConfigWrite(cfg, configFilePath)
% BEVCONFIGWRITE Write a BEV config struct to a JSON file.
%   bevConfigWrite(cfg, configFilePath)
%
%   Formats the config struct as readable JSON matching the style of
%   VehicleTemplateConfig.json (compact arrays, clean indentation) and
%   writes it to disk.
%
%   Inputs:
%     cfg            — config struct (one or more template entries)
%     configFilePath — absolute path to the output JSON file
%
% Copyright 2026 The MathWorks, Inc.

    jsonText = formatConfigJson(cfg);

    [outputDir, ~, ~] = fileparts(configFilePath);
    if ~isfolder(outputDir)
        mkdir(outputDir);
    end

    % ---- Atomic write: temp file first, then move to target ----
    tempFile = [char(configFilePath) '.tmp'];
    fileID = fopen(tempFile, 'w');
    if fileID == -1
        error('bevConfigWrite:WriteError', 'Cannot write to %s', tempFile);
    end

    try
        fprintf(fileID, '%s', jsonText);
        fclose(fileID);
    catch writeErr
        fclose(fileID);
        delete(tempFile);
        rethrow(writeErr);
    end

    [status, msg] = movefile(tempFile, configFilePath, 'f');
    if ~status
        delete(tempFile);
        error('bevConfigWrite:WriteError', ...
            'Failed to move temp file to %s: %s', configFilePath, msg);
    end
end


%% Local helpers

function jsonText = formatConfigJson(cfg)
% FORMATCONFIGJSON Format config struct as readable JSON.
%   Matches the hand-formatted style of VehicleTemplateConfig.json:
%   compact arrays on one line, clean indentation, grouped by template.

    lines = {'{'}; %#ok<*AGROW>
    templateNames = fieldnames(cfg);

    for tIdx = 1:numel(templateNames)
        tmplName = templateNames{tIdx};
        tmpl = cfg.(tmplName);

        lines{end+1} = sprintf('    "%s": {', tmplName);

        % ---- Description ----
        if isfield(tmpl, 'Description') && ~isempty(tmpl.Description)
            lines{end+1} = sprintf('        "Description": "%s",', escapeJsonString(tmpl.Description));
        end

        % ---- Components ----
        if isfield(tmpl, 'Components')
            lines{end+1} = '        "Components": {';
            compNames = fieldnames(tmpl.Components);

            for cIdx = 1:numel(compNames)
                comp = tmpl.Components.(compNames{cIdx});
                instancesStr = formatStringArray(comp.Instances);
                modelsStr = formatStringArray(comp.Models);
                hasSelections = isfield(comp, 'Selections') && isstruct(comp.Selections);

                compTrailingComma = '';
                if cIdx < numel(compNames)
                    compTrailingComma = ',';
                end

                if ~hasSelections
                    % ---- Compact format (no Selections) ----
                    lines{end+1} = sprintf('            "%s": {"Instances": %s,', ...
                        compNames{cIdx}, instancesStr);
                    lines{end+1} = sprintf('                          "Models": %s}%s', ...
                        modelsStr, compTrailingComma);
                else
                    % ---- Expanded format (with Selections) ----
                    lines{end+1} = sprintf('            "%s": {', compNames{cIdx});
                    lines{end+1} = sprintf('                "Instances": %s,', instancesStr);
                    lines{end+1} = sprintf('                "Models": %s,', modelsStr);
                    lines = appendSelectionsBlock(lines, comp.Selections);
                    lines{end+1} = sprintf('            }%s', compTrailingComma);
                end
            end

            hasMore = isfield(tmpl, 'Controls') || isfield(tmpl, 'SystemParameter');
            if hasMore
                lines{end+1} = '        },';
            else
                lines{end+1} = '        }';
            end
        end

        % ---- Controls ----
        if isfield(tmpl, 'Controls')
            instancesStr = formatStringArray(tmpl.Controls.Instances);
            modelsStr = formatStringArray(tmpl.Controls.Models);

            hasSystemParam = isfield(tmpl, 'SystemParameter');
            trailingComma = '';
            if hasSystemParam
                trailingComma = ',';
            end

            lines{end+1} = '        "Controls": {';
            lines{end+1} = sprintf('            "Instances": %s,', instancesStr);
            lines{end+1} = sprintf('            "Models": %s', modelsStr);
            lines{end+1} = sprintf('        }%s', trailingComma);
        end

        % ---- SystemParameter ----
        if isfield(tmpl, 'SystemParameter')
            sysParamStr = formatStringArray(tmpl.SystemParameter);
            lines{end+1} = sprintf('        "SystemParameter": %s', sysParamStr);
        end

        % ---- Close template block ----
        if tIdx < numel(templateNames)
            lines{end+1} = '    },';
        else
            lines{end+1} = '    }';
        end
    end

    lines{end+1} = '}';
    jsonText = strjoin(lines, newline);
end


function lines = appendSelectionsBlock(lines, selections)
% APPENDSELECTIONSBLOCK Format Selections struct as indented JSON block.
%   Each instance key maps to {Label, Model, ParamFile}.

    lines{end+1} = '                "Selections": {';
    selKeys = fieldnames(selections);

    for sIdx = 1:numel(selKeys)
        sel = selections.(selKeys{sIdx});

        % ---- Build key-value pairs for this instance ----
        selParts = {};
        if isfield(sel, 'Label')
            selParts{end+1} = sprintf('"Label": "%s"', escapeJsonString(sel.Label));
        end
        if isfield(sel, 'Model')
            selParts{end+1} = sprintf('"Model": "%s"', escapeJsonString(sel.Model));
        end
        if isfield(sel, 'ParamFile')
            selParts{end+1} = sprintf('"ParamFile": "%s"', escapeJsonString(sel.ParamFile));
        end

        selTrailingComma = '';
        if sIdx < numel(selKeys)
            selTrailingComma = ',';
        end

        lines{end+1} = sprintf('                    "%s": {%s}%s', ...
            selKeys{sIdx}, strjoin(selParts, ', '), selTrailingComma); %#ok<AGROW>
    end

    lines{end+1} = '                }';
end


function jsonArrayStr = formatStringArray(values)
% FORMATSTRINGARRAY Format a cell array of strings as a compact JSON array.
%   {"a", "b"} -> '["a", "b"]'

    if ischar(values)
        values = {values};
    elseif isstring(values)
        values = cellstr(values);
    end

    quoted = cellfun(@(s) sprintf('"%s"', escapeJsonString(s)), values, 'UniformOutput', false);
    jsonArrayStr = sprintf('[%s]', strjoin(quoted, ', '));
end


function escaped = escapeJsonString(str)
% ESCAPEJSONSTRING Escape special characters for safe JSON string output.

    str = char(str);
    str = strrep(str, '\', '\\');
    str = strrep(str, '"', '\"');
    str = strrep(str, sprintf('\n'), '\n');
    str = strrep(str, sprintf('\t'), '\t');
    str = strrep(str, sprintf('\r'), '\r');
    escaped = str;
end

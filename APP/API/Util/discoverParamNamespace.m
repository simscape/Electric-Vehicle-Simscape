function [ns, fields, values, comments, nsPerField] = discoverParamNamespace(paramFile)
% DISCOVERPARAMNAMESPACE Parse a param script to find struct namespace and fields.
%
%   [ns, fields, values, comments]              = discoverParamNamespace(paramFile)
%   [ns, fields, values, comments, nsPerField]  = discoverParamNamespace(paramFile)
%
%   Reads the param .m file and extracts all assignments of the form:
%       namespace.field = value;  % comment
%
%   Returns:
%     ns          - first struct variable name found (e.g., 'pump')
%     fields      - cell array of field names (deduplicated, last wins)
%     values      - cell array of default value strings
%     comments    - cell array of inline comments for mask prompts
%     nsPerField  - cell array of namespace per field (same size as fields)
%                   Supports param files with mixed namespaces, e.g.:
%                     batteryPump22.pump_displacement = 2;
%                     batteryPump212.pump_speed_max = 1000;
%
%   If the same field appears multiple times, the last assignment wins.
%
%   Example:
%     [ns, fields, ~, ~, nsPerField] = discoverParamNamespace('PumpParams.m');
%
% Copyright 2026 The MathWorks, Inc.

    txt = fileread(paramFile);
    lines = splitlines(txt);

    ns = '';
    fields = {};
    values = {};
    comments = {};
    nsPerField = {};

    % ---- Parse each line for struct assignments ----
    for k = 1:numel(lines)
        line = strtrim(lines{k});

        % Match: namespace.field = value; % comment
        tokens = regexp(line, '^(\w+)\.(\w+)\s*=\s*([^;%]+)', 'tokens');
        if isempty(tokens)
            continue;
        end

        currentNamespace = tokens{1}{1};
        currentField     = tokens{1}{2};
        currentValue     = strtrim(tokens{1}{3});

        if isempty(ns)
            ns = currentNamespace;
        end

        % Extract inline comment if present
        commentTokens = regexp(line, '%\s*(.*)', 'tokens');
        if ~isempty(commentTokens)
            currentComment = strtrim(commentTokens{1}{1});
        else
            currentComment = '';
        end

        % Deduplicate: if field already seen, overwrite (last wins)
        idx = find(strcmp(fields, currentField), 1);
        if ~isempty(idx)
            values{idx}     = currentValue;
            comments{idx}   = currentComment;
            nsPerField{idx} = currentNamespace;
        else
            fields{end+1}     = currentField; %#ok<AGROW>
            values{end+1}     = currentValue; %#ok<AGROW>
            comments{end+1}   = currentComment; %#ok<AGROW>
            nsPerField{end+1} = currentNamespace; %#ok<AGROW>
        end
    end
end

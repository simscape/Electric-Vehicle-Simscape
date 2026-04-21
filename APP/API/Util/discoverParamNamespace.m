function [ns, fields, values, comments, nsPerField] = discoverParamNamespace(paramFile)
% discoverParamNamespace  Parse a param script to find struct namespace and fields.
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

% Copyright 2026 The MathWorks, Inc.

    txt = fileread(paramFile);
    lines = splitlines(txt);

    ns = '';
    fields = {};
    values = {};
    comments = {};
    nsPerField = {};

    for k = 1:numel(lines)
        line = strtrim(lines{k});

        % Match: namespace.field = value; % comment
        tok = regexp(line, '^(\w+)\.(\w+)\s*=\s*([^;%]+)', 'tokens');
        if ~isempty(tok)
            thisNs    = tok{1}{1};
            thisField = tok{1}{2};
            thisValue = strtrim(tok{1}{3});

            if isempty(ns)
                ns = thisNs;
            end

            % Extract comment if present
            cmtTok = regexp(line, '%\s*(.*)', 'tokens');
            if ~isempty(cmtTok)
                thisCmt = strtrim(cmtTok{1}{1});
            else
                thisCmt = '';
            end

            % Deduplicate: if field already seen, overwrite (last wins)
            idx = find(strcmp(fields, thisField), 1);
            if ~isempty(idx)
                values{idx}     = thisValue;
                comments{idx}   = thisCmt;
                nsPerField{idx} = thisNs;
            else
                fields{end+1}     = thisField; %#ok<AGROW>
                values{end+1}     = thisValue; %#ok<AGROW>
                comments{end+1}   = thisCmt; %#ok<AGROW>
                nsPerField{end+1} = thisNs; %#ok<AGROW>
            end
        end
    end
end

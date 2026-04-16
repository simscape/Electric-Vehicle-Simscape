function [tmplName, popupNotes, matched] = resolveTemplateName(rawCfg, uiSelection)
%RESOLVETEMPLATENAME Match a UI template selection to a JSON config field name.
%   [tmplName, popupNotes, matched] = resolveTemplateName(rawCfg, uiSelection)
%
%   Matching priority:
%     1. Case-insensitive exact match
%     2. Case-insensitive substring (contains) match
%     3. Fall back to first config field
%
%   Inputs:
%     rawCfg      — parsed JSON config struct (from jsondecode)
%     uiSelection — string from the VehicleTemplate dropdown (may include .slx)
%
%   Outputs:
%     tmplName   — resolved config field name (char)
%     popupNotes — string array of warning notes (empty if exact match)
%     matched    — true if exact match found, false if fallback was used

    popupNotes = strings(0,1);
    uiBase = erase(char(uiSelection), '.slx');
    cfgFields = string(fieldnames(rawCfg));

    % 1) Exact match (case-insensitive)
    chosenIdx = find(strcmpi(cfgFields, uiBase), 1);

    if ~isempty(chosenIdx)
        % Exact match found
        tmplName = char(cfgFields(chosenIdx));
        matched = true;
    else
        % 2) Substring match
        chosenIdx = find(contains(lower(cfgFields), lower(uiBase)), 1);
        if isempty(chosenIdx)
            % 3) Fall back to first entry
            chosenIdx = 1;
        end
        tmplName = char(cfgFields(chosenIdx));
        matched = false;
        popupNotes(end+1,1) = sprintf( ...
            "Configuration '%s' not found in config. Auto-selected '%s' from the design scenario.", ...
            uiBase, tmplName);
    end
end

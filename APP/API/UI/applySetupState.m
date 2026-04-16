function applySetupState(app, state)
%APPLYSETUPSTATE Restore UI selections from a saved setup state struct.
%   applySetupState(app, state)
%
%   Full restore: sets config/template dropdowns, rebuilds the UI,
%   then applies all saved selections.
%
%   Inputs:
%     app   — BEVapp handle
%     state — struct from buildSetupState or jsondecode of a saved setup JSON

    % ---- Resolve template-level data ----
    if ~isstruct(state), return; end
    flds = fieldnames(state);
    if isempty(flds), return; end
    templateName = flds{1};
    tmpl = state.(templateName);

    % ---- Config file dropdown (must be set FIRST) ----
    if isfield(tmpl, 'ConfigFile') && ~isempty(tmpl.ConfigFile)
        setDropdownByMatch(app.ConfigDropDown, char(tmpl.ConfigFile), '');
    end

    % ---- BEV Model dropdown ----
    if isfield(tmpl, 'BEVModel') && ~isempty(tmpl.BEVModel)
        setDropdownByMatch(app.BEVModelDropDown, char(tmpl.BEVModel), '.slx');
    end

    % ---- Vehicle Template dropdown ----
    if ~isempty(templateName)
        setDropdownByMatch(app.VehicleTemplateDropDown, templateName, '.slx');
    end

    % ---- Rebuild UI ----
    try
        createComponentDropdowns(app, true);  % skipCache=true to prevent recursion
    catch
    end

    % ---- Control detection (populates control dropdown Items) ----
    try
        controlSelectionDropdown(app);
    catch
    end

    % ---- Apply selections on the rebuilt UI ----
    applySelections(app, tmpl);
end

%% Local helper

function setDropdownByMatch(dd, target, ext)
%SETDROPDOWNBYMATCH Try to match target in dropdown items and set Value.
    try
        target = char(target);
        withExt = target;
        if ~isempty(ext) && ~endsWith(target, ext, 'IgnoreCase', true)
            withExt = [target ext];
        end
        bare = regexprep(target, '\.(slx|mdl)$', '', 'ignorecase');

        if ~isempty(dd.ItemsData), data = string(dd.ItemsData);
        else,                      data = string(dd.Items);
        end

        idx = find(data == string(withExt), 1);
        if isempty(idx), idx = find(data == string(bare), 1); end
        if isempty(idx), idx = find(strcmpi(data, withExt), 1); end
        if isempty(idx), idx = find(strcmpi(data, bare), 1); end

        if ~isempty(idx)
            if ~isempty(dd.ItemsData), dd.Value = dd.ItemsData{idx};
            else,                      dd.Value = dd.Items{idx};
            end
        end
    catch
    end
end

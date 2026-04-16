function applySetupState(app, state)
%APPLYSETUPSTATE Restore UI selections from a saved setup state struct.
%   applySetupState(app, state)
%
%   Full restore: sets config/template/model dropdowns, rebuilds the
%   component UI, then applies all saved selections.
%
%   Restore order matters:
%     1. Config dropdown  — must be first; controls which JSON is loaded
%     2. BEV Model        — sets the model context
%     3. Vehicle Template  — determines component layout
%     4. createComponentDropdowns — rebuilds all component UI from config
%     5. controlSelectionDropdown — populates control dropdown Items
%     6. applySelections   — restores saved per-widget selections
%
%   Inputs:
%     app   — BEVapp handle
%     state — struct from buildSetupState or jsondecode of a saved setup JSON

    % ---- Validate and normalize input ----
    if ~isstruct(state), return; end

    [templateName, setupData] = normalizeState(state);
    if isempty(templateName), return; end

    % ---- 1. Config file dropdown (must be set FIRST — drives JSON load) ----
    if isfield(setupData, 'ConfigFile') && ~isempty(setupData.ConfigFile)
        setDropdownByMatch(app.ConfigDropDown, char(setupData.ConfigFile), '');
    end

    % ---- 2. BEV Model dropdown ----
    if isfield(setupData, 'BEVModel') && ~isempty(setupData.BEVModel)
        setDropdownByMatch(app.BEVModelDropDown, char(setupData.BEVModel), '.slx');
    end

    % ---- 3. Vehicle Template dropdown ----
    if ~isempty(templateName)
        setDropdownByMatch(app.VehicleTemplateDropDown, templateName, '.slx');
    end

    % ---- 4. Rebuild component UI (skipCache=true to prevent recursion) ----
    try
        createComponentDropdowns(app, true);
    catch ME
        warning('BEVapp:applySetupState', ...
            'createComponentDropdowns failed: %s', ME.message);
    end

    % ---- 5. Populate control dropdown Items ----
    try
        controlSelectionDropdown(app);
    catch ME
        warning('BEVapp:applySetupState', ...
            'controlSelectionDropdown failed: %s', ME.message);
    end

    % ---- 6. Apply saved selections on the rebuilt UI ----
    applySelections(app, setupData);
end

%% Local helpers

function [templateName, setupData] = normalizeState(state)
%NORMALIZESTATE Detect flat vs wrapped state and return (templateName, inner struct).
%   Flat format:    state.TemplateName = 'X'; state.Components = ...
%   Wrapped format: state.X.Components = ...  (from saved JSON files)
    if isfield(state, 'TemplateName')
        templateName = state.TemplateName;
        setupData    = rmfield(state, 'TemplateName');
    else
        flds = fieldnames(state);
        if isempty(flds)
            templateName = '';
            setupData    = struct();
            return;
        end
        templateName = flds{1};
        setupData    = state.(templateName);
    end
end

function setDropdownByMatch(dropdown, target, ext)
%SETDROPDOWNBYMATCH Try to match target in dropdown items and set Value.
%   Match strategies (in order):
%     1. Exact match against ItemsData/Items (with extension)
%     2. Exact match without extension
%     3. Case-insensitive with extension
%     4. Case-insensitive without extension
%     5. Basename-only match against Items (handles full-path ItemsData
%        when target is a bare filename, or vice versa)
    target  = char(target);
    withExt = target;
    if ~isempty(ext) && ~endsWith(target, ext, 'IgnoreCase', true)
        withExt = [target ext];
    end
    bare = regexprep(target, '\.(slx|mdl)$', '', 'ignorecase');

    % Primary search pool: ItemsData if populated, otherwise Items
    if ~isempty(dropdown.ItemsData)
        data = string(dropdown.ItemsData);
    else
        data = string(dropdown.Items);
    end

    % Try progressively looser matching
    idx = find(data == string(withExt), 1);
    if isempty(idx), idx = find(data == string(bare), 1); end
    if isempty(idx), idx = find(strcmpi(data, withExt), 1); end
    if isempty(idx), idx = find(strcmpi(data, bare), 1); end

    % Fallback: match basename of target against Items (display names).
    % Covers the case where ItemsData holds full paths but target is bare.
    if isempty(idx) && ~isempty(dropdown.ItemsData)
        [~, baseName, baseExt] = fileparts(target);
        targetBase = [baseName baseExt];
        displayNames = string(dropdown.Items);

        idx = find(strcmpi(displayNames, targetBase), 1);
    end

    if ~isempty(idx)
        if ~isempty(dropdown.ItemsData)
            dropdown.Value = dropdown.ItemsData{idx};
        else
            dropdown.Value = dropdown.Items{idx};
        end
    end
end

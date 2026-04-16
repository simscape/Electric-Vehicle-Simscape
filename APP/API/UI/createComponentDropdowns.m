function createComponentDropdowns(app, skipCache)
%CREATECOMPONENTDROPDOWNS Orchestrate component UI build from config JSON.
%   createComponentDropdowns(app)
%   createComponentDropdowns(app, skipCache)
%
%   Reads the selected config JSON, resolves the template, validates it,
%   detects the vehicle platform, scans component availability, renders
%   dropdown panels, and applies saved/cached selections.

    if nargin < 2, skipCache = false; end

    % Snapshot current state to session cache BEFORE clearing UI
    if ~skipCache
        try
            snapshotToCache(app);
        catch ME
            warning('BEVapp:createComponentDropdowns', ...
                'snapshotToCache failed: %s', ME.message);
        end
    end

    % Clear existing component UI
    delete(app.ComponentsPanel.Children);

    % ---- Project root ----
    proj = matlab.project.rootProject;
    root = proj.RootFolder;

    % ---- Parse config JSON and resolve template ----
    rawCfg = jsondecode(fileread(app.ConfigDropDown.Value));

    [templateKey, templatePopupNotes, templateMatched] = ...
        resolveTemplateName(rawCfg, app.VehicleTemplateDropDown.Value);

    syncTemplateDropdown(app, templateKey, templateMatched);

    % If saved setup, restore BEV model dropdown (before platform detection)
    rawTmpl = rawCfg.(templateKey);
    restoreBEVModelDropdown(app, rawTmpl);

    % ---- Validate config structure ----
    try
        validateVehicleConfig(rawCfg, templateKey);
    catch
        setExportButtonsEnabled(app, false);
        uialert(app.UIFigure, ...
            "Config JSON structure is invalid. Check help document.", "Error");
        return;
    end

    % ---- Build component entries and enable UI ----
    entries = buildComponentEntries(rawCfg, templateKey);
    setExportButtonsEnabled(app, true);

    % HVAC-specific: enable/disable AC controls
    hasHVAC = any(strcmp({entries.Comp}, 'HVAC'));
    app.ACButton.Enable = ternEnable(hasHVAC);
    app.CabinTempSetpointEditField.Enable = ternEnable(hasHVAC);

    % ---- Check template SSR blocks against entries ----
    [presentMask, templateMissingLines, foundStruct] = ...
        checkTemplateSubsystemRefs(root, templateKey, entries);

    if ~isstruct(app.UIFigure.UserData), app.UIFigure.UserData = struct(); end
    app.UIFigure.UserData.TemplateSubsystemRefs = foundStruct;

    entries = entries(presentMask);

    % ---- Vehicle platform detection (abort if not found) ----
    if ~platformDetectFromBEVModel(app, root)
        setExportButtonsEnabled(app, false);
        app.ControlSelectionDropDown.Enable = "off";
        app.ControlDesc.Enable = "off";
        return;
    end
    app.ControlSelectionDropDown.Enable = "on";
    app.ControlDesc.Enable = "on";

    % ---- Scan component folders for model availability ----
    [preCheck, missingMap] = scanComponentAvailability(root, entries);

    % ---- Show consolidated warnings popup ----
    warningLines = buildWarningLines(templatePopupNotes, templateMissingLines, missingMap);
    if ~isempty(warningLines)
        try
            uialert(app.UIFigure, strjoin(warningLines, newline), ...
                'Configuration warnings');
        catch
            warndlg(strjoin(warningLines, newline), 'Configuration warnings');
        end
    end

    % ---- Render component panels ----
    renderComponentPanels(app, preCheck, root);

    % ---- Apply saved selections or restore from cache ----
    if isfield(rawTmpl, 'SchemaVersion')
        try
            applySelections(app, rawTmpl);
        catch ME
            warning('BEVapp:createComponentDropdowns', ...
                'applySelections failed: %s', ME.message);
        end
    elseif ~skipCache
        try
            restoreFromCache(app);
        catch ME
            warning('BEVapp:createComponentDropdowns', ...
                'restoreFromCache failed: %s', ME.message);
        end
    end

    % ---- Store cache tag for next config switch ----
    storeCacheTag(app);
end

%% ========================= Local helpers =========================

function setExportButtonsEnabled(app, enabled)
%SETEXPORTBUTTONSENABLED Enable or disable the main export/action buttons.
    state = ternEnable(enabled);
    app.DriveCycleDropDown.Enable      = state;
    app.DriveCycleDesc.Enable          = state;
    app.CreateModelButton.Enable       = state;
    app.ParameterExportButton.Enable   = state;
    app.ModelExportButton.Enable       = state;
end

function restoreBEVModelDropdown(app, rawTmpl)
%RESTOREBEVMODELDROPDOWN Set BEV model dropdown from saved setup (if present).
    if ~isfield(rawTmpl, 'BEVModel') || isempty(rawTmpl.BEVModel)
        return;
    end
    bevTarget = char(rawTmpl.BEVModel);
    bevItems = string(app.BEVModelDropDown.Items);
    idx = find(bevItems == string(bevTarget) ...
             | bevItems == string([bevTarget '.slx']), 1);
    if ~isempty(idx)
        app.BEVModelDropDown.Value = app.BEVModelDropDown.Items{idx};
    end
end

function warningLines = buildWarningLines(templateNotes, templateMissing, missingMap)
%BUILDWARNINGLINES Assemble all config warning messages into one string array.
    warningLines = strings(0, 1);

    if ~isempty(templateNotes)
        warningLines = [warningLines; templateNotes(:); ""];
    end

    if ~isempty(templateMissing)
        warningLines(end+1, 1) = ...
            "Vehicle configuration is missing some instance " + ...
            "Subsystem Reference blocks (name match against Instances):";
        warningLines = [warningLines; templateMissing(:); ""];
    end

    if isempty(missingMap), return; end

    warningLines(end+1, 1) = ...
        "Some models listed in the config are missing from the expected component folder.";
    warningLines(end+1, 1) = "";
    warningLines(end+1, 1) = "Checked folder pattern:";
    warningLines(end+1, 1) = "  <projectRoot>\Components\<Component>\Model\<Model>.slx";
    warningLines(end+1, 1) = "";
    warningLines(end+1, 1) = ...
        "Missing (Component -> Model  --  Instances  [Found elsewhere if any]):";

    keys = sort(missingMap.keys);
    for kk = 1:numel(keys)
        key = keys{kk};
        parts = split(string(key), "|");
        compName  = parts(1);
        modelName = parts(2);
        rec = missingMap(key);
        instanceList = strjoin(rec.Instances, ', ');

        if strlength(rec.FoundElsewhere) > 0
            warningLines(end+1, 1) = sprintf("%s -> %s.slx  --  %s  [found at: %s]", ...
                compName, modelName, instanceList, rec.FoundElsewhere); %#ok<AGROW>
        else
            warningLines(end+1, 1) = sprintf("%s -> %s.slx  --  %s", ...
                compName, modelName, instanceList); %#ok<AGROW>
        end
    end
end

function storeCacheTag(app)
%STORECACHETAG Record the active template+config tag for snapshotToCache.
    templateBase = erase(char(app.VehicleTemplateDropDown.Value), '.slx');
    [~, configBase] = fileparts(char(app.ConfigDropDown.Value));
    if isempty(templateBase) || isempty(configBase), return; end
    if ~isstruct(app.UIFigure.UserData), app.UIFigure.UserData = struct(); end
    app.UIFigure.UserData.lastCacheTag = ...
        matlab.lang.makeValidName([templateBase '__' configBase]);
end

function syncTemplateDropdown(app, templateKey, matched)
%SYNCTEMPLATEDROPDOWN Update VehicleTemplate dropdown to reflect resolved template.
    dd = app.VehicleTemplateDropDown;
    itemsNow = string(dd.Items);
    idx = findItemByBasename(itemsNow, templateKey);

    if ~isempty(idx)
        dd.Value = dd.Items{idx};
    elseif ~matched
        dd.Items = [dd.Items, {templateKey}];
        dd.Value = templateKey;
    end

    if isstruct(dd.UserData)
        dd.UserData.LastValidValue = dd.Value;
    end

    % If fallback was used, tag the original selection as [missing]
    if ~matched
        origBase = erase(char(dd.Value), '.slx');
        if ~strcmpi(origBase, templateKey)
            missTag = sprintf("%s [missing]", origBase);
            if ~any(strcmpi(itemsNow, missTag))
                dd.Items = [dd.Items, {missTag}];
            end
        end
    end
end

function idx = findItemByBasename(items, targetNoExt)
%FINDITEMBYBASENAME Find dropdown item matching target basename (case-insensitive).
    bases = erase(string(items), '.slx');
    idx = find(strcmpi(bases, string(targetNoExt)), 1, 'first');
end

function state = ternEnable(flag)
%TERNENABLE Convert logical to "on"/"off" string for widget Enable property.
    if flag, state = "on"; else, state = "off"; end
end

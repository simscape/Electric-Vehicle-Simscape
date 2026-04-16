function createComponentDropdowns(app, skipCache)
%CREATECOMPONENTDROPDOWNS Orchestrate component UI build from config JSON.
%   createComponentDropdowns(app)
%   createComponentDropdowns(app, skipCache)
%
%   Reads the selected config JSON, resolves the template, validates it,
%   detects the vehicle platform, scans component availability, renders
%   dropdown panels, and applies saved/cached selections.

    if nargin < 2
        skipCache = false;
    end

    % ---- Snapshot current selections before switching ----
    snapshotCurrentSelections(app, skipCache);

    % ---- Clear existing component UI ----
    delete(app.ComponentsPanel.Children);

    % ---- Resolve project root and parse config ----
    root   = char(getBEVProjectRoot(app));
    rawCfg = jsondecode(fileread(app.ConfigDropDown.Value));

    % ---- Resolve template name against config ----
    [templateKey, templateNotes, templateMatched] = ...
        resolveTemplateName(rawCfg, app.VehicleTemplateDropDown.Value);

    syncTemplateDropdown(app, templateKey, templateMatched);

    % ---- Restore BEV model from saved setup (before platform detection) ----
    templateConfig = rawCfg.(templateKey);
    restoreBEVModelDropdown(app, templateConfig);

    % ---- Validate config structure ----
    if ~validateConfigOrWarn(app, rawCfg, templateKey)
        return;
    end

    % ---- Build component entries and enable export controls ----
    entries = buildComponentEntries(rawCfg, templateKey);
    setExportButtonsEnabled(app, true);

    % ---- Enable/disable HVAC controls ----
    updateHVACControls(app, entries);

    % ---- Filter entries against template SSR blocks ----
    [entries, templateMissingLines, templateSubsystemRefs] = ...
        filterEntriesAgainstTemplate(root, templateKey, entries);

    storeTemplateRefs(app, templateSubsystemRefs);

    % ---- Detect vehicle platform (abort if not found) ----
    if ~ensurePlatformDetected(app, root)
        return;
    end

    % ---- Scan component availability on disk ----
    [componentAvailability, missingMap] = scanComponentAvailability(root, entries);

    % ---- Show consolidated warnings ----
    showConfigurationWarnings(app, templateNotes, templateMissingLines, missingMap);

    % ---- Render component panels ----
    renderComponentPanels(app, componentAvailability, root);

    % ---- Restore saved selections or cache ----
    restoreSelectionsAfterRender(app, templateConfig, skipCache);

    % ---- Store cache tag for next config switch ----
    storeCacheTag(app);
end

%% ========================= Orchestrator step helpers =========================

function snapshotCurrentSelections(app, skipCache)
%SNAPSHOTCURRENTSELECTIONS Save current state to session cache before clearing UI.
    if skipCache
        return;
    end

    try
        snapshotToCache(app);
    catch ME
        warning('BEVapp:createComponentDropdowns', ...
            'snapshotToCache failed: %s', ME.message);
    end
end

function valid = validateConfigOrWarn(app, rawCfg, templateKey)
%VALIDATECONFIGORWARN Validate config structure; disable exports and warn on failure.
    try
        validateVehicleConfig(rawCfg, templateKey);
        valid = true;
    catch ME
        warning('BEVapp:validateConfigOrWarn', ...
            'Config validation failed: %s', ME.message);
        setExportButtonsEnabled(app, false);
        uialert(app.UIFigure, ...
            "Config JSON structure is invalid. Check help document.", "Error");
        valid = false;
    end
end

function updateHVACControls(app, entries)
%UPDATEHVACCONTROLS Enable or disable AC controls based on HVAC component presence.
    hasHVAC = any(strcmp({entries.Comp}, 'HVAC'));

    if hasHVAC
        app.ACButton.Enable = "on";
        app.CabinTempSetpointEditField.Enable = "on";
    else
        app.ACButton.Enable = "off";
        app.CabinTempSetpointEditField.Enable = "off";
    end
end

function [filteredEntries, templateMissingLines, templateSubsystemRefs] = ...
        filterEntriesAgainstTemplate(root, templateKey, entries)
%FILTERENTRIESAGAINSTTEMPLATE Check template SSR blocks and filter to present only.
    [presentMask, templateMissingLines, templateSubsystemRefs] = ...
        checkTemplateSubsystemRefs(root, templateKey, entries);

    filteredEntries = entries(presentMask);
end

function storeTemplateRefs(app, templateSubsystemRefs)
%STORETEMPLATEREFS Save template SSR reference data on UIFigure UserData.
    if ~isstruct(app.UIFigure.UserData)
        app.UIFigure.UserData = struct();
    end
    app.UIFigure.UserData.TemplateSubsystemRefs = templateSubsystemRefs;
end

function detected = ensurePlatformDetected(app, root)
%ENSUREPLATFORMDETECTED Detect vehicle platform; disable controls on failure.
    if platformDetectFromBEVModel(app, root)
        app.ControlSelectionDropDown.Enable = "on";
        app.ControlDesc.Enable = "on";
        detected = true;
    else
        setExportButtonsEnabled(app, false);
        app.ControlSelectionDropDown.Enable = "off";
        app.ControlDesc.Enable = "off";
        detected = false;
    end
end

function showConfigurationWarnings(app, templateNotes, templateMissingLines, missingMap)
%SHOWCONFIGURATIONWARNINGS Show a consolidated popup if there are any warnings.
    warningLines = buildWarningLines(templateNotes, templateMissingLines, missingMap);

    if isempty(warningLines)
        return;
    end

    try
        uialert(app.UIFigure, strjoin(warningLines, newline), ...
            'Configuration warnings');
    catch ME
        warning('BEVapp:showConfigurationWarnings', ...
            'uialert fallback to warndlg: %s', ME.message);
        warndlg(strjoin(warningLines, newline), 'Configuration warnings');
    end
end

function restoreSelectionsAfterRender(app, templateConfig, skipCache)
%RESTORESELECTIONSAFTERRENDER Apply saved selections or restore from cache.
    if isfield(templateConfig, 'SchemaVersion')
        % Saved setup file: apply selections directly
        try
            applySelections(app, templateConfig);
        catch ME
            warning('BEVapp:createComponentDropdowns', ...
                'applySelections failed: %s', ME.message);
        end

    elseif ~skipCache
        % No saved setup: try restoring from session cache
        try
            restoreFromCache(app);
        catch ME
            warning('BEVapp:createComponentDropdowns', ...
                'restoreFromCache failed: %s', ME.message);
        end
    end
end

%% ========================= Stable local helpers =========================

function setExportButtonsEnabled(app, enabled)
%SETEXPORTBUTTONSENABLED Enable or disable the main export/action buttons.
    if enabled
        state = "on";
    else
        state = "off";
    end

    app.DriveCycleDropDown.Enable      = state;
    app.DriveCycleDesc.Enable          = state;
    app.CreateModelButton.Enable       = state;
    app.ParameterExportButton.Enable   = state;
    app.SaveSetupButton.Enable       = state;
end

function restoreBEVModelDropdown(app, templateConfig)
%RESTOREBEVMODELDROPDOWN Set BEV model dropdown from saved setup if present.
    if ~isfield(templateConfig, 'BEVModel') || isempty(templateConfig.BEVModel)
        return;
    end

    bevTarget = char(templateConfig.BEVModel);
    bevItems  = string(app.BEVModelDropDown.Items);

    idx = find( ...
        bevItems == string(bevTarget) | ...
        bevItems == string([bevTarget '.slx']), 1);

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

    if isempty(missingMap)
        return;
    end

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
        key   = keys{kk};
        parts = split(string(key), "|");
        compName  = parts(1);
        modelName = parts(2);
        rec = missingMap(key);
        instanceList = strjoin(rec.Instances, ', ');

        if strlength(rec.FoundElsewhere) > 0
            warningLines(end+1, 1) = sprintf( ...
                "%s -> %s.slx  --  %s  [found at: %s]", ...
                compName, modelName, instanceList, rec.FoundElsewhere); %#ok<AGROW>
        else
            warningLines(end+1, 1) = sprintf( ...
                "%s -> %s.slx  --  %s", ...
                compName, modelName, instanceList);                     %#ok<AGROW>
        end
    end
end

function storeCacheTag(app)
%STORECACHETAG Record the active template+config tag for snapshotToCache.
    templateBase = erase(char(app.VehicleTemplateDropDown.Value), '.slx');
    [~, configBase] = fileparts(char(app.ConfigDropDown.Value));

    if isempty(templateBase) || isempty(configBase)
        return;
    end

    if ~isstruct(app.UIFigure.UserData)
        app.UIFigure.UserData = struct();
    end

    app.UIFigure.UserData.lastCacheTag = ...
        matlab.lang.makeValidName([templateBase '__' configBase]);
end

function syncTemplateDropdown(app, templateKey, matched)
%SYNCTEMPLATEDROPDOWN Update VehicleTemplate dropdown to reflect resolved template.
    dd       = app.VehicleTemplateDropDown;
    itemsNow = string(dd.Items);
    idx      = findItemByBasename(itemsNow, templateKey);

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

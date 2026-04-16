function createComponentDropdowns(app, skipCache)
    if nargin < 2, skipCache = false; end

    % Snapshot current state to session cache BEFORE clearing UI
    if ~skipCache
        try, snapshotToCache(app); catch, end
    end

    % clear UI
    delete(app.ComponentsPanel.Children);


    % PRECHECKS
    proj = matlab.project.rootProject;
    root = proj.RootFolder;

    % Read raw & parsed JSON
    rawCfg = jsondecode(fileread(app.ConfigDropDown.Value));

    % Resolve template name (pure logic, no UI)
    [tmpl, templatePopupNotes, tmplMatched] = resolveTemplateName(rawCfg, app.VehicleTemplateDropDown.Value);

    % Sync dropdown to reflect the resolved template
    syncTemplateDropdown(app, tmpl, tmplMatched);

    % If saved setup, restore BEV model dropdown (before platform detection)
    rawTmpl = rawCfg.(tmpl);
    if isfield(rawTmpl, 'BEVModel') && ~isempty(rawTmpl.BEVModel)
        bevTarget = char(rawTmpl.BEVModel);
        bevItems = string(app.BEVModelDropDown.Items);
        idx = find(bevItems == string(bevTarget) | bevItems == string([bevTarget '.slx']), 1);
        if ~isempty(idx)
            app.BEVModelDropDown.Value = app.BEVModelDropDown.Items{idx};
        end
    end

    % Validate config structure
    try
        validateVehicleConfig(rawCfg, tmpl);
    catch
        app.CreateModelButton.Enable = "off";
        app.ParameterExportButton.Enable = "off";
        app.ModelExportButton.Enable = "off";
        uialert(app.UIFigure, "Structure of the config json file doesn't have valid structure. ..." + ...
                   "Check help document", "Error");
        return;   % abort BEFORE any UI is rendered
    end

    % Build flat entries from config (pure data, no UI)
    entries = buildComponentEntries(rawCfg, tmpl);
    app.DriveCycleDropDown.Enable = "on";
    app.DriveCycleDesc.Enable = "on";
    app.CreateModelButton.Enable = "on";
    app.ParameterExportButton.Enable = "on";
    app.ModelExportButton.Enable = "on";

    % Check if HVAC present in the component list or not
    if ~any(strcmp({entries.Comp}, 'HVAC'))
        app.ACButton.Enable = 'off';
        app.CabinTempSetpointEditField.Enable = 'off';
    else
        app.ACButton.Enable = 'on';
        app.CabinTempSetpointEditField.Enable = 'on';
    end
    % Find Subsystem References (by ReferencedSubsystem) and keep only present instances.
    [presentMask, templateMissingLines, foundStruct] = ...
        checkTemplateSubsystemRefs(root, tmpl, entries);

    % Store for later 
    if ~isstruct(app.UIFigure.UserData), app.UIFigure.UserData = struct(); end
    app.UIFigure.UserData.TemplateSubsystemRefs = foundStruct;  

    entries = entries(presentMask);


    % Vehicle Platform detection
    % if this fails, we return before building UI.
    if ~platformDetectFromBEVModel(app, root)
        app.DriveCycleDropDown.Enable = "off";
        app.DriveCycleDesc.Enable = "off";
        app.CreateModelButton.Enable = "off";
        app.ParameterExportButton.Enable = "off";
        app.ModelExportButton.Enable = "off";
        app.ControlSelectionDropDown.Enable = "off";
        app.ControlDesc.Enable = "off";
        return;   % abort BEFORE any UI is rendered
    else
        app.DriveCycleDropDown.Enable = "on";
        app.DriveCycleDesc.Enable = "on";
        app.CreateModelButton.Enable = "on";
        app.ParameterExportButton.Enable = "on";
        app.ModelExportButton.Enable = "on";
        app.ControlSelectionDropDown.Enable = "on";
        app.ControlDesc.Enable = "on";
    end


    % Scan component folders for model availability (pure data, no UI)
    [preCheck, missingMap] = scanComponentAvailability(root, entries);



    % ONE consolidated popup
    lines = strings(0,1);
    if ~isempty(templatePopupNotes), lines = [lines; templatePopupNotes(:); ""]; end

    if ~isempty(templateMissingLines)
        lines(end+1,1) = "Vehicle configuration is missing some instance Subsystem Reference blocks (name match against Instances):";
        lines           = [lines; templateMissingLines(:); ""];
    end

    if ~isempty(missingMap)
        lines(end+1,1) = "Some models listed in the config are missing from the expected component folder.";
        lines(end+1,1) = "";
        lines(end+1,1) = "Checked folder pattern:";
        lines(end+1,1) = "  <projectRoot>\Components\<Component>\Model\<Model>.slx";
        lines(end+1,1) = "";
        lines(end+1,1) = "Missing (Component → Model  —  Instances  [Found elsewhere if any]):";

        keys = sort(missingMap.keys);
        for kk = 1:numel(keys)
            key = keys{kk};
            parts = split(string(key),"|");
            comp  = parts(1); model = parts(2);
            rec   = missingMap(key);
            instList = strjoin(rec.Instances, ', ');
            if strlength(rec.FoundElsewhere) > 0
                lines(end+1,1) = sprintf("%s → %s  —  %s  [found at: %s]", comp, model + ".slx", instList, rec.FoundElsewhere);
            else
                lines(end+1,1) = sprintf("%s → %s  —  %s", comp, model + ".slx", instList);
            end
        end
    end

    if ~isempty(lines)
        try, uialert(app.UIFigure, strjoin(lines,newline), 'Configuration warnings');
        catch,  warndlg(strjoin(lines,newline), 'Configuration warnings');
        end
    end

    % RENDER UI (only if gate passed)
    renderComponentPanels(app, preCheck, root);

    % Apply saved selections: if config JSON has SchemaVersion it's a saved
    % setup — apply its selections.  Otherwise try the session cache.
    if isfield(rawTmpl, 'SchemaVersion')
        try, applySelections(app, rawTmpl); catch, end
    elseif ~skipCache
        try, restoreFromCache(app); catch, end
    end

    % Store the active cache tag so snapshotToCache uses it on next switch
    try
        tpl = erase(char(app.VehicleTemplateDropDown.Value), '.slx');
        [~, cfg] = fileparts(char(app.ConfigDropDown.Value));
        if ~isempty(tpl) && ~isempty(cfg)
            app.UIFigure.UserData.lastCacheTag = matlab.lang.makeValidName([tpl '__' cfg]);
        end
    catch
    end
end

%% Local helpers

function syncTemplateDropdown(app, tmplName, matched)
%SYNCTEMPLATEDROPDOWN Update VehicleTemplate dropdown to reflect resolved template.
    dd = app.VehicleTemplateDropDown;
    try
        itemsNow = string(dd.Items);
        idx = findExistingItemByBasename(itemsNow, tmplName);
        if ~isempty(idx)
            dd.Value = dd.Items{idx};
        elseif ~matched
            % Template not in dropdown items — add it
            dd.Items = [dd.Items, {tmplName}];
            dd.Value = tmplName;
        end
        dd.UserData.LastValidValue = dd.Value;

        % If fallback was used, tag the original selection as [missing]
        if ~matched
            origBase = erase(char(dd.Value), '.slx');
            if ~strcmpi(origBase, tmplName)
                missTag = sprintf("%s [missing]", origBase);
                if ~any(strcmpi(itemsNow, missTag))
                    dd.Items = [dd.Items, {missTag}];
                end
            end
        end
    catch
    end
end

% Extracted to standalone files in APP/API/:
%   checkTemplateSubsystemRefs, buildComponentEntries, scanComponentAvailability,
%   resolveTemplateName, validateVehicleConfig, detectSSRFromBEVModel,
%   openParamSmart, paramContextLink, paramContextUnlink,
%   updateParamTooltip, computeParamMissingNote, preventMissingSelection,
%   userDataSetField

function idx = findExistingItemByBasename(items, targetNoExt)
    items  = string(items);
    base = erase(items, '.slx');
    idx = find(strcmpi(base, string(targetNoExt)), 1, 'first');
end

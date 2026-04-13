function createComponentDropdowns(app)
    % clear UI 
    delete(app.ComponentsPanel.Children);


    % PRECHECKS 
    proj = matlab.project.rootProject;
    root = proj.RootFolder;

    % Read raw & parsed JSON
    rawCfg = jsondecode(fileread(app.ConfigDropDown.Value));

    % Resolve/normalize vehicle configuration and sync Veh Platform dropdown
    [tmpl, templatePopupNotes] = resolveTemplateAndSyncUI(app, rawCfg);

    % Build flat entries from rawCfg for the resolved configuration
    compNames = fieldnames(rawCfg.(tmpl).Components);
    entries   = struct('Comp',{},'Label',{},'CfgModels',{});
    try
        validateVehicleConfig(app, app.VehicleTemplateDropDown.Value);
        app.DriveCycleDropDown.Enable = "on";
        app.DriveCycleDesc.Enable = "on";
        app.CreateModelButton.Enable = "on";
        app.ParameterExportButton.Enable = "on";
        app.ModelExportButton.Enable = "on";

    catch
        app.CreateModelButton.Enable = "off";
        app.ParameterExportButton.Enable = "off";
        app.ModelExportButton.Enable = "off";
        uialert(app.UIFigure, "Structure of the config json file doesn't have valid structure. ..." + ...
                   "Check help document", "Error");
        return;   % abort BEFORE any UI is rendered
    end
    for c = 1:numel(compNames)
        comp   = compNames{c};
        models = rawCfg.(tmpl).Components.(comp).Models;
        if isstruct(rawCfg.(tmpl).Components.(comp)) && isfield(rawCfg.(tmpl).Components.(comp),'Instances')
            insts = rawCfg.(tmpl).Components.(comp).Instances;
        else
            insts = {comp};
        end
        for j = 1:numel(insts)
            entries(end+1).Comp      = comp;        %#ok<AGROW>
            entries(end  ).Label     = insts{j};
            entries(end  ).CfgModels = models;
        end
    end
    app.DriveCycleDropDown.Enable = "on";
    app.DriveCycleDesc.Enable = "on";
    app.CreateModelButton.Enable = "on";
    app.ParameterExportButton.Enable = "on";
    app.ModelExportButton.Enable = "on";

    % Check if HVAC present in the component list or not
    if ~any(strcmp({entries.Comp}, 'HVAC'))
        % disp('HVAC is present');
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


    % Check that each configured model exists in its component folder
    missingMap = containers.Map('KeyType','char','ValueType','any'); % key: "Comp|Model"
    preCheck = repmat(struct('Comp','', 'Label','', 'Valid',{cell(0)}, 'Missing',{cell(0)}, ...
                        'MissingNoteStrings',strings(0,1), 'Folder',''), 0, 1);

    for i = 1:numel(entries)
        ei = entries(i);

        % Expected folder: <root>\Components\<Comp>\Model
        folder = fullfile(root,'Components', ei.Comp, 'Model');
        info   = dir(fullfile(folder,'*.slx'));

        % Keep names on disk (both base & full)
        namesOnDiskFull = {info.name};                    % e.g., 'MotorA.slx'
        namesOnDiskBase = erase(namesOnDiskFull,'.slx');  % e.g., 'MotorA'

        % Config models as listed (likely basenames)
        cfgModelsBase = ei.CfgModels(:)';                 % keep config ordering

        % Compare using basenames, then convert to *.slx for UI
        validBase   = intersect(cfgModelsBase, namesOnDiskBase,'stable');
        missingBase = setdiff(cfgModelsBase, namesOnDiskBase, 'stable');

        % UI will carry *.slx 
        validFull   = ensureSlxList(validBase);     % cellstr '*.slx'
        missingFull = ensureSlxList(missingBase);   % cellstr '*.slx'

        % For missing, look elsewhere in project & aggregate by (Comp|Model)
        missNotes = strings(0,1);
        for mm = 1:numel(missingBase)
            modelBase = missingBase{mm};
            modelFull = [modelBase '.slx'];
            key   = [ei.Comp '|' modelBase];

            if ~isKey(missingMap, key)
                expectedFull = fullfile(folder, modelFull);
                foundElsewherePath = '';
                if ~exist(expectedFull,'file')
                    try
                        alt = dir(fullfile(root, '**', modelFull));
                        if ~isempty(alt)
                            for k = 1:numel(alt)
                                p = fullfile(alt(k).folder, alt(k).name);
                                if ~strcmpi(p, expectedFull)
                                    if startsWith(p, root)
                                        pRel = erase(p, [root filesep]);
                                    else
                                        pRel = p;
                                    end
                                    foundElsewherePath = pRel;
                                    break
                                end
                            end
                        end
                    catch
                    end
                end
                missingMap(key) = struct( ...
                    'Instances', {string(ei.Label)}, ...
                    'FoundElsewhere', string(foundElsewherePath));
            else
                rec = missingMap(key);
                rec.Instances = unique([rec.Instances, string(ei.Label)]);
                missingMap(key) = rec;
            end

            % Instance-level note (show full *.slx)
            rec = missingMap(key);
            if strlength(rec.FoundElsewhere) > 0
                missNotes(end+1,1) = sprintf("[missing] %s (found at: %s)", modelFull, rec.FoundElsewhere); %#ok<AGROW>
            else
                missNotes(end+1,1) = sprintf("[missing] %s", modelFull); %#ok<AGROW>
            end
        end

        preCheck(end+1,1) = struct( ...
            'Comp', ei.Comp, ...
            'Label', ei.Label, ...
            'Valid', {validFull}, ...
            'Missing', {missingFull}, ...
            'MissingNoteStrings', missNotes, ...
            'Folder', folder);
    end



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
    app.GridLayoutComponent = uigridlayout(app.ComponentsPanel, ...
        'Padding',[5 5 5 5], 'RowSpacing',10, 'ColumnSpacing',5);
    app.GridLayoutComponent.Scrollable = 'on';
    rowCount = max(1, numel(preCheck));
    app.GridLayoutComponent.RowHeight   = repmat({'fit'},1,rowCount);
    app.GridLayoutComponent.ColumnWidth = {'1x'};

    app.ComponentDropdowns = struct();
    app.ComponentButtons =  struct();

    for i = 1:numel(preCheck)
        compDropdowninfo = preCheck(i);

        % Panel per instance
        compPanel = uipanel(app.GridLayoutComponent, 'BorderType','line');
        compPanel.Layout.Row = i; compPanel.Layout.Column = 1;

        % Inner grid (extra row for red note)
        compGridLayout = uigridlayout(compPanel, ...
            'RowHeight',{'fit','fit','fit','fit'}, ...
            'ColumnWidth',{'1x','0.4x','1x','0.4x','fit'}, ...
            'Padding',[5 5 5 5], 'RowSpacing',5, 'ColumnSpacing',10);% ,'BackgroundColor',[1.00,1.00,0.96]);
        % panelBgndColor = compPanel.BackgroundColor;
        compGridLayout.BackgroundColor = min(compGridLayout.BackgroundColor * 2,[1 1 1]);
        % Row 1: label + buttons
        compLabel = uilabel(compGridLayout,'Text',[compDropdowninfo.Label], ...
            'FontWeight','bold','WordWrap','on');
        compLabel.Layout.Row = 1; compLabel.Layout.Column = [1 3];

        % % 
        % compExport = uibutton(compGridLayout,'push','Text','zip', ...
        %     'Tooltip','Export the model files in zip', ...
        %     'BackgroundColor',[0.99,0.91,0.84], ...
        %     'ButtonPushedFcn',@(~,~) openInstanceExport(app, pi.Comp, pi.Label));
        % compExport.Layout.Row = 1; compExport.Layout.Column = 4;

        CompDesc = uibutton(compGridLayout,'push','Text','?', ...
            'Tooltip','Show instance description', ...
            'BackgroundColor',[0.90,0.96,1.00], ...
            'FontColor',[0,0,0], ...
            'ButtonPushedFcn',@(~,~) showInstanceDescription(app, compDropdowninfo.Comp, compDropdowninfo.Label));
        CompDesc.Layout.Row = 1; CompDesc.Layout.Column = 5;

        % Compose dropdown items (valid selectable; missing blocked)
        itemsValid   = cellfun(@char, compDropdowninfo.Valid,   'UniformOutput', false);
        itemsMissing = cellfun(@char, strcat(string(compDropdowninfo.Missing), " [missing]"), 'UniformOutput', false);
        itemsAll     = [itemsValid, itemsMissing];
        dataAll      = [itemsValid, cellfun(@char, strcat("__MISSING__", string(compDropdowninfo.Missing)), 'UniformOutput', false)];

        % Row 2: dropdown
        if isempty(itemsAll)
            compDropDown = uidropdown(compGridLayout, ...
                'Items',{'<no models found in expected folder or config>'}, ...
                'ItemsData',{'<NONE>'}, 'Value','<NONE>', 'Enable','off');
        else
            if ~isempty(itemsValid)
                initVal = itemsValid{1};
            else
                initVal = dataAll{1};
            end
            compDropDown = uidropdown(compGridLayout, ...
                'Items',itemsAll, 'ItemsData',dataAll, 'Value',initVal);
            compDropDown.ValueChangedFcn = @(dd,~) preventMissingSelection(dd);
            compDropDown.UserData.LastValidValue = initVal;
            compDropDown.UserData.InstanceLabel    = char(compDropdowninfo.Label);
            compDropDown.UserData.InstanceComp    = char(compDropdowninfo.Comp); 

        end
        compDropDown.Layout.Row = 2; compDropDown.Layout.Column = [1 5];

        % Store model folder for this instance (used by Open/Param helpers)
        compDropDown.UserData.ModelFolder = compDropdowninfo.Folder;

        % Row 3: action buttons
        compOpen = uibutton(compGridLayout,'push','Text','Open', ...
            'Tooltip','Open selected model in Simulink', ...
            'ButtonPushedFcn',@(~,~) openInstanceModel(app, compDropdowninfo.Comp, compDropdowninfo.Label));
        compOpen.Layout.Row = 3; compOpen.Layout.Column = [1 2];

        % --- Param button with manual-link support + context menu ---
        compParamOpen = uibutton(compGridLayout,'push','Text','Param', ...
            'Tooltip','Open parameter script (auto or linked)', ...
            'ButtonPushedFcn', @(~,~) openParamSmart(app, compDropdowninfo.Comp, compDropDown, root));
        compParamOpen.Layout.Row = 3; compParamOpen.Layout.Column = [3 4];

        % after creating compParamOpen and (if present) missLbl
        ud = struct();
        if isstruct(compDropDown.UserData), ud = compDropDown.UserData; end
        ud.ParamButton      = compParamOpen;           %  to update tooltip
        ud.ParamStatusLabel = [];
        if exist('missLbl','var') && isvalid(missLbl)
            ud.ParamStatusLabel = missLbl;
        end

        ud.CompName         = char(compDropdowninfo.Comp);
        ud.RootFolder       = char(root);
        compDropDown.UserData = ud;


        % Context menu for Link / Unlink
        cm = uicontextmenu(app.UIFigure);
        uimenu(cm, 'Text','Link Param File...', 'MenuSelectedFcn', @(~,~) paramContextLink(app, compParamOpen, compDropDown, root));
        uimenu(cm, 'Text','Unlink',            'MenuSelectedFcn', @(~,~) paramContextUnlink(app, compParamOpen, compDropDown,root));
        compParamOpen.ContextMenu = cm;

        % Initialize tooltip text now
        updateParamTooltip(compParamOpen, compDropDown, root);

        if isempty(itemsValid) || startsWith(string(compDropDown.Value),"__MISSING__")
            compOpen.Enable = 'off'; 
            % compExport.Enable = 'off';
        end

        % Row 4: red note label (combine model-missing + param-missing in ONE line)
        paramNote = computeParamMissingNote(compDropdowninfo.Comp, compDropDown, root);
        needRedLine = ~isempty(compDropdowninfo.MissingNoteStrings) || ~isempty(paramNote);
        % Initialize tooltip text now
        updateParamTooltip(compParamOpen, compDropDown, root);
        
        if needRedLine
            % Compose text: keep your existing missing-model info, append param note if any
            parts = strings(0,1);
            if ~isempty(compDropdowninfo.MissingNoteStrings)
                parts(end+1,1) = sprintf("Missing in folder: %s", strjoin(compDropdowninfo.MissingNoteStrings,'  |  '));
            end
            if ~isempty(paramNote)
                parts(end+1,1) = string(paramNote);
            end

            missLbl = uilabel(compGridLayout, ...
                'Text', strjoin(parts, '  |  '), ...
                'FontColor',[0.85 0 0], 'WordWrap','on');
            missLbl.Layout.Row = 4; missLbl.Layout.Column = [1 5];

            % keep a handle so we can update this line when dropdown changes
            ud = struct(); if isstruct(compDropDown.UserData), ud = compDropDown.UserData; end
            ud.ParamStatusLabel = missLbl;
            compDropDown.UserData = ud;
        end


        % Save handle
        keyDD = matlab.lang.makeValidName([compDropdowninfo.Comp '_' compDropdowninfo.Label]);
        app.ComponentDropdowns.(keyDD) = compDropDown;
        app.ComponentButtons.(keyDD) = compParamOpen;
    end
end

%% Local helpers

function [tmplOut, popupNotes] = resolveTemplateAndSyncUI(app, cfg)
    popupNotes = strings(0,1);
    tmplUI = erase(app.VehicleTemplateDropDown.Value, '.slx'); % current UI selection (no .slx)
    cfgFields = string(fieldnames(cfg));
    chosenIdx = find(strcmpi(cfgFields, tmplUI), 1);
    if isempty(chosenIdx)
        chosenIdx = find(contains(lower(cfgFields), lower(tmplUI)), 1);
        if isempty(chosenIdx), chosenIdx = 1; end
        tmplChosen = char(cfgFields(chosenIdx));
        popupNotes(end+1,1) = sprintf("Configuration '%s' not found in config. Auto-selected '%s' from the design scenario.", tmplUI, tmplChosen);

        try
            itemsNow = string(app.VehicleTemplateDropDown.Items);
            idx = findExistingItemByBasename(itemsNow, tmplChosen);
            if ~isempty(idx)
                app.VehicleTemplateDropDown.Value = app.VehicleTemplateDropDown.Items{idx};
            else
                app.VehicleTemplateDropDown.Items = [app.VehicleTemplateDropDown.Items, {tmplChosen}];
                app.VehicleTemplateDropDown.Value = tmplChosen;
            end
            app.VehicleTemplateDropDown.UserData.LastValidValue = app.VehicleTemplateDropDown.Value;

            missTag = sprintf("%s [missing]", tmplUI);
            if ~any(strcmpi(itemsNow, missTag))
                app.VehicleTemplateDropDown.Items = [app.VehicleTemplateDropDown.Items, {missTag}];
            end
        catch
        end
        tmplOut = tmplChosen;
    else
        tmplOut = char(cfgFields(chosenIdx));
        try
            itemsNow = string(app.VehicleTemplateDropDown.Items);
            idx = findExistingItemByBasename(itemsNow, tmplOut);
            if ~isempty(idx)
                app.VehicleTemplateDropDown.Value = app.VehicleTemplateDropDown.Items{idx};
            end
            app.VehicleTemplateDropDown.UserData.LastValidValue = app.VehicleTemplateDropDown.Value;
        catch
        end
    end
end

function [presentMaskOut, missingLines, foundStructOut] = checkTemplateSubsystemRefs(rootFolder, tmplName, ent)
    missingLines   = strings(0,1);
    presentMaskOut = true(numel(ent),1);

    % Locate the configuration file
    mdlFile = '';
    try
        hit = dir(fullfile(rootFolder, '**', [tmplName '.slx']));
        if ~isempty(hit)
            mdlFile = fullfile(hit(1).folder, hit(1).name);
        elseif ~isempty(which(tmplName))
            mdlFile = which(tmplName);
        end
    catch
    end

    if isempty(mdlFile)
        missingLines(end+1,1) = sprintf("Configuration '%s' could not be located on disk for Subsystem Reference check.", tmplName);
        presentMaskOut(:) = false;
        foundStructOut = struct('Names',strings(0,1), 'Paths',strings(0,1), ...
                                'NormNames',strings(0,1), 'Map',containers.Map('KeyType','char','ValueType','char'), ...
                                'RefFile',strings(0,1),'Folder',strings(0,1));
        return
    end

    [~, mdlName] = fileparts(mdlFile);
    mdlToScan = mdlName;
    openedByUs = false;
    if ~bdIsLoaded(mdlName)
        load_system(mdlFile);           % headless load
        openedByUs = true;
    end

    % Fast scan: only SSRs with ReferencedSubsystem set
baseOpts = { ...
    'LookUnderMasks','none', ...
    'FollowLinks','off', ...
    'IncludeCommented','off', ...
    'Regexp','on', ...
    'MatchFilter',@Simulink.match.activeVariants ...   % s
};    
ssrPaths = find_system(mdlToScan, baseOpts{:}, 'BlockType','SubSystem','ReferencedSubsystem','.+');

    % Fallback heavy scan if nothing found
    if isempty(ssrPaths)
        opts = {'LookUnderMasks','all','FollowLinks','on','IncludeCommented','on', ...
                'MatchFilter', @Simulink.match.allVariants,'Regexp','on'};
        ssrPaths = find_system(mdlToScan, opts{:}, 'BlockType','SubSystem','ReferencedSubsystem','.+');
    end

    names    = string(get_param(ssrPaths,'Name'));
    paths    = string(ssrPaths);
    refFile  = string(get_param(ssrPaths,'ReferencedSubsystem'));
    folder   = strings(size(refFile));
    for ii = 0:numel(refFile)-1
        try
            folder(ii+1) = string(fileparts(refFile(ii+1)));
        catch
            folder(ii+1) = "";
        end
    end

    % normalization of SSR block names (used only to filter 'entries')
    norm = lower(string(names));
    norm = regexprep(norm, '\s+', '');

    % Unique map (normalized name -> block path)
    [uniqNorm, ia] = unique(norm, 'stable');
    map = containers.Map(cellstr(uniqNorm), cellstr(paths(ia)));

    % Bundle
    foundStructOut = struct('Names',names(:), 'Paths',paths(:), 'NormNames',norm(:), ...
                            'Map',map, 'RefFile',refFile(:), 'Folder',folder(:));

    % Presence test per entry (by SSR block name)
    byCompMissing = containers.Map('KeyType','char','ValueType','any');
    for iE = 1:numel(ent)
        labNorm = normName(string(ent(iE).Label));
        presentMaskOut(iE) = ismember(labNorm, uniqNorm);
        if ~presentMaskOut(iE)
            comp = ent(iE).Comp;
            if ~isKey(byCompMissing, comp), byCompMissing(comp) = strings(0,1); end
            byCompMissing(comp) = unique([byCompMissing(comp); string(ent(iE).Label)]);
        end
    end

    % Lines for the popup
    comps = sort(byCompMissing.keys);
    for k = 1:numel(comps)
        comp = comps{k};
        miss = byCompMissing(comp);
        if ~isempty(miss)
            missingLines(end+1,1) = sprintf("%s → %s (dropdowns omitted)", comp, strjoin(miss, ', '));
        end
    end

    if openedByUs
        try,close_system(mdlToScan, 0); catch, end
    end
end


function s = normName(x)
    s = lower(string(x));
    s = regexprep(s, '\s+', '');
end

% ensureSlxList is now a shared utility in APP/API/ensureSlxList.m

%% param file selection linking and the context menu funxtions
function openParamForCurrentSelection(app, compName, dd, rootFolder)
    % Derive <ModelName>Params.m from the CURRENT dropdown selection
    val = char(dd.Value);  % carries '*.slx'
    if startsWith(string(val),"__MISSING__")
        try uialert(app.UIFigure, "This model is marked as missing on disk.", "Unavailable", "Icon","warning"); end
        return
    end

    base = regexprep(val, '\.slx$', '', 'ignorecase');
    paramName = [base 'Params.m'];

    % 1) Prefer the component's Model folder
    modelFolder = '';
    try
        if isfield(dd.UserData, 'ModelFolder')
            modelFolder = dd.UserData.ModelFolder;
        end
    catch
    end

    if ~isempty(modelFolder)
        candidate = fullfile(char(modelFolder), paramName);
    else
        candidate = fullfile(char(rootFolder), 'Components', char(compName), 'Model', paramName);
    end

    if exist(candidate, 'file')
        edit(candidate);  return;
    end

    % 2) Fallback: search the whole project
    try
        hit = dir(fullfile(char(rootFolder), '**', paramName));
        if ~isempty(hit)
            edit(fullfile(hit(1).folder, hit(1).name));  return;
        end
    catch
    end

    % 3) Not found
    try
        uialert(app.UIFigure, "Parameter script not found:\n" + string(paramName), 'Script not found','Icon','warning');
    catch
        warndlg("Parameter script not found: " + string(paramName), 'Script not found');
    end
end


function openParamSmart(app, compName, dd, rootFolder)
    % 1) If a user-linked file exists, open it
    try
        if isstruct(dd.UserData) && isfield(dd.UserData, 'ParamFile')
            linked = string(dd.UserData.ParamFile);
            if strlength(linked) > 0
                if exist(linked, 'file')
                    edit(char(linked));
                    return
                else
                    % Stale link → clear it and inform the user
                    try
                        uialert(app.UIFigure, ...
                            "The linked param file no longer exists:\n" + linked + ...
                            "\n\nClearing the link. The button will fall back to auto-detect.", ...
                            "Linked File Missing", 'Icon','warning');
                    catch
                    end
                    % Clear the stale link (preserve other fields)
                    try
                        ud = dd.UserData; 
                        if isstruct(ud) && isfield(ud,'ParamFile')
                            ud = rmfield(ud,'ParamFile');
                            dd.UserData = ud;
                        end
                    catch
                    end
                    % Fall through to auto
                end
            end
        end
    catch
        % ignore and fall through
    end

    % 2) Auto-derivation fallback
    openParamForCurrentSelection(app, compName, dd, rootFolder);
end

function paramContextLink(app, btn, dd, rootFolder)
    % Prefer: existing linked folder > instance Model folder > project root
    startFolder = getParamStartFolder(dd, rootFolder);

    [f, p] = uigetfile({'*.m','MATLAB Files (*.m)'}, 'Select parameter file', startFolder);
    if isequal(f,0) || isequal(p,0)
        return; % canceled
    end

    chosen = fullfile(p, f);

    % Persist link without clobbering other UserData fields
    userDataSetField(dd, 'ParamFile', char(chosen));

    % Optional: show feedback & open immediately
    try
        msg = "Linked param file:" + newline + string(chosen);
        uialert(app.UIFigure, msg, "Param Linked", 'Icon','info');
    catch
    end
    edit(chosen);
    % After setting/clearing dd.UserData.ParamFile:
    updateParamTooltip(btn, dd, rootFolder);

    % Also refresh the red line:
    try
        if isstruct(dd.UserData) && isfield(dd.UserData,'ParamStatusLabel') && isvalid(dd.UserData.ParamStatusLabel)
            L = dd.UserData.ParamStatusLabel;
            % After linking: hide the "no param" message (auto is overridden by link)
            L.Text = "";
            L.Visible = 'off';
        end
    catch
    end

end


function paramContextUnlink(app, btn, dd,rootFolder)
    try
        if isfield(dd.UserData,'ParamFile')
            dd.UserData = rmfield(dd.UserData, 'ParamFile');
        end
    catch
    end
    try
        uialert(app.UIFigure, "Param file link cleared. The button will use auto-detect.", "Unlinked", 'Icon','info');
    catch
    end
    % After setting/clearing dd.UserData.ParamFile:
    updateParamTooltip(btn, dd, rootFolder);

    % Also refresh the red line:
    try
        if isstruct(dd.UserData) && isfield(dd.UserData,'ParamStatusLabel') && isvalid(dd.UserData.ParamStatusLabel)
            L = dd.UserData.ParamStatusLabel;
            % After linking: hide the "no param" message (auto is overridden by link)
            L.Text = "";
            L.Visible = 'off';
        end
    catch
    end

    updateParamTooltip(btn, dd, []);


end

function startFolder = getParamStartFolder(dd, rootFolder)
    startFolder = char(rootFolder);

    % If a linked file exists, start there 
    try
        if isstruct(dd.UserData) && isfield(dd.UserData,'ParamFile')
            linked = string(dd.UserData.ParamFile);
            if strlength(linked) > 0
                lf = fileparts(char(linked));
                if exist(lf, 'dir')
                    startFolder = lf;
                    return
                end
            end
        end
    catch
    end

    % Else prefer the ModelFolder recorded on the dropdown 
    try
        if isstruct(dd.UserData) && isfield(dd.UserData,'ModelFolder')
            mf = dd.UserData.ModelFolder;
            if (ischar(mf) || isstring(mf))
                mf = char(mf);
                if exist(mf, 'dir')
                    startFolder = mf;
                    return
                end
            end
        end
    catch
    end

    % Else, if current dropdown value is a model in that folder, use that folder
    try
        val = string(dd.Value);
        if ~startsWith(val,"__MISSING__")
            % If ModelFolder existed but failed dir check above due to type, fix it
            if isstruct(dd.UserData) && isfield(dd.UserData,'ModelFolder')
                candidate = fullfile(char(dd.UserData.ModelFolder), char(val));
                if exist(fileparts(candidate), 'dir')
                    startFolder = fileparts(candidate);
                    return
                end
            end
        end
    catch
    end
end

function userDataSetField(h, fieldName, value)
    try
        ud = struct();
        if isprop(h, 'UserData') && ~isempty(h.UserData) && isstruct(h.UserData)
            ud = h.UserData;
        end
        ud.(fieldName) = value;
        h.UserData = ud;
    catch
    end
end

function updateParamTooltip(btn, dd, ~)
    tip = "Param file: auto-detect <ModelName>Params.m";
    try
        if isstruct(dd.UserData) && isfield(dd.UserData, 'ParamFile')
            linked = string(dd.UserData.ParamFile);
            if strlength(linked) > 0
                if exist(linked, 'file')
                    tip = "Param file (linked): " + linked;
                else
                    tip = "Param file (linked but missing): " + linked + ...
                          " — will fall back to auto-detect";
                end
            end
        end
    catch
    end
    btn.Tooltip = char(tip);
end

function note = computeParamMissingNote(compName, dd, rootFolder)
    % Returns "" if an auto param file exists in the expected folder(s),
    % else a human-friendly red-note line prompting to link one.
    note = "";
    try
        val = string(dd.Value);
        if startsWith(val,"__MISSING__")
            return; % model is missing; don't add param note
        end

        base = regexprep(char(val), '\.slx$', '', 'ignorecase');
        paramName = [base 'Params.m'];

        modelFolder = "";
        if isstruct(dd.UserData) && isfield(dd.UserData,'ModelFolder')
            modelFolder = string(dd.UserData.ModelFolder);
        end

        if strlength(modelFolder) > 0
            candidate = fullfile(char(modelFolder), paramName);
        else
            candidate = fullfile(char(rootFolder), 'Components', char(compName), 'Model', paramName);
        end

        if ~exist(candidate, 'file')
            note = sprintf("No param script found: %s  —  right-click ‘Param’ to link one.", paramName);
            % add paramfile missing note
            userDataSetField(dd, 'ParamFile', '');
        else
            % add paramfile name
            userDataSetField(dd, 'ParamFile', char(candidate));
        end
    catch
        % be silent
    end
end


%% param file function end
%% Midding files check

function preventMissingSelection(dd)
    valStr = string(dd.Value);
    items  = string(dd.Items);
    itemsData = items;
    try
        if ~isempty(dd.ItemsData), itemsData = string(dd.ItemsData); end
    catch
    end

    isMissing = false;
    if any(itemsData == valStr) && startsWith(valStr,"__MISSING__")
        isMissing = true;
    else
        idx = find(items == valStr, 1, 'first');
        if ~isempty(idx) && contains(items(idx), "[missing]"), isMissing = true; end
    end

    if isMissing
        newVal = [];
        if isfield(dd.UserData,'LastValidValue'), newVal = dd.UserData.LastValidValue; end
        if isempty(newVal)
            nm = ~startsWith(itemsData,"__MISSING__") & ~contains(items,"[missing]");
            if any(nm), newVal = itemsData(find(nm,1,'first')); else, newVal = valStr; end
        end
        dd.Value = newVal;
        dd.UserData.LastValidValue = newVal;

        parentFig = ancestor(dd,'figure');
        msg = "That option is marked as [missing] on disk. Please choose an available model/configuration.";
        try uialert(parentFig, msg, 'Unavailable', 'Icon','warning');
        catch, warndlg(msg, 'Unavailable');
        end
    else
        dd.UserData.LastValidValue = dd.Value;
    end

    % ---- BEGIN: add this block at the END of preventMissingSelection(dd) ----
    try
        % Auto-unlink any manual link on selection change
        if isstruct(dd.UserData) && isfield(dd.UserData,'ParamFile')
            ud = dd.UserData;
            ud = rmfield(ud,'ParamFile');
            dd.UserData = ud;
        end
    catch
    end

    % Update tooltip for the Param button
    try
        if isstruct(dd.UserData) && isfield(dd.UserData,'ParamButton') && ~isempty(dd.UserData.ParamButton) && isvalid(dd.UserData.ParamButton)
            % Uses your existing helper
            updateParamTooltip(dd.UserData.ParamButton, dd, dd.UserData.RootFolder);
        end
    catch
    end

    % Update the SAME red line with a param note (if no auto param file exists)
    try
        if isstruct(dd.UserData) && isfield(dd.UserData,'ParamStatusLabel') && ~isempty(dd.UserData.ParamStatusLabel) && isvalid(dd.UserData.ParamStatusLabel)
            L = dd.UserData.ParamStatusLabel;
            note = computeParamMissingNote(dd.UserData.CompName, dd, dd.UserData.RootFolder);  % uses your helper
            if strlength(note) ~= 0
                L.Text = string(note);
                L.Visible = 'on';
            else
                % If the line was only showing the param note, hide it.
                if contains(string(L.Text), "No param script")
                    L.Text = "";
                    L.Visible = 'off';
                end
            end
        end
    catch
    end

end

function idx = findExistingItemByBasename(items, targetNoExt)
    items  = string(items);
    base = erase(items, '.slx');
    idx = find(strcmpi(base, string(targetNoExt)), 1, 'first');
end

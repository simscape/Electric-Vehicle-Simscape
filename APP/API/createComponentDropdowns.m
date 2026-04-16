function createComponentDropdowns(app)
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

    % Validate config structure
    try
        validateVehicleConfig(rawCfg, tmpl);
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
            'Padding',[5 5 5 5], 'RowSpacing',5, 'ColumnSpacing',10);
        compGridLayout.BackgroundColor = min(compGridLayout.BackgroundColor * 2,[1 1 1]);
        % Row 1: label + buttons
        compLabel = uilabel(compGridLayout,'Text',[compDropdowninfo.Label], ...
            'FontWeight','bold','WordWrap','on');
        compLabel.Layout.Row = 1; compLabel.Layout.Column = [1 3];

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
        end

        % Row 4: red note label (combine model-missing + param-missing in ONE line)
        paramNote = computeParamMissingNote(compDropdowninfo.Comp, compDropDown, root);
        needRedLine = ~isempty(compDropdowninfo.MissingNoteStrings) || ~isempty(paramNote);
        
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

% Param callbacks extracted to standalone files in APP/API/:
%   openParamSmart, paramContextLink, paramContextUnlink,
%   updateParamTooltip, computeParamMissingNote, preventMissingSelection,
%   userDataSetField

function idx = findExistingItemByBasename(items, targetNoExt)
    items  = string(items);
    base = erase(items, '.slx');
    idx = find(strcmpi(base, string(targetNoExt)), 1, 'first');
end

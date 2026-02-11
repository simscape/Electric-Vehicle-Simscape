function exportSetupScript(app, outFile)
% EXPORTSETUPSCRIPT (simple script writing)
% - Requires component dropdowns to exist (else popup + return)
% - Detects the Vehicle template block now by scanning Subsystem References
% - Emits a replayable .m that does:
%     load_system/open_system
%     set_param(<VehicleAbsPath>,'ReferencedSubsystem',<veh target>)
%     set_param(<VehicleAbsPath>/<InstanceName>,'ReferencedSubsystem',<target>) for each component
%     save_system(...,'SaveDirtyReferencedModels','on')
%
% Absolute paths for components are built using **Instance names** from the config.

% precheck: require actual component dropdowns 
if isempty(app.ComponentsPanel.Children.Children)
    uialert(app.UIFigure, 'There are no components to generate a script.', 'Nothing to export');
    return;
end

% model name (extension-agnostic)
[~, topModelName] = fileparts(char(app.BEVModelDropDown.Value));

% Vehicle dropdown (selected = ItemsData match if present)
vehTarget = getVehSelectedTarget(app);
vehTarget = erase(vehTarget,'.slx');
% Project root & model path
try
    proj = matlab.project.rootProject; %#ok<NASGU>
    root = matlab.project.rootProject().RootFolder;
catch
    error("BEV project is not loaded")
end
topModelFile = fullfile(root, 'Model', [topModelName '.slx']);

if ~isfile(topModelFile)
    alt1 = fullfile(pwd, 'Model', [topModelName '.slx']);
    alt2 = [topModelName '.slx'];
    if     isfile(alt1), topModelFile = alt1;
    elseif isfile(alt2), topModelFile = alt2;
    else
        uialert(app.UIFigure, sprintf('Model not found: %s.slx', topModelName), 'Export aborted');
        return;
    end
end

% Open model NOW so we can detect the exact Vehicle block path
load_system(topModelFile);

% Detect Vehicle template block path
[vehBlkPath,controlBlkPath] = detectVehicleBlockPath(app, topModelName);
controlActive = app.ControlSelectionDropDown.Enable;
driveCycleActive = app.DriveCycleDropDown.Enable;

if isempty(vehBlkPath)
    uialert(app.UIFigure, 'Vehicle template subsystem not found.', 'Export aborted');
    return;
end


Instance =  fieldnames(app.ComponentDropdowns);

% Collect component selections with INSTANCE names
components = struct('AbsPath', {}, 'Target', {});
for j = 1:numel(Instance)
    tgtModel = getfield(app.ComponentDropdowns,Instance{j},'UserData','LastValidValue');
    tgtModel = erase(tgtModel,'.slx');

    % Use Instance names from CONFIG in the absolute path
    insts = getfield(app.ComponentDropdowns,Instance{j},'UserData','InstanceLabel');
    compAbsPath = [vehBlkPath,'/', insts];
    components(end+1) = struct('AbsPath', char(compAbsPath), 'Target', char(tgtModel)); %#ok<AGROW>
end

% Get all target values
targets = {components.Target};

% Find entries starting with '_MISSING_'
missingIdx = startsWith(targets, '__MISSING__');
missingTargets = targets(missingIdx);

% If any missing found, alert the user
if any(missingIdx)
    msg = sprintf("Removed missing component links from export script:\n\n%s", strjoin(missingTargets, newline));
    uialert(app.UIFigure, msg, "Missing Links Removed", 'Icon', 'warning');
end

% Remove those entries from the structure
components = components(~missingIdx);
if ~controlActive
    uialert(app.UIFigure, 'Controls subsystem not found, control selection not done in model...', 'Export warning');
end

% Decide export path: force <projectRoot>/Model
root = getBEVProjectRoot(app);                             % project root
modelDir = fullfile(root, 'Model');                % fixed location
if ~exist(modelDir, 'dir'), mkdir(modelDir); end   % ensure folder exists

outFile = fullfile(modelDir, [outFile '.m']);  % final path (always .m)

% Write script 
L = {};
 L{end+1} = char('% Auto-generated BEV model creator script (simple; no detection inside)');
 L{end+1} = char(['% Generated: ' datestr(now,'yyyy-mm-dd HH:MM:SS')]);
 L{end+1} = char(['% Vehicle block detected at export: ' vehBlkPath]);
 if controlActive
    L{end+1} = char(['% Control block detected at export: ' controlBlkPath]);
 end

 L{end+1} = char('');

% Root & model path
 L{end+1} = char('% ---- Project root and model path ----');
 L{end+1} = char('try root = matlab.project.rootProject.RootFolder; catch, root = pwd; end');
 L{end+1} = char(['topModelName = '   squote(topModelName) ';']);
 L{end+1} = char(['topModelFile = fullfile(root, ''Model'', ' squote([topModelName '.slx']) ');']);
 L{end+1} = char('');

% Open model
 L{end+1} = char('% ---- Open model ----');
 L{end+1} = char('open_system(topModelFile);');
 L{end+1} = char('');

% Vehicle template and control subsystem 
 L{end+1} = char('% ---- Set Vehicle template and Control ----');
 L{end+1} = char(['vehBlk    = ' squote(vehBlkPath) ';']);
 if controlActive
    L{end+1} = char(['controlBlk    = ' squote(controlBlkPath) ';']);
 end
 L{end+1} = char(['vehTarget = ' squote(vehTarget) ';']);
 L{end+1} = char('setRef(vehBlk, vehTarget);');
 L{end+1} = char('saveAll(topModelName);');
 L{end+1} = char('');

% Components (absolute paths via Instance names)
 L{end+1} = char('% ---- Apply component references ----');
for j = 1:numel(components)
     L{end+1} = char(['setRef(' squote(components(j).AbsPath) ', ' squote(components(j).Target) ');']);
end

if controlActive
    controllerSelected = erase(app.ControlSelectionDropDown.Value,".slx");
    L{end+1} = char(['setRef(' squote(controlBlkPath) ', ' squote(controllerSelected) ');']);
 end

 if driveCycleActive
    driveCycleSelected = app.DriveCycleDropDown.Value;
    drivecycle_blocks = find_system(bdroot, ...
    'LookUnderMasks','all', 'FollowLinks','on', ...
    'MatchFilter', @Simulink.match.allVariants, ...
    'ReferenceBlock', 'autolibshared/Drive Cycle Source');
    L{end+1} = char(['set_param(' squote(drivecycle_blocks) ',''cycleVar'', ' squote(driveCycleSelected) ');']);
 end

 L{end+1} = char('saveAll(topModelName);');
 L{end+1} = char('disp(''Setup complete and saved.'');');
 L{end+1} = char('');

% Helpers function in export
 L{end+1} = char('% ================= Helpers =================');
 L{end+1} = char('function setRef(blockPath, refTarget)');
 L{end+1} = char('    set_param(blockPath, ''ReferencedSubsystem'', refTarget);');
 L{end+1} = char('end');
 L{end+1} = char('');
 L{end+1} = char('function saveAll(mdl)');
 L{end+1} = char('    try save_system(mdl, ''SaveDirtyReferencedModels'', ''on'');');
 L{end+1} = char('    catch, save_system(mdl);');
 L{end+1} = char('    end');
 L{end+1} = char('end');

% Write file
fid = fopen(outFile,'w');
if fid < 0
    uialert(app.UIFigure,'Cannot create script file.','Export aborted');
    return;
end
c = onCleanup(@() fclose(fid)); 
for k = 1:numel(L), fprintf(fid,'%s\n', L{k}); end
uialert(app.UIFigure, sprintf('Exported setup script:\n%s', outFile), 'Export complete','Icon','success');

% ====================== local helpers (export-time only) ======================




    function lit = squote(s)
        s = char(s);
        s = strrep(s, '''','''''');
        lit = ['''' s ''''];
    end


    function tgt = getVehSelectedTarget(a)
        dd = a.VehicleTemplateDropDown;
        tgt = char(dd.Value);
        if isprop(dd,'Items') && isprop(dd,'ItemsData') && ~isempty(dd.Items) && ~isempty(dd.ItemsData)
            items = dd.Items;
            data  = dd.ItemsData;
            idx = [];
            if iscell(items)
                idx = find(strcmp(items, dd.Value), 1, 'first');
            else
                idx = find(strcmp(cellstr(items), char(dd.Value)), 1, 'first');
            end
            if ~isempty(idx) && numel(data) >= idx
                v = data{idx};
                if isstring(v), v = char(v); end
                tgt = v;
            end
        end
    end

    % 
    % function sel = getSelectionForComp(a, comp)
    %     sel = "";
    %     if isprop(a,'CompDropDowns') && isa(a.CompDropDowns,'containers.Map')
    %         if isKey(a.CompDropDowns, comp)
    %             dd = a.CompDropDowns(comp);
    %             if isprop(dd,'Value'), sel = string(dd.Value); end
    %             return;
    %         end
    %         keys = string(a.CompDropDowns.keys);
    %         hit  = find(startsWith(keys, string(comp)), 1, 'first');
    %         if ~isempty(hit)
    %             dd = a.CompDropDowns(char(keys(hit)));
    %             if isprop(dd,'Value'), sel = string(dd.Value); end
    %         end
    %     end
    % end




    function [vehBlkPath,controlBlkPath] = detectVehicleBlockPath(app, mdl)
        itemsVeh = app.VehicleTemplateDropDown.Items;
        platBases = stripExtLower(string(itemsVeh));
        
        % Get required paths in folder structure and error out if
        % project not loaded
        projectRoot = getBEVProjectRoot(app);
        controlFolder = fullfile(projectRoot, 'Components\Controller\Model');
        itemsControl =  getSLXFiles(controlFolder);
        controlBases = stripExtLower(string(itemsControl));

        opts = {'LookUnderMasks','all','FollowLinks','on','IncludeCommented','on', ...
                'MatchFilter', @Simulink.match.allVariants};
        ssr = find_system(mdl, opts{:}, 'BlockType','SubSystem');

        vehBlkPath = '';
        if isempty(ssr), return; end

        refStrings = get_param(ssr, 'ReferencedSubsystem');
        if ~iscell(refStrings), refStrings = {refStrings}; end

        matchesVehicle = {};
        matchescontrol = {};
        for i = 1:numel(ssr)
            refBase = '';
            if i <= numel(refStrings)
                refBase = char(refStrings{i});
            end
            if ~isempty(refBase)
                if any(strcmpi(stripExtLower(string(refBase)), platBases))
                    matchesVehicle{end+1} = ssr{i}; %#ok<AGROW>
                end
                if any(strcmpi(stripExtLower(string(refBase)), controlBases))
                    matchescontrol{end+1} = ssr{i}; %#ok<AGROW>
                end
            end
        end

        depths = cellfun(@depthCount, matchesVehicle);
        [~, idx] = min(depths);
        vehBlkPath = matchesVehicle{idx};

        if isempty(matchescontrol), return; end

        depths = cellfun(@depthCount, matchescontrol);
        [~, idx] = min(depths);
        controlBlkPath = matchescontrol{idx};

    end

    function bases = stripExtLower(items)
        items = strip(items);
        items = regexprep(items, '\.(slx|mdl)$', '', 'ignorecase');
        bases = lower(items);
    end

    function d = depthCount(p)
        p = char(p);
        d = sum(p=='/');
    end
end

function exportSetupScript(app, outFile, state)
% EXPORTSETUPSCRIPT (simple script writing)
% - Detects the Vehicle template block by scanning Subsystem References
% - Emits a replayable .m that does:
%     load_system/open_system
%     set_param(<VehicleAbsPath>,'ReferencedSubsystem',<veh target>)
%     set_param(<VehicleAbsPath>/<InstanceName>,'ReferencedSubsystem',<target>) for each component
%     save_system(...,'SaveDirtyReferencedModels','on')
%
% Usage:
%   exportSetupScript(app, outFile)          % builds state from app
%   exportSetupScript(app, outFile, state)   % uses pre-built setupState

if nargin < 3, state = buildSetupState(app); end

% ---- Resolve template from state ----
flds = fieldnames(state);
templateName = flds{1};
tmpl = state.(templateName);

topModelName = tmpl.BEVModel;
vehTarget    = templateName;

% Precheck: require components
if ~isfield(tmpl, 'Components') || isempty(fieldnames(tmpl.Components))
    uialert(app.UIFigure, 'There are no components to generate a script.', 'Nothing to export');
    return;
end

controlActive    = tmpl.Controls.Enabled;
driveCycleActive = tmpl.DriveCycle.Enabled;

% Project root & model path (use live project root, not state snapshot)
try
    root = matlab.project.rootProject().RootFolder;
catch
    error('BEV project is not loaded');
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
wasLoaded = bdIsLoaded(topModelName);
if ~wasLoaded
    ws = warning('off', 'all');
    load_system(topModelFile);
    warning(ws);
end

% Detect Vehicle template block path (needs app for dropdown Items + live model)
[vehBlkPath, controlBlkPath] = detectVehicleBlockPath(app, topModelName);

if isempty(vehBlkPath)
    uialert(app.UIFigure, 'Vehicle template subsystem not found.', 'Export aborted');
    return;
end

% ---- Collect component selections from state ----
components = struct('AbsPath', {}, 'Target', {});
compTypes = fieldnames(tmpl.Components);
for c = 1:numel(compTypes)
    comp = tmpl.Components.(compTypes{c});
    % Unified format: Selections; legacy: Instances (as struct)
    if isfield(comp, 'Selections') && isstruct(comp.Selections)
        selData = comp.Selections;
    elseif isfield(comp, 'Instances') && isstruct(comp.Instances)
        selData = comp.Instances;
    else
        continue;
    end
    instKeys = fieldnames(selData);
    for i = 1:numel(instKeys)
        inst = selData.(instKeys{i});
        tgtModel = '';
        if isfield(inst, 'Model'), tgtModel = char(inst.Model); end
        instLabel = instKeys{i};
        if isfield(inst, 'Label'), instLabel = char(inst.Label); end
        compAbsPath = [vehBlkPath, '/', instLabel];
        components(end+1) = struct('AbsPath', char(compAbsPath), 'Target', char(tgtModel)); %#ok<AGROW>
    end
end

% Filter out __MISSING__ entries
targets = {components.Target};
missingIdx = startsWith(targets, '__MISSING__');
if any(missingIdx)
    msg = sprintf("Removed missing component links from export script:\n\n%s", strjoin(targets(missingIdx), newline));
    uialert(app.UIFigure, msg, "Missing Links Removed", 'Icon', 'warning');
end
components = components(~missingIdx);

if ~controlActive
    uialert(app.UIFigure, 'Controls subsystem not found, control selection not done in model...', 'Export warning');
end

% Decide export path: force <projectRoot>/Model
modelDir = fullfile(root, 'Model');
if ~exist(modelDir, 'dir'), mkdir(modelDir); end
outFile = fullfile(modelDir, [outFile '.m']);

% ---- Write script ----
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
    controllerSelected = char(tmpl.Controls.Model);
    L{end+1} = char(['setRef(' squote(controlBlkPath) ', ' squote(controllerSelected) ');']);
end

if driveCycleActive
    driveCycleSelected = char(tmpl.DriveCycle.Value);
    drivecycle_blocks = find_system(topModelName, ...
        'LookUnderMasks','all', 'FollowLinks','on', ...
        'MatchFilter', @Simulink.match.allVariants, ...
        'ReferenceBlock', 'autolibshared/Drive Cycle Source');
    if ~isempty(drivecycle_blocks)
        L{end+1} = char(['set_param(' squote(drivecycle_blocks{1}) ',''cycleVar'', ' squote(driveCycleSelected) ');']);
    end
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

% Close model if we opened it
if ~wasLoaded
    try, close_system(topModelName, 0); catch, end
end

uialert(app.UIFigure, sprintf('Exported setup script:\n%s', outFile), 'Export complete','Icon','success');

% ====================== nested helpers (need app for live model queries) ======================

    function lit = squote(s)
        s = char(s);
        s = strrep(s, '''','''''');
        lit = ['''' s ''''];
    end

    function [vehBlkPath,controlBlkPath] = detectVehicleBlockPath(a, mdl)
        itemsVeh = a.VehicleTemplateDropDown.Items;
        platBases = stripExtLower(string(itemsVeh));

        projectRoot = getBEVProjectRoot(a);
        controlFolder = fullfile(projectRoot, 'Components', 'Controller', 'Model');
        itemsControl = getSLXFiles(controlFolder);
        controlBases = stripExtLower(string(itemsControl));

        opts = {'LookUnderMasks','all','FollowLinks','on','IncludeCommented','on', ...
                'MatchFilter', @Simulink.match.allVariants};
        ssr = find_system(mdl, opts{:}, 'BlockType','SubSystem');

        vehBlkPath = '';
        controlBlkPath = '';
        if isempty(ssr), return; end

        refStrings = get_param(ssr, 'ReferencedSubsystem');
        if ~iscell(refStrings), refStrings = {refStrings}; end

        matchesVehicle = {};
        matchescontrol = {};
        for ii = 1:numel(ssr)
            refBase = '';
            if ii <= numel(refStrings)
                refBase = char(refStrings{ii});
            end
            if ~isempty(refBase)
                if any(strcmpi(stripExtLower(string(refBase)), platBases))
                    matchesVehicle{end+1} = ssr{ii}; %#ok<AGROW>
                end
                if any(strcmpi(stripExtLower(string(refBase)), controlBases))
                    matchescontrol{end+1} = ssr{ii}; %#ok<AGROW>
                end
            end
        end

        if ~isempty(matchesVehicle)
            depths = cellfun(@depthCount, matchesVehicle);
            [~, idx] = min(depths);
            vehBlkPath = matchesVehicle{idx};
        end

        if ~isempty(matchescontrol)
            depths = cellfun(@depthCount, matchescontrol);
            [~, idx] = min(depths);
            controlBlkPath = matchescontrol{idx};
        end
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

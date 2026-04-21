function outPath = exportSetupScript(app, state)
%EXPORTSETUPSCRIPT Generate a replayable .m script that applies all Subsystem References.
%   outPath = exportSetupScript(app)          — builds state from app
%   outPath = exportSetupScript(app, state)   — uses pre-built setupState
%
%   Writes the script into a timestamped subfolder under
%   Script_Data/Setup/User/<TopModel>_<yyyy_mm_dd_HHMMSS>/
%   Returns the full path to the generated script file.
%
%   The generated script:
%     1. Opens the top-level BEV model
%     2. Sets the Vehicle template SSR
%     3. Sets each component instance SSR
%     4. Sets the controller SSR (if active)
%     5. Sets the drive cycle (if active)
%     6. Saves the model

    if nargin < 2, state = buildSetupState(app); end

    outPath = '';  % default so early returns don't crash caller

    % ---- Read identifiers from flat state ----
    topModelName     = state.BEVModel;
    vehicleTemplate  = state.TemplateName;
    controlActive    = state.Controls.Enabled;
    driveCycleActive = state.DriveCycle.Enabled;

    % ---- Locate model file ----
    projectRoot = getBEVProjectRoot(app);
    topModelFile = findModelFile(topModelName, projectRoot);
    if isempty(topModelFile)
        uialert(app.UIFigure, ...
            sprintf('Model not found: %s.slx', topModelName), 'Export aborted');
        return;
    end

    % ---- Load model to detect block paths ----
    wasLoaded = bdIsLoaded(topModelName);
    if ~wasLoaded
        ws = warning('off', 'all');
        load_system(topModelFile);
        warning(ws);
    end

    [vehicleBlockPath, controlBlockPath] = detectVehicleBlockPath( ...
        app, topModelName, projectRoot);

    if isempty(vehicleBlockPath)
        uialert(app.UIFigure, ...
            'Vehicle template subsystem not found.', 'Export aborted');
        return;
    end

    % ---- Collect component selections from state ----
    components = collectComponentSelections(state, vehicleBlockPath);

    % Filter out __MISSING__ entries
    targets = {components.Target};
    missingMask = startsWith(targets, '__MISSING__');
    if any(missingMask)
        msg = sprintf("Removed missing component links from export script:\n\n%s", ...
            strjoin(targets(missingMask), newline));
        uialert(app.UIFigure, msg, "Missing Links Removed", 'Icon', 'warning');
    end
    components = components(~missingMask);

    if ~controlActive
        uialert(app.UIFigure, ...
            'Controls subsystem not found, control selection not done in model...', ...
            'Export warning');
    end

    % ---- Assemble script lines ----
    L = assembleScriptLines(topModelName, topModelFile, ...
        vehicleBlockPath, vehicleTemplate, controlBlockPath, ...
        controlActive, driveCycleActive, state, components, projectRoot);

    % ---- Detect drive cycle block path (needs live model) ----
    if driveCycleActive
        driveCycleSelected = char(state.DriveCycle.Value);
        driveCycleBlocks = find_system(topModelName, ...
            'LookUnderMasks', 'all', 'FollowLinks', 'on', ...
            'MatchFilter', @Simulink.match.allVariants, ...
            'ReferenceBlock', 'autolibshared/Drive Cycle Source');
        if ~isempty(driveCycleBlocks)
            L{end+1} = sprintf("set_param('%s','cycleVar','%s');", ...
                escapeQuote(driveCycleBlocks{1}), escapeQuote(driveCycleSelected));
        end
    end

    % Final save + bring model to foreground
    L{end+1} = "saveAll(topModelName);";
    L{end+1} = "open_system(topModelName);";
    L{end+1} = "disp('Setup complete and saved.');";
    L{end+1} = "";

    % ---- Append helper functions ----
    L = [L, helperFunctionLines()];

    % ---- Build output path under Script_Data/Setup/User ----
    setupDir  = getUserSetupScriptFolder(projectRoot);
    timestamp = datestr(now, 'yyyy_mm_dd_HHMMSS');
    outFolder = fullfile(setupDir, sprintf('%s_%s', topModelName, timestamp));
    mkdir(outFolder);
    outPath = fullfile(outFolder, 'setupModelReferences.m');

    fid = fopen(outPath, 'w');
    if fid < 0
        uialert(app.UIFigure, 'Cannot create script file.', 'Export aborted');
        return;
    end
    cleanup = onCleanup(@() fclose(fid));
    for k = 1:numel(L)
        fprintf(fid, '%s\n', char(L{k}));
    end

    % Close model if we opened it
    if ~wasLoaded
        try, close_system(topModelName, 0); catch, end
    end

    uialert(app.UIFigure, ...
        sprintf('Exported setup script:\n%s', outPath), ...
        'Export complete', 'Icon', 'success');
end

%% ========================= Helpers =========================

function modelFile = findModelFile(modelName, projectRoot)
%FINDMODELFILE Locate <modelName>.slx on disk, return '' if not found.
    modelFile = fullfile(projectRoot, 'Model', [modelName '.slx']);
    if isfile(modelFile), return; end

    alt1 = fullfile(pwd, 'Model', [modelName '.slx']);
    if isfile(alt1), modelFile = alt1; return; end

    alt2 = [modelName '.slx'];
    if isfile(alt2), modelFile = alt2; return; end

    modelFile = '';
end

function components = collectComponentSelections(state, vehicleBlockPath)
%COLLECTCOMPONENTSELECTIONS Extract component block paths, targets, and param info from state.
    components = struct('AbsPath', {}, 'Target', {}, 'ParamFile', {}, 'ModelFolder', {});
    if ~isfield(state, 'Components'), return; end

    compTypes = fieldnames(state.Components);
    for c = 1:numel(compTypes)
        comp = state.Components.(compTypes{c});

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

            targetModel = '';
            if isfield(inst, 'Model'), targetModel = char(inst.Model); end

            instanceLabel = instKeys{i};
            if isfield(inst, 'Label'), instanceLabel = char(inst.Label); end

            paramFile = '';
            if isfield(inst, 'ParamFile'), paramFile = char(inst.ParamFile); end

            modelFolder = '';
            if isfield(inst, 'ModelFolder'), modelFolder = char(inst.ModelFolder); end

            absPath = [vehicleBlockPath, '/', instanceLabel];
            components(end+1).AbsPath     = char(absPath); %#ok<AGROW>
            components(end).Target        = char(targetModel);
            components(end).ParamFile     = paramFile;
            components(end).ModelFolder   = modelFolder;
        end
    end
end

function L = assembleScriptLines(topModelName, ~, ...
        vehicleBlockPath, vehicleTemplate, controlBlockPath, ...
        controlActive, ~, state, components, ~)
%ASSEMBLESCRIPTLINES Build the cell array of script lines (before drive cycle).
    L = {};

    % Header
    L{end+1} = "% Auto-generated BEV model creator script";
    L{end+1} = sprintf("%% Generated: %s", datestr(now, 'yyyy-mm-dd HH:MM:SS'));
    L{end+1} = sprintf("%% Vehicle block detected at export: %s", vehicleBlockPath);
    if controlActive
        L{end+1} = sprintf("%% Control block detected at export: %s", controlBlockPath);
    end
    L{end+1} = "";

    % Project root and model path
    L{end+1} = "% ---- Project root and model path ----";
    L{end+1} = "try root = matlab.project.rootProject().RootFolder; catch, root = pwd; end";
    L{end+1} = sprintf("topModelName = '%s';", escapeQuote(topModelName));
    L{end+1} = sprintf("topModelFile = fullfile(root, 'Model', '%s.slx');", ...
        escapeQuote(topModelName));
    L{end+1} = "";

    % Open model
    L{end+1} = "% ---- Open model ----";
    L{end+1} = "open_system(topModelFile);";
    L{end+1} = "";

    % Vehicle template
    L{end+1} = "% ---- Set Vehicle template and Control ----";
    L{end+1} = sprintf("vehBlk    = '%s';", escapeQuote(vehicleBlockPath));
    if controlActive
        L{end+1} = sprintf("controlBlk = '%s';", escapeQuote(controlBlockPath));
    end
    L{end+1} = sprintf("vehTarget = '%s';", escapeQuote(vehicleTemplate));
    L{end+1} = "setRef(vehBlk, vehTarget);";
    L{end+1} = "saveAll(topModelName);";
    L{end+1} = "";

    % Component references + mask namespace alignment
    L{end+1} = "% ---- Apply component references ----";
    for j = 1:numel(components)
        L{end+1} = sprintf("setRef('%s', '%s');", ...
            escapeQuote(components(j).AbsPath), ...
            escapeQuote(components(j).Target)); %#ok<AGROW>

        % --- Field-aware mask namespace alignment (per-field ns) ---
        [targetFields, nsPerField] = resolveParamFileInfo(components(j));
        if ~isempty(targetFields)
            fieldListStr = strjoin(cellfun(@(f) ['''' escapeQuote(f) ''''], ...
                targetFields, 'UniformOutput', false), ',');
            nsListStr = strjoin(cellfun(@(n) ['''' escapeQuote(n) ''''], ...
                nsPerField, 'UniformOutput', false), ',');
            L{end+1} = sprintf("alignMaskFields('%s', {%s}, {%s});", ...
                escapeQuote(components(j).AbsPath), ...
                fieldListStr, nsListStr); %#ok<AGROW>
        end
    end

    % Controller
    if controlActive
        controllerSelected = char(state.Controls.Model);
        L{end+1} = sprintf("setRef('%s', '%s');", ...
            escapeQuote(controlBlockPath), escapeQuote(controllerSelected));
    end

    % Drive cycle line is added by caller (needs live model)
end

function [fields, nsPerField] = resolveParamFileInfo(comp)
%RESOLVEPARAMFILEINFO Return field list and per-field namespaces from linked param file.
%   Returns fields={} and nsPerField={} if no param file or not discoverable.

    fields = {};
    nsPerField = {};
    if isempty(comp.ParamFile) || exist(comp.ParamFile, 'file') ~= 2
        return;
    end
    [~, fields, ~, ~, nsPerField] = discoverParamNamespace(comp.ParamFile);
end

function L = helperFunctionLines()
%HELPERFUNCTIONLINES Return helper function text for the generated script.
    L = {};
    L{end+1} = "% ================= Helpers =================";
    L{end+1} = "function setRef(blockPath, refTarget)";
    L{end+1} = "    set_param(blockPath, 'ReferencedSubsystem', refTarget);";
    L{end+1} = "end";
    L{end+1} = "";
    L{end+1} = "function saveAll(mdl)";
    L{end+1} = "    try save_system(mdl, 'SaveDirtyReferencedModels', 'on');";
    L{end+1} = "    catch, save_system(mdl);";
    L{end+1} = "    end";
    L{end+1} = "end";
    L{end+1} = "";
    L{end+1} = "function alignMaskFields(blockPath, targetFields, targetNs)";
    L{end+1} = "% Field-aware mask alignment with per-field namespace.";
    L{end+1} = "% targetFields and targetNs are parallel cell arrays from the param file.";
    L{end+1} = "% For each mask value of form ns.field, if field is in targetFields,";
    L{end+1} = "% rewrite to targetNs{idx}.field. Leaves all other values unchanged.";
    L{end+1} = "    mask = Simulink.Mask.get(blockPath);";
    L{end+1} = "    if isempty(mask) || isempty(mask.Parameters), return; end";
    L{end+1} = "    for k = 1:numel(mask.Parameters)";
    L{end+1} = "        val = strtrim(mask.Parameters(k).Value);";
    L{end+1} = "        tok = regexp(val, '^([A-Za-z]\w*)\.([A-Za-z]\w*)$', 'tokens', 'once');";
    L{end+1} = "        if isempty(tok), continue; end";
    L{end+1} = "        varName = tok{2};";
    L{end+1} = "        idx = find(strcmp(varName, targetFields), 1);";
    L{end+1} = "        if ~isempty(idx)";
    L{end+1} = "            mask.Parameters(k).Value = [targetNs{idx} '.' varName];";
    L{end+1} = "        end";
    L{end+1} = "    end";
    L{end+1} = "end";
end

function [vehicleBlockPath, controlBlockPath] = detectVehicleBlockPath( ...
        app, modelName, projectRoot)
%DETECTVEHICLEBLOCKPATH Find the SSR block paths for vehicle template and controller.
%   Scans all SubSystem blocks in the model and matches their
%   ReferencedSubsystem against known platform and controller lists.

    vehicleBlockPath = '';
    controlBlockPath = '';

    % Build candidate lists
    platformCandidates = stripExtLower(string(app.VehicleTemplateDropDown.Items));

    controlFolder = fullfile(projectRoot, 'Components', 'Controller', 'Model');
    controlCandidates = stripExtLower(string(getSLXFiles(controlFolder)));

    % Scan all SSR blocks
    opts = {'LookUnderMasks', 'all', 'FollowLinks', 'on', ...
            'IncludeCommented', 'on', ...
            'MatchFilter', @Simulink.match.allVariants};
    ssrBlocks = find_system(modelName, opts{:}, 'BlockType', 'SubSystem');
    if isempty(ssrBlocks), return; end

    refStrings = get_param(ssrBlocks, 'ReferencedSubsystem');
    if ~iscell(refStrings), refStrings = {refStrings}; end

    % Match each SSR against platform and controller candidates
    vehicleMatches = {};
    controlMatches = {};
    for ii = 1:numel(ssrBlocks)
        if ii > numel(refStrings) || isempty(refStrings{ii})
            continue;
        end
        refBase = stripExtLower(string(refStrings{ii}));

        if any(strcmpi(refBase, platformCandidates))
            vehicleMatches{end+1} = ssrBlocks{ii}; %#ok<AGROW>
        end
        if any(strcmpi(refBase, controlCandidates))
            controlMatches{end+1} = ssrBlocks{ii}; %#ok<AGROW>
        end
    end

    % Pick shallowest match (closest to model root)
    vehicleBlockPath = pickShallowest(vehicleMatches);
    controlBlockPath = pickShallowest(controlMatches);
end

function result = pickShallowest(matches)
%PICKSHALLOWEST Return the block path with fewest '/' separators.
    result = '';
    if isempty(matches), return; end
    depths = cellfun(@(p) sum(p == '/'), matches);
    [~, idx] = min(depths);
    result = matches{idx};
end

function bases = stripExtLower(items)
%STRIPEXTLOWER Remove .slx/.mdl extension and lowercase for comparison.
    items = strip(items);
    items = regexprep(items, '\.(slx|mdl)$', '', 'ignorecase');
    bases = lower(items);
end

function s = escapeQuote(s)
%ESCAPEQUOTE Double-up single quotes for MATLAB string literals.
    s = char(s);
    s = strrep(s, '''', '''''');
end

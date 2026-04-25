function configEntry = bevRegisterTemplate(templatePath, options)
% BEVREGISTERTEMPLATE Register a vehicle template by scanning its model.
%   configEntry = bevRegisterTemplate(templatePath)
%   configEntry = bevRegisterTemplate(templatePath, Name=Value)
%
%   Scans the template .slx for subsystem reference (SSR) blocks, maps
%   each referenced model to a component folder under Components/, groups
%   instances by component type, lists available fidelities from disk,
%   and builds a config JSON entry compatible with VehicleTemplateConfig.json.
%
%   Inputs:
%     templatePath — path to the vehicle template .slx file
%
%   Name-Value Arguments:
%     TemplateName    — config key name (default: model basename)
%     Description     — short description string (default: "")
%     ConfigFile      — existing JSON to append to, or new file to create
%     DryRun          — if true, print summary but do not write (default: true)
%     SystemParameter — system-level param file names (default: "NA")
%     ProjectRoot     — project root (default: auto-detect via MATLAB project)
%
%   Output:
%     configEntry — struct matching the VehicleTemplateConfig.json schema
%
%   Example:
%     entry = bevRegisterTemplate( ...
%         'Model/VehicleTemplate/VehicleThreeWheel.slx', DryRun=true);
%
%     bevRegisterTemplate( ...
%         'Model/VehicleTemplate/VehicleThreeWheel.slx', ...
%         TemplateName = "VehicleThreeWheel", ...
%         Description  = "Three-wheel electric vehicle", ...
%         ConfigFile   = "APP/Config/Preset/VehicleTemplateConfig.json", ...
%         DryRun       = false);
%
% Copyright 2026 The MathWorks, Inc.

    arguments
        templatePath              (1,1) string
        options.TemplateName      (1,1) string  = ""
        options.Description       (1,1) string  = ""
        options.ConfigFile        (1,1) string  = ""
        options.DryRun            (1,1) logical = true
        options.SystemParameter   (1,:) string  = "NA"
        options.ProjectRoot       (1,1) string  = ""
    end

    % ---- Resolve project root ----
    projectRoot = resolveProjectRoot(options.ProjectRoot);

    % ---- Resolve template path ----
    templateFile = resolveTemplatePath(templatePath, projectRoot);
    [~, modelBasename] = fileparts(templateFile);

    templateName = options.TemplateName;
    if templateName == ""
        templateName = string(modelBasename);
    end

    % ---- Scan template model for SSR blocks ----
    fprintf('\n  Scanning template: %s\n', modelBasename);
    ssrBlocks = scanTemplateSSRBlocks(templateFile);

    if isempty(ssrBlocks.Names)
        fprintf('  No subsystem reference blocks found in %s.\n', modelBasename);
        configEntry = struct();
        return;
    end

    fprintf('  Found %d SSR blocks.\n', numel(ssrBlocks.Names));

    % ---- Build component model lookup from disk ----
    componentLookup = buildComponentModelLookup(projectRoot);

    % ---- Map each SSR block to a component ----
    [componentGroups, controllerGroup, unmappedBlocks] = ...
        mapSSRToComponents(ssrBlocks, componentLookup);

    % ---- Print unmapped blocks (non-component SSRs) ----
    if ~isempty(unmappedBlocks)
        fprintf('\n  Skipped %d SSR blocks (not in Components/):\n', ...
            numel(unmappedBlocks));
        for idx = 1:numel(unmappedBlocks)
            fprintf('    - %s  [ref: %s]\n', ...
                unmappedBlocks(idx).BlockName, ...
                unmappedBlocks(idx).ReferencedModel);
        end
    end

    % ---- Build the config entry struct ----
    configEntry = buildConfigStruct( ...
        componentGroups, controllerGroup, ...
        options.Description, options.SystemParameter);

    % ---- Print summary ----
    printSummary(templateName, configEntry, componentGroups, controllerGroup);

    % ---- Write to file if requested ----
    if ~options.DryRun && options.ConfigFile ~= ""
        configFilePath = resolveConfigPath(options.ConfigFile, projectRoot);
        writeConfigEntry(configFilePath, templateName, configEntry);
    elseif options.DryRun
        fprintf('\n  DryRun = true. No file written.\n');
        fprintf('  Set DryRun=false and provide ConfigFile to write.\n');
    end

    fprintf('\n');
end

%% ========================================================================
%  Local helpers
%  ========================================================================

function projectRoot = resolveProjectRoot(rootOption)
% RESOLVEPROJECTROOT Get project root from option or MATLAB project.
    if rootOption ~= ""
        projectRoot = rootOption;
    else
        try
            proj = matlab.project.rootProject();
            projectRoot = string(proj.RootFolder);
        catch
            error('bevRegisterTemplate:NoProject', ...
                'MATLAB project not loaded. Provide ProjectRoot explicitly.');
        end
    end
end


function templateFile = resolveTemplatePath(templatePath, projectRoot)
% RESOLVETEMPLATEPATH Resolve template path to an absolute .slx path.
    candidatePath = templatePath;

    if ~isfile(candidatePath)
        candidatePath = fullfile(projectRoot, templatePath);
    end

    if ~isfile(candidatePath)
        error('bevRegisterTemplate:TemplateNotFound', ...
            'Template not found: %s', templatePath);
    end

    templateFile = string(candidatePath);
end


function ssrBlocks = scanTemplateSSRBlocks(templateFile)
% SCANTEMPLATESSR Blocks Load template and scan for subsystem references.
    [~, mdlName] = fileparts(templateFile);
    openedByUs = false;

    if ~bdIsLoaded(mdlName)
        warningState = warning('off', 'all');
        load_system(templateFile);
        warning(warningState);
        openedByUs = true;
    end

    cleanupObj = onCleanup(@() closeModelIfOpened(mdlName, openedByUs)); %#ok<NASGU>

    % ---- Fast scan: active variants only ----
    ssrPaths = find_system(mdlName, ...
        'LookUnderMasks',   'none', ...
        'FollowLinks',      'off', ...
        'IncludeCommented',  'off', ...
        'Regexp',           'on', ...
        'MatchFilter',      @Simulink.match.activeVariants, ...
        'BlockType',        'SubSystem', ...
        'ReferencedSubsystem', '.+');

    % ---- Fallback: heavy scan ----
    if isempty(ssrPaths)
        ssrPaths = find_system(mdlName, ...
            'LookUnderMasks',   'all', ...
            'FollowLinks',      'on', ...
            'IncludeCommented',  'on', ...
            'Regexp',           'on', ...
            'MatchFilter',      @Simulink.match.allVariants, ...
            'BlockType',        'SubSystem', ...
            'ReferencedSubsystem', '.+');
    end

    if isempty(ssrPaths)
        ssrBlocks = struct('Names', strings(0,1), 'RefModels', strings(0,1));
        return;
    end

    blockNames = string(get_param(ssrPaths, 'Name'));
    refSubsystems = string(get_param(ssrPaths, 'ReferencedSubsystem'));

    % ---- Extract model basenames from referenced paths ----
    refModelNames = strings(size(refSubsystems));
    for idx = 1:numel(refSubsystems)
        [~, refModelNames(idx)] = fileparts(char(refSubsystems(idx)));
    end

    ssrBlocks = struct( ...
        'Names',     blockNames(:), ...
        'RefModels', refModelNames(:));
end


function componentLookup = buildComponentModelLookup(projectRoot)
% BUILDCOMPONENTMODELLOOKUP Scan Components/ folders and map model names.
%   Returns a containers.Map: modelBasename -> struct with ComponentName,
%   ComponentFolder, and AllModels (all .slx basenames in that folder).

    componentsDir = fullfile(projectRoot, 'Components');
    componentFolders = dir(componentsDir);
    componentFolders = componentFolders([componentFolders.isdir]);
    componentFolders = componentFolders(~ismember({componentFolders.name}, {'.', '..'}));

    componentLookup = containers.Map('KeyType', 'char', 'ValueType', 'any');

    for idx = 1:numel(componentFolders)
        compName = componentFolders(idx).name;
        modelDir = fullfile(componentsDir, compName, 'Model');

        if ~isfolder(modelDir)
            continue;
        end

        slxFiles = dir(fullfile(modelDir, '*.slx'));
        modelBasenames = strings(numel(slxFiles), 1);

        for fileIdx = 1:numel(slxFiles)
            [~, modelBasenames(fileIdx)] = fileparts(slxFiles(fileIdx).name);
        end

        compInfo = struct( ...
            'ComponentName', string(compName), ...
            'ComponentFolder', string(modelDir), ...
            'AllModels', modelBasenames);

        for fileIdx = 1:numel(modelBasenames)
            lookupKey = lower(char(modelBasenames(fileIdx)));
            componentLookup(lookupKey) = compInfo;
        end
    end
end


function [componentGroups, controllerGroup, unmappedBlocks] = ...
        mapSSRToComponents(ssrBlocks, componentLookup)
% MAPSSRTOCOMPONENTS Map SSR blocks to component types.
%   Groups SSR blocks by component folder. Controller entries are
%   separated into controllerGroup. Unrecognized SSRs go to unmappedBlocks.

    componentGroups = containers.Map('KeyType', 'char', 'ValueType', 'any');
    controllerGroup = struct('Instances', {{}}, 'Models', {{}});
    unmappedBlocks  = struct('BlockName', {}, 'ReferencedModel', {});

    for idx = 1:numel(ssrBlocks.Names)
        blockName = ssrBlocks.Names(idx);
        refModel  = ssrBlocks.RefModels(idx);
        lookupKey = lower(char(refModel));

        if ~isKey(componentLookup, lookupKey)
            unmappedBlocks(end+1) = struct( ...
                'BlockName', blockName, ...
                'ReferencedModel', refModel); %#ok<AGROW>
            continue;
        end

        compInfo = componentLookup(lookupKey);
        compName = char(compInfo.ComponentName);

        % ---- Separate Controller into Controls section ----
        if strcmp(compName, 'Controller')
            controllerGroup.Instances{end+1} = char(blockName);
            controllerGroup.Models = cellstr(compInfo.AllModels);
            continue;
        end

        % ---- Group by component type ----
        if ~isKey(componentGroups, compName)
            componentGroups(compName) = struct( ...
                'Instances', {{}}, ...
                'Models', {cellstr(compInfo.AllModels)}, ...
                'CurrentRef', {{}});
        end

        group = componentGroups(compName);
        group.Instances{end+1} = char(blockName);
        group.CurrentRef{end+1} = char(refModel);
        componentGroups(compName) = group;
    end

    % ---- Deduplicate controller models ----
    if ~isempty(controllerGroup.Models)
        controllerGroup.Models = unique(controllerGroup.Models, 'stable');
    end
end


function configEntry = buildConfigStruct(componentGroups, controllerGroup, ...
        description, systemParameter)
% BUILDCONFIGSTRUCT Build the JSON-compatible config struct.

    configEntry = struct();

    if description ~= ""
        configEntry.Description = char(description);
    end

    % ---- Components section ----
    compStruct = struct();
    compNames = sort(componentGroups.keys);

    for idx = 1:numel(compNames)
        compName = compNames{idx};
        group = componentGroups(compName);

        compStruct.(compName) = struct( ...
            'Instances', {group.Instances}, ...
            'Models', {group.Models});
    end

    configEntry.Components = compStruct;

    % ---- Controls section (optional) ----
    if ~isempty(controllerGroup.Instances)
        configEntry.Controls = struct( ...
            'Instances', {controllerGroup.Instances}, ...
            'Models', {controllerGroup.Models});
    end

    % ---- SystemParameter (optional) ----
    configEntry.SystemParameter = cellstr(systemParameter);
end


function printSummary(templateName, configEntry, componentGroups, controllerGroup)
% PRINTSUMMARY Display a readable summary of the discovered config.
    fprintf('\n  ============================================\n');
    fprintf('  Template: %s\n', templateName);

    if isfield(configEntry, 'Description') && ~isempty(configEntry.Description)
        fprintf('  Description: %s\n', configEntry.Description);
    end

    fprintf('  ============================================\n');

    % ---- Components table ----
    fprintf('\n  %-20s %-30s %-s\n', 'Component', 'Instances', 'Available Models');
    fprintf('  %-20s %-30s %-s\n', ...
        '--------------------', '------------------------------', ...
        '-----------------------------');

    compNames = sort(componentGroups.keys);
    for idx = 1:numel(compNames)
        compName = compNames{idx};
        group = componentGroups(compName);

        instanceStr = strjoin(group.Instances, ', ');
        modelStr = strjoin(group.Models, ', ');

        fprintf('  %-20s %-30s %s\n', compName, instanceStr, modelStr);
    end

    % ---- Controls ----
    if ~isempty(controllerGroup.Instances)
        fprintf('\n  Controls:\n');
        fprintf('    Instances: %s\n', strjoin(controllerGroup.Instances, ', '));
        fprintf('    Models:    %s\n', strjoin(controllerGroup.Models, ', '));
    else
        fprintf('\n  Controls: (none detected — add manually if needed)\n');
    end

    % ---- SystemParameter ----
    if isfield(configEntry, 'SystemParameter')
        fprintf('  SystemParameter: %s\n', ...
            strjoin(string(configEntry.SystemParameter), ', '));
    end
end


function configFilePath = resolveConfigPath(configFile, projectRoot)
% RESOLVECONFIGPATH Resolve config file path to absolute.
    if isfile(configFile)
        configFilePath = configFile;
    elseif isfile(fullfile(projectRoot, configFile))
        configFilePath = fullfile(projectRoot, configFile);
    else
        configFilePath = configFile;
    end
end


function writeConfigEntry(configFilePath, templateName, configEntry)
% WRITECONFIGENTRY Append or create a config JSON file.

    templateKey = char(templateName);

    % ---- Load existing config or start fresh ----
    if isfile(configFilePath)
        existingJson = fileread(configFilePath);
        existingConfig = jsondecode(existingJson);

        if isfield(existingConfig, templateKey)
            fprintf('\n  WARNING: Template "%s" already exists in %s.\n', ...
                templateKey, configFilePath);
            response = input('  Overwrite? (y/n): ', 's');
            if ~strcmpi(response, 'y')
                fprintf('  Aborted. Config file not modified.\n');
                return;
            end
        end
    else
        existingConfig = struct();
        fprintf('\n  Creating new config file: %s\n', configFilePath);
    end

    % ---- Merge the new entry ----
    existingConfig.(templateKey) = configEntry;

    % ---- Fix single-element arrays lost during jsondecode round-trip ----
    existingConfig = fixJsonArrayFields(existingConfig);

    % ---- Write with readable formatting ----
    jsonText = jsonencode(existingConfig, PrettyPrint=true);
    [outputDir, ~, ~] = fileparts(configFilePath);

    if ~isfolder(outputDir)
        mkdir(outputDir);
    end

    fileID = fopen(configFilePath, 'w');
    if fileID == -1
        error('bevRegisterTemplate:WriteError', ...
            'Cannot write to %s', configFilePath);
    end

    cleanupFile = onCleanup(@() fclose(fileID));
    fprintf(fileID, '%s', jsonText);

    fprintf('  Written: %s\n', configFilePath);
    fprintf('  Template "%s" added to config.\n', templateKey);
end


function closeModelIfOpened(mdlName, openedByUs)
% CLOSEMODELIFOPENED Close the model only if we opened it.
    if openedByUs
        try
            close_system(mdlName, 0);
        catch
        end
    end
end


function cfg = fixJsonArrayFields(cfg)
% FIXJSONARRAYFIELDS Ensure Instances/Models/SystemParameter stay as arrays.
%   jsondecode converts single-element JSON arrays to scalar strings.
%   This restores them to cell arrays so jsonencode produces valid arrays.

    templateNames = fieldnames(cfg);

    for tIdx = 1:numel(templateNames)
        tmpl = cfg.(templateNames{tIdx});

        if ~isstruct(tmpl)
            continue;
        end

        % ---- Fix Components section ----
        if isfield(tmpl, 'Components') && isstruct(tmpl.Components)
            compNames = fieldnames(tmpl.Components);
            for cIdx = 1:numel(compNames)
                comp = tmpl.Components.(compNames{cIdx});
                if isfield(comp, 'Instances')
                    comp.Instances = ensureCellArray(comp.Instances);
                end
                if isfield(comp, 'Models')
                    comp.Models = ensureCellArray(comp.Models);
                end
                tmpl.Components.(compNames{cIdx}) = comp;
            end
        end

        % ---- Fix Controls section ----
        if isfield(tmpl, 'Controls') && isstruct(tmpl.Controls)
            if isfield(tmpl.Controls, 'Instances')
                tmpl.Controls.Instances = ensureCellArray(tmpl.Controls.Instances);
            end
            if isfield(tmpl.Controls, 'Models')
                tmpl.Controls.Models = ensureCellArray(tmpl.Controls.Models);
            end
        end

        % ---- Fix SystemParameter ----
        if isfield(tmpl, 'SystemParameter')
            tmpl.SystemParameter = ensureCellArray(tmpl.SystemParameter);
        end

        cfg.(templateNames{tIdx}) = tmpl;
    end
end


function val = ensureCellArray(val)
% ENSURECELLARRAY Convert scalar char/string to a cell array.
    if ischar(val)
        val = {val};
    elseif isstring(val) && isscalar(val)
        val = cellstr(val);
    end
end

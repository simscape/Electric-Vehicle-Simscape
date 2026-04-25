function configEntry = bevRegisterTemplate(templatePath, options)
% BEVREGISTERTEMPLATE Register a vehicle template by scanning its model.
%   configEntry = bevRegisterTemplate(templatePath)
%   configEntry = bevRegisterTemplate(templatePath, Name=Value)
%
%   Scans the template .slx for subsystem reference (SSR) blocks, maps
%   each referenced model to a component folder under Components/, groups
%   instances by component type, and builds a config JSON entry compatible
%   with VehicleTemplateConfig.json.
%
%   The config key is always the .slx model basename (e.g.,
%   VehicleThreeWheel.slx → "VehicleThreeWheel"). Different fidelity
%   presets for the same template go in separate config JSON files.
%
%   Inputs:
%     templatePath — path to the vehicle template .slx file
%
%   Name-Value Arguments:
%     Description     — short description string (default: "")
%     ConfigFile      — JSON filename or path to write to (default: dry run)
%     DryRun          — if true, print summary but do not write (default: true)
%     SystemParameter — system-level param file names (default: "NA")
%     ProjectRoot     — project root (default: auto-detect via MATLAB project)
%
%   Output:
%     configEntry — struct matching the VehicleTemplateConfig.json schema
%
%   Example:
%     entry = bevRegisterTemplate( ...
%         'Model/VehicleTemplate/VehicleThreeWheel.slx');
%
%     bevRegisterTemplate( ...
%         'Model/VehicleTemplate/VehicleThreeWheel.slx', ...
%         Description  = "Three-wheel electric vehicle", ...
%         ConfigFile   = "ThreeWheelConfig.json", ...
%         DryRun       = false);
%
% Copyright 2026 The MathWorks, Inc.

    arguments
        templatePath              (1,1) string
        options.Description       (1,1) string  = ""
        options.ConfigFile        (1,1) string  = ""
        options.DryRun            (1,1) logical = true
        options.SystemParameter   (1,:) string  = "NA"
        options.ProjectRoot       (1,1) string  = ""
    end

    % ---- Resolve project root ----
    if options.ProjectRoot ~= ""
        projectRoot = options.ProjectRoot;
    else
        projectRoot = string(getBEVProjectRoot());
    end

    % ---- Resolve template path and derive name ----
    templateFile = resolveTemplatePath(templatePath, projectRoot);
    [~, modelBasename] = fileparts(templateFile);
    templateName = string(modelBasename);

    % ---- Check existing preset configs ----
    printPresetStatus(templateName, projectRoot);

    % ---- Scan template model for SSR blocks ----
    fprintf('  Scanning template: %s\n', modelBasename);
    ssrBlocks = scanTemplateSSRBlocks(templateFile);

    if isempty(ssrBlocks.Names)
        fprintf('  No subsystem reference blocks found in %s.\n', modelBasename);
        configEntry = struct();
        return;
    end

    fprintf('  Found %d SSR blocks.\n', numel(ssrBlocks.Names));

    % ---- Map SSR blocks to component folders ----
    componentLookup = buildComponentModelLookup(projectRoot);
    [componentGroups, controllerGroup, unmappedBlocks] = ...
        mapSSRToComponents(ssrBlocks, componentLookup);

    % ---- Report unmapped blocks ----
    if ~isempty(unmappedBlocks)
        fprintf('\n  Skipped %d SSR blocks (not in Components/):\n', ...
            numel(unmappedBlocks));
        for idx = 1:numel(unmappedBlocks)
            fprintf('    - %s  [ref: %s]\n', ...
                unmappedBlocks(idx).BlockName, ...
                unmappedBlocks(idx).ReferencedModel);
        end
    end

    % ---- Build config entry ----
    configEntry = buildConfigStruct( ...
        componentGroups, controllerGroup, ...
        options.Description, options.SystemParameter);

    % ---- Print summary ----
    printSummary(templateName, configEntry, componentGroups, controllerGroup);

    % ---- Write to file ----
    if ~options.DryRun && options.ConfigFile ~= ""
        [existingConfig, configFilePath] = bevConfigRead( ...
            options.ConfigFile, projectRoot);

        templateKey = char(templateName);
        if isfield(existingConfig, templateKey)
            fprintf('\n  WARNING: Template "%s" already exists in config.\n', ...
                templateKey);
            response = input('  Overwrite? (y/n): ', 's');
            if ~strcmpi(response, 'y')
                fprintf('  Aborted.\n');
                return;
            end
        end

        existingConfig.(templateKey) = configEntry;

        % ---- Validate before writing ----
        validateVehicleConfig(existingConfig, templateKey);

        bevConfigWrite(existingConfig, configFilePath);
        fprintf('  Written: %s\n', configFilePath);
    elseif ~options.DryRun && options.ConfigFile == ""
        fprintf('\n  No file written. To write, specify ConfigFile:\n');
        fprintf('    bevRegisterTemplate("%s", ConfigFile = "<name>.json", DryRun = false)\n', ...
            templatePath);
    else
        fprintf('\n  DryRun = true. No file written.\n');
    end

    fprintf('\n');
end

%% ========================================================================
%  Local helpers — template-registration-specific
%  ========================================================================

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
% SCANTEMPLATESSRBLOCKS Load template and extract SSR block names and refs.
%   Uses shared scanForSSRBlocks from APP/API/Detect/.

    [~, mdlName] = fileparts(templateFile);
    openedByUs = false;

    if ~bdIsLoaded(mdlName)
        warningState = warning('off', 'all');
        load_system(templateFile);
        warning(warningState);
        openedByUs = true;
    end

    cleanupObj = onCleanup(@() closeIfOpened(mdlName, openedByUs)); %#ok<NASGU>

    % ---- Scan using shared utility ----
    ssrPaths = scanForSSRBlocks(mdlName);

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


function [componentGroups, controllerGroup, unmappedBlocks] = ...
        mapSSRToComponents(ssrBlocks, componentLookup)
% MAPSSRTOCOMPONENTS Group SSR blocks by component type.
%   Controller entries go to controllerGroup. Unrecognized go to unmappedBlocks.

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
            if ~ismember(char(refModel), controllerGroup.Models)
                controllerGroup.Models{end+1} = char(refModel);
            end
            continue;
        end

        % ---- Group by component type ----
        if ~isKey(componentGroups, compName)
            componentGroups(compName) = struct( ...
                'Instances', {{}}, ...
                'Models', {{}});
        end

        group = componentGroups(compName);
        group.Instances{end+1} = char(blockName);
        if ~ismember(char(refModel), group.Models)
            group.Models{end+1} = char(refModel);
        end
        componentGroups(compName) = group;
    end
end


function configEntry = buildConfigStruct(componentGroups, controllerGroup, ...
        description, systemParameter)
% BUILDCONFIGSTRUCT Build the JSON-compatible config struct.

    configEntry = struct();

    if description ~= ""
        configEntry.Description = char(description);
    end

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

    if ~isempty(controllerGroup.Instances)
        configEntry.Controls = struct( ...
            'Instances', {controllerGroup.Instances}, ...
            'Models', {controllerGroup.Models});
    end

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

    fprintf('\n  %-20s %-30s %-s\n', 'Component', 'Instances', 'Models');
    fprintf('  %-20s %-30s %-s\n', ...
        '--------------------', '------------------------------', ...
        '-----------------------------');

    compNames = sort(componentGroups.keys);
    for idx = 1:numel(compNames)
        compName = compNames{idx};
        group = componentGroups(compName);
        fprintf('  %-20s %-30s %s\n', compName, ...
            strjoin(group.Instances, ', '), strjoin(group.Models, ', '));
    end

    if ~isempty(controllerGroup.Instances)
        fprintf('\n  Controls:\n');
        fprintf('    Instances: %s\n', strjoin(controllerGroup.Instances, ', '));
        fprintf('    Models:    %s\n', strjoin(controllerGroup.Models, ', '));
    else
        fprintf('\n  Controls: (none detected)\n');
    end

    if isfield(configEntry, 'SystemParameter')
        fprintf('  SystemParameter: %s\n', ...
            strjoin(string(configEntry.SystemParameter), ', '));
    end
end


function printPresetStatus(templateName, projectRoot)
% PRINTPRESETSTATUS Scan all preset configs and report which contain this template.

    presetDir = fullfile(projectRoot, 'APP', 'Config', 'Preset');
    if ~isfolder(presetDir)
        return;
    end

    jsonFiles = dir(fullfile(presetDir, '*.json'));
    if isempty(jsonFiles)
        return;
    end

    templateKey = char(templateName);
    matchingPresets = {};

    for idx = 1:numel(jsonFiles)
        jsonPath = fullfile(presetDir, jsonFiles(idx).name);
        try
            rawCfg = jsondecode(fileread(jsonPath));
            if isfield(rawCfg, templateKey)
                matchingPresets{end+1} = jsonFiles(idx).name; %#ok<AGROW>
            end
        catch
            % ---- Skip malformed JSON files ----
        end
    end

    fprintf('\n');
    if isempty(matchingPresets)
        fprintf('  Preset status: "%s" not found in any preset config.\n', templateKey);
    else
        fprintf('  Preset status: "%s" already exists in:\n', templateKey);
        for idx = 1:numel(matchingPresets)
            fprintf('    - %s\n', matchingPresets{idx});
        end
    end

    fprintf('\n');
end


function closeIfOpened(mdlName, openedByUs)
% CLOSEIFOPENED Close the model only if we opened it.
    if openedByUs
        try
            close_system(mdlName, 0);
        catch
        end
    end
end

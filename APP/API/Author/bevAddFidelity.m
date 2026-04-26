function bevAddFidelity(configFile, templateName, componentName, modelName, options)
% BEVADDFIDELITY Add a model fidelity to an existing template config.
%   bevAddFidelity(configFile, templateName)
%   bevAddFidelity(configFile, templateName, componentName)
%   bevAddFidelity(configFile, templateName, componentName, modelName)
%   bevAddFidelity(..., Name=Value)
%
%   Progressive discovery: omit componentName to list components in the
%   template; omit modelName to list available models on disk for the
%   component. Provide all four to add a fidelity.
%
%   Optionally links a param file by creating a Selections section
%   (same structure the app writes when saving user setups).
%
%   Inputs:
%     configFile    — JSON filename (bare name resolves to APP/Config/Preset/)
%     templateName  — template key in config (e.g. "VehicleElectric")
%     componentName — component type; omit to list components (default: "")
%     modelName     — .slx model basename to add; omit to list models (default: "")
%
%   Name-Value Arguments:
%     ParamFile   — param file to link; creates Selections (default: "")
%     MakeDefault — true = make this model first in list (default: false)
%     DryRun      — true = preview only (default: true)
%     ProjectRoot — project root (default: auto-detect via MATLAB project)
%
%   Examples:
%     % List components in VehicleElectric
%     bevAddFidelity("VehicleTemplateConfig.json", "VehicleElectric")
%
%     % List available models for MotorDrive
%     bevAddFidelity("VehicleTemplateConfig.json", ...
%         "VehicleElectric", "MotorDrive")
%
%     % Add a fidelity with custom param file
%     bevAddFidelity("VehicleTemplateConfig.json", ...
%         "VehicleElectric", "MotorDrive", "MotorDriveGearTh", ...
%         ParamFile   = "ThreeWheelMotorParams.m", ...
%         MakeDefault = true, ...
%         DryRun      = false);
%
% Copyright 2026 The MathWorks, Inc.

    arguments
        configFile              (1,1) string
        templateName            (1,1) string
        componentName           (1,1) string  = ""
        modelName               (1,1) string  = ""
        options.ParamFile       (1,1) string  = ""
        options.MakeDefault     (1,1) logical = false
        options.DryRun          (1,1) logical = true
        options.ProjectRoot     (1,1) string  = ""
    end

    % ---- Resolve project root ----
    if options.ProjectRoot ~= ""
        projectRoot = options.ProjectRoot;
    else
        projectRoot = string(getBEVProjectRoot());
    end

    % ---- Read existing config ----
    [cfg, configFilePath] = bevConfigRead(configFile, projectRoot);

    % ---- Validate template exists ----
    templateKey = char(templateName);
    if ~isfield(cfg, templateKey)
        error('bevAddFidelity:TemplateNotFound', ...
            'Template "%s" not found in config.', templateKey);
    end

    templateData = cfg.(templateKey);

    % ---- Level 1: List components ----
    if componentName == ""
        printComponentList(templateName, templateData);
        return;
    end

    % ---- Validate component exists ----
    compKey = char(componentName);
    if ~isfield(templateData, 'Components') || ~isfield(templateData.Components, compKey)
        error('bevAddFidelity:ComponentNotFound', ...
            'Component "%s" not found in template "%s".', compKey, templateKey);
    end

    comp = templateData.Components.(compKey);

    % ---- Level 2: List available models ----
    if modelName == ""
        componentLookup = buildComponentModelLookup(projectRoot);
        printAvailableModels(templateName, componentName, comp, componentLookup);
        return;
    end

    % ---- Check if model already in list ----
    existingModels = comp.Models;
    if ischar(existingModels)
        existingModels = {existingModels};
    end

    isExisting = ismember(char(modelName), existingModels);

    % ---- Skip if duplicate with no modifications requested ----
    if isExisting && options.ParamFile == "" && ~options.MakeDefault
        fprintf('\n  Model "%s" is already in %s.%s.Models. No changes requested.\n\n', ...
            modelName, templateKey, compKey);
        return;
    end

    % ---- Validate model exists on disk ----
    componentLookup = buildComponentModelLookup(projectRoot);
    lookupKey = lower(char(modelName));

    if ~isKey(componentLookup, lookupKey)
        if ~options.DryRun
            error('bevAddFidelity:MissingModel', ...
                ['Model "%s" not found in any Components/*/Model/ folder.\n' ...
                 '  Place the model .slx file in the correct folder before adding it to config.'], ...
                modelName);
        end
        fprintf('\n  WARNING: Model "%s" not found in any Components/ folder.\n', modelName);
        fprintf('  This would block write mode.\n\n');
    end

    % ---- Add or reorder model in list ----
    if ~isExisting
        if options.MakeDefault
            comp.Models = [{char(modelName)}, existingModels(:)'];
        else
            comp.Models = [existingModels(:)', {char(modelName)}];
        end
    elseif options.MakeDefault
        remaining = existingModels(~strcmp(existingModels, char(modelName)));
        comp.Models = [{char(modelName)}, remaining(:)'];
    end

    % ---- Build Selections if ParamFile specified ----
    if options.ParamFile ~= ""
        comp = buildSelections(comp, modelName, options.ParamFile);
        validateParamFile(options.ParamFile, lookupKey, componentLookup, options.DryRun);
    end

    % ---- Update config struct ----
    templateData.Components.(compKey) = comp;
    cfg.(templateKey) = templateData;

    % ---- Print summary ----
    printFidelitySummary(templateName, componentName, modelName, ...
        comp.Models, options.ParamFile, options.MakeDefault, isExisting);

    % ---- Validate before writing ----
    validateVehicleConfig(cfg, templateKey);

    % ---- Write to file ----
    if ~options.DryRun
        bevConfigWrite(cfg, configFilePath);
        fprintf('  Written: %s\n', configFilePath);
    else
        fprintf('\n  DryRun = true. No file written.\n');
    end

    fprintf('\n');
end


%% ========================================================================
%  Local helpers
%  ========================================================================

function comp = buildSelections(comp, modelName, paramFile)
% BUILDSELECTIONS Create or update Selections entries for all instances.
%   Sets each instance to use the specified model and param file.
%   Uses matlab.lang.makeValidName for instance keys, matching the
%   app's convention in buildSetupState.

    instances = comp.Instances;
    if ischar(instances)
        instances = {instances};
    end

    if ~isfield(comp, 'Selections')
        comp.Selections = struct();
    end

    for idx = 1:numel(instances)
        instanceLabel = instances{idx};
        instanceKey = char(matlab.lang.makeValidName(instanceLabel));

        comp.Selections.(instanceKey) = struct( ...
            'Label',     instanceLabel, ...
            'Model',     char(modelName), ...
            'ParamFile', char(paramFile));
    end
end


function validateParamFile(paramFile, lookupKey, componentLookup, isDryRun)
% VALIDATEPARAMFILE Error or warn if the specified param file is not found on disk.

    if ~isKey(componentLookup, lookupKey)
        return;
    end

    compInfo = componentLookup(lookupKey);
    candidatePath = fullfile(char(compInfo.ComponentFolder), char(paramFile));

    if ~isfile(candidatePath)
        if ~isDryRun
            error('bevAddFidelity:MissingParamFile', ...
                ['Param file "%s" not found at:\n' ...
                 '  %s\n' ...
                 '  Create the file before adding it to config.'], ...
                paramFile, candidatePath);
        end
        fprintf('  WARNING: Param file "%s" not found at:\n', paramFile);
        fprintf('    %s\n', candidatePath);
        fprintf('  This would block write mode.\n\n');
    end
end


function printComponentList(templateName, templateData)
% PRINTCOMPONENTLIST List all components in a template with instances and models.

    fprintf('\n  Components in %s:\n', templateName);
    fprintf('  %-20s %-35s %s\n', 'Component', 'Instances', 'Models');
    fprintf('  %-20s %-35s %s\n', ...
        '--------------------', '-----------------------------------', ...
        '-----------------------------');

    if ~isfield(templateData, 'Components')
        fprintf('  (no components)\n\n');
        return;
    end

    compNames = fieldnames(templateData.Components);
    for idx = 1:numel(compNames)
        comp = templateData.Components.(compNames{idx});

        % ---- Format instance names ----
        instances = comp.Instances;
        if ischar(instances), instances = {instances}; end
        instanceStr = strjoin(instances, ', ');
        if strlength(instanceStr) > 33
            instanceStr = extractBefore(instanceStr, 31) + "...";
        end

        % ---- Format model names ----
        models = comp.Models;
        if ischar(models), models = {models}; end
        modelStr = strjoin(models, ', ');

        fprintf('  %-20s %-35s [%s]\n', compNames{idx}, instanceStr, modelStr);
    end

    fprintf('\n  Tip: bevAddFidelity(configFile, "%s", "<ComponentName>")\n', templateName);
    fprintf('       to see available models for a component.\n\n');
end


function printAvailableModels(templateName, componentName, comp, componentLookup)
% PRINTAVAILABLEMODELS List on-disk models for a component, marking config status.

    % ---- Show current config state ----
    instances = comp.Instances;
    if ischar(instances), instances = {instances}; end
    configModels = comp.Models;
    if ischar(configModels), configModels = {configModels}; end

    fprintf('\n  %s in %s:\n', componentName, templateName);
    fprintf('    Instances:      %s\n', strjoin(instances, ', '));
    fprintf('    Current Models: [%s]\n', strjoin(configModels, ', '));

    % ---- Find all models on disk for this component ----
    diskModels = findDiskModelsForComponent(componentName, componentLookup);

    if isempty(diskModels)
        fprintf('\n    No models found on disk for %s.\n\n', componentName);
        return;
    end

    fprintf('\n    Available on disk (Components/%s/Model/):\n', componentName);
    for idx = 1:numel(diskModels)
        mdlName = diskModels{idx};
        if ismember(mdlName, configModels)
            marker = 'in config';
        else
            marker = 'can add';
        end
        fprintf('      %-30s  %s\n', mdlName, marker);
    end

    fprintf('\n  Tip: bevAddFidelity(configFile, "%s", "%s", "<ModelName>")\n', ...
        templateName, componentName);
    fprintf('       to add a model fidelity.\n\n');
end


function diskModels = findDiskModelsForComponent(componentName, componentLookup)
% FINDDISKMODELSFORCOMPONENT Get all model basenames for a component type.
%   Scans the componentLookup for entries matching this component name.

    diskModels = {};
    allKeys = keys(componentLookup);

    for idx = 1:numel(allKeys)
        compInfo = componentLookup(allKeys{idx});
        if strcmp(char(compInfo.ComponentName), char(componentName))
            diskModels = cellstr(compInfo.AllModels);
            break;
        end
    end
end


function printFidelitySummary(templateName, componentName, modelName, ...
        modelList, paramFile, makeDefault, isExisting)
% PRINTFIDELITYSUMMARY Display summary of the fidelity addition or modification.

    if isExisting
        actionLabel = 'Modify Fidelity';
    else
        actionLabel = 'Add Fidelity';
    end

    fprintf('\n  ============================================\n');
    fprintf('  %s\n', actionLabel);
    fprintf('  ============================================\n');
    fprintf('  Template:  %s\n', templateName);
    fprintf('  Component: %s\n', componentName);
    fprintf('  Model:     %s\n', modelName);

    if makeDefault
        fprintf('  Position:  DEFAULT (first in list)\n');
    else
        fprintf('  Position:  appended\n');
    end

    fprintf('  Models:    %s\n', strjoin(string(modelList), ', '));

    if paramFile ~= ""
        fprintf('  ParamFile: %s\n', paramFile);
        fprintf('  Selections: updated for all instances\n');
    else
        fprintf('  ParamFile: (convention-based)\n');
    end
end

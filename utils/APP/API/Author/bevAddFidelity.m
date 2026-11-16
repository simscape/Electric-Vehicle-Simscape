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
%   Optionally links a param file by creating a ParamMap entry at the
%   component level, mapping the model name to the param filename.
%
%   Use ControlModel to add or update the Controls section (controller
%   instance defaults to "Controller"). Use SystemParameter to set
%   system-level parameter file names.
%
%   Inputs:
%     configFile    — JSON filename (bare name resolves to utils/APP/Config/Preset/)
%     templateName  — template key in config (e.g. "VehicleElectric")
%     componentName — component type; omit to list components (default: "")
%     modelName     — .slx model basename to add; omit to list models (default: "")
%
%   Name-Value Arguments:
%     ParamFile        — param file to link; creates ParamMap entry (default: "")
%     MakeDefault      — true = make this model first in list (default: false)
%     DryRun           — true = preview only (default: true)
%     ProjectRoot      — project root (default: auto-detect via MATLAB project)
%     ControlModel     — controller model basename to add to Controls section
%     ControlParamFile — param file for the Controls section
%     SystemParameter  — system-level parameter file names (string array)
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
%         DryRun      = false)
%
%     % Add controller model and param file
%     bevAddFidelity("VehicleTemplateConfig.json", ...
%         "VehicleElectric", ...
%         ControlModel     = "ControllerFRM", ...
%         ControlParamFile = "ControllerParams", ...
%         DryRun           = false)
%
%     % Set system parameter
%     bevAddFidelity("VehicleTemplateConfig.json", ...
%         "VehicleElectric", ...
%         SystemParameter = "BEVThermalParams", ...
%         DryRun          = false)
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
        options.ControlModel    (1,1) string  = ""
        options.ControlParamFile (1,1) string = ""
        options.SystemParameter (1,:) string  = strings(0)
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

    % ---- Handle Controls section ----
    hasControlChange = options.ControlModel ~= "" || options.ControlParamFile ~= "";
    hasSysParamChange = ~isempty(options.SystemParameter);

    if hasControlChange || hasSysParamChange
        templateData = applyControlAndSysParam(templateData, templateKey, ...
            options.ControlModel, options.ControlParamFile, ...
            options.SystemParameter, options.MakeDefault, projectRoot);
        cfg.(templateKey) = templateData;

        validateVehicleConfig(cfg, templateKey);

        if ~options.DryRun
            bevConfigWrite(cfg, configFilePath);
            fprintf('  Written: %s\n', configFilePath);
        else
            fprintf('\n  DryRun = true. No file written.\n');
        end
        fprintf('\n');

        % If no component work requested, we're done
        if componentName == ""
            return;
        end
        % Otherwise fall through to component handling below
        templateData = cfg.(templateKey);
    end

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

    % ---- Update ParamMap if ParamFile specified ----
    if options.ParamFile ~= ""
        normParamFile = normalizeParamFile(options.ParamFile, projectRoot);
        if ~isfield(comp, 'ParamMap')
            comp.ParamMap = struct();
        end
        comp.ParamMap.(char(modelName)) = char(normParamFile);
        validateParamFile(normParamFile, lookupKey, componentLookup, options.DryRun);
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

function validateParamFile(paramFile, lookupKey, componentLookup, isDryRun)
% VALIDATEPARAMFILE Error or warn if the specified param file is not found on disk.
%   Bare filenames are checked in the component Model folder.
%   Full paths (external) are checked directly.

    hasPathSep = strlength(fileparts(paramFile)) > 0;

    if hasPathSep
        % Full external path — validate directly
        candidatePath = char(paramFile);
    else
        % Bare filename — check in component Model folder
        if ~isKey(componentLookup, lookupKey)
            return;
        end
        compInfo = componentLookup(lookupKey);
        candidatePath = fullfile(char(compInfo.ComponentFolder), char(paramFile));
    end

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

    % ---- Show Controls section ----
    if isfield(templateData, 'Controls')
        ctrl = templateData.Controls;
        ctrlModels = ctrl.Models;
        if ischar(ctrlModels), ctrlModels = {ctrlModels}; end
        paramStr = '';
        if isfield(ctrl, 'ParamFile') && ~isempty(ctrl.ParamFile)
            paramStr = sprintf('  ParamFile: %s', ctrl.ParamFile);
        end
        fprintf('  %-20s %-35s [%s]%s\n', 'Controls', 'Controller', ...
            strjoin(ctrlModels, ', '), paramStr);
    else
        fprintf('  %-20s %-35s %s\n', 'Controls', '(not configured)', '');
    end

    % ---- Show SystemParameter ----
    if isfield(templateData, 'SystemParameter')
        sp = templateData.SystemParameter;
        if ischar(sp), sp = {sp}; end
        fprintf('\n  SystemParameter: %s\n', strjoin(sp, ', '));
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

    % Show param mappings if any
    if isfield(comp, 'ParamMap') && isstruct(comp.ParamMap)
        mapKeys = fieldnames(comp.ParamMap);
        if ~isempty(mapKeys)
            fprintf('    Param Mapping:\n');
            for mi = 1:numel(mapKeys)
                fprintf('      %-25s → %s\n', mapKeys{mi}, comp.ParamMap.(mapKeys{mi}));
            end
        end
    end

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
        fprintf('  ParamMap:   linked for model\n');
    else
        fprintf('  ParamFile: (convention-based)\n');
    end
end


function templateData = applyControlAndSysParam(templateData, templateKey, ...
        controlModel, controlParamFile, systemParameter, makeDefault, projectRoot)
% APPLYCONTROLANDSYSPARAM Add/update Controls section and SystemParameter.

    % Ensure Controls section exists if any control option is specified
    if (controlModel ~= "" || controlParamFile ~= "") ...
            && ~isfield(templateData, 'Controls')
        templateData.Controls = struct( ...
            'Instances', {{'Controller'}}, ...
            'Models', {{}});
    end

    % ---- Controls model ----
    if controlModel ~= ""
        existingModels = templateData.Controls.Models;
        if ischar(existingModels), existingModels = {existingModels}; end

        isExisting = ismember(char(controlModel), existingModels);

        if ~isExisting
            if makeDefault
                templateData.Controls.Models = [{char(controlModel)}, existingModels(:)'];
            else
                templateData.Controls.Models = [existingModels(:)', {char(controlModel)}];
            end
        elseif makeDefault
            remaining = existingModels(~strcmp(existingModels, char(controlModel)));
            templateData.Controls.Models = [{char(controlModel)}, remaining(:)'];
        end

        if isExisting
            fprintf('\n  Controls: model "%s" updated in %s\n', controlModel, templateKey);
        else
            fprintf('\n  Controls: model "%s" added to %s\n', controlModel, templateKey);
        end
        fprintf('    Instance: Controller\n');
        fprintf('    Models:   %s\n', strjoin(string(templateData.Controls.Models), ', '));
    end

    % ---- Controls.ParamFile ----
    if controlParamFile ~= ""
        templateData.Controls.ParamFile = char(controlParamFile);

        paramPath = fullfile(char(projectRoot), ...
            'Components', 'Controller', 'Model', char(controlParamFile));
        if ~contains(controlParamFile, '.')
            paramPath = [char(paramPath) '.m'];
        end
        if ~isfile(paramPath)
            fprintf('    WARNING: Param file not found: %s\n', paramPath);
        end
        fprintf('    ParamFile: %s\n', controlParamFile);
    end

    % ---- SystemParameter ----
    if ~isempty(systemParameter)
        templateData.SystemParameter = cellstr(systemParameter);
        fprintf('\n  SystemParameter: %s\n', strjoin(systemParameter, ', '));
    end
end


function paramFile = normalizeParamFile(paramFile, projectRoot)
% NORMALIZEPARAMFILE Normalize param file to bare name or full external path.
%   Relative paths        → strip to filename.
%   Absolute in-project   → strip to filename.
%   Absolute external     → keep full path.

    hasPathSep = strlength(fileparts(paramFile)) > 0;
    if ~hasPathSep
        return;
    end

    isAbsPath = ~isempty(regexp(paramFile, '^([/\\]|[A-Za-z]:)', 'once'));

    if ~isAbsPath
        % Relative path → strip to bare filename
        [~, baseName, ext] = fileparts(paramFile);
        paramFile = baseName + ext;
        return;
    end

    % Absolute path — check if inside project root
    normFile = lower(strrep(char(paramFile), '\', '/'));
    normRoot = lower(strrep(char(projectRoot), '\', '/'));
    if ~endsWith(normRoot, '/')
        normRoot = [normRoot '/'];
    end

    if startsWith(normFile, normRoot)
        % In-project → strip to bare filename
        [~, baseName, ext] = fileparts(paramFile);
        paramFile = baseName + ext;
    end
    % External → keep full path as-is
end

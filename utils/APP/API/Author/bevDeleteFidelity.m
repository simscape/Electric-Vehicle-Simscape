function bevDeleteFidelity(configFile, templateName, componentName, modelName, options)
% BEVDELETEFIDELITY Remove a model fidelity from a template config.
%   bevDeleteFidelity(configFile, templateName, componentName, modelName)
%   bevDeleteFidelity(..., Name=Value)
%
%   Removes the specified model from the component's Models list and cleans
%   up all related entries: ParamMap and Selections referencing that model.
%   If the component has no models left after removal, the entire component
%   entry is removed from the config.
%
%   Use componentName = "Controls" to delete a controller model from the
%   Controls section instead of from Components.
%
%   Inputs:
%     configFile    — JSON filename (bare name resolves to utils/APP/Config/Preset/)
%     templateName  — template key in config (e.g. "VehicleElectric")
%     componentName — component type (e.g. "MotorDrive") or "Controls"
%     modelName     — model basename to remove (e.g. "MotorDriveGearTh")
%
%   Name-Value Arguments:
%     DryRun      — true = preview only (default: true)
%     ProjectRoot — project root (default: auto-detect via MATLAB project)
%
%   Examples:
%     % Preview what would be removed
%     bevDeleteFidelity("VehicleTemplateConfig.json", ...
%         "VehicleElectric", "MotorDrive", "MotorDriveGear")
%
%     % Remove and write
%     bevDeleteFidelity("VehicleTemplateConfig.json", ...
%         "VehicleElectric", "MotorDrive", "MotorDriveGear", ...
%         DryRun = false)
%
% Copyright 2026 The MathWorks, Inc.

    arguments
        configFile              (1,1) string
        templateName            (1,1) string
        componentName           (1,1) string
        modelName               (1,1) string
        options.DryRun          (1,1) logical = true
        options.ProjectRoot     (1,1) string  = ""
    end

    % ---- Resolve project root ----
    if options.ProjectRoot ~= ""
        projectRoot = options.ProjectRoot;
    else
        projectRoot = string(getBEVProjectRoot());
    end

    % ---- Read config ----
    [cfg, configFilePath] = bevConfigRead(configFile, projectRoot);

    % ---- Validate template exists ----
    templateKey = char(templateName);
    if ~isfield(cfg, templateKey)
        error('bevDeleteFidelity:TemplateNotFound', ...
            'Template "%s" not found in config.', templateKey);
    end

    templateData = cfg.(templateKey);
    isControls = componentName == "Controls";

    % ---- Validate component exists ----
    if isControls
        if ~isfield(templateData, 'Controls') || ~isfield(templateData.Controls, 'Models')
            error('bevDeleteFidelity:ComponentNotFound', ...
                'Controls section not found in template "%s".', templateKey);
        end
        comp = templateData.Controls;
    else
        if ~isfield(templateData, 'Components') || ~isfield(templateData.Components, char(componentName))
            error('bevDeleteFidelity:ComponentNotFound', ...
                'Component "%s" not found in template "%s".', componentName, templateKey);
        end
        comp = templateData.Components.(char(componentName));
    end

    modelList = ensureCell(comp.Models);

    % ---- Validate model exists in list ----
    if ~ismember(char(modelName), modelList)
        error('bevDeleteFidelity:ModelNotFound', ...
            'Model "%s" not found in %s.%s.Models.', modelName, templateKey, componentName);
    end

    % ---- Print header ----
    fprintf('\n  ============================================\n');
    fprintf('  Delete Fidelity\n');
    fprintf('  ============================================\n');
    fprintf('  Config:    %s\n', configFilePath);
    fprintf('  Template:  %s\n', templateKey);
    fprintf('  Section:   %s\n', componentName);
    fprintf('  Model:     %s\n', modelName);

    % ---- Remove model from Models list ----
    survivingModels = setdiff(modelList, {char(modelName)}, 'stable');
    fprintf('\n    - %s.%s removed from Models\n', componentName, modelName);

    if isempty(survivingModels)
        if isControls
            fprintf('    * Controls removed entirely (no models left)\n');
            templateData = rmfield(templateData, 'Controls');
        else
            fprintf('    * %s removed entirely (no models left)\n', componentName);
            templateData.Components = rmfield(templateData.Components, char(componentName));
        end
    else
        comp.Models = survivingModels;

        % ---- Clean ParamMap ----
        if isfield(comp, 'ParamMap') && isstruct(comp.ParamMap)
            if isfield(comp.ParamMap, char(modelName))
                comp.ParamMap = rmfield(comp.ParamMap, char(modelName));
                fprintf('    - ParamMap.%s cleaned\n', modelName);
                if isempty(fieldnames(comp.ParamMap))
                    comp = rmfield(comp, 'ParamMap');
                    fprintf('    - ParamMap removed (empty)\n');
                end
            end
        end

        % ---- Clean Selections ----
        if isfield(comp, 'Selections') && isstruct(comp.Selections)
            selKeys = fieldnames(comp.Selections);
            for sIdx = 1:numel(selKeys)
                sel = comp.Selections.(selKeys{sIdx});
                if isfield(sel, 'Model') && strcmp(sel.Model, char(modelName))
                    comp.Selections = rmfield(comp.Selections, selKeys{sIdx});
                    fprintf('    - Selections.%s cleaned (referenced %s)\n', ...
                        selKeys{sIdx}, modelName);
                end
            end
            if isfield(comp, 'Selections') && isempty(fieldnames(comp.Selections))
                comp = rmfield(comp, 'Selections');
                fprintf('    - Selections removed (empty)\n');
            end
        end

        if isControls
            templateData.Controls = comp;
        else
            templateData.Components.(char(componentName)) = comp;
        end
    end

    cfg.(templateKey) = templateData;

    % ---- Print remaining state ----
    if isControls && isfield(templateData, 'Controls')
        remaining = ensureCell(templateData.Controls.Models);
        fprintf('\n  Remaining models: [%s]\n', strjoin(remaining, ', '));
    elseif ~isControls && isfield(templateData.Components, char(componentName))
        remaining = ensureCell(templateData.Components.(char(componentName)).Models);
        fprintf('\n  Remaining models: [%s]\n', strjoin(remaining, ', '));
    end

    % ---- Write or skip ----
    if ~options.DryRun
        validateVehicleConfig(cfg, templateKey);
        bevConfigWrite(cfg, configFilePath);
        fprintf('\n  Written: %s\n\n', configFilePath);
    else
        fprintf('\n  DryRun = true. No file written.\n\n');
    end
end


function cellArr = ensureCell(value)
% ENSURECELL Convert char or string to cell array if needed.

    if ischar(value)
        cellArr = {value};
    elseif isstring(value)
        cellArr = cellstr(value);
    else
        cellArr = value;
    end
end

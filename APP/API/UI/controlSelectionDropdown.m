function controlSelectionDropdown(app, rawCfg)
%CONTROLSELECTIONDROPDOWN Populate controller dropdown from config and model detection.
%   controlSelectionDropdown(app)
%   controlSelectionDropdown(app, rawCfg)

    if nargin < 2
        rawCfg = jsondecode(fileread(app.ConfigDropDown.Value));
    end

    root = getBEVProjectRoot(app);
    vehicleConfig = erase(app.VehicleTemplateDropDown.Value, ".slx");

    app.ControlSelectionDropDown.Enable = "on";
    app.ControlDesc.Enable = "on";

    % ---- Controller detection from BEV model SSRs ----
    if ~controlsDetectFromBEVModel(app, root)
        app.ControlSelectionDropDown.Enable = "off";
        app.ControlDesc.Enable = "off";
        return;
    end

    % ---- Read control models from config JSON ----
    if ~isfield(rawCfg, vehicleConfig) ...
            || ~isfield(rawCfg.(vehicleConfig), 'Controls') ...
            || ~isfield(rawCfg.(vehicleConfig).Controls, 'Models')
        uialert(app.UIFigure, ...
            "No control model found in the design scenario", "Error");
        app.ControlSelectionDropDown.Enable = "off";
        app.ControlDesc.Enable = "off";
        return;
    end
    configControlModels = rawCfg.(vehicleConfig).Controls.Models;

    % ---- Cross-reference config models with detected models ----
    detectedItems = app.ControlSelectionDropDown.Items;
    configModelsSlx = ensureSlxList(configControlModels);

    validModels   = intersect(configModelsSlx, detectedItems, 'stable');
    missingModels = setdiff(configModelsSlx, detectedItems, 'stable');

    if isempty(validModels)
        app.ControlSelectionDropDown.Items = {'No controls available'};
        uialert(app.UIFigure, ...
            "No matching control model found in the controller folder and design scenario.", ...
            "Error");
        app.ControlSelectionDropDown.Enable = "off";
        app.ControlDesc.Enable = "off";
        return;
    end

    % Set dropdown to valid items only
    app.ControlSelectionDropDown.Items = cellfun(@char, validModels, 'UniformOutput', false);

    % Select the config-specified model if it's in the list
    configTarget = ensureSlxList(configControlModels);
    matchIdx = find(strcmp(app.ControlSelectionDropDown.Items, configTarget), 1);
    if ~isempty(matchIdx)
        app.ControlSelectionDropDown.Value = app.ControlSelectionDropDown.Items{matchIdx};
    end

    % Warn about any missing models
    if ~isempty(missingModels)
        uialert(app.UIFigure, ...
            "No matching control model found in the controller folder and design scenario.", ...
            "Error");
    end
end

function state = buildSetupState(app)
%BUILDSETUPSTATE Snapshot the current app UI state into a hierarchical struct.
%   state = buildSetupState(app)
%
%   Reads all user selections from the BEV app and returns a
%   JSON-serializable struct that mirrors the config JSON structure
%   but captures what the user SELECTED (not what's available).
%
%   Output structure (as JSON):
%     { "<TemplateName>": {
%         "BEVModel":    "BEVsystemModel",
%         "ConfigFile":  "path/to/config.json",
%         "SchemaVersion": "1.0",
%         "Timestamp":   "2026-04-16 14:00:00",
%         "Components": {
%           "MotorDrive": {
%             "Instances": {...},
%             "Selections": {
%               "FrontMotor_EM1_": { "Model": "...", "ParamFile": "..." }
%             }
%           }, ...
%         },
%         "Controls":     { "Model": "Controller" },
%         "DriveCycle":   "FTP75",
%         "Environment":  { "AmbientTemp": 25, ... },
%         "SystemParameter": ["BEVThermalParams"]
%       }
%     }
%
%   The struct contains NO handle objects, NO function handles —
%   only strings, doubles, logicals, and struct arrays.

    % ---- Core identifiers ----
    configFile = safeValue(app, 'ConfigDropDown', '');
    [~, bevModel]  = fileparts(safeValue(app, 'BEVModelDropDown', ''));
    [~, template]  = fileparts(safeValue(app, 'VehicleTemplateDropDown', ''));

    try
        root = char(matlab.project.rootProject.RootFolder);
    catch
        root = pwd;
    end

    % ---- Build the template-level struct ----
    setupState = struct();
    setupState.SchemaVersion = '1.0';
    setupState.Timestamp     = char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss'));
    setupState.BEVModel      = bevModel;
    setupState.ConfigFile    = configFile;
    setupState.Root          = root;

    % ---- Components (hierarchical: Component > Instance > Selection) ----
    setupState.Components = buildComponentsHierarchy(app);

    % ---- Controls ----
    controlState = struct('Enabled', false, 'Model', '');

    if isprop(app, 'ControlSelectionDropDown')
        controlState.Enabled = (app.ControlSelectionDropDown.Enable == "on");
        if controlState.Enabled
            controlState.Model = erase(char(app.ControlSelectionDropDown.Value), '.slx');
        end
        items = app.ControlSelectionDropDown.Items;
        controlState.Models = cellfun( ...
            @(x) erase(char(x), '.slx'), items, 'UniformOutput', false);
    end

    setupState.Controls = controlState;

    % ---- Drive cycle ----
    driveCycleState = struct('Enabled', false, 'Value', '');

    if isprop(app, 'DriveCycleDropDown')
        driveCycleState.Enabled = (app.DriveCycleDropDown.Enable == "on");
        if driveCycleState.Enabled
            driveCycleState.Value = char(app.DriveCycleDropDown.Value);
        end
    end

    setupState.DriveCycle = driveCycleState;

    % ---- Environment ----
    environment = struct();
    environment.AmbientTemp   = safeNumericValue(app, 'AmbTempEditField',           25);
    environment.CabinSetpoint = safeNumericValue(app, 'CabinTempSetpointEditField', 20);
    environment.AmbPressure   = safeNumericValue(app, 'AmbPressInitEditField',      1);
    environment.RelHumidity   = safeNumericValue(app, 'RelHumidityInitEditField',   0.5);
    environment.CO2Fraction   = safeNumericValue(app, 'CO2FractionInitialEditField', 0.0004);

    setupState.Environment = environment;

    % ---- Dashboard buttons ----
    dashboard = struct();
    dashboard.ACEnabled = safeLogicalProp(app, 'ACButton',       'Enable', false);
    dashboard.ACOn      = safeLogicalProp(app, 'ACButton',       'Value',  false);
    dashboard.AWD       = safeLogicalProp(app, 'AWDButton',      'Value',  false);
    dashboard.Regen     = safeLogicalProp(app, 'RegenButton',    'Value',  false);
    dashboard.Charging  = safeLogicalProp(app, 'ChargingButton', 'Value',  false);

    setupState.Dashboard = dashboard;

    % ---- System parameters (from JSON config) ----
    setupState.SystemParameter = {'NA'};
    try
        rawCfg   = jsondecode(fileread(configFile));
        sysParam = rawCfg.(template).SystemParameter;
        if iscell(sysParam), sysParam = string(sysParam); end
        sysParam = sysParam(strlength(sysParam) > 0);
        if ~isempty(sysParam)
            setupState.SystemParameter = cellstr(sysParam);
        end
    catch ME
        warning('BEVapp:buildSetupState', ...
            'Could not read SystemParameter from config: %s', ME.message);
    end

    % ---- Wrap under template name as top-level key ----
    if ~isempty(template) && isvarname(template)
        state.(template) = setupState;
    else
        state.Setup = setupState;
    end
end

%% Local helpers

function val = safeValue(app, propName, default)
%SAFEVALUE Read a dropdown/field Value, return default if widget missing.
    val = default;
    if isprop(app, propName)
        v = app.(propName).Value;
        if ~isempty(v)
            val = char(v);
        end
    end
end

function val = safeNumericValue(app, propName, default)
%SAFENUMERICVALUE Read a numeric edit field Value, return default if missing.
    val = default;
    if isprop(app, propName)
        val = double(app.(propName).Value);
    end
end

function val = safeLogicalProp(app, propName, field, default)
%SAFELOGICALPROP Read a logical property (Value or Enable) from a widget.
    val = default;
    if isprop(app, propName)
        if strcmp(field, 'Enable')
            val = (app.(propName).Enable == "on");
        else
            val = logical(app.(propName).Value);
        end
    end
end

function components = buildComponentsHierarchy(app)
%BUILDCOMPONENTSHIERARCHY Group component dropdowns by type, then by instance.
%   Returns a struct like:
%     components.MotorDrive.Instances    = {'Front Motor (EM1)', ...}
%     components.MotorDrive.Models       = {'MotorDriveGearTh', ...}
%     components.MotorDrive.Selections.FrontMotor_EM1_.Model = 'MotorDriveGearTh'
%
%   Also preserves Instances (name list) and Models (available list) from
%   dropdown Items so the output is a superset of the raw config JSON.
    components = struct();

    if ~isprop(app, 'ComponentDropdowns') || ~isstruct(app.ComponentDropdowns)
        return;
    end

    keys = fieldnames(app.ComponentDropdowns);

    for k = 1:numel(keys)
        dropdown = app.ComponentDropdowns.(keys{k});

        % Identify which component type and instance this dropdown represents
        compType  = safeUserData(dropdown, 'InstanceComp',  '');
        instLabel = safeUserData(dropdown, 'InstanceLabel', '');
        if isempty(compType), continue; end

        % Selected model (prefer LastValidValue over current Value)
        selectedModel = safeUserData(dropdown, 'LastValidValue', '');
        if isempty(selectedModel)
            selectedModel = char(dropdown.Value);
        end
        selectedModel = erase(char(selectedModel), '.slx');

        % Param file and model folder from UserData
        paramFile   = safeUserData(dropdown, 'ParamFile', '');
        modelFolder = safeUserData(dropdown, 'ModelFolder', '');

        % Build selection entry for this instance
        selEntry = struct( ...
            'Label',       instLabel, ...
            'Model',       selectedModel, ...
            'ParamFile',   paramFile, ...
            'ModelFolder', modelFolder);

        % Safe field name for JSON serialization
        instKey = matlab.lang.makeValidName(instLabel);

        % Ensure component type exists with Selections sub-struct
        if ~isfield(components, compType)
            components.(compType) = struct('Selections', struct());
        end

        % Collect instance names (for Instances array in output)
        if ~isfield(components.(compType), 'InstanceNames')
            components.(compType).InstanceNames = {};
        end
        components.(compType).InstanceNames{end+1} = instLabel;

        % Collect available models from dropdown Items (once per type)
        if ~isfield(components.(compType), 'Models')
            items  = dropdown.Items;
            models = cellfun(@(x) erase(char(x), '.slx'), items, 'UniformOutput', false);
            models = models(~startsWith(models, '__MISSING__'));
            components.(compType).Models = models;
        end

        % Store selection
        components.(compType).Selections.(instKey) = selEntry;
    end

    % Convert InstanceNames to Instances for JSON compat
    compTypes = fieldnames(components);
    for c = 1:numel(compTypes)
        ct = components.(compTypes{c});
        if isfield(ct, 'InstanceNames')
            ct.Instances = ct.InstanceNames;
            ct = rmfield(ct, 'InstanceNames');
            components.(compTypes{c}) = ct;
        end
    end
end

function val = safeUserData(dropdown, fieldName, default)
%SAFEUSERDATA Read a field from dropdown.UserData, return default if missing.
    val = default;
    if isstruct(dropdown.UserData) && isfield(dropdown.UserData, fieldName)
        v = dropdown.UserData.(fieldName);
        if ~isempty(v)
            val = char(v);
        end
    end
end

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
%             "Instances": {
%               "Front Motor (EM1)": { "Model": "MotorDriveGearTh", "ParamFile": "..." },
%               "Rear Motor (EM2)":  { "Model": "MotorDriveGearTh", "ParamFile": "..." }
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
    tmpl = struct();
    tmpl.SchemaVersion = '1.0';
    tmpl.Timestamp     = char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
    tmpl.BEVModel      = bevModel;
    tmpl.ConfigFile    = configFile;
    tmpl.Root          = root;

    % ---- Components (hierarchical: Component → Instance → Selection) ----
    tmpl.Components = buildComponentsHierarchy(app);

    % ---- Controls ----
    tmpl.Controls = struct('Enabled', false, 'Model', '');
    if isprop(app, 'ControlSelectionDropDown')
        tmpl.Controls.Enabled = (app.ControlSelectionDropDown.Enable == "on");
        if tmpl.Controls.Enabled
            tmpl.Controls.Model = erase(char(app.ControlSelectionDropDown.Value), '.slx');
        end
        items = app.ControlSelectionDropDown.Items;
        tmpl.Controls.Models = cellfun(@(x) erase(char(x), '.slx'), ...
            items, 'UniformOutput', false);
    end

    % ---- Drive cycle ----
    tmpl.DriveCycle = struct('Enabled', false, 'Value', '');
    if isprop(app, 'DriveCycleDropDown')
        tmpl.DriveCycle.Enabled = (app.DriveCycleDropDown.Enable == "on");
        if tmpl.DriveCycle.Enabled
            tmpl.DriveCycle.Value = char(app.DriveCycleDropDown.Value);
        end
    end

    % ---- Environment ----
    env = struct();
    env.AmbientTemp   = safeNumericValue(app, 'AmbTempEditField',           25);
    env.CabinSetpoint = safeNumericValue(app, 'CabinTempSetpointEditField', 20);
    env.AmbPressure   = safeNumericValue(app, 'AmbPressInitEditField',      1);
    env.RelHumidity   = safeNumericValue(app, 'RelHumidityInitEditField',   0.5);
    env.CO2Fraction   = safeNumericValue(app, 'CO2FractionInitialEditField', 0.0004);
    tmpl.Environment = env;

    % ---- Dashboard buttons ----
    dash = struct();
    dash.ACEnabled  = safeLogicalProp(app, 'ACButton',       'Enable', false);
    dash.ACOn       = safeLogicalProp(app, 'ACButton',       'Value',  false);
    dash.AWD        = safeLogicalProp(app, 'AWDButton',      'Value',  false);
    dash.Regen      = safeLogicalProp(app, 'RegenButton',    'Value',  false);
    dash.Charging   = safeLogicalProp(app, 'ChargingButton', 'Value',  false);
    tmpl.Dashboard = dash;

    % ---- System parameters (from JSON config) ----
    tmpl.SystemParameter = {'NA'};
    try
        rawCfg   = jsondecode(fileread(configFile));
        sysParam = rawCfg.(template).SystemParameter;
        if iscell(sysParam), sysParam = string(sysParam); end
        sysParam = sysParam(strlength(sysParam) > 0);
        if ~isempty(sysParam)
            tmpl.SystemParameter = cellstr(sysParam);
        end
    catch ME
        warning('BEVapp:buildSetupState', ...
            'Could not read SystemParameter from config: %s', ME.message);
    end

    % ---- Wrap under template name as top-level key ----
    if ~isempty(template) && isvarname(template)
        state.(template) = tmpl;
    else
        state.Setup = tmpl;
    end
end

%% Local helpers

function val = safeValue(app, propName, default)
%SAFEVALUE Read a dropdown/field Value, return default on failure.
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

function comps = buildComponentsHierarchy(app)
%BUILDCOMPONENTSHIERARCHY Group component dropdowns by type, then by instance.
%   Returns a struct like:
%     comps.MotorDrive.Selections.FrontMotor_EM1_.Model = 'MotorDriveGearTh'
%     comps.MotorDrive.Selections.FrontMotor_EM1_.ParamFile = '...'
%   Also preserves Instances (name list) and Models (available list) from
%   dropdown Items so the output is a superset of the raw config JSON.
    comps = struct();
    if ~isprop(app, 'ComponentDropdowns') || ~isstruct(app.ComponentDropdowns)
        return;
    end

    keys = fieldnames(app.ComponentDropdowns);
    for k = 1:numel(keys)
        dd = app.ComponentDropdowns.(keys{k});

        compType  = safeUserData(dd, 'InstanceComp',  '');
        instLabel = safeUserData(dd, 'InstanceLabel', '');
        if isempty(compType), continue; end

        % Selected model
        sel = safeUserData(dd, 'LastValidValue', '');
        if isempty(sel)
            sel = char(dd.Value);
        end
        sel = erase(char(sel), '.slx');

        % Param file
        paramFile = safeUserData(dd, 'ParamFile', '');

        % Model folder
        modelFolder = safeUserData(dd, 'ModelFolder', '');

        % Build selection entry
        selEntry = struct();
        selEntry.Label      = instLabel;   % original name (for Simulink block paths)
        selEntry.Model      = sel;
        selEntry.ParamFile  = paramFile;
        selEntry.ModelFolder = modelFolder;

        % Make safe field name for the instance
        instKey = matlab.lang.makeValidName(instLabel);

        % Ensure component type exists with Selections sub-struct
        if ~isfield(comps, compType)
            comps.(compType) = struct('Selections', struct());
        end

        % Collect instance name (for Instances array)
        if ~isfield(comps.(compType), 'InstanceNames')
            comps.(compType).InstanceNames = {};
        end
        comps.(compType).InstanceNames{end+1} = instLabel;

        % Collect available models from dropdown Items (for Models array)
        if ~isfield(comps.(compType), 'Models')
            items = dd.Items;
            models = cellfun(@(x) erase(char(x), '.slx'), items, 'UniformOutput', false);
            % Filter out __MISSING__ entries
            models = models(~startsWith(models, '__MISSING__'));
            comps.(compType).Models = models;
        end

        % Add selection under component
        comps.(compType).Selections.(instKey) = selEntry;
    end

    % Convert InstanceNames to Instances for JSON compat
    compTypes = fieldnames(comps);
    for c = 1:numel(compTypes)
        if isfield(comps.(compTypes{c}), 'InstanceNames')
            comps.(compTypes{c}).Instances = comps.(compTypes{c}).InstanceNames;
            comps.(compTypes{c}) = rmfield(comps.(compTypes{c}), 'InstanceNames');
        end
    end
end

function val = safeUserData(dd, fieldName, default)
%SAFEUSERDATA Read a field from dd.UserData, return default on failure.
    val = default;
    if isstruct(dd.UserData) && isfield(dd.UserData, fieldName)
        v = dd.UserData.(fieldName);
        if ~isempty(v)
            val = char(v);
        end
    end
end

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

    root = '';
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
    try, tmpl.Controls.Enabled = (app.ControlSelectionDropDown.Enable == "on"); catch, end
    try
        if tmpl.Controls.Enabled
            tmpl.Controls.Model = erase(char(app.ControlSelectionDropDown.Value), '.slx');
        end
        % Include available models from dropdown Items (superset of raw config)
        items = app.ControlSelectionDropDown.Items;
        tmpl.Controls.Models = cellfun(@(x) erase(char(x), '.slx'), items, 'UniformOutput', false);
    catch
    end

    % ---- Drive cycle ----
    tmpl.DriveCycle = struct('Enabled', false, 'Value', '');
    try, tmpl.DriveCycle.Enabled = (app.DriveCycleDropDown.Enable == "on"); catch, end
    try
        if tmpl.DriveCycle.Enabled
            tmpl.DriveCycle.Value = char(app.DriveCycleDropDown.Value);
        end
    catch
    end

    % ---- Environment ----
    env = struct();
    env.AmbientTemp   = 25;
    env.CabinSetpoint = 20;
    env.AmbPressure   = 1;
    env.RelHumidity   = 0.5;
    env.CO2Fraction   = 0.0004;

    try, env.AmbientTemp   = double(app.AmbTempEditField.Value);               catch, end
    try, env.CabinSetpoint = double(app.CabinTempSetpointEditField.Value);     catch, end
    try, env.AmbPressure   = double(app.AmbPressInitEditField.Value);           catch, end
    try, env.RelHumidity   = double(app.RelHumidityInitEditField.Value);       catch, end
    try, env.CO2Fraction   = double(app.CO2FractionInitialEditField.Value);    catch, end

    tmpl.Environment = env;

    % ---- Dashboard buttons ----
    dash = struct();
    dash.ACEnabled  = false;
    dash.ACOn       = false;
    dash.AWD        = false;
    dash.Regen      = false;
    dash.Charging   = false;

    try, dash.ACEnabled  = (app.ACButton.Enable == "on");     catch, end
    try, dash.ACOn       = logical(app.ACButton.Value);       catch, end
    try, dash.AWD        = logical(app.AWDButton.Value);      catch, end
    try, dash.Regen      = logical(app.RegenButton.Value);    catch, end
    try, dash.Charging   = logical(app.ChargingButton.Value); catch, end

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
    catch
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
    try
        if isprop(app, propName)
            v = app.(propName).Value;
            if ~isempty(v)
                val = char(v);
            end
        end
    catch
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
    try
        if ~isstruct(app.ComponentDropdowns), return; end
    catch
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
            try, sel = char(dd.Value); catch, end
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
            try
                items = dd.Items;
                models = cellfun(@(x) erase(char(x), '.slx'), items, 'UniformOutput', false);
                % Filter out __MISSING__ entries
                models = models(~startsWith(models, '__MISSING__'));
                comps.(compType).Models = models;
            catch
                comps.(compType).Models = {};
            end
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
    try
        if isstruct(dd.UserData) && isfield(dd.UserData, fieldName)
            v = dd.UserData.(fieldName);
            if ~isempty(v)
                val = char(v);
            end
        end
    catch
    end
end

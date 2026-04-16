function applySelections(app, tmpl)
%APPLYSELECTIONS Set dropdown values, edit fields, and buttons on existing UI.
%   applySelections(app, tmpl)
%
%   Does NOT rebuild the UI — assumes dropdowns already have correct Items.
%   Used by applySetupState (after rebuild) and restoreFromCache (no rebuild).
%
%   Inputs:
%     app  — BEVapp handle
%     tmpl — template-level struct (e.g. state.VehicleElectroThermal)

    % ---- Control selection ----
    if isfield(tmpl, 'Controls') && isfield(tmpl.Controls, 'Model')
        controlModel = char(tmpl.Controls.Model);
        if ~isempty(controlModel)
            trySetDropdownValue(app.ControlSelectionDropDown, controlModel, '.slx');
        end
    end

    % ---- Drive cycle ----
    if isfield(tmpl, 'DriveCycle')
        if isstruct(tmpl.DriveCycle) && isfield(tmpl.DriveCycle, 'Value')
            dcVal = char(tmpl.DriveCycle.Value);
        else
            dcVal = char(tmpl.DriveCycle);  % backward compat with old cache files
        end
        if ~isempty(dcVal)
            trySetDropdownValue(app.DriveCycleDropDown, dcVal, '');
        end
    end

    % ---- Environment fields ----
    if isfield(tmpl, 'Environment')
        env = tmpl.Environment;
        trySetField(app, 'AmbTempEditField',           env, 'AmbientTemp');
        trySetField(app, 'CabinTempSetpointEditField',  env, 'CabinSetpoint');
        trySetField(app, 'AmbPressInitEditField',        env, 'AmbPressure');
        trySetField(app, 'RelHumidityInitEditField',    env, 'RelHumidity');
        trySetField(app, 'CO2FractionInitialEditField', env, 'CO2Fraction');
    end

    % ---- Operating mode buttons (two-pass: set all values, then trigger callbacks) ----
    %   Callbacks may have cross-dependencies (e.g. Charging can affect AWD).
    %   Setting all values first ensures each callback sees the final state.
    if isfield(tmpl, 'OperatingModes')
        dash = tmpl.OperatingModes;
        btnMap = { 'ACButton','ACOn'; 'AWDButton','AWD'; ...
                   'RegenButton','Regen'; 'ChargingButton','Charging' };

        % Pass 1: set .Value only
        for b = 1:size(btnMap,1)
            setButtonValue(app, btnMap{b,1}, dash, btnMap{b,2});
        end
        % Pass 2: trigger callbacks for visual update
        for b = 1:size(btnMap,1)
            fireButtonCallback(app, btnMap{b,1});
        end
    end

    % ---- Component dropdowns ----
    if isfield(tmpl, 'Components')
        applyComponentSelections(app, tmpl.Components);
    end
end

%% Local helpers

function changed = trySetDropdownValue(dd, targetBase, ext)
%TRYSETDROPDOWNVALUE Match targetBase against dropdown ItemsData and set Value.
    changed = false;
    oldVal = dd.Value;

    target = char(targetBase);
    targetWithExt = target;
    if ~isempty(ext) && ~endsWith(target, ext, 'IgnoreCase', true)
        targetWithExt = [target ext];
    end
    targetBare = regexprep(target, '\.(slx|mdl)$', '', 'ignorecase');

    if ~isempty(dd.ItemsData)
        data = string(dd.ItemsData);
    else
        data = string(dd.Items);
    end

    idx = find(data == string(targetWithExt), 1);
    if isempty(idx), idx = find(data == string(targetBare), 1); end
    if isempty(idx), idx = find(strcmpi(data, targetWithExt), 1); end
    if isempty(idx), idx = find(strcmpi(data, targetBare), 1); end

    if ~isempty(idx) && ~startsWith(data(idx), "__MISSING__")
        if ~isempty(dd.ItemsData)
            dd.Value = dd.ItemsData{idx};
        else
            dd.Value = dd.Items{idx};
        end
        changed = ~isequal(oldVal, dd.Value);
        if isstruct(dd.UserData)
            dd.UserData.LastValidValue = dd.Value;
        end
    end
end

function trySetField(app, propName, source, sourceField)
%TRYSETFIELD Set an edit field Value from a source struct field.
    if ~isfield(source, sourceField), return; end
    if ~isprop(app, propName), return; end
    try
        app.(propName).Value = double(source.(sourceField));
    catch ME
        warning('applySelections:FieldFail', ...
            'Could not set %s: %s', propName, ME.message);
    end
end

function setButtonValue(app, propName, source, sourceField)
%SETBUTTONVALUE Set a state button .Value without triggering its callback.
    if ~isfield(source, sourceField), return; end
    if ~isprop(app, propName), return; end
    try
        app.(propName).Value = logical(source.(sourceField));
    catch ME
        warning('applySelections:ButtonFail', ...
            'Could not set %s: %s', propName, ME.message);
    end
end

function fireButtonCallback(app, propName)
%FIREBUTTONCALLBACK Trigger a state button's ValueChangedFcn for visual update.
    if ~isprop(app, propName), return; end
    try
        triggerCallback(app.(propName), app.(propName).Value);
    catch ME
        warning('applySelections:CallbackFail', ...
            'Callback failed for %s: %s', propName, ME.message);
    end
end

function triggerCallback(btn, newVal)
%TRIGGERCALLBACK Manually invoke a UI component's ValueChangedFcn.
    cb = btn.ValueChangedFcn;
    if isempty(cb), return; end
    evt = struct('Value', newVal, 'PreviousValue', ~newVal, ...
                 'Source', btn, 'EventName', 'ValueChanged');
    if iscell(cb)
        feval(cb{1}, cb{2:end}, evt);
    elseif isa(cb, 'function_handle')
        cb(btn, evt);
    end
end

function applyComponentSelections(app, savedComps)
%APPLYCOMPONENTSELECTIONS Walk saved Components hierarchy and set dropdown values.
    if ~isprop(app, 'ComponentDropdowns') || ~isstruct(app.ComponentDropdowns)
        return;
    end

    keys = fieldnames(app.ComponentDropdowns);
    for k = 1:numel(keys)
        dd = app.ComponentDropdowns.(keys{k});

        compType  = '';
        instLabel = '';
        if isstruct(dd.UserData)
            if isfield(dd.UserData, 'InstanceComp'),  compType  = char(dd.UserData.InstanceComp); end
            if isfield(dd.UserData, 'InstanceLabel'), instLabel = char(dd.UserData.InstanceLabel); end
        end
        if isempty(compType), continue; end

        if ~isfield(savedComps, compType), continue; end
        compData = savedComps.(compType);
        % Check Selections first (unified format), fallback to Instances (legacy cache)
        if isfield(compData, 'Selections') && isstruct(compData.Selections)
            selData = compData.Selections;
        elseif isfield(compData, 'Instances') && isstruct(compData.Instances)
            selData = compData.Instances;
        else
            continue;
        end

        instKey = matlab.lang.makeValidName(instLabel);
        if ~isfield(selData, instKey), continue; end
        instData = selData.(instKey);

        if isfield(instData, 'Model') && ~isempty(instData.Model)
            trySetDropdownValue(dd, char(instData.Model), '.slx');
        end

        if isfield(instData, 'ParamFile') && ~isempty(instData.ParamFile)
            ud = dd.UserData;
            ud.ParamFile = char(instData.ParamFile);
            dd.UserData = ud;

            if isfield(dd.UserData, 'ParamButton') && isvalid(dd.UserData.ParamButton)
                updateParamTooltip(dd.UserData.ParamButton, dd, dd.UserData.RootFolder);
            end
        end
    end
end

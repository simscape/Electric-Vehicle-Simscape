function registerAction(app, action)
% REGISTERACTION Execute register template actions: scan, write, or newConfig.

    switch action
        case "scan"
            registerScan(app);
        case "write"
            registerWrite(app);
        case "newConfig"
            registerNewConfig(app);
    end
end

% =========================================================================
function registerScan(app)

    slxPath = app.RegTemplateDropDown.Value;
    if isempty(slxPath)
        uialert(app.UIFigure, 'Select a template first.', 'Missing Input');
        return;
    end

    appendLog(app, "Scanning template (preview)...");
    app.RegLamp.Color   = app.AMBER;
    app.RegLamp.Tooltip = 'Processing...';
    drawnow;

    try
        root = app.ProjectRoot;
        output = evalc('bevRegisterTemplate(slxPath, DryRun=true, ProjectRoot=root)');
        showResult(app, output, app.RegLamp, true);
        app.RegLamp.Color   = app.AMBER;
        app.RegLamp.Tooltip = 'Previewed — ready to apply';
        app.RegWriteBtn.Enable = 'on';
        appendLog(app, "Scan complete — review results, then click Register.");
    catch ME
        showResult(app, ME.message, app.RegLamp, false);
        appendLog(app, "Scan failed: " + ME.message);
    end
end

% =========================================================================
function registerWrite(app)

    slxPath = app.RegTemplateDropDown.Value;
    cfgPath = app.RegConfigDropDown.Value;
    if isempty(slxPath)
        uialert(app.UIFigure, 'Select a template first.', 'Missing Input');
        return;
    end
    if isempty(cfgPath)
        uialert(app.UIFigure, 'Select a target config file.', 'Missing Input');
        return;
    end

    root = app.ProjectRoot;
    nv = {'DryRun', false, 'ProjectRoot', root, 'ConfigFile', cfgPath};

    desc = app.RegDescField.Value;
    if strlength(desc) > 0
        nv = [nv, {'Description', desc}];
    end
    if app.RegAllowUnmappedCB.Value
        nv = [nv, {'AllowUnmapped', true}];
    end
    if app.RegOverwriteCB.Value
        nv = [nv, {'Overwrite', true}];
    end

    appendLog(app, "Registering template...");
    app.RegLamp.Color   = app.AMBER;
    app.RegLamp.Tooltip = 'Processing...';
    drawnow;

    try
        output = evalc('bevRegisterTemplate(slxPath, nv{:})');
        showResult(app, output, app.RegLamp, true);
        appendLog(app, "Template registered.");
        populateConfigDropdowns(app);
        refreshPreview(app);
    catch ME
        showResult(app, ME.message, app.RegLamp, false);
        appendLog(app, "Register failed: " + ME.message);
    end
end

% =========================================================================
function registerNewConfig(app)

    presetFolder = getPresetConfigFolder();
    [f, p] = uiputfile('*.json', 'Create New Config', presetFolder);
    if isequal(f, 0), return; end

    newPath = fullfile(p, f);
    fid = fopen(newPath, 'w');
    fprintf(fid, '{}');
    fclose(fid);

    populateConfigDropdowns(app);
    app.RegConfigDropDown.Value = newPath;
    appendLog(app, "Created new config: " + string(f));
end

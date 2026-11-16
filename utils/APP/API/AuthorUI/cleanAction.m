function cleanAction(app, action)
% CLEANACTION Execute clean config actions: scan or apply.

    cfgPath = app.ClnConfigDropDown.Value;
    if isempty(cfgPath)
        uialert(app.UIFigure, 'Select a config file first.', 'Missing Input');
        return;
    end

    root = app.ProjectRoot;

    switch action
        case "scan"
            appendLog(app, "Scanning for stale entries...");
            app.ClnLamp.Color   = app.AMBER;
            app.ClnLamp.Tooltip = 'Processing...';
            drawnow;
            try
                output = evalc('bevCleanConfig(cfgPath, DryRun=true, ProjectRoot=root)');
                showResult(app, output, app.ClnLamp, true);
                app.ClnLamp.Color   = app.AMBER;
                app.ClnLamp.Tooltip = 'Previewed — ready to apply';
                app.ClnApplyBtn.Enable = 'on';
                appendLog(app, "Scan complete.");
            catch ME
                showResult(app, ME.message, app.ClnLamp, false);
                appendLog(app, "Scan failed: " + ME.message);
            end

        case "apply"
            appendLog(app, "Cleaning config...");
            app.ClnLamp.Color   = app.AMBER;
            app.ClnLamp.Tooltip = 'Processing...';
            drawnow;
            try
                output = evalc('bevCleanConfig(cfgPath, DryRun=false, ProjectRoot=root)');
                showResult(app, output, app.ClnLamp, true);
                appendLog(app, "Config cleaned.");
                refreshPreview(app);
            catch ME
                showResult(app, ME.message, app.ClnLamp, false);
                appendLog(app, "Failed: " + ME.message);
            end
    end
end

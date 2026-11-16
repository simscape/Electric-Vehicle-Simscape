function updateAction(app, action)
% UPDATEACTION Execute update template actions: scan or apply.

    slxPath = string(app.UpdTemplateDropDown.Value);
    if strlength(slxPath) == 0
        uialert(app.UIFigure, 'Select a template first.', 'Missing Input');
        return;
    end

    root = app.ProjectRoot;

    switch action
        case "scan"
            appendLog(app, "Scanning for changes (preview)...");
            app.UpdLamp.Color   = app.AMBER;
            app.UpdLamp.Tooltip = 'Processing...';
            drawnow;
            try
                output = evalc('bevUpdateTemplate(slxPath, DryRun=true, ProjectRoot=root)');
                showResult(app, output, app.UpdLamp, true);
                app.UpdLamp.Color   = app.AMBER;
                app.UpdLamp.Tooltip = 'Previewed — ready to apply';
                app.UpdApplyBtn.Enable = 'on';
                appendLog(app, "Diff preview complete.");
            catch ME
                showResult(app, ME.message, app.UpdLamp, false);
                appendLog(app, "Scan failed: " + ME.message);
            end

        case "apply"
            appendLog(app, "Applying template update...");
            app.UpdLamp.Color   = app.AMBER;
            app.UpdLamp.Tooltip = 'Processing...';
            drawnow;
            try
                output = evalc('bevUpdateTemplate(slxPath, DryRun=false, ProjectRoot=root)');
                showResult(app, output, app.UpdLamp, true);
                appendLog(app, "Configs synced.");
                populateConfigDropdowns(app);
                refreshPreview(app);
            catch ME
                showResult(app, ME.message, app.UpdLamp, false);
                appendLog(app, "Failed: " + ME.message);
            end
    end
end

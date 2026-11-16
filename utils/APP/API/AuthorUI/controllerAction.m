function controllerAction(app, action)
% CONTROLLERACTION Execute controller step actions: preview or write.

    if app.CtrlMode == "add"
        args = buildAddArgs(app, strcmp(action, "preview"));
    elseif app.CtrlMode == "delete"
        args = buildDeleteArgs(app, strcmp(action, "preview"));
    else
        uialert(app.UIFigure, 'Select Add or Delete first.', 'No Action');
        return;
    end
    if isempty(args), return; end

    switch action
        case "preview"
            appendLog(app, "Controller preview...");
            app.CtrlLamp.Color   = app.AMBER;
            app.CtrlLamp.Tooltip = 'Processing...';
            drawnow;
            try
                if app.CtrlMode == "add"
                    output = evalc('bevAddFidelity(args{:})');
                else
                    output = evalc('bevDeleteFidelity(args{:})');
                end
                showResult(app, output, app.CtrlLamp, true);
                app.CtrlLamp.Color   = app.AMBER;
                app.CtrlLamp.Tooltip = 'Previewed — ready to apply';
                app.CtrlWriteBtn.Enable = 'on';
                appendLog(app, "Preview complete.");
            catch ME
                showResult(app, buildErrorMsg(ME), app.CtrlLamp, false);
                appendLog(app, "Preview failed: " + ME.message);
            end

        case "write"
            appendLog(app, "Applying controller change...");
            app.CtrlLamp.Color   = app.AMBER;
            app.CtrlLamp.Tooltip = 'Processing...';
            drawnow;
            try
                if app.CtrlMode == "add"
                    output = evalc('bevAddFidelity(args{:})');
                else
                    output = evalc('bevDeleteFidelity(args{:})');
                end
                showResult(app, output, app.CtrlLamp, true);
                appendLog(app, "Controller applied.");
                refreshPreview(app);
            catch ME
                showResult(app, buildErrorMsg(ME), app.CtrlLamp, false);
                appendLog(app, "Failed: " + ME.message);
            end
    end
end

% =========================================================================
function args = buildAddArgs(app, dryRun)

    cfgPath = string(app.CtrlConfigDropDown.Value);
    tmpl    = string(app.CtrlTemplateDropDown.Value);
    mdl     = string(app.CtrlModelDropDown.Value);

    if strlength(cfgPath) == 0 || strlength(tmpl) == 0
        uialert(app.UIFigure, 'Config and Template are required.', 'Missing Input');
        args = {};
        return;
    end
    if strlength(mdl) == 0
        uialert(app.UIFigure, 'Select a controller model.', 'Missing Input');
        args = {};
        return;
    end

    root = app.ProjectRoot;
    args = {cfgPath, tmpl};
    nv = {'ControlModel', mdl, 'DryRun', dryRun, 'ProjectRoot', root};

    pf = strtrim(string(app.CtrlParamField.Value));
    if strlength(pf) > 0
        nv = [nv, {'ControlParamFile', pf}];
    end
    if app.CtrlMakeDefaultCB.Value
        nv = [nv, {'MakeDefault', true}];
    end

    args = [args, nv];
end

% =========================================================================
function args = buildDeleteArgs(app, dryRun)

    cfgPath = string(app.CtrlConfigDropDown.Value);
    tmpl    = string(app.CtrlTemplateDropDown.Value);
    mdl     = string(app.CtrlModelDropDown.Value);

    if strlength(cfgPath) == 0 || strlength(tmpl) == 0
        uialert(app.UIFigure, 'Config and Template are required.', 'Missing Input');
        args = {};
        return;
    end
    if strlength(mdl) == 0
        uialert(app.UIFigure, 'Select a controller model to delete.', 'Missing Input');
        args = {};
        return;
    end

    root = app.ProjectRoot;
    args = {cfgPath, tmpl, "Controls", mdl, ...
        'DryRun', dryRun, 'ProjectRoot', root};
end

% =========================================================================
function msg = buildErrorMsg(ME)
% BUILDERRORMSG Format error with stack trace for diagnostics.

    msg = ME.message;
    if ~isempty(ME.stack)
        msg = msg + newline + "  in " + ME.stack(1).name ...
            + " (line " + ME.stack(1).line + ")";
    end
end

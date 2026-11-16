function sysParamAction(app, action)
% SYSPARAMACTION Execute system parameter actions: preview or apply.

    args = buildSysParamArgs(app, strcmp(action, "preview"));
    if isempty(args), return; end

    switch action
        case "preview"
            appendLog(app, "System param preview...");
            app.SysLamp.Color   = app.AMBER;
            app.SysLamp.Tooltip = 'Processing...';
            drawnow;
            try
                output = evalc('bevAddFidelity(args{:})');
                showResult(app, output, app.SysLamp, true);
                app.SysLamp.Color   = app.AMBER;
                app.SysLamp.Tooltip = 'Previewed — ready to apply';
                app.SysApplyBtn.Enable = 'on';
                appendLog(app, "Preview complete.");
            catch ME
                showResult(app, buildErrorMsg(ME), app.SysLamp, false);
                appendLog(app, "Preview failed: " + ME.message);
            end

        case "apply"
            appendLog(app, "Setting system parameter...");
            app.SysLamp.Color   = app.AMBER;
            app.SysLamp.Tooltip = 'Processing...';
            drawnow;
            try
                output = evalc('bevAddFidelity(args{:})');
                showResult(app, output, app.SysLamp, true);
                appendLog(app, "System parameter applied.");
                refreshPreview(app);
            catch ME
                showResult(app, buildErrorMsg(ME), app.SysLamp, false);
                appendLog(app, "Failed: " + ME.message);
            end
    end
end

% =========================================================================
function args = buildSysParamArgs(app, dryRun)

    cfgPath = string(app.SysConfigDropDown.Value);
    tmpl    = string(app.SysTemplateDropDown.Value);
    sp      = strtrim(string(app.SysParamField.Value));

    if strlength(cfgPath) == 0 || strlength(tmpl) == 0
        uialert(app.UIFigure, 'Config and Template are required.', 'Missing Input');
        args = {};
        return;
    end
    if strlength(sp) == 0
        uialert(app.UIFigure, 'Enter a system parameter file name.', 'Missing Input');
        args = {};
        return;
    end

    root = app.ProjectRoot;
    args = {cfgPath, tmpl, ...
        'SystemParameter', sp, 'DryRun', dryRun, 'ProjectRoot', root};
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

function fidelityAction(app, action)
% FIDELITYACTION Execute fidelity step actions: preview or write.

    if app.FidMode == "add"
        args = buildAddArgs(app, strcmp(action, "preview"));
    elseif app.FidMode == "delete"
        args = buildDeleteArgs(app, strcmp(action, "preview"));
    else
        uialert(app.UIFigure, 'Select Add or Delete first.', 'No Action');
        return;
    end
    if isempty(args), return; end

    switch action
        case "preview"
            appendLog(app, "Fidelity preview...");
            app.FidLamp.Color   = app.AMBER;
            app.FidLamp.Tooltip = 'Processing...';
            drawnow;
            try
                if app.FidMode == "add"
                    output = evalc('bevAddFidelity(args{:})');
                else
                    output = evalc('bevDeleteFidelity(args{:})');
                end
                showResult(app, output, app.FidLamp, true);
                app.FidLamp.Color   = app.AMBER;
                app.FidLamp.Tooltip = 'Previewed — ready to apply';
                app.FidWriteBtn.Enable = 'on';
                appendLog(app, "Preview complete.");
            catch ME
                showResult(app, buildErrorMsg(ME), app.FidLamp, false);
                appendLog(app, "Preview failed: " + ME.message);
            end

        case "write"
            appendLog(app, "Applying fidelity change...");
            app.FidLamp.Color   = app.AMBER;
            app.FidLamp.Tooltip = 'Processing...';
            drawnow;
            try
                if app.FidMode == "add"
                    output = evalc('bevAddFidelity(args{:})');
                else
                    output = evalc('bevDeleteFidelity(args{:})');
                end
                showResult(app, output, app.FidLamp, true);
                appendLog(app, "Fidelity change applied.");

                % Refresh dropdowns after delete
                if app.FidMode == "delete"
                    cfgPath = string(app.FidConfigDropDown.Value);
                    tmpl    = string(app.FidTemplateDropDown.Value);
                    comp    = string(app.FidComponentDropDown.Value);
                    populateComponentKeys(app, cfgPath, tmpl, ...
                        app.FidComponentDropDown);
                    if any(strcmp(char(comp), app.FidComponentDropDown.ItemsData))
                        app.FidComponentDropDown.Value = comp;
                        populateModelChoices(app, cfgPath, tmpl, ...
                            comp, app.FidModelDropDown, "delete");
                    else
                        app.FidModelDropDown.Items = {'Select model...'};
                        app.FidModelDropDown.ItemsData = {''};
                    end
                end

                refreshPreview(app);
            catch ME
                showResult(app, buildErrorMsg(ME), app.FidLamp, false);
                appendLog(app, "Failed: " + ME.message);
            end
    end
end

% =========================================================================
function args = buildAddArgs(app, dryRun)

    configFile = string(app.FidConfigDropDown.Value);
    tmpl       = string(app.FidTemplateDropDown.Value);

    if strlength(configFile) == 0 || strlength(tmpl) == 0
        uialert(app.UIFigure, 'Config and Template are required.', 'Missing Input');
        args = {};
        return;
    end

    args = {configFile, tmpl};
    comp = string(app.FidComponentDropDown.Value);
    if strlength(comp) > 0, args{end+1} = comp; end
    mdl = string(app.FidModelDropDown.Value);
    if strlength(mdl) > 0, args{end+1} = mdl; end

    root = app.ProjectRoot;
    nv = {'DryRun', dryRun, 'ProjectRoot', root};

    pf = string(app.FidParamField.Value);
    if strlength(pf) > 0
        nv = [nv, {'ParamFile', pf}];
    end
    if app.FidMakeDefaultCB.Value
        nv = [nv, {'MakeDefault', true}];
    end

    args = [args, nv];
end

% =========================================================================
function args = buildDeleteArgs(app, dryRun)

    cfgPath = string(app.FidConfigDropDown.Value);
    tmpl    = string(app.FidTemplateDropDown.Value);
    comp    = string(app.FidComponentDropDown.Value);
    mdl     = string(app.FidModelDropDown.Value);

    if strlength(cfgPath) == 0 || strlength(tmpl) == 0
        uialert(app.UIFigure, 'Config and Template are required.', 'Missing Input');
        args = {};
        return;
    end
    if strlength(comp) == 0
        uialert(app.UIFigure, 'Select a component.', 'Missing Input');
        args = {};
        return;
    end
    if strlength(mdl) == 0
        uialert(app.UIFigure, 'Select a model to delete.', 'Missing Input');
        args = {};
        return;
    end

    root = app.ProjectRoot;
    args = {cfgPath, tmpl, comp, mdl, 'DryRun', dryRun, 'ProjectRoot', root};
end

% =========================================================================
function msg = buildErrorMsg(ME)
% BUILDERRORMSG Format error message with source location from stack trace.

    msg = ME.message;
    if ~isempty(ME.stack)
        loc = ME.stack(1);
        msg = sprintf('%s\n  in %s (line %d)', msg, loc.name, loc.line);
    end
end

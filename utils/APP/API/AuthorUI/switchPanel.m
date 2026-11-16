function switchPanel(app, name)
% SWITCHPANEL Show the named step panel and update navigation state.

    % Sync config/template selection before switching
    syncConfigSelection(app, name);

    % Hide all step panels
    panels = fieldnames(app.StepPanels);
    for k = 1:numel(panels)
        app.StepPanels.(panels{k}).Visible = 'off';
    end

    % Show selected
    if isfield(app.StepPanels, name)
        app.StepPanels.(name).Visible = 'on';
    end

    % Clear results
    app.ResultsArea.Value = {'Ready.'};

    % Reset controller and fidelity add/delete mode
    resetCtrlMode(app);
    resetFidMode(app);

    % Disable write buttons until next preview
    app.RegWriteBtn.Enable  = 'off';
    app.CtrlWriteBtn.Enable = 'off';
    app.FidWriteBtn.Enable  = 'off';
    app.UpdApplyBtn.Enable  = 'off';
    app.ClnApplyBtn.Enable  = 'off';
    app.SysApplyBtn.Enable  = 'off';

    % Reset lamps
    lamps = [app.RegLamp, app.CtrlLamp, app.FidLamp, ...
             app.UpdLamp, app.ClnLamp, app.SysLamp];
    for k = 1:numel(lamps)
        lamps(k).Color   = [0.8 0.8 0.8];
        lamps(k).Tooltip = '';
    end

    % Reset all nav button styles
    for k = 1:numel(app.NavButtons)
        app.NavButtons{k}.BackgroundColor = app.DefaultNavBg;
        app.NavButtons{k}.FontColor = app.DefaultNavFg;
        app.NavButtons{k}.FontWeight = 'normal';
    end

    % Highlight active button
    btnMap = struct( ...
        'register',   app.Nav1RegisterBtn, ...
        'controller', app.Nav2ComponentBtn, ...
        'fidelity',   app.Nav3FidelityBtn, ...
        'update',     app.NavUpdateBtn, ...
        'clean',      app.NavCleanBtn, ...
        'sysparam',   app.NavSysParamBtn);

    if isfield(btnMap, name)
        activeBtn = btnMap.(name);
        activeBtn.BackgroundColor = app.DARK_BLUE;
        activeBtn.FontColor = app.WHITE;
        activeBtn.FontWeight = 'bold';
    end
end

% =========================================================================
function syncConfigSelection(app, targetPanel)
% SYNCCONFIGSELECTION Copy config and template selections across panels.

    cfgVal  = '';
    tmplVal = '';
    cfgSources = {app.RegConfigDropDown, app.CtrlConfigDropDown, ...
                  app.FidConfigDropDown, app.ClnConfigDropDown, ...
                  app.SysConfigDropDown, app.PreviewConfigDropDown};
    tmplSources = {app.CtrlTemplateDropDown, app.FidTemplateDropDown, ...
                   app.SysTemplateDropDown, app.PreviewTemplateDropDown};

    for k = 1:numel(cfgSources)
        v = string(cfgSources{k}.Value);
        if strlength(v) > 0, cfgVal = v; break; end
    end
    for k = 1:numel(tmplSources)
        v = string(tmplSources{k}.Value);
        if strlength(v) > 0, tmplVal = v; break; end
    end

    % Map panel name to its config and template dropdowns
    cfgMap = struct( ...
        'register',   app.RegConfigDropDown, ...
        'controller', app.CtrlConfigDropDown, ...
        'fidelity',   app.FidConfigDropDown, ...
        'clean',      app.ClnConfigDropDown, ...
        'sysparam',   app.SysConfigDropDown);
    tmplMap = struct( ...
        'controller', app.CtrlTemplateDropDown, ...
        'fidelity',   app.FidTemplateDropDown, ...
        'sysparam',   app.SysTemplateDropDown);

    % Set config on target panel
    if strlength(cfgVal) > 0 && isfield(cfgMap, targetPanel)
        dd = cfgMap.(targetPanel);
        if any(strcmp(cfgVal, dd.ItemsData))
            dd.Value = cfgVal;
        end
        % Populate template dropdown then restore selection
        if isfield(tmplMap, targetPanel)
            populateTemplateKeys(app, cfgVal, tmplMap.(targetPanel));
            if strlength(tmplVal) > 0 ...
                    && any(strcmp(tmplVal, tmplMap.(targetPanel).ItemsData))
                tmplMap.(targetPanel).Value = tmplVal;
            end
        end
    end

    % Sync preview panel
    if strlength(cfgVal) > 0 && any(strcmp(cfgVal, app.PreviewConfigDropDown.ItemsData))
        app.PreviewConfigDropDown.Value = cfgVal;
        populateTemplateKeys(app, cfgVal, app.PreviewTemplateDropDown);
        if strlength(tmplVal) > 0 ...
                && any(strcmp(tmplVal, app.PreviewTemplateDropDown.ItemsData))
            app.PreviewTemplateDropDown.Value = tmplVal;
        end
    end
end

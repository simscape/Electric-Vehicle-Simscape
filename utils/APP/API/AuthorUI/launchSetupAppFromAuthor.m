function launchSetupAppFromAuthor(app)
% LAUNCHSETUPAPPFROMAUTHOR Open the BEV Model Setup App from the Config Author.
%   Reads the current config and template selections in the Config Author
%   app. If the template exists on disk and is found in a config JSON, the
%   Model Setup App launches with those pre-applied. Otherwise launches
%   with defaults.
%
% Copyright 2026 The MathWorks, Inc.

    [configFile, templateName] = getCurrentSelection(app);

    templateDir = fullfile(app.ProjectRoot, 'Model', 'VehicleTemplate');
    slxPath = fullfile(templateDir, templateName + ".slx");

    bevApp = loadAppShortcut();

    if strlength(templateName) > 0 && isfile(slxPath) && strlength(configFile) > 0
        waitForDropdownsReady(bevApp, 5.0);

        configSet = setConfigDropdown(bevApp, configFile);
        if configSet
            drawnow;
            createComponentDropdowns(bevApp);
            controlSelectionDropdown(bevApp);
        end

        templateSet = setTemplateDropdown(bevApp, templateName);
        if templateSet
            drawnow;
            createComponentDropdowns(bevApp);
            controlSelectionDropdown(bevApp);
        end
    else
        if strlength(templateName) > 0 && ~isfile(slxPath)
            appendLog(app, sprintf('Template "%s" not on disk — launched with defaults.', templateName));
        end
    end
end


function success = setConfigDropdown(bevApp, configFile)
    success = false;
    if isempty(bevApp.ConfigDropDown.ItemsData)
        return
    end
    data = string(bevApp.ConfigDropDown.ItemsData);

    idx = find(data == configFile, 1);

    if isempty(idx)
        [~, fname, fext] = fileparts(configFile);
        target = string([char(fname) char(fext)]);
        items = string(bevApp.ConfigDropDown.Items);
        idx = find(items == target, 1);
        if isempty(idx)
            idx = find(strcmpi(items, target), 1);
        end
        if ~isempty(idx)
            bevApp.ConfigDropDown.Value = bevApp.ConfigDropDown.ItemsData{idx};
            success = true;
        end
    else
        bevApp.ConfigDropDown.Value = bevApp.ConfigDropDown.ItemsData{idx};
        success = true;
    end
end


function success = setTemplateDropdown(bevApp, templateName)
    success = false;
    items = string(bevApp.VehicleTemplateDropDown.Items);

    withExt = templateName + ".slx";
    idx = find(items == withExt, 1);
    if isempty(idx)
        idx = find(strcmpi(items, withExt), 1);
    end
    if isempty(idx)
        idx = find(items == templateName, 1);
    end

    if ~isempty(idx)
        bevApp.VehicleTemplateDropDown.Value = bevApp.VehicleTemplateDropDown.Items{idx};
        success = true;
    end
end


function waitForDropdownsReady(bevApp, timeoutSec)
    startTime = tic;
    while toc(startTime) < timeoutSec
        if ~isempty(bevApp.ConfigDropDown.ItemsData) ...
                && numel(bevApp.ConfigDropDown.ItemsData) > 1
            return
        end
        drawnow;
        pause(0.1);
    end
end


function [configFile, templateName] = getCurrentSelection(app)
    configFile = "";
    templateName = "";

    activePanel = getCurrentActivePanel(app);

    switch activePanel
        case "register"
            configFile = string(app.RegConfigDropDown.Value);
            templateName = string(app.RegTemplateDropDown.Value);
        case "controller"
            configFile = string(app.CtrlConfigDropDown.Value);
            templateName = string(app.CtrlTemplateDropDown.Value);
        case "fidelity"
            configFile = string(app.FidConfigDropDown.Value);
            templateName = string(app.FidTemplateDropDown.Value);
        case "sysparam"
            configFile = string(app.SysConfigDropDown.Value);
            templateName = string(app.SysTemplateDropDown.Value);
        otherwise
            configFile = string(app.PreviewConfigDropDown.Value);
            templateName = string(app.PreviewTemplateDropDown.Value);
    end

    templateName = extractTemplateName(templateName);
end


function name = extractTemplateName(raw)
    [~, name, ~] = fileparts(raw);
    name = string(name);
end


function panelName = getCurrentActivePanel(app)
    panelName = "register";
    names = fieldnames(app.StepPanels);
    for i = 1:numel(names)
        if strcmp(app.StepPanels.(names{i}).Visible, 'on')
            panelName = string(names{i});
            return
        end
    end
end

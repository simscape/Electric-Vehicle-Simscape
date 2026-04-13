function controlSelectionDropdown(app)
    proj = matlab.project.rootProject;
    root = proj.RootFolder;
    rawCfg = jsondecode(fileread(app.ConfigDropDown.Value));
    vehicleConfig = erase(app.VehicleTemplateDropDown.Value,".slx");
    app.ControlSelectionDropDown.Enable = "on";
    app.ControlDesc.Enable = "on";

    % Controller detection
    % if this fails, we disable control selection, component selection
    % still possible
    if ~controlsDetectFromBEVModel(app, root)
        app.ControlSelectionDropDown.Enable = "off";
        app.ControlDesc.Enable = "off";
    else
        app.ControlSelectionDropDown.Enable = "on";
        app.ControlDesc.Enable = "on";

        % check config file for matching control model
        try
            controlSubsystem = rawCfg.(vehicleConfig).Controls;
            controlSelected = controlSubsystem.Models;
            app.ControlSelectionDropDown.Enable = "on";
            app.ControlDesc.Enable = "on";
        catch
            uialert(app.UIFigure, "No control model found in the design scenario", "Error");
            app.ControlSelectionDropDown.Enable = "off";
            app.ControlDesc.Enable = "off";
        end
        if app.ControlSelectionDropDown.Enable == "on"
            try
                controlItems = app.ControlSelectionDropDown.Items;
                controlSelected   = ensureSlxList(controlSelected);     % cellstr '*.slx'

                % Compare using basenames, then convert to *.slx for UI
                validBase   = intersect(controlSelected, controlItems,'stable');
                missingBase = setdiff(controlSelected, controlItems, 'stable');
                % UI will carry *.slx
                validFull   = ensureSlxList(validBase);     % cellstr '*.slx'
                missingFull = ensureSlxList(missingBase);   % cellstr '*.slx'

                % Compose dropdown items (valid selectable; missing blocked)
                itemsValid   = cellfun(@char, validFull,   'UniformOutput', false);
                itemsMissing = cellfun(@char, strcat(string(missingFull), " [missing]"), 'UniformOutput', false);
                itemsAll     = [itemsValid, itemsMissing];
                dataAll      = [itemsValid, cellfun(@char, strcat("__MISSING__", string(missingFull)), 'UniformOutput', false)];
                if isempty(itemsValid)
                    itemsValid = ['No controls available'];
                    app.ControlSelectionDropDown.Items = itemsValid;
                    error(' ');
                end

                app.ControlSelectionDropDown.Items = itemsValid;
                controlIdx = find(strcmp(itemsAll,controlSelected));
                app.ControlSelectionDropDown.Value = app.ControlSelectionDropDown.Items(controlIdx);

                if ~ isempty(itemsMissing)
                    uialert(app.UIFigure, "No matching control model found in the .." + ...
                        " controller folder and design scenario ", "Error");
                end
            catch
                uialert(app.UIFigure, "No matching control model found in the ..." + ...
                    "controller folder and design scenario ", "Error");
                app.ControlSelectionDropDown.Enable = "off";
                app.ControlDesc.Enable = "off";
            end
        end
    end

end

% ensureSlxList is now a shared utility in APP/API/ensureSlxList.m
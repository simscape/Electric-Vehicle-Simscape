function initAppDropdowns(app)
%INITAPPDROPDOWNS Populate all top-level dropdowns at app startup.
%   initAppDropdowns(app)
%
%   Resolves folder paths via getBEVAppPaths and populates:
%     1. BEV Model dropdown          — .slx files from Model/
%     2. Vehicle Template dropdown    — .slx files from Model/VehicleTemplate/
%     3. Config dropdown              — .json files from Config/Preset + Config/User
%     4. Control Selection dropdown   — .slx files from Components/Controller/Model/
%
%   Replaces the inline path + dropdown setup in mlapp startupFcn.
% Copyright 2026 The MathWorks, Inc.

    paths = getBEVAppPaths(app);

    % ---- 1. BEV Model dropdown ----
    app.BEVModelDropDown.Items = getSLXFiles(paths.Model);

    if isempty(app.BEVModelDropDown.Items)
        uialert(app.UIFigure, 'No BEV model found in Model folder.', 'Error');
        return;
    end

    app.BEVModelDropDown.Value = app.BEVModelDropDown.Items{1};
    app.ModelNameLabel.Text    = app.BEVModelDropDown.Items{1};

    % ---- 2. Vehicle Template dropdown ----
    app.VehicleTemplateDropDown.Items = getSLXFiles(paths.VehicleTemplate);

    if isempty(app.VehicleTemplateDropDown.Items)
        uialert(app.UIFigure, 'No template found in the template folder.', 'Error');
        return;
    end

    app.VehicleTemplateDropDown.Value = app.VehicleTemplateDropDown.Items{1};

    % ---- 3. Config dropdown (Preset + User, full-path ItemsData) ----
    populateConfigDropDown(app);

    % ---- 4. Control Selection dropdown (initial population; controlSelectionDropdown refines later) ----
    app.ControlSelectionDropDown.Items = getSLXFiles(paths.Controller);

    if isempty(app.ControlSelectionDropDown.Items)
        uialert(app.UIFigure, 'No controller template found in the controller folder.', 'Error');
        return;
    end

    app.ControlSelectionDropDown.Value = app.ControlSelectionDropDown.Items{1};
end

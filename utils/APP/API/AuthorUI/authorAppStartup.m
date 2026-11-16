function authorAppStartup(app)
% AUTHORAPPSTARTUP Initialize the BEV Config Author app.

    try
        app.ProjectRoot = string(getBEVProjectRoot());
    catch
        classFolder = fileparts(which('BEVauthorAppNative'));
        app.ProjectRoot = string(fileparts(fileparts(classFolder)));
    end

    % Capture default nav button colors before any highlight
    app.DefaultNavBg = app.Nav1RegisterBtn.BackgroundColor;
    app.DefaultNavFg = app.Nav1RegisterBtn.FontColor;

    populateConfigDropdowns(app);
    populateControllerModels(app);
    populateRegTemplates(app);
    switchPanel(app, "register");

    try
        scaleAppToMonitor(app);
    catch
    end
end

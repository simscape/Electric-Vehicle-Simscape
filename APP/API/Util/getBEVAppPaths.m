function paths = getBEVAppPaths(app)
%GETBEVAPPPATHS Centralized folder path resolution for the BEV app.
%   paths = getBEVAppPaths(app)
%
%   Returns a struct with all folder paths used by the app.
%   Single place to update if the project layout changes.
%
%   Fields:
%     paths.ProjectRoot      — MATLAB project root
%     paths.Model            — BEV system model .slx files
%     paths.VehicleTemplate  — vehicle template .slx files
%     paths.Controller       — controller .slx files
%     paths.PresetConfig     — shipped JSON configs (APP/Config/Preset)
%     paths.UserConfig       — user-saved JSON configs (APP/Config/User)

    projectRoot = getBEVProjectRoot(app);

    paths.ProjectRoot     = projectRoot;
    paths.Model           = fullfile(projectRoot, 'Model');
    paths.VehicleTemplate = fullfile(projectRoot, 'Model', 'VehicleTemplate');
    paths.Controller      = fullfile(projectRoot, 'Components', 'Controller', 'Model');
    paths.PresetConfig    = getPresetConfigFolder();
    paths.UserConfig      = getUserConfigFolder();
end

function projectRoot = getBEVProjectRoot(app)
    %GETBEVPROJECTROOT Safely returns the BEV project root folder
    %   Checks if a MATLAB project is loaded and returns its root folder.
    %   If not, displays a UI alert and throws an error.
% Copyright 2026 The MathWorks, Inc.
    
    try
        proj = matlab.project.rootProject();
        projectRoot = proj.RootFolder; % Full path to .prj folder
    catch
        uialert(app.UIFigure, "Project not loaded.", "Error", ...
            "Icon", "error");
        error("BEVApp:ProjectNotLoaded", "Project is not loaded.");
    end
end

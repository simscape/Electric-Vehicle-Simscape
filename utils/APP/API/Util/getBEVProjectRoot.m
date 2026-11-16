function projectRoot = getBEVProjectRoot(app)
% GETBEVPROJECTROOT Safely returns the BEV project root folder.
%   projectRoot = getBEVProjectRoot(app)   — shows uialert on error
%   projectRoot = getBEVProjectRoot()      — CLI-friendly, no UI
%
%   Checks if a MATLAB project is loaded and returns its root folder.
%   When called with an app handle, displays a UI alert on failure.
%   When called without arguments, throws an error directly.
%
% Copyright 2026 The MathWorks, Inc.

    try
        proj = matlab.project.rootProject();
        projectRoot = proj.RootFolder;
    catch
        if nargin > 0 && isprop(app, 'UIFigure')
            uialert(app.UIFigure, "Project not loaded.", "Error", ...
                "Icon", "error");
        end
        error("BEVApp:ProjectNotLoaded", "Project is not loaded.");
    end
end

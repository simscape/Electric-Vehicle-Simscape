function restored = restoreFromCache(app)
%RESTOREFROMCACHE Check for a cached state matching current config+template and apply it.
%   restored = restoreFromCache(app)
%
%   Looks in the session cache folder for a JSON snapshot matching the
%   current template + config basename. If found, applies selections
%   directly (no UI rebuild). If not found, returns false so the caller
%   keeps defaults.
%
% Copyright 2026 The MathWorks, Inc.

    restored = false;

    % ---- Locate cache directory ----
    if ~isstruct(app.UIFigure.UserData) ...
            || ~isfield(app.UIFigure.UserData, 'sessionCacheDir')
        return;
    end
    cacheDir = app.UIFigure.UserData.sessionCacheDir;
    if ~isfolder(cacheDir), return; end

    % ---- Build cache tag from current template + config ----
    template = erase(char(app.VehicleTemplateDropDown.Value), '.slx');
    [~, cfgBase] = fileparts(char(app.ConfigDropDown.Value));
    if isempty(template) || isempty(cfgBase), return; end
    tag = matlab.lang.makeValidName([template '__' cfgBase]);

    % ---- Check for matching snapshot ----
    cacheFile = fullfile(cacheDir, [tag '.json']);
    if ~isfile(cacheFile), return; end

    % ---- Cache hit: load and apply selections ----
    try
        state = jsondecode(fileread(cacheFile));

        if ~isstruct(state), return; end

        applySelections(app, state);
        restored = true;
    catch ME
        warning('BEVapp:restoreFromCache', ...
            'Cache restore failed: %s', ME.message);
    end
end

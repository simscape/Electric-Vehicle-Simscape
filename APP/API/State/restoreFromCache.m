function restored = restoreFromCache(app)
%RESTOREFROMCACHE Check for a cached state matching current config+template and apply it.
%   restored = restoreFromCache(app)
%
%   Looks in the session cache folder for a JSON snapshot matching the
%   current template + config basename. If found, applies selections
%   directly (no UI rebuild). If not found, returns false (caller keeps defaults).

    restored = false;

    % Read cache dir from app (created by snapshotToCache on first use)
    if ~isstruct(app.UIFigure.UserData) || ~isfield(app.UIFigure.UserData, 'sessionCacheDir')
        return;
    end
    cacheDir = app.UIFigure.UserData.sessionCacheDir;
    if ~isfolder(cacheDir), return; end

    % Build tag from current template + config
    template = erase(char(app.VehicleTemplateDropDown.Value), '.slx');
    [~, cfgBase] = fileparts(char(app.ConfigDropDown.Value));
    if isempty(template) || isempty(cfgBase), return; end
    tag = matlab.lang.makeValidName([template '__' cfgBase]);

    % Check if snapshot exists
    cacheFile = fullfile(cacheDir, [tag '.json']);
    if ~isfile(cacheFile), return; end

    % Load and apply selections only (no rebuild — UI is already built)
    try
        state = jsondecode(fileread(cacheFile));
        if ~isstruct(state), return; end
        flds = fieldnames(state);
        if isempty(flds), return; end
        applySelections(app, state.(flds{1}));
        restored = true;
    catch ME
        warning('BEVapp:restoreFromCache', ...
            'Cache restore failed: %s', ME.message);
    end
end

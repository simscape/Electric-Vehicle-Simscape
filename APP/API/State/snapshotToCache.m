function snapshotToCache(app)
%SNAPSHOTTOCACHE Save current app state to session cache before switching config.
%   snapshotToCache(app)
%
%   Snapshots the current UI state using buildSetupState and saves it
%   to the session cache folder, tagged by template + config basename.
%   Uses lastCacheTag (set after each build) so the snapshot is tagged
%   with the OLD template+config, not the new one the user just picked.

    % Get or create cache directory
    cacheDir = getCacheDir(app);
    if isempty(cacheDir), return; end

    % Use the tag from when the UI was last built (dropdown already changed)
    if ~isstruct(app.UIFigure.UserData) ...
            || ~isfield(app.UIFigure.UserData, 'lastCacheTag') ...
            || isempty(app.UIFigure.UserData.lastCacheTag)
        return;
    end
    tag = app.UIFigure.UserData.lastCacheTag;

    % Build state
    try
        state = buildSetupState(app);
    catch ME
        warning('BEVapp:snapshotToCache', ...
            'Failed to build setup state for caching: %s', ME.message);
        return;
    end

    % Write JSON
    try
        json = jsonencode(state, 'PrettyPrint', true);
        fid = fopen(fullfile(cacheDir, [tag '.json']), 'w');
        if fid > 0
            fwrite(fid, json, 'char');
            fclose(fid);
        end
    catch ME
        warning('BEVapp:snapshotToCache', ...
            'Cache write failed: %s', ME.message);
    end
end

%% Local helper

function cacheDir = getCacheDir(app)
%GETCACHEDIR Get or create the session cache folder inside APP/.sessionCache.
%   Also registers cleanup so the folder is deleted when the app closes.
    cacheDir = '';
    try
        % Already initialized?
        if isstruct(app.UIFigure.UserData) && isfield(app.UIFigure.UserData, 'sessionCacheDir')
            d = app.UIFigure.UserData.sessionCacheDir;
            if isfolder(d)
                cacheDir = d;
                return;
            end
        end

        % Create on first use
        appFolder = fileparts(fileparts(fileparts(mfilename('fullpath')))); % APP/API/State/ → APP/
        cacheDir = fullfile(appFolder, '.sessionCache');
        if ~isfolder(cacheDir)
            mkdir(cacheDir);
        end

        % Store on app
        if ~isstruct(app.UIFigure.UserData)
            app.UIFigure.UserData = struct();
        end
        app.UIFigure.UserData.sessionCacheDir = cacheDir;

        % Register cleanup on app close
        origClose = app.UIFigure.CloseRequestFcn;
        app.UIFigure.CloseRequestFcn = @(src, evt) cleanupCache(src, evt, cacheDir, origClose);
    catch ME
        warning('BEVapp:snapshotToCache', ...
            'Session cache setup failed: %s', ME.message);
        cacheDir = '';
    end
end

function cleanupCache(src, evt, cacheDir, origClose)
%CLEANUPCACHE Delete session cache folder, then run original close.
    try
        if isfolder(cacheDir), rmdir(cacheDir, 's'); end
    catch
    end
    try
        if isempty(origClose)
            delete(src);
        elseif iscell(origClose)
            feval(origClose{1}, origClose{2:end}, evt);
        elseif isa(origClose, 'function_handle')
            origClose(src, evt);
        else
            delete(src);
        end
    catch
        delete(src);
    end
end

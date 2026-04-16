function app = loadAppShortcut()
%LOADAPPSHORTCUT Shows a loader popup, launches BEVapp, then closes the loader.

    % ---- Loader UI ----
    f = uifigure( ...
        'Name',        'Starting…', ...
        'Position',    centerOnScreen([360 120]), ...
        'Resize',      'off', ...
        'WindowStyle', 'modal');

    gl = uigridlayout(f, [2 1]);
    gl.RowHeight = {'1x', 30};
    gl.Padding   = [15 15 15 10];

    uilabel(gl, ...
        'Text',                'Loading BEV app…', ...
        'FontSize',            14, ...
        'HorizontalAlignment', 'center');

    d = uiprogressdlg(f, ...
        'Title',         'Please wait', ...
        'Message',       'Initializing…', ...
        'Indeterminate', 'on');

    drawnow;

    % ---- Launch main app ----
    app = [];

    try
        app = BEVapp();
        waitForMainUIFigure(app, 8.0);
    catch ME
        safeClose(d, f);
        rethrow(ME);
    end

    % ---- Close loader ----
    safeClose(d, f);
end

%% Local helpers

function pos = centerOnScreen(sz)
%CENTERONSCREEN Compute centered position for a figure of the given size.
    mp = get(0, 'MonitorPositions');
    m  = mp(1, :);
    x  = m(1) + (m(3) - sz(1)) / 2;
    y  = m(2) + (m(4) - sz(2)) / 2;
    pos = [x y sz(1) sz(2)];
end

function waitForMainUIFigure(app, timeoutSec)
%WAITFORMAINUIFIGURE Poll until the app's UIFigure is visible or timeout.
    t0 = tic;

    while toc(t0) < timeoutSec
        if ~isempty(app) && isvalid(app) && isprop(app, 'UIFigure')
            fig = app.UIFigure;
            if ~isempty(fig) && isvalid(fig) && strcmp(fig.Visible, 'on')
                drawnow;
                return;
            end
        end

        drawnow;
        pause(0.05);
    end
end

function safeClose(d, f)
%SAFECLOSE Safely close progress dialog and loader figure.
    try
        if ~isempty(d)
            close(d);
        end
    catch
    end

    try
        if ~isempty(f) && isvalid(f)
            delete(f);
        end
    catch
    end
end

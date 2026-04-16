function app = loadAppShortcut()
%LOADAPPSHORTCUT Shows a loader popup, launches BEVapp, then closes the loader.

    % ----- Loader UI -----
    f = uifigure( ...
        'Name','Starting…', ...
        'Position', centerOnScreen([360 120]), ...
        'Resize','off', ...
        'WindowStyle','modal');

    gl = uigridlayout(f,[2 1]);
    gl.RowHeight = {'1x', 30};
    gl.Padding = [15 15 15 10];

    uilabel(gl, ...
        'Text','Loading BEV app…', ...
        'FontSize',14, ...
        'HorizontalAlignment','center');

    % Indeterminate spinner dialog (if available in your release)
    d = uiprogressdlg(f, ...
        'Title','Please wait', ...
        'Message','Initializing…', ...
        'Indeterminate','on');

    drawnow; % force loader to render

    % ----- Launch main app -----
    app = [];
    try
        app = BEVapp();                 % <-- your app constructor
        waitForMainUIFigure(app, 8.0);  % optional: wait until app figure is visible
    catch ME
        safeClose(d, f);
        rethrow(ME);
    end

    % ----- Close loader -----
    safeClose(d, f);
end

function pos = centerOnScreen(sz)
    mp = get(0,'MonitorPositions');
    m = mp(1,:); % primary monitor
    x = m(1) + (m(3)-sz(1))/2;
    y = m(2) + (m(4)-sz(2))/2;
    pos = [x y sz(1) sz(2)];
end

function waitForMainUIFigure(app, timeoutSec)
    t0 = tic;
    while toc(t0) < timeoutSec
        if ~isempty(app) && isvalid(app) && isprop(app,'UIFigure')
            fig = app.UIFigure;
            if ~isempty(fig) && isvalid(fig) && strcmp(fig.Visible,'on')
                drawnow;
                return;
            end
        end
        drawnow;
        pause(0.05);
    end
end

function safeClose(d, f)
    try, if ~isempty(d), close(d); end, end %#ok<TRYNC>
    try, if ~isempty(f) && isvalid(f), delete(f); end, end %#ok<TRYNC>
end

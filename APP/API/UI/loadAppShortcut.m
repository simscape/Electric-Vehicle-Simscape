function app = loadAppShortcut()
% LOADAPPSHORTCUT Show a loader popup, launch BEVapp, then close the loader.
%   app = loadAppShortcut()
%
%   Creates a modal splash figure with a progress bar, launches the main
%   BEVapp, waits for its UIFigure to become visible, then closes the splash.
%
% Copyright 2026 The MathWorks, Inc.

    % ---- Loader UI ----
    loaderFig = uifigure( ...
        'Name',        'Starting…', ...
        'Position',    centerOnScreen([360 120]), ...
        'Resize',      'off', ...
        'WindowStyle', 'modal');

    gridLayout = uigridlayout(loaderFig, [2 1]);
    gridLayout.RowHeight = {'1x', 30};
    gridLayout.Padding   = [15 15 15 10];

    uilabel(gridLayout, ...
        'Text',                'Loading BEV app…', ...
        'FontSize',            14, ...
        'HorizontalAlignment', 'center');

    progressDlg = uiprogressdlg(loaderFig, ...
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
        safeClose(progressDlg, loaderFig);
        rethrow(ME);
    end

    % ---- Close loader ----
    safeClose(progressDlg, loaderFig);
end

%% Local helpers

function pos = centerOnScreen(figSize)
% CENTERONSCREEN Compute [x y w h] position to center a figure on the primary monitor.
    monitorPositions = get(0, 'MonitorPositions');
    primaryMonitor   = monitorPositions(1, :);
    xPos = primaryMonitor(1) + (primaryMonitor(3) - figSize(1)) / 2;
    yPos = primaryMonitor(2) + (primaryMonitor(4) - figSize(2)) / 2;
    pos  = [xPos yPos figSize(1) figSize(2)];
end

function waitForMainUIFigure(app, timeoutSec)
% WAITFORMAINUIFIGURE Poll until the app's UIFigure becomes visible, or time out.
    startTime = tic;

    while toc(startTime) < timeoutSec
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

function safeClose(progressDlg, loaderFig)
% SAFECLOSE Close the progress dialog and loader figure, suppressing errors.
    try
        if ~isempty(progressDlg)
            close(progressDlg);
        end
    catch
    end

    try
        if ~isempty(loaderFig) && isvalid(loaderFig)
            delete(loaderFig);
        end
    catch
    end
end

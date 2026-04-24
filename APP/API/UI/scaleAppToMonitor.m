function scaleAppToMonitor(app)
%SCALEAPPTOMONITOR Auto-scale app UI to monitor DPI and resolution.
%   Uses setappdata/getappdata on UIFigure to store baseline sizes.
%
% Copyright 2026 The MathWorks, Inc.

    baselineDPI = 96;
    minScale = 0.7;
    maxScale = 2.0;

    % ---- DPI detection ----
    try
        dpi = groot.ScreenPixelsPerInch;
        if isempty(dpi) || ~isnumeric(dpi)
            dpi = baselineDPI;
        end
    catch
        dpi = baselineDPI;
    end
    dpiScale = dpi / baselineDPI;

    % ---- Find monitor containing pointer ----
    monitorPositions = get(0, 'MonitorPositions');
    pointerLocation  = get(0, 'PointerLocation');

    if isempty(monitorPositions) || size(monitorPositions, 2) < 4
        monitorPositions = [0 0 1024 768];
    end

    monIdx = find( ...
        pointerLocation(1) >= monitorPositions(:, 1) & ...
        pointerLocation(1) <= (monitorPositions(:, 1) + monitorPositions(:, 3)) & ...
        pointerLocation(2) >= monitorPositions(:, 2) & ...
        pointerLocation(2) <= (monitorPositions(:, 2) + monitorPositions(:, 4)), 1);
    if isempty(monIdx), monIdx = 1; end
    activeMonitor = monitorPositions(monIdx, :);

    % ---- Compute fit scale ----
    figPos = app.UIFigure.Position;
    if numel(figPos) < 4 || figPos(3) <= 0 || figPos(4) <= 0
        figPos = [100 100 1000 700];
    end

    usableWidth  = activeMonitor(3) * 0.95;
    usableHeight = activeMonitor(4) * 0.92;
    fitW = usableWidth  / (figPos(3) * dpiScale);
    fitH = usableHeight / (figPos(4) * dpiScale);
    fitFactor = min([1, fitW, fitH]);

    finalScale = dpiScale * fitFactor;
    finalScale = max(minScale, min(maxScale, finalScale));

    % ---- Capture baseline on first call ----
    if ~isappdata(app.UIFigure, 'BaselineSaved') ...
            || ~getappdata(app.UIFigure, 'BaselineSaved')
        setappdata(app.UIFigure, 'BaselineSaved', true);
        setappdata(app.UIFigure, 'BaselineFigPos', figPos);

        fontHandles = findall(app.UIFigure, '-property', 'FontSize');
        setappdata(app.UIFigure, 'BaselineFontHandles', fontHandles);

        fontSizes = arrayfun(@(h) safeGetFontSize(h), fontHandles);
        setappdata(app.UIFigure, 'BaselineFontSizes', fontSizes);
    end

    % ---- Resize figure (centered on active monitor) ----
    basePos = getappdata(app.UIFigure, 'BaselineFigPos');
    newW = max(100, round(basePos(3) * finalScale));
    newH = max(80,  round(basePos(4) * finalScale));
    newX = round(activeMonitor(1) + (activeMonitor(3) - newW) / 2);
    newY = round(activeMonitor(2) + (activeMonitor(4) - newH) / 2);

    app.UIFigure.Units = 'pixels';
    app.UIFigure.Position = [newX newY newW newH];

    % ---- Scale fonts ----
    fontHandles = getappdata(app.UIFigure, 'BaselineFontHandles');
    fontSizes   = getappdata(app.UIFigure, 'BaselineFontSizes');

    for k = 1:numel(fontHandles)
        if ~isvalid(fontHandles(k)), continue; end
        fontHandles(k).FontSize = max(6, round(fontSizes(k) * finalScale));
    end

    % ---- Nested helper ----
    function fs = safeGetFontSize(h)
        try
            fs = h.FontSize;
            if isempty(fs) || ~isnumeric(fs), fs = 10; end
        catch
            fs = 10;
        end
    end
end

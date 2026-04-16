function scaleAppToMonitor(app)
       % Minimal pure-MATLAB autoscale using setappdata/getappdata on UIFigure.
    baselineDPI = 96; minScale = 0.7; maxScale = 2.0;

    % 1) DPI via groot (pure MATLAB)
    try
        dpi = groot.ScreenPixelsPerInch;
        if isempty(dpi) || ~isnumeric(dpi), dpi = baselineDPI; end
    catch
        dpi = baselineDPI;
    end
    dpiScale = dpi / baselineDPI;

    % 2) monitor containing pointer
    mons = get(0,'MonitorPositions'); ptr = get(0,'PointerLocation');
    if isempty(mons) || size(mons,2) < 4
        mons = [0 0 1024 768];
    end
    idx = find(ptr(1) >= mons(:,1) & ptr(1) <= (mons(:,1)+mons(:,3)) & ...
               ptr(2) >= mons(:,2) & ptr(2) <= (mons(:,2)+mons(:,4)), 1);
    if isempty(idx), idx = 1; end
    mon = mons(idx,:);

    % 3) fit scale
    figPos = app.UIFigure.Position;
    if numel(figPos) < 4 || figPos(3) <= 0 || figPos(4) <= 0
        figPos = [100 100 1000 700];
    end
    usableW = mon(3) * 0.95; usableH = mon(4) * 0.92;
    a = usableW / (figPos(3) * dpiScale);
    b = usableH / (figPos(4) * dpiScale);
    fitFactor = min([1, a, b]);
    finalScale = dpiScale * fitFactor;
    finalScale = max(minScale, min(maxScale, finalScale));

    % 4) capture baseline once using app.UIFigure appdata
    if ~isappdata(app.UIFigure,'BaselineSaved') || ~getappdata(app.UIFigure,'BaselineSaved')
        setappdata(app.UIFigure,'BaselineSaved',true);
        setappdata(app.UIFigure,'BaselineFigPos', figPos);
        hWithFont = findall(app.UIFigure,'-property','FontSize');
        setappdata(app.UIFigure,'BaselineFontHandles', hWithFont);
        sizes = arrayfun(@(h) safeGetFont(h), hWithFont);
        setappdata(app.UIFigure,'BaselineFontSizes', sizes);
    end

    % 5) resize figure (center)
    base = getappdata(app.UIFigure,'BaselineFigPos');
    newW = max(100, round(base(3) * finalScale));
    newH = max(80,  round(base(4) * finalScale));
    x = round(mon(1) + (mon(3)-newW)/2);
    y = round(mon(2) + (mon(4)-newH)/2);
    app.UIFigure.Units = 'pixels';
    app.UIFigure.Position = [x y newW newH];

    % 6) scale fonts
    handles = getappdata(app.UIFigure,'BaselineFontHandles');
    sizes   = getappdata(app.UIFigure,'BaselineFontSizes');
    for k = 1:numel(handles)
        h = handles(k);
        if ~isvalid(h), continue; end
        try
            h.FontSize = max(6, round(sizes(k) * finalScale));
        catch
            % ignore
        end
    end

    % helper
    function fs = safeGetFont(h)
        try
            fs = h.FontSize;
            if isempty(fs) || ~isnumeric(fs), fs = 10; end
        catch
            fs = 10;
        end
    end
end

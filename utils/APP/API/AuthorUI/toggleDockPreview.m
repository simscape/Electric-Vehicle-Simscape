function toggleDockPreview(app)
% TOGGLEDOCKPREVIEW Dock or undock the config preview panel.

    if app.PreviewDocked
        undockPreview(app);
    else
        dockPreview(app);
    end
end

% =========================================================================
function undockPreview(app)

    % Create floating figure
    mainPos = app.UIFigure.Position;
    app.PreviewFigure = uifigure( ...
        'Name', 'Config Preview', ...
        'Position', [mainPos(1)+mainPos(3)+10, mainPos(2), 400, mainPos(4)], ...
        'Resize', 'on', ...
        'CloseRequestFcn', @(~,~) dockPreview(app));

    % Reparent preview panel
    app.RightPanel.Parent = app.PreviewFigure;
    app.RightPanel.Position = [0 0 400 mainPos(4)];

    % Use grid in floating figure
    fg = uigridlayout(app.PreviewFigure, [1 1]);
    fg.Padding = [0 0 0 0];
    app.RightPanel.Parent = fg;
    app.RightPanel.Layout.Row = 1;
    app.RightPanel.Layout.Column = 1;

    % Collapse right column in main grid
    app.GridLayout.ColumnWidth = {220, '1x', 0};
    app.PreviewDocked = false;
    app.UndockBtn.Text = char(8601);
    app.UndockBtn.Tooltip = 'Dock preview back to main window';
end

% =========================================================================
function dockPreview(app)

    % Reparent back to main grid
    app.RightPanel.Parent = app.GridLayout;
    app.RightPanel.Layout.Row = 1;
    app.RightPanel.Layout.Column = 3;

    % Restore column width
    app.GridLayout.ColumnWidth = {220, '1x', 340};

    % Close floating figure
    if ~isempty(app.PreviewFigure) && isvalid(app.PreviewFigure)
        delete(app.PreviewFigure);
    end
    app.PreviewFigure = [];
    app.PreviewDocked = true;
    app.UndockBtn.Text = char(8599);
    app.UndockBtn.Tooltip = 'Undock preview to separate window';
end

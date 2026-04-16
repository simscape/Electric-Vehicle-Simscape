function selectionPreviewStatus(app, event)
%SELECTIONPREVIEWSTATUS Toggle visibility of the preview image panel.

    isHidden = app.HideShowButton.Value;

    if isHidden
        app.HideShowButton.Text            = 'Show';
        app.DescriptionGrid.RowHeight      = {'0.13x', '1x'};
        app.PreviewImage.Visible           = 'off';
        app.HideMenu.Enable                = "off";
        app.ShowMenu.Enable                = "on";
        app.HideShowButton.BackgroundColor = [1.00, 0.95, 0.93];
    else
        app.HideShowButton.Text            = 'Hide';
        app.DescriptionGrid.RowHeight      = {'1x', '1x'};
        app.PreviewImage.Visible           = 'on';
        app.HideMenu.Enable                = "on";
        app.ShowMenu.Enable                = "off";
        app.HideShowButton.BackgroundColor = [0.93, 1.00, 0.98];
    end
end

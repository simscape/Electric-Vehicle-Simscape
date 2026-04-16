function modelDescription(app, modelName)
    modelBaseName = erase(convertStringsToChars(modelName), '.slx');

    % Create unique PNG file name in temp folder
    timestamp = datestr(now, 'yyyymmddTHHMMSSFFF');
    tempPng = fullfile(tempdir, [modelBaseName, '_', timestamp, '.png']);
    root = getBEVProjectRoot(app);
    previewPng = fullfile(root, 'preview.png');

    d = uiprogressdlg(app.UIFigure, ...
        'Title','Please wait', ...
        'Message','Loading model description…', ...
        'Indeterminate','on', ...
        'Cancelable','off');

    try
        % Load silently if not already open
        wasLoaded = bdIsLoaded(modelBaseName);
        if ~wasLoaded
            ws = warning('off', 'all');
            load_system(modelName);
            warning(ws);
        end

        % Print canvas and fetch description
        print(['-s', modelBaseName], '-dpng', tempPng);
        print(['-s', modelBaseName], '-dpng', previewPng);
        desc = get_param(modelBaseName, 'Description');
        descHTML = descTextHTML(desc);
        app.HTML.HTMLSource = descHTML;

        % Close only if we opened it
        if ~wasLoaded
            try, close_system(modelBaseName, 0); catch, end
        end

        % Update image
        app.selectionPreviewPanel.Visible = 'on';
        app.DescriptionGrid.RowHeight = {'1x','1x'};
        app.PreviewImage.Visible = 'on';
        app.PreviewImage.ImageSource = tempPng;
        selectionPreviewStatus(app);
        % Pause to allow UI update, then delete temp file
        pause(1);
        delete(tempPng);
        close(d);

    catch ME
        close(d);
        uialert(app.UIFigure, ME.message, 'Error');
    end

    app.UIFigure.Pointer = 'arrow';
    app.ModelNameLabel.Text = modelName;
end

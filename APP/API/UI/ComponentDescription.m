function ComponentDescription(app, modelName)
%COMPONENTDESCRIPTION Generate preview snapshot and load component description text.
%   Also looks for published HTML documentation and adds a clickable link.

    modelBaseName = erase(convertStringsToChars(modelName), '.slx');
    root = getBEVProjectRoot(app);

    % Create unique PNG in temp folder
    timestamp = datestr(now, 'yyyymmddTHHMMSSFFF');
    tempPng    = fullfile(tempdir, [modelBaseName, '_', timestamp, '.png']);
    previewPng = fullfile(root, 'preview.png');

    d = uiprogressdlg(app.UIFigure, ...
        'Title', 'Please wait', ...
        'Message', 'Loading component description…', ...
        'Indeterminate', 'on', ...
        'Cancelable', 'off');

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

        % Look for published HTML documentation and add clickable link
        htmlPattern = fullfile(root, 'Components', '**', ...
            'Documentation', 'html', [modelBaseName 'Description.html']);
        htmlFiles = dir(htmlPattern);
        if ~isempty(htmlFiles)
            htmlPath = strrep( ...
                fullfile(htmlFiles(1).folder, htmlFiles(1).name), '\', '/');
            linkHTML = [ ...
                '<br><br><a href="#" id="docLink" style="color:#0072BD;font-weight:bold;">' ...
                'Open Documentation</a>' ...
                '<script>' ...
                'function setup(htmlComponent){' ...
                '  document.getElementById("docLink").addEventListener("click",function(e){' ...
                '    e.preventDefault();' ...
                '    htmlComponent.Data="' htmlPath '";' ...
                '  });' ...
                '}' ...
                '</script>'];
            descHTML = strrep(descHTML, '</body></html>', [linkHTML '</body></html>']);
            app.HTML.DataChangedFcn = @(src, ~) web(src.Data);
        end

        app.HTML.HTMLSource = descHTML;

        % Close only if we opened it
        if ~wasLoaded
            try, close_system(modelBaseName, 0); catch, end
        end

        % Update preview image
        app.selectionPreviewPanel.Visible = 'on';
        app.DescriptionGrid.RowHeight = {'1x', '1x'};
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

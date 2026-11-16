function ComponentDescription(app, modelName, context)
% COMPONENTDESCRIPTION Load a component's description and preview snapshot into the app.
%   ComponentDescription(app, modelName)
%   ComponentDescription(app, modelName, context)
%
%   Opens the model headlessly, captures a canvas snapshot, reads its
%   Description field, and (if available) adds a clickable link to published
%   HTML documentation.
%
%   context (optional) — struct with InstanceLabel, CompName, ParamFile
%   for enriched display in the description panel.
%
% Copyright 2026 The MathWorks, Inc.

    if nargin < 3, context = struct(); end

    modelBaseName = erase(convertStringsToChars(modelName), '.slx');
    root = getBEVProjectRoot(app);

    % Create unique PNG in temp folder
    timestamp = datestr(now, 'yyyymmddTHHMMSSFFF');
    tempPng    = fullfile(tempdir, [modelBaseName, '_', timestamp, '.png']);
    previewPng = fullfile(root, 'preview.png');

    % ---- Progress dialog ----
    progressDlg = uiprogressdlg(app.UIFigure, ...
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

        % Snapshot canvas (once) and restore zoom to avoid progressive shrinkage
        origZoom = get_param(modelBaseName, 'ZoomFactor');
        print(['-s', modelBaseName], '-dpng', tempPng);
        set_param(modelBaseName, 'ZoomFactor', origZoom);
        copyfile(tempPng, previewPng);
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

        % Inject instance/model/param context into description
        descHTML = injectContextBanner(descHTML, modelBaseName, context);

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
        close(progressDlg);

    catch ME
        if exist('wasLoaded','var') && ~wasLoaded
            try, close_system(modelBaseName, 0); catch, end
        end
        close(progressDlg);
        uialert(app.UIFigure, ME.message, 'Error');
    end

    app.UIFigure.Pointer = 'arrow';
    app.ModelNameLabel.Text = modelName;
end


function html = injectContextBanner(html, modelBaseName, context)
%INJECTCONTEXTBANNER Add instance/model/param summary table to description HTML.

    if ~isstruct(context) || ~isfield(context, 'InstanceLabel')
        return;
    end

    rows = {};
    rows{end+1} = sprintf('<tr><td><b>Instance</b></td><td>%s</td></tr>', context.InstanceLabel);
    rows{end+1} = sprintf('<tr><td><b>Component</b></td><td>%s</td></tr>', context.CompName);
    rows{end+1} = sprintf('<tr><td><b>Model</b></td><td>%s</td></tr>', modelBaseName);

    if isfield(context, 'ParamFile') && strlength(string(context.ParamFile)) > 0
        [~, pName, pExt] = fileparts(context.ParamFile);
        rows{end+1} = sprintf('<tr><td><b>Param File</b></td><td>%s%s</td></tr>', pName, pExt);
    else
        rows{end+1} = '<tr><td><b>Param File</b></td><td style="color:#999;">convention-based</td></tr>';
    end

    banner = [ ...
        '<table style="border-collapse:collapse;margin-bottom:12px;font-size:13px;">' ...
        strjoin(rows, '') ...
        '</table><hr style="border:none;border-top:1px solid #ccc;margin-bottom:10px;">'];

    % Insert after <body...> tag
    bodyEnd = regexp(html, '<body[^>]*>', 'end', 'once');
    if ~isempty(bodyEnd)
        html = [html(1:bodyEnd) banner html(bodyEnd+1:end)];
    end
end

function ComponentDescription(app,modelName)
            modelBaseName = erase(convertStringsToChars(modelName), '.slx');

            % Create unique PNG file name in temp folder
            timestamp = datestr(now, 'yyyymmddTHHMMSSFFF');
            tempPng = fullfile(tempdir, [modelBaseName, '_', timestamp, '.png']);
            root = getBEVProjectRoot(app);                          % project root
            previewPng = fullfile(root, 'preview.png');

            d = uiprogressdlg(app.UIFigure, ...
                'Title','Please wait', ...
                'Message','Loading component description…', ...
                'Indeterminate','on', ...
                'Cancelable','off');

            try
                % Load and print
                load_system(modelName);
                print(['-s', modelBaseName], '-dpng', tempPng);
                print(['-s', modelBaseName], '-dpng', previewPng);
                % Fetch the model description
                desc = get_param(modelBaseName, 'Description');
                descHTML = descTextHTML(desc);

                % Find HTML documentation and add clickable link via uihtml Data callback
                htmlDoc = fullfile(root, 'Components', '**', 'Documentation', 'html', [modelBaseName 'Description.html']);
                htmlFiles = dir(htmlDoc);
                if ~isempty(htmlFiles)
                    htmlPath = strrep(fullfile(htmlFiles(1).folder, htmlFiles(1).name), '\', '/');
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
                    app.HTML.DataChangedFcn = @(src,~) web(src.Data);
                end

                app.HTML.HTMLSource = descHTML;
                close_system(modelName, 0);

                % Update image
                app.selectionPreviewPanel.Visible = 'on';
                app.DescriptionGrid.RowHeight = {'1x','1x'};
                app.PreviewImage.Visible = 'on';
                app.PreviewImage.ImageSource = tempPng;
                selectionPreviewStatus(app);
                % Pause to allow UI update,
                pause(1);
               % then delete the file
                delete(tempPng);
                close(d);

            catch ME
                uialert(app.UIFigure, ME.message, 'Error');
            end

            app.UIFigure.Pointer = 'arrow';
            app.ModelNameLabel.Text = modelName;
        end

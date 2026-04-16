function openInstanceModel(app, comp, label)
    % OPENINSTANCEMODEL Opens the SLX file selected for a given instance
    %   app   - the app object
    %   comp  - component folder name
    %   label - instance label used as dropdown tag

    % Build the handle key
    % checkk this string conversion later
    key = matlab.lang.makeValidName([comp '_' label]);
    % Retrieve the corresponding dropdown handle
    if isfield(app.ComponentDropdowns, key)
        compSelected = app.ComponentDropdowns.(key);
        modelName = compSelected.Value;
        % Construct full model file path
        root = getBEVProjectRoot(app);                          % project root
        modelFile = fullfile(root, 'Components', char(comp), 'Model', modelName);
        % Open in Simulink if the file exists, else show alert
        if isfile(modelFile)
            open_system(modelFile);
        else
            uialert(app.UIFigure, sprintf('Model file not found:\n%s', modelFile), 'File Error');
        end
    else
        uialert(app.UIFigure, sprintf('Dropdown for %s not found.', key), 'Lookup Error');
    end
end

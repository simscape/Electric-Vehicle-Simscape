function showInstanceDescription(app, comp, label)
    % Find the dropdown for this instance
    key = matlab.lang.makeValidName([comp '_' label]);
    if ~isfield(app.ComponentDropdowns, key)
        uialert(app.UIFigure, ...
            sprintf('Couldn’t find dropdown for %s_%s', comp, label), ...
            'Lookup Error');
        return
    end
    dd = app.ComponentDropdowns.(key);

    % Grab the selected item (e.g. 'MotorDriveGear' or 'MyModel.slx')
    modelItem = dd.Value;

    % Ensure it ends with ".slx"
    [~, modelName, ~] = fileparts(modelItem);
    % if isempty(ext)
    %     modelName = [base, '.slx'];
    % else
    %     modelName = [base, ext];
    % end

    % Call your existing preview function with just the model name
    % (print -s expects the system name, so ModelDescriptiom strips the path)
    app.UIFigure.Pointer = 'watch';
    drawnow;
    ComponentDescription(app, modelName);
    app.UIFigure.Pointer = 'arrow';
end

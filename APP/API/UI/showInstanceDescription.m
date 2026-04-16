function showInstanceDescription(app, compName, label)
%SHOWINSTANCEDESCRIPTION Show model preview and description for a component instance.

    handleKey = matlab.lang.makeValidName([compName '_' label]);

    if ~isfield(app.ComponentDropdowns, handleKey)
        uialert(app.UIFigure, ...
            sprintf("Couldn't find dropdown for %s_%s", compName, label), ...
            'Lookup Error');
        return;
    end

    dropdown  = app.ComponentDropdowns.(handleKey);
    modelItem = dropdown.Value;

    [~, modelName] = fileparts(modelItem);

    app.UIFigure.Pointer = 'watch';
    drawnow;

    ComponentDescription(app, modelName);

    app.UIFigure.Pointer = 'arrow';
end

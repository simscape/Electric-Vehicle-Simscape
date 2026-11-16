function openInstanceModel(app, compName, label)
%OPENINSTANCEMODEL Open the SLX file selected for a given component instance.
%
% Copyright 2026 The MathWorks, Inc.

    handleKey = matlab.lang.makeValidName([compName '_' label]);

    if ~isfield(app.ComponentDropdowns, handleKey)
        uialert(app.UIFigure, ...
            sprintf('Dropdown for %s not found.', handleKey), 'Lookup Error');
        return;
    end

    dropdown  = app.ComponentDropdowns.(handleKey);
    modelName = dropdown.Value;

    root      = getBEVProjectRoot(app);
    modelFile = fullfile(root, 'Components', char(compName), 'Model', modelName);

    if isfile(modelFile)
        open_system(modelFile);
    else
        uialert(app.UIFigure, ...
            sprintf('Model file not found:\n%s', modelFile), 'File Error');
    end
end

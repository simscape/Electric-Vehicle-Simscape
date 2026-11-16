function showInstanceDescription(app, compName, label)
%SHOWINSTANCEDESCRIPTION Show model preview and description for a component instance.
%
% Copyright 2026 The MathWorks, Inc.

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

    % Build context for enriched description panel
    context = struct( ...
        'InstanceLabel', label, ...
        'CompName',      compName, ...
        'ParamFile',     '');

    ud = dropdown.UserData;
    if isstruct(ud) && isfield(ud, 'ParamFile') && strlength(string(ud.ParamFile)) > 0
        context.ParamFile = char(ud.ParamFile);
    elseif isstruct(ud) && isfield(ud, 'ParamMap') && isstruct(ud.ParamMap)
        modelBase = regexprep(char(modelItem), '\.slx$', '', 'ignorecase');
        if isfield(ud.ParamMap, modelBase)
            context.ParamFile = char(ud.ParamMap.(modelBase));
        end
    end

    app.UIFigure.Pointer = 'watch';
    drawnow;

    ComponentDescription(app, modelName, context);

    app.UIFigure.Pointer = 'arrow';
end

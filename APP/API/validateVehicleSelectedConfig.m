function selectionValid = validateVehicleSelectedConfig(app)
    % Read JSON
    data = jsondecode(fileread(app.ConfigDropDown.Value));
    platforms = fieldnames(data);
    selectionValid = true;
    vehConfigSelected = erase(app.VehicleTemplateDropDown.Value,".slx");
    vehIdx = find(strcmp(platforms, vehConfigSelected));
    platName = platforms{vehIdx};
    platData = data.(platName);
    % fprintf('Checking platform: %s\n', platName);

    % 1) Required fields
    % mustHave(platData, "Description", platName);
    mustHave(platData, "Components",  platName);
    % mustHave(platData, "Controls",    platName);

    % 2) Components: map -> { componentName: {Instances[], Models[]} }
    checkComponentsSection(platData.Components, platName);

    % 3) Controls: single object -> { Instances[], Models[] }
    % checkControlsSection(platData.Controls, platName);

    % disp("✅ JSON structure validated successfully.");
end

function mustHave(S, f, platName)
    if ~isfield(S, f)
        error("Platform '%s' missing required field: %s", platName, f);
    end
    return;
end

function checkComponentsSection(components, platName)
    if ~isstruct(components)
        error("In platform '%s', 'Components' must be a struct/object.", platName);
    end
    compNames = fieldnames(components);
    for i = 1:numel(compNames)
        name = compNames{i};
        node = components.(name);
        if ~isstruct(node)
            error("In platform '%s', Components.%s must be an object.", platName, name);
        end
        if ~isfield(node, 'Instances') || ~isfield(node, 'Models')
            error("In platform '%s', Components.%s must have 'Instances' and 'Models'.", platName, name);
        end
        assertStringList(node.Instances, platName, "Components."+name+".Instances");
        assertStringList(node.Models,    platName, "Components."+name+".Models");
    end
end

function checkControlsSection(controls, platName)
    if ~isstruct(controls)
        warning("In platform '%s', 'Controls' must be an object.", platName);
    end
    if ~isfield(controls, 'Instances') || ~isfield(controls, 'Models')
        warning("In platform '%s', 'Controls' must have top-level 'Instances' and 'Models'.", platName);
    end
    % assertStringList(controls.Instances, platName, "Controls.Instances");
    % assertStringList(controls.Models,    platName, "Controls.Models");
end

function assertStringList(val, platName, fieldPath)
    ok = (iscellstr(val)) || (isstring(val) && isvector(val) && all(strlength(val) >= 0));
    if ~ok
        error("In platform '%s', '%s' must be a list/array of strings.", platName, fieldPath);
    end
end

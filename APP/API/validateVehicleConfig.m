function valid = validateVehicleConfig(app, platformName)
%VALIDATEVEHICLECONFIG Validate the JSON config structure.
%   valid = validateVehicleConfig(app) validates ALL platforms in the config.
%   valid = validateVehicleConfig(app, platformName) validates one platform.

    data = jsondecode(fileread(app.ConfigDropDown.Value));
    allPlatforms = fieldnames(data);
    valid = true;

    if nargin < 2 || isempty(platformName)
        % Validate all platforms
        targets = allPlatforms;
    else
        % Validate selected platform only
        platformName = erase(string(platformName), ".slx");
        idx = find(strcmp(allPlatforms, platformName), 1);
        if isempty(idx)
            error("Platform '%s' not found in config.", platformName);
        end
        targets = allPlatforms(idx);
    end

    for p = 1:numel(targets)
        platName = targets{p};
        platData = data.(platName);

        mustHave(platData, "Components", platName);
        checkComponentsSection(platData.Components, platName);

        if isfield(platData, 'Controls')
            checkControlsSection(platData.Controls, platName);
        end
    end
end

function mustHave(S, f, platName)
    if ~isfield(S, f)
        error("Platform '%s' missing required field: %s", platName, f);
    end
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
end

function assertStringList(val, platName, fieldPath)
    ok = iscellstr(val) || (isstring(val) && isvector(val));
    if ~ok
        error("In platform '%s', '%s' must be a list/array of strings.", platName, fieldPath);
    end
end

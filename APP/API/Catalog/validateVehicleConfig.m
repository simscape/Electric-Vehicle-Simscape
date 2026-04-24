function valid = validateVehicleConfig(data, platformName)
%VALIDATEVEHICLECONFIG Validate the JSON config structure for one or all platforms.
%   valid = validateVehicleConfig(data)               — validate ALL platforms
%   valid = validateVehicleConfig(data, platformName)  — validate one platform
%
%   data — parsed JSON struct (from jsondecode), not the app object.
%
%   Required fields per platform:
%     Components           — struct with named component types
%     Components.<type>.Instances  — string list
%     Components.<type>.Models     — string list
%
%   Optional fields:
%     Controls             — struct with Instances and Models
%
% Copyright 2026 The MathWorks, Inc.

    allPlatforms = fieldnames(data);
    valid = true;

    % Determine which platforms to check
    if nargin < 2 || isempty(platformName)
        targets = allPlatforms;
    else
        platformName = erase(string(platformName), ".slx");
        idx = find(strcmp(allPlatforms, platformName), 1);
        if isempty(idx)
            error("Platform '%s' not found in config.", platformName);
        end
        targets = allPlatforms(idx);
    end

    % Validate each target platform
    for p = 1:numel(targets)
        platName = targets{p};
        platData = data.(platName);

        % Components section is required
        mustHaveField(platData, "Components", platName);
        checkComponentsSection(platData.Components, platName);

        % Controls section is optional
        if isfield(platData, 'Controls')
            checkControlsSection(platData.Controls, platName);
        end
    end
end

%% Validation helpers

function mustHaveField(S, fieldName, platName)
%MUSTHAVEFIELD Error if a required field is missing from the platform struct.
    if ~isfield(S, fieldName)
        error("Platform '%s' missing required field: %s", platName, fieldName);
    end
end

function checkComponentsSection(components, platName)
%CHECKCOMPONENTSSECTION Validate all component types under Components.
    if ~isstruct(components)
        error("In platform '%s', 'Components' must be a struct/object.", platName);
    end

    compNames = fieldnames(components);
    for i = 1:numel(compNames)
        typeName = compNames{i};
        node     = components.(typeName);

        if ~isstruct(node)
            error("In platform '%s', Components.%s must be an object.", ...
                platName, typeName);
        end

        if ~isfield(node, 'Instances') || ~isfield(node, 'Models')
            error("In platform '%s', Components.%s must have 'Instances' and 'Models'.", ...
                platName, typeName);
        end

        assertStringList(node.Instances, platName, "Components." + typeName + ".Instances");
        assertStringList(node.Models,    platName, "Components." + typeName + ".Models");
    end
end

function checkControlsSection(controls, platName)
%CHECKCONTROLSSECTION Validate the optional Controls section.
    if ~isstruct(controls)
        warning("In platform '%s', 'Controls' must be an object.", platName);
    end

    if ~isfield(controls, 'Instances') || ~isfield(controls, 'Models')
        warning("In platform '%s', 'Controls' must have top-level 'Instances' and 'Models'.", ...
            platName);
    end
end

function assertStringList(val, platName, fieldPath)
%ASSERTSTRINGLIST Error if a value is not a cell/string array of strings.
    ok = iscellstr(val) || (isstring(val) && isvector(val));
    if ~ok
        error("In platform '%s', '%s' must be a list/array of strings.", ...
            platName, fieldPath);
    end
end

function componentLookup = buildComponentModelLookup(projectRoot)
% BUILDCOMPONENTMODELLOOKUP Scan Components/ folders and map model names.
%   componentLookup = buildComponentModelLookup(projectRoot)
%
%   Scans every subfolder under Components/ for .slx files in Model/,
%   and builds a lookup map from lowercase model basename to component info.
%
%   Output:
%     componentLookup — containers.Map keyed by lowercase model basename,
%                       values are structs with fields:
%                         ComponentName   — folder name (e.g., 'MotorDrive')
%                         ComponentFolder — full path to Model/ subfolder
%                         AllModels       — string array of all .slx basenames
%
% Copyright 2026 The MathWorks, Inc.

    % ---- Discover component folders ----
    componentsDir = fullfile(projectRoot, 'Components');
    componentFolders = dir(componentsDir);
    componentFolders = componentFolders([componentFolders.isdir]);
    componentFolders = componentFolders(~ismember({componentFolders.name}, {'.', '..'}));

    componentLookup = containers.Map('KeyType', 'char', 'ValueType', 'any');

    % ---- Map each component's models to the lookup ----
    for idx = 1:numel(componentFolders)
        compName = componentFolders(idx).name;
        modelDir = fullfile(componentsDir, compName, 'Model');

        if ~isfolder(modelDir)
            continue;
        end

        slxFileNames = getSLXFiles(modelDir);
        modelBasenames = strings(numel(slxFileNames), 1);

        for fileIdx = 1:numel(slxFileNames)
            [~, modelBasenames(fileIdx)] = fileparts(slxFileNames{fileIdx});
        end

        compInfo = struct( ...
            'ComponentName',   string(compName), ...
            'ComponentFolder', string(modelDir), ...
            'AllModels',       modelBasenames);

        for fileIdx = 1:numel(modelBasenames)
            lookupKey = lower(char(modelBasenames(fileIdx)));
            componentLookup(lookupKey) = compInfo;
        end
    end
end

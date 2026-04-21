function populateConfigDropDown(app)
%POPULATECONFIGDROPDOWN Scan Preset + User config folders and populate the dropdown.
%   populateConfigDropDown(app)
%
%   Sets ConfigDropDown.Items (display names) and ItemsData (full paths)
%   so that fileread(app.ConfigDropDown.Value) resolves without needing
%   the folder on the MATLAB path.
%
%   Preset files appear first, then a separator, then user-saved files
%   prefixed with [Saved].
% Copyright 2026 The MathWorks, Inc.

    presetFolder = getPresetConfigFolder();
    userFolder   = getUserConfigFolder();

    items     = {};
    itemsData = {};

    % ---- Preset configs ----
    [items, itemsData] = appendJsonFiles(items, itemsData, presetFolder, '');

    % ---- User-saved configs ----
    userItems     = {};
    userItemsData = {};
    [userItems, userItemsData] = appendJsonFiles(userItems, userItemsData, userFolder, '');

    % ---- Merge with separator if both sections have files ----
    if ~isempty(items) && ~isempty(userItems)
        items{end+1}     = [char(repmat(8212, 1, 4)), ' Saved Setups ', char(repmat(8212, 1, 4))];
        itemsData{end+1} = '__SEPARATOR__';
    end

    items     = [items,     userItems];
    itemsData = [itemsData, userItemsData];

    if isempty(items)
        uialert(app.UIFigure, ...
            'No config JSON files found in Preset or User folders.', 'Error');
        return;
    end

    % ---- Populate dropdown ----
    app.ConfigDropDown.Items     = items;
    app.ConfigDropDown.ItemsData = itemsData;

    % ---- Default selection: VehicleTemplateConfig.json ----
    idx = find(strcmp(items, 'VehicleTemplateConfig.json'), 1);

    if ~isempty(idx)
        app.ConfigDropDown.Value = itemsData{idx};
    else
        % Pick first non-separator item
        firstReal = find(~strcmp(itemsData, '__SEPARATOR__'), 1);
        if ~isempty(firstReal)
            app.ConfigDropDown.Value = itemsData{firstReal};
        end
    end
end

%% Local helper

function [items, itemsData] = appendJsonFiles(items, itemsData, folder, prefix)
%APPENDJSONFILES Append .json filenames and full paths from a folder.
    if ~isfolder(folder), return; end

    files = dir(fullfile(folder, '*.json'));

    for i = 1:numel(files)
        items{end+1}     = [prefix, files(i).name];                     %#ok<AGROW>
        itemsData{end+1} = fullfile(files(i).folder, files(i).name);    %#ok<AGROW>
    end
end

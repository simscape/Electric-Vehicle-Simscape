function populateConfigDropdowns(app)
% POPULATECONFIGDROPDOWNS Scan Preset and User config folders and fill all config dropdowns.

    presetFolder = getPresetConfigFolder();
    userFolder   = getUserConfigFolder();
    items = {'Select config...'};
    itemsData = {''};

    if isfolder(presetFolder)
        d = dir(fullfile(presetFolder, '*.json'));
        for k = 1:numel(d)
            items{end+1} = d(k).name; %#ok<AGROW>
            itemsData{end+1} = fullfile(d(k).folder, d(k).name); %#ok<AGROW>
        end
    end
    if isfolder(userFolder)
        d = dir(fullfile(userFolder, '*.json'));
        for k = 1:numel(d)
            items{end+1} = ['[User] ' d(k).name]; %#ok<AGROW>
            itemsData{end+1} = fullfile(d(k).folder, d(k).name); %#ok<AGROW>
        end
    end

    targets = {app.RegConfigDropDown, app.CtrlConfigDropDown, ...
               app.FidConfigDropDown, app.ClnConfigDropDown, ...
               app.SysConfigDropDown, app.PreviewConfigDropDown};
    for k = 1:numel(targets)
        targets{k}.Items = items;
        targets{k}.ItemsData = itemsData;
        targets{k}.Value = '';
    end
end

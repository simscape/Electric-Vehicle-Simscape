function populateRegTemplates(app)
% POPULATEREGTEMPLATES Scan VehicleTemplate folder and fill template dropdowns.

    tmplDir = fullfile(app.ProjectRoot, 'Model', 'VehicleTemplate');
    items = {'Select template...'};
    itemsData = {''};

    if isfolder(tmplDir)
        d = dir(fullfile(tmplDir, '*.slx'));
        for k = 1:numel(d)
            [~, name] = fileparts(d(k).name);
            items{end+1} = name; %#ok<AGROW>
            itemsData{end+1} = fullfile(d(k).folder, d(k).name); %#ok<AGROW>
        end
    end

    app.RegTemplateDropDown.Items = items;
    app.RegTemplateDropDown.ItemsData = itemsData;
    app.UpdTemplateDropDown.Items = items;
    app.UpdTemplateDropDown.ItemsData = itemsData;
end

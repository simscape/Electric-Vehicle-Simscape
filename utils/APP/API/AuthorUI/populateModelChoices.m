function populateModelChoices(app, configPath, templateKey, componentName, targetDD, mode)
% POPULATEMODELCHOICES Fill model dropdown from disk or config.
%
%   populateModelChoices(app, cfg, tmpl, comp, dd)          — all disk models (default)
%   populateModelChoices(app, cfg, tmpl, comp, dd, "delete") — in-config models only
%
% Copyright 2026 The MathWorks, Inc.

    if nargin < 6, mode = "add"; end

    tmpl = char(templateKey);
    comp = char(componentName);

    [cfg, ~] = bevConfigRead(configPath, app.ProjectRoot);

    % Get in-config models
    inConfig = {};
    if isfield(cfg, tmpl)
        if strcmp(comp, 'Controls')
            if isfield(cfg.(tmpl), 'Controls') && isfield(cfg.(tmpl).Controls, 'Models')
                m = cfg.(tmpl).Controls.Models;
                if ischar(m), m = {m}; elseif isstring(m), m = cellstr(m); end
                inConfig = m(:)';
            end
        elseif isfield(cfg.(tmpl), 'Components') ...
                && isfield(cfg.(tmpl).Components, comp) ...
                && isfield(cfg.(tmpl).Components.(comp), 'Models')
            m = cfg.(tmpl).Components.(comp).Models;
            if ischar(m), m = {m}; elseif isstring(m), m = cellstr(m); end
            inConfig = m(:)';
        end
    end

    items = {'Select model...'};
    itemsData = {''};

    if mode == "add"
        modelDir = fullfile(app.ProjectRoot, 'Components', comp, 'Model');
        if isfolder(modelDir)
            slxFiles = dir(fullfile(modelDir, '*.slx'));
            for k = 1:numel(slxFiles)
                [~, name] = fileparts(slxFiles(k).name);
                if ismember(name, inConfig)
                    items{end+1} = [name ' (in config)']; %#ok<AGROW>
                else
                    items{end+1} = [name ' (add)']; %#ok<AGROW>
                end
                itemsData{end+1} = name; %#ok<AGROW>
            end
        end
    else
        for k = 1:numel(inConfig)
            items{end+1} = inConfig{k}; %#ok<AGROW>
            itemsData{end+1} = inConfig{k}; %#ok<AGROW>
        end
    end

    targetDD.Items = items;
    targetDD.ItemsData = itemsData;
    targetDD.Value = '';
end

function populateControllerModels(app, mode)
% POPULATECONTROLLERMODELS Fill controller dropdown from disk or config.
%
%   populateControllerModels(app)          — scan disk (default)
%   populateControllerModels(app, "config") — show only in-config models
%
% Copyright 2026 The MathWorks, Inc.

    if nargin < 2, mode = "disk"; end

    items = {'Select controller...'};
    itemsData = {''};

    if mode == "config"
        cfgPath = string(app.CtrlConfigDropDown.Value);
        tmpl    = string(app.CtrlTemplateDropDown.Value);
        if strlength(cfgPath) > 0 && strlength(tmpl) > 0
            [cfg, ~] = bevConfigRead(cfgPath, app.ProjectRoot);
            if isfield(cfg, char(tmpl)) && isfield(cfg.(char(tmpl)), 'Controls') ...
                    && isfield(cfg.(char(tmpl)).Controls, 'Models')
                m = cfg.(char(tmpl)).Controls.Models;
                if ischar(m), m = {m}; elseif isstring(m), m = cellstr(m); end
                for k = 1:numel(m)
                    items{end+1} = m{k}; %#ok<AGROW>
                    itemsData{end+1} = m{k}; %#ok<AGROW>
                end
            end
        end
    else
        ctrlDir = fullfile(app.ProjectRoot, 'Components', 'Controller', 'Model');
        if isfolder(ctrlDir)
            slxFiles = dir(fullfile(ctrlDir, '*.slx'));
            for k = 1:numel(slxFiles)
                [~, baseName] = fileparts(slxFiles(k).name);
                items{end+1} = baseName; %#ok<AGROW>
                itemsData{end+1} = baseName; %#ok<AGROW>
            end
        end
    end

    app.CtrlModelDropDown.Items = items;
    app.CtrlModelDropDown.ItemsData = itemsData;
    app.CtrlModelDropDown.Value = '';
end

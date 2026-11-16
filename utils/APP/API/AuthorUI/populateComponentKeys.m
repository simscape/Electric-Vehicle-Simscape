function populateComponentKeys(app, configPath, templateKey, targetDD)
% POPULATECOMPONENTKEYS List components for a template and fill dropdown.

    [cfg, ~] = bevConfigRead(configPath, app.ProjectRoot);
    if ~isfield(cfg, templateKey), return; end

    tmpl = cfg.(templateKey);
    if ~isfield(tmpl, 'Components') || ~isstruct(tmpl.Components), return; end

    keys = fieldnames(tmpl.Components);
    targetDD.Items = [{'Select component...'}, keys(:)'];
    targetDD.ItemsData = [{''},                 keys(:)'];
    targetDD.Value = '';
end

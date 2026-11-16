function populateTemplateKeys(app, configPath, targetDD)
% POPULATETEMPLATEKEYS Read config and populate a template dropdown with its keys.

    [cfg, ~] = bevConfigRead(configPath, app.ProjectRoot);
    if isempty(fieldnames(cfg)), return; end

    keys = fieldnames(cfg);
    targetDD.Items = [{'Select template...'}, keys(:)'];
    targetDD.ItemsData = [{''},               keys(:)'];
    targetDD.Value = '';
end

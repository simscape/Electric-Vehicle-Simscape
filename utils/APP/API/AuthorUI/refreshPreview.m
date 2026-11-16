function refreshPreview(app)
% REFRESHPREVIEW Render config summary HTML in the preview panel and validate.

    configPath  = app.PreviewConfigDropDown.Value;
    templateKey = app.PreviewTemplateDropDown.Value;
    if isempty(configPath) || isempty(templateKey)
        return;
    end

    root = app.ProjectRoot;
    try
        [cfg, resolvedPath] = bevConfigRead(configPath, root);
    catch
        app.PreviewHTML.HTMLSource = '<html><body style="color:red;">Failed to read config.</body></html>';
        return;
    end
    if ~isfield(cfg, templateKey), return; end

    [~, cfgName, cfgExt] = fileparts(resolvedPath);
    tmplNames = strjoin(string(fieldnames(cfg)), ", ");

    header = sprintf([ ...
        '<div style="position:relative;background:#f5f5f5;border:1px solid #d0d0d0;' ...
        'border-radius:10px;padding:12px 14px 12px 22px;margin-bottom:14px;font-size:12px;">' ...
        '<div style="position:absolute;left:5px;top:8px;bottom:8px;width:5px;' ...
        'background:#0072BD;border-radius:4px;"></div>' ...
        '<div style="font-size:11px;color:#999;margin-bottom:2px;">Config: ' ...
        '<span style="font-family:monospace;">%s%s</span></div>' ...
        '<div style="font-size:11px;color:#999;margin-bottom:6px;">Templates: ' ...
        '<span style="font-family:monospace;color:#155724;">%s</span></div>' ...
        '<div style="font-size:15px;font-weight:bold;">Selected: ' ...
        '<span style="color:#0072BD;">%s</span></div></div>'], ...
        cfgName, cfgExt, tmplNames, templateKey);

    body = buildConfigSummaryHTML(cfg, templateKey, root);

    app.PreviewHTML.HTMLSource = ['<html><body style="font-family:Segoe UI,Arial,sans-serif;' ...
        'font-size:13px;padding:6px 10px;">' header char(body) '</body></html>'];

    try
        validateVehicleConfig(cfg, templateKey);
        app.ValidationLamp.Color   = app.GREEN;
        app.ValidationLamp.Tooltip = 'Config is valid';
        app.ValidationLabel.Text   = 'Config is valid';
    catch ME
        app.ValidationLamp.Color   = app.RED;
        app.ValidationLamp.Tooltip = 'Validation failed';
        app.ValidationLabel.Text   = ME.message;
    end
end

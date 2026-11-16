function jsonDescriptionView(app)
% JSONDESCRIPTIONVIEW Show structured config summary in the description panel.
%   jsonDescriptionView(app)
%
%   Reads the selected config JSON, renders a clean vertical layout
%   showing template overview with instance/model/param mapping and
%   validation warnings, and displays it in the app HTML panel.
%
% Copyright 2026 The MathWorks, Inc.

    configPath = app.ConfigDropDown.Value;
    root = getBEVProjectRoot(app);
    [cfg, ~] = bevConfigRead(configPath, root);
    tmpl = erase(app.VehicleTemplateDropDown.Value, '.slx');

    [~, cfgName, cfgExt] = fileparts(configPath);
    configDisplay = [cfgName cfgExt];

    % Template list
    tmplNames = string(fieldnames(cfg));
    tmplList  = strjoin(tmplNames, ", ");

    % BEV model name (saved setups only)
    tmplData = cfg.(tmpl);
    if isfield(tmplData, 'BEVModel') && ~isempty(tmplData.BEVModel)
        modelLine = "<div style=""font-size:12px;margin-top:4px;"">" + ...
            "Model: <span style=""font-family:monospace;font-weight:bold;"">" + ...
            string(tmplData.BEVModel) + "</span></div>";
    else
        modelLine = "";
    end

    % Header card — config, templates, selected, model
    headerCard = ...
        "<div style=""position:relative;" + ...
        "background:#f5f5f5;" + ...
        "border:1px solid #d0d0d0;" + ...
        "border-radius:10px;" + ...
        "padding:10px 12px 10px 18px;" + ...
        "margin:4px 0 12px 0;" + ...
        "font-size:12px;"">" + ...
        "<div style=""position:absolute;left:4px;top:6px;bottom:6px;" + ...
        "width:6px;background:#D95319;border-radius:6px;""></div>" + ...
        "<div style=""font-size:11px;color:#777;margin-bottom:2px;"">Config: " + ...
        "<span style=""font-family:monospace;"">" + configDisplay + "</span></div>" + ...
        "<div style=""font-size:11px;color:#777;margin-bottom:6px;"">Templates: " + ...
        "<span style=""font-family:monospace;color:#155724;"">" + tmplList + "</span></div>" + ...
        "<div style=""font-size:15px;font-weight:bold;"">" + ...
        "Selected: <span style=""color:#D95319;"">" + tmpl + "</span></div>" + ...
        modelLine + ...
        "</div>";

    % Structured summary
    inner = string(buildConfigSummaryHTML(cfg, tmpl, root));

    % Assemble final HTML
    html = "<html><body style=""font-family:system-ui,Segoe UI,Arial,sans-serif;font-size:13px;padding:4px 8px;"">" + ...
        headerCard + inner + ...
        "</body></html>";

    app.HTML.HTMLSource = char(html);

    % Layout
    app.selectionPreviewPanel.Visible = 'off';
    app.DescriptionGrid.RowHeight = {'0x','1x'};

    % Disable view menu
    app.HideMenu.Enable = "off";
    app.ShowMenu.Enable = "off";
end

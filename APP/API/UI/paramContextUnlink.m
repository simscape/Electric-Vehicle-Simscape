function paramContextUnlink(app, btn, dd, rootFolder)
%PARAMCONTEXTUNLINK Context menu action: unlink param file, reset to default.

    % Clear the explicit link
    if isfield(dd.UserData, 'ParamFile')
        dd.UserData = rmfield(dd.UserData, 'ParamFile');
    end

    % Re-discover the default param file (e.g. <Model>Params.m)
    compName = '';
    if isstruct(dd.UserData) && isfield(dd.UserData, 'CompName')
        compName = dd.UserData.CompName;
    end
    note = computeParamMissingNote(compName, dd, rootFolder);

    % Build user message
    if isstruct(dd.UserData) && isfield(dd.UserData, 'ParamFile') ...
            && strlength(string(dd.UserData.ParamFile)) > 0
        msg = sprintf("Link cleared. Reset to default: %s", dd.UserData.ParamFile);
    else
        msg = "Link cleared. No default param file found — right-click to link one.";
    end

    try
        uialert(app.UIFigure, msg, "Unlinked", 'Icon', 'info');
    catch ME
        warning('BEVapp:paramContextUnlink', 'uialert failed: %s', ME.message);
    end

    % Refresh tooltip (now shows default param file)
    updateParamTooltip(btn, dd);

    % Update the red note label
    if isstruct(dd.UserData) ...
            && isfield(dd.UserData, 'ParamStatusLabel') ...
            && ~isempty(dd.UserData.ParamStatusLabel) ...
            && isvalid(dd.UserData.ParamStatusLabel)
        if strlength(note) ~= 0
            dd.UserData.ParamStatusLabel.Text    = string(note);
            dd.UserData.ParamStatusLabel.Visible = 'on';
        else
            dd.UserData.ParamStatusLabel.Text    = "";
            dd.UserData.ParamStatusLabel.Visible = 'off';
        end
    end
end

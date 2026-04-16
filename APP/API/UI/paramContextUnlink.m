function paramContextUnlink(app, btn, dd, rootFolder)
%PARAMCONTEXTUNLINK Context menu action: unlink param file from this instance.

    if isfield(dd.UserData, 'ParamFile')
        dd.UserData = rmfield(dd.UserData, 'ParamFile');
    end

    try
        uialert(app.UIFigure, ...
            "Param file link cleared. The button will use auto-detect.", ...
            "Unlinked", 'Icon', 'info');
    catch ME
        warning('BEVapp:paramContextUnlink', 'uialert failed: %s', ME.message);
    end

    % Refresh tooltip
    updateParamTooltip(btn, dd, rootFolder);

    % Hide the red note
    if isstruct(dd.UserData) ...
            && isfield(dd.UserData, 'ParamStatusLabel') ...
            && isvalid(dd.UserData.ParamStatusLabel)
        dd.UserData.ParamStatusLabel.Text    = "";
        dd.UserData.ParamStatusLabel.Visible = 'off';
    end
end

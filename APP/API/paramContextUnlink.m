function paramContextUnlink(app, btn, dd, rootFolder)
%PARAMCONTEXTUNLINK Context menu action: unlink param file from this instance.
    try
        if isfield(dd.UserData,'ParamFile')
            dd.UserData = rmfield(dd.UserData, 'ParamFile');
        end
    catch
    end
    try
        uialert(app.UIFigure, "Param file link cleared. The button will use auto-detect.", "Unlinked", 'Icon','info');
    catch
    end
    % After setting/clearing dd.UserData.ParamFile:
    updateParamTooltip(btn, dd, rootFolder);

    % Also refresh the red line:
    try
        if isstruct(dd.UserData) && isfield(dd.UserData,'ParamStatusLabel') && isvalid(dd.UserData.ParamStatusLabel)
            L = dd.UserData.ParamStatusLabel;
            L.Text = "";
            L.Visible = 'off';
        end
    catch
    end

    updateParamTooltip(btn, dd, []);
end

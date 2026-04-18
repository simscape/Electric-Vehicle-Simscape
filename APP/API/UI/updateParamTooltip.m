function updateParamTooltip(btn, dd)
%UPDATEPARAMTOOLTIP Refresh param button tooltip based on current ParamFile.
    tip = "No param file found — right-click to link one";
    if isstruct(dd.UserData) && isfield(dd.UserData, 'ParamFile')
        pf = string(dd.UserData.ParamFile);
        if strlength(pf) > 0
            [~, name, ext] = fileparts(char(pf));
            if exist(pf, 'file')
                tip = sprintf("Param: %s%s", name, ext);
            else
                tip = sprintf("Param (missing): %s%s", name, ext);
            end
        end
    end
    btn.Tooltip = char(tip);
end

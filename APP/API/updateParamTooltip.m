function updateParamTooltip(btn, dd, ~)
%UPDATEPARAMTOOLTIP Refresh param button tooltip based on linked/auto state.
    tip = "Param file: auto-detect <ModelName>Params.m";
    try
        if isstruct(dd.UserData) && isfield(dd.UserData, 'ParamFile')
            linked = string(dd.UserData.ParamFile);
            if strlength(linked) > 0
                if exist(linked, 'file')
                    tip = "Param file (linked): " + linked;
                else
                    tip = "Param file (linked but missing): " + linked + ...
                          " — will fall back to auto-detect";
                end
            end
        end
    catch
    end
    btn.Tooltip = char(tip);
end

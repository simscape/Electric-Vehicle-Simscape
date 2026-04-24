function updateParamTooltip(btn, dd)
% UPDATEPARAMTOOLTIP Refresh the param button tooltip to reflect the current ParamFile link.
%   updateParamTooltip(btn, dd)
%
%   Shows the linked filename, a "missing" warning, or a prompt to link one.
%
% Copyright 2026 The MathWorks, Inc.
    tip = "No param file found — right-click to link one";
    if isstruct(dd.UserData) && isfield(dd.UserData, 'ParamFile')
        paramFile = string(dd.UserData.ParamFile);
        if strlength(paramFile) > 0
            [~, name, ext] = fileparts(char(paramFile));
            if exist(paramFile, 'file')
                tip = sprintf("Param: %s%s", name, ext);
            else
                tip = sprintf("Param (missing): %s%s", name, ext);
            end
        end
    end
    btn.Tooltip = char(tip);
end

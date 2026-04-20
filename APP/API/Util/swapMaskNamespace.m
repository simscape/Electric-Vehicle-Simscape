function swapMaskNamespace(blockPath, oldNs, newNs)
% swapMaskNamespace  Regex-swap the namespace prefix on all mask parameter values.
%
%   swapMaskNamespace(blockPath, oldNs, newNs)
%
%   Replaces the struct namespace prefix in every mask parameter's Value field.
%   e.g., swapMaskNamespace('BEV/Battery Pump', 'pump', 'pumpBattery')
%     pump.pump_displacement  →  pumpBattery.pump_displacement
%     pump.coolant_pipe_D     →  pumpBattery.coolant_pipe_D
%
%   Use with discoverParamNamespace to find the namespace from a param file:
%     defaultNs  = discoverParamNamespace('PumpParams.m');
%     instanceNs = discoverParamNamespace('BatteryPumpParams.m');
%     swapMaskNamespace(blockPath, defaultNs, instanceNs);

% Copyright 2025-2026 The MathWorks, Inc.

    mask = Simulink.Mask.get(blockPath);
    if isempty(mask)
        error('swapMaskNamespace:noMask', 'No mask found on %s', blockPath);
    end

    pattern = ['^' oldNs '\.'];
    replacement = [newNs '.'];
    for k = 1:numel(mask.Parameters)
        mask.Parameters(k).Value = regexprep(mask.Parameters(k).Value, pattern, replacement);
    end
end

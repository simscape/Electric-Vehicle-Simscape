function detect = platformDetectFromBEVModel(app, rootFolder)
%PLATFORMDETECTFROMBEVMODEL Detect vehicle platform from BEV model SSRs.
%   Scans the BEV model for Subsystem Reference blocks and checks if any
%   match the vehicle template dropdown items.
%
% Copyright 2026 The MathWorks, Inc.

    detect = false;

    vehPlatformItemsRaw = string(app.VehicleTemplateDropDown.Items);
    if isempty(vehPlatformItemsRaw), return; end

    [detect, ~] = detectSSRFromBEVModel(app.BEVModelDropDown.Value, rootFolder, vehPlatformItemsRaw);

    if ~detect
        uialert(app.UIFigure, ...
            "No Vehicle Platform referenced model matched the available platform list. " + ...
            "Component creation will be aborted.", ...
            "Vehicle Platform Not Detected", 'Icon','error');
    end
end

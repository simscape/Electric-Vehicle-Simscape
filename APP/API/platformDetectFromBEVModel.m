function detect = platformDetectFromBEVModel(app, rootFolder)
%PLATFORMDETECTFROMBEVMODEL Detect vehicle platform from BEV model SSRs.
%   Scans the BEV model for Subsystem Reference blocks and checks if any
%   match the vehicle template dropdown items.

    detect = false;

    vehPlatformItemsRaw = string(app.VehicleTemplateDropDown.Items);
    if isempty(vehPlatformItemsRaw), return; end

    [detect, ~] = detectSSRFromBEVModel(app, rootFolder, vehPlatformItemsRaw);

    if ~detect
        try
            uialert(app.UIFigure, ...
                "No Vehicle Platform referenced model matched the available platform list. " + ...
                "Component creation will be aborted.", ...
                "Vehicle Platform Not Detected", 'Icon','error');
        catch
        end
    end
end

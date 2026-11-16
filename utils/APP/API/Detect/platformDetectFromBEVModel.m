function detect = platformDetectFromBEVModel(app, rootFolder)
%PLATFORMDETECTFROMBEVMODEL Detect vehicle platform from BEV model SSRs.
%   Scans the BEV model for Subsystem Reference blocks and checks if any
%   match the vehicle template dropdown items.
%
% Copyright 2026 The MathWorks, Inc.

    detect = false;

    % ---- Build candidate list from ALL templates on disk ----
    %   The system model may reference any template, not just the ones in
    %   the selected config. Scan the full VehicleTemplate folder so
    %   switching configs never fails platform detection.
    templateDir = fullfile(rootFolder, 'Model', 'VehicleTemplate');
    diskTemplates = string(getSLXFiles(templateDir));
    dropdownItems = string(app.VehicleTemplateDropDown.Items);
    vehPlatformItemsRaw = unique([dropdownItems(:); diskTemplates(:)]);
    if isempty(vehPlatformItemsRaw), return; end

    [detect, ~] = detectSSRFromBEVModel(app.BEVModelDropDown.Value, rootFolder, vehPlatformItemsRaw);

    if ~detect
        uialert(app.UIFigure, ...
            "No Vehicle Platform referenced model matched the available platform list. " + ...
            "Component creation will be aborted.", ...
            "Vehicle Platform Not Detected", 'Icon','error');
    end
end

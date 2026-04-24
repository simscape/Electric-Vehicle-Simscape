function detect = controlsDetectFromBEVModel(app, rootFolder)
%CONTROLSDETECTFROMBEVMODEL Detect controller from BEV model SSRs.
%   Populates the controller dropdown from the Controller/Model folder,
%   then scans the BEV model for a matching Subsystem Reference.
%
% Copyright 2026 The MathWorks, Inc.

    detect = false;

    controlFolder = fullfile(rootFolder, 'Components', 'Controller', 'Model');
    app.ControlSelectionDropDown.Items = getSLXFiles(controlFolder);

    controlsItemsRaw = string(app.ControlSelectionDropDown.Items);
    if isempty(controlsItemsRaw), return; end

    [detect, ~] = detectSSRFromBEVModel(app.BEVModelDropDown.Value, rootFolder, controlsItemsRaw);

    if ~detect
        uialert(app.UIFigure, ...
            "No Controller referenced model matched the available platform list. " + ...
            "Control selection will be aborted.", ...
            "Controller Not Detected", 'Icon','error');
    end
end

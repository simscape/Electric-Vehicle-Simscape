function detect = controlsDetectFromBEVModel(app, rootFolder)
%CONTROLSDETECTFROMBEVMODEL Detect controller from BEV model SSRs.
%   Populates the controller dropdown from the Controller/Model folder,
%   then scans the BEV model for a matching Subsystem Reference.

    detect = false;

    controlFolder = fullfile(rootFolder, 'Components', 'Controller', 'Model');
    app.ControlSelectionDropDown.Items = getSLXFiles(controlFolder);

    controlsItemsRaw = string(app.ControlSelectionDropDown.Items);
    if isempty(controlsItemsRaw), return; end

    [detect, ~] = detectSSRFromBEVModel(app, rootFolder, controlsItemsRaw);

    if ~detect
        try
            uialert(app.UIFigure, ...
                "No Controller referenced model matched the available platform list. " + ...
                "Control selection will be aborted.", ...
                "Controller Not Detected", 'Icon','error');
        catch
        end
    end
end

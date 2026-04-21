function modelDashboardSetup(app)
%MODELDASHBOARDSETUP Configure model HMI blocks from app toggle buttons.
%   Sets AWD, Charging/BatCmd, and Regen Gain blocks in the live model.

    modelName    = erase(app.BEVModelDropDown.Value, '.slx');
    awdStatus    = double(app.AWDButton.Value);
    regenStatus  = double(app.RegenButton.Value);
    chargeStatus = double(app.ChargingButton.Value);

    try
        % Load the model if needed
        wasLoaded = bdIsLoaded(modelName);
        if ~wasLoaded
            ws = warning('off', 'all');
            load_system(modelName);
            warning(ws);
        end

        % AWD toggle
        set_param([modelName '/HMI/AWD'], 'Value', num2str(awdStatus));

        % Charging mode: 2 = charging, 3 = normal
        if chargeStatus == 1
            batCmdValue = "2";
        else
            batCmdValue = "3";
        end
        set_param([modelName '/HMI/BatCmd Input'], 'Value', batCmdValue);

        % Regen gain
        set_param([modelName '/Controller/Vehicle Control' ...
            '/Torque Control/Motor Trq Split/Regen'], ...
            'Gain', num2str(regenStatus));

    catch
        if exist('wasLoaded','var') && ~wasLoaded
            try, close_system(modelName, 0); catch, end
        end
        uialert(app.UIFigure, ...
            sprintf("Dashboard items couldn't be set automatically. " + ...
                "Please change the values manually in the model %s", ...
                app.BEVModelDropDown.Value), ...
            "Dashboard UI", 'Icon', 'error');
    end
end

function driveCycleSetup(app)
%DRIVECYCLESETUP Populate drive cycle dropdown from the BEV model's Drive Cycle Source block.

    modelName = erase(app.BEVModelDropDown.Value, '.slx');
    app.DriveCycleDropDown.Enable = "on";
    app.DriveCycleDesc.Enable = "on";

    try
        % Load the model silently if needed
        wasLoaded = bdIsLoaded(modelName);
        if ~wasLoaded
            ws = warning('off', 'all');
            load_system(modelName);
            warning(ws);
        end

        % Find the Drive Cycle Source block (check all variants)
        opts = {'LookUnderMasks', 'all', 'FollowLinks', 'off', ...
                'MatchFilter', @Simulink.match.allVariants};
        drvSourceBlocks = find_system(modelName, opts{:}, ...
            'ReferenceBlock', 'autolibshared/Drive Cycle Source');

        % Read cycle options from mask
        driveCycleMask = get_param(drvSourceBlocks{1}, 'MaskObject');
        cycleOptions = driveCycleMask.Parameters(1, 1).TypeOptions;
        app.DriveCycleDropDown.Items = cycleOptions;
        app.DriveCycleDropDown.Value = cycleOptions{1};

        % Close if we opened it
        if ~wasLoaded
            try, close_system(modelName, 0); catch, end
        end

    catch
        uialert(app.UIFigure, ...
            sprintf("Drive cycle source block missing in the base model: %s", ...
                app.BEVModelDropDown.Value), ...
            "Drive cycle missing", 'Icon', 'error');
        app.DriveCycleDropDown.Enable = "off";
        app.DriveCycleDesc.Enable = "off";
    end
end

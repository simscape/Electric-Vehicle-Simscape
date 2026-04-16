function driveCycleSetup(app)
            modelName = app.BEVModelDropDown.Value;
            modelName = erase(modelName,'.slx');
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

                % Robust search: check all variants, look under masks
                opts = {'LookUnderMasks','all', 'FollowLinks','off', ...
                    'MatchFilter', @Simulink.match.allVariants};

                drvSource = find_system(modelName, opts{:}, ...
                    'ReferenceBlock', 'autolibshared/Drive Cycle Source');

                driveCycleMask = get_param(drvSource{1},'MaskObject');
                app.DriveCycleDropDown.Items = driveCycleMask.Parameters(1, 1).TypeOptions;
                app.DriveCycleDropDown.Value = app.DriveCycleDropDown.Items{1};

                % Close if we opened it
                if ~wasLoaded
                    try, close_system(modelName, 0); catch, end
                end
            catch
                driveWarn = sprintf("Drive cycle source block missing in the base model: %s" ...
                    ,app.BEVModelDropDown.Value);
                uialert(app.UIFigure,driveWarn,"Drive cycle missing",'Icon','error');
                app.DriveCycleDropDown.Enable = "off";
                app.DriveCycleDesc.Enable = "off";
            end
end
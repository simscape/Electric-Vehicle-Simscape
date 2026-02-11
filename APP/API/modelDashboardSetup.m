function modelDashboardSetup(app)
            modelName = app.BEVModelDropDown.Value;
            modelName = erase(modelName,'.slx');
            awdStatus = double(app.AWDButton.Value);
            regenStatus = double(app.RegenButton.Value);
            chargeStatus = double(app.ChargingButton.Value);
            

            try
                % Load the model if needed
                if ~bdIsLoaded(modelName), load_system(modelName); end
                set_param([modelName '/HMI/AWD'],'Value',num2str(awdStatus));
                if chargeStatus == 1
                    set_param([modelName '/HMI/BatCmd Input'],'Value',"2");
                else
                    set_param([modelName '/HMI/BatCmd Input'],'Value',"3");
                end
                set_param([modelName '/Controller/Vehicle Control' ...
                    '/Torque Control/Motor Trq Split/Regen'],'Gain',num2str(regenStatus));

                set_param([modelName '/HMI/AWD'],'Value',num2str(awdStatus));


            catch
                driveWarn = sprintf("Dashboard items couoldn't be set automatically," + ...
                    " please change the values manually in the model %s" ...
                    ,app.BEVModelDropDown.Value);
                uialert(app.UIFigure,driveWarn,"Dashboard UI",'Icon','error');
            end
end
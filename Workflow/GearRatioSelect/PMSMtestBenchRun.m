%% Function for running Motor thermal test bench 
% The script runs PMSMThermalTestbenchFst.slx in batch mode based on user input 

% Copyright 2022 - 2023 The MathWorks, Inc.

function tstResultTable = PMSMtestBenchRun(gearRatio,testcycle,testduration)

   % Open the simulink model
   open_system PMSMThermalTestbench.slx
   thermalTB = 'PMSMThermalTestbench';

   % Check for the test cycle
   try
       set_param([thermalTB,'/Drive Cycle Source'],'cycleVar',testcycle(1))
   catch
       % Display an error message if the test cycle is not found
       disp("Plese Install desired test cycle using Drive Cycle Source block in the slx model")
       % Set the test cycle to a default cycle (FTP75)
       disp("Running available Default cycle FTP75")
       testcycle = ["FTP75"];
   end

   % Initialize arrays to store the results
   motFault = zeros(numel(gearRatio),numel(testcycle));
   tstResult = string(zeros(numel(gearRatio),numel(testcycle)));
   grr = string(zeros(numel(gearRatio),1));
   yout = [0,0];
   PMSMallTempBatch = cell(numel(gearRatio),numel(testcycle),3);

   % Loop through each gear ratio
   for i = 1:numel(gearRatio)
        gearRatio1 = string(gearRatio(i));
        grr(i) = ["Gear Ratio "]+gearRatio1;

        % Loop through each test cycle
        for j=1:numel(testcycle)
            testduration1 = string(testduration(j));

            % Set the test duration and gear ratio parameters
            set_param(thermalTB,'StopTime',testduration1)
            set_param([thermalTB,'/Final Drive Ratio'],'ratio',gearRatio1)
            set_param([thermalTB,'/Drive Cycle Source'],'cycleVar',testcycle(j))

            % Run the simulation
            sim("PMSMThermalTestbench");

            % Get the magnet and coil temperatures
            Tmag = simlogPmsmThermalTestbench.EM.Temperature.Rotor_Thermal_Block.Magnet_Temperature.T.series.values;
            allTime = simlogPmsmThermalTestbench.EM.Temperature.Rotor_Thermal_Block.Magnet_Temperature.T.series.time;
            Tcoil = simlogPmsmThermalTestbench.EM.Temperature.Stator_Thermal_Block.Stator_winding.T.series.values;

            % Get the maximum fault value for each simulation
            motFault(i,j) = max(yout(:,2));

            % Set the test result for each simulation
            if motFault(i,j) > 0
                tstResult(i,j) = "Fail";
            else
                tstResult(i,j) = "Pass";
            end

            % Store simulation results into cell array
            PMSMallTempBatch(i,j,1) = {allTime};
            PMSMallTempBatch(i,j,2) = {Tcoil};
            PMSMallTempBatch(i,j,3) = {Tmag};
        end
    end

    % Save the simulation results
    save('PMSMbatchRunTemp','PMSMallTempBatch')

    % Convert test results into table format
    tstResultTable = array2table(tstResult,"VariableNames",testcycle,"RowNames",grr);

    % Close the simulink model
    close_system ('PMSMThermalTestbench.slx',0);
end

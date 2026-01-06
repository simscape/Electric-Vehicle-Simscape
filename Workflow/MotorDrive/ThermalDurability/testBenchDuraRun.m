%% Function for running Motor thermal test bench for continous thermal test at constant load  
% The script runs MotorDriveThermalTestbench.slx in batch mode based on user input 

% Copyright 2022 - 2025 The MathWorks, Inc.

function DUdurabilityTable = testBenchDuraRun(sumpT,testcycle)

   % Initialize test result array with zeros
   tstResult = zeros(numel(sumpT),numel(testcycle));
      
   % Add 273.15 to sump temperature to convert it into Kelvin
   sumpT = sumpT+273.15;
   
   % Open the Simulink model
   open_system MotorDriveThermalTestbench.slx
   thermalTB = 'MotorDriveThermalTestbench';
   
   % Initialize a cell array to store all the simulation results
   PMSMallTempBatch = cell(numel(sumpT),numel(testcycle),5);
   
   % Convert test cycle name and sump temperature values into string format
   testName = string(testcycle);
   tempName = string(sumpT);
   
   % Set the stoptime to 10000 for all test cases
   set_param(thermalTB, 'StopTime', "10000")
    
   % Loop through each test cycle
   for tst = 1:numel(testcycle)
        % Set the road inclination to 0.16 for UDDS driving cycle, otherwise set to 0
        if tst == 1
             set_param([thermalTB,'/Test Env N Controls/Motor speed N test environment/Test Environment/Setting/Road Inclination'],'Value','0.248')
        else
             set_param([thermalTB,'/Test Env N Controls/Motor speed N test environment/Test Environment/Setting/Road Inclination'],'Value','0.025')
        end
        
        % Loop through each sump temperature value
        for tmp = 1:numel(sumpT)
            % Convert the sump temperature value into string
            tempstring = string(sumpT(tmp));
            
            % Set the test variables
            set_param([thermalTB,'/Motor Cooling/coolantJacket/ControlTsump'],'reservoir_temperature',tempstring)
            set_param([thermalTB,'/Drive Cycle Source'],'cycleVar','Workspace variable','wsVar',testcycle(tst),'srcUnit','km/h')
            
            % Run the simulation
            simOut = sim("MotorDriveThermalTestbench");
            
            % Get the magnet and coil temperatures
            Tmag = simOut.simlogPmsmThermalTestbench.EM.Temperature.Rotor_Thermal_Block.Magnet_Temperature.T.series.values;
            allTime = simOut.simlogPmsmThermalTestbench.EM.Temperature.Rotor_Thermal_Block.Magnet_Temperature.T.series.time;
            Tcoil = simOut.simlogPmsmThermalTestbench.EM.Temperature.Stator_Thermal_Block.Stator_winding.T.series.values;
                              
            % Store simulation results into cell array
            PMSMallTempBatch(tmp,tst,1) = {allTime};
            PMSMallTempBatch(tmp,tst,2) = {Tcoil};
            PMSMallTempBatch(tmp,tst,3) = {Tmag};

            % Get the maximum time value for each simulation
            tstResult(tmp,tst) = max(allTime);
        end
              
    end
    
    % Save the simulation results
    save('PMSMDuraRunTemp','PMSMallTempBatch')
    
    % Convert the test result array into a table format
    DUdurabilityTable = array2table(tstResult,"VariableNames",'Test Duration(s) '+testName,"RowNames",tempName +' K');
   
   % Close the Simulink model
   close_system ('MotorDriveThermalTestbench.slx',0)
end    

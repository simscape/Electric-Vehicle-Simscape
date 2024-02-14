%% Function for running Motor thermal test bench for continous thermal test at constant load  
% The script runs PMSMThermalTestbenchFst.slx in batch mode based on user input 

% Copyright 2022 - 2023 The MathWorks, Inc.

function DUdurabilityTable = PMSMtestBenchDuraRun(sumpT,testcycle,prfLS,prfHS)

   % Initialize test result array with zeros
   tstResult = zeros(numel(sumpT),numel(testcycle));
   
   % These arrays contain the maximum high speed and low speed limit test duration 
   LSHT = [0 0;1 5; 2 10; 3 15; 4 20; 5 20]; 
   HSLT = [0 0;2 20;4 30; 6 45; 8 60; 10 75; 12 85; 14 90;16 100; 18 100];
   
   % These arrays store the desired low speed and high speed limit test duration
   LSHT = prfLS;
   HSLT = prfHS; 
   
   % Add 273.15 to sump temperature to convert it into Kelvin
   sumpT = sumpT+273.15;
   
   % Open the Simulink model
   open_system PMSMThermalTestbench.slx
   thermalTB = 'PMSMThermalTestbench';
   
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
            simOut = sim("PMSMThermalTestbench");
            
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
   close_system ('PMSMThermalTestbench.slx',0)
end    

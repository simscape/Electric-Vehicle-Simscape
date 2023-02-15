%% Function for running Motor thermal test bench 
% The script runs PMSMThermalTestbenchFst.slx in batch mode based on user input 

% Copyright 2022 - 2023 The MathWorks, Inc.

function tstResultTable = PMSMtestBenchRun(gearRatio,testcycle,testduration)
   motFault = zeros(numel(gearRatio),numel(testcycle));
   tstResult=string(zeros(numel(gearRatio),numel(testcycle)));
   grr=string(zeros(numel(gearRatio),1));

   open_system PMSMThermalTestbenchFst.slx
   thermalTB = 'PMSMThermalTestbenchFst';
   PMSMallTempBatch = cell(numel(gearRatio),numel(testcycle),3);
    for i = 1:numel(gearRatio)
        gearRatio1 = string(gearRatio(i));
        grr(i) = ["Gear Ratio "]+gearRatio1;
        
        for j=1:numel(testcycle)
            testduration1 = string(testduration(j));
            set_param(thermalTB,'StopTime',testduration1)
            set_param([thermalTB,'/Final Drive Ratio'],'ratio',gearRatio1)
            set_param([thermalTB,'/Drive Cycle Source'],'cycleVar',testcycle(j))
            sim("PMSMThermalTestbenchFst");
            Tmag = simlogPmsmThermalTestbench.PMSM_Drive.Temperature.Rotor_Thermal_Block.Magnet_Temperature.T.series.values;
            allTime = simlogPmsmThermalTestbench.PMSM_Drive.Temperature.Rotor_Thermal_Block.Magnet_Temperature.T.series.time;
            Tcoil = simlogPmsmThermalTestbench.PMSM_Drive.Temperature.Stator_Thermal_Block.Stator_winding.T.series.values;
            motFault(i,j)=max(simlogPmsmThermalTestbench.PMSM_Drive.Motor_Drive.F.series.values);
            if motFault(i,j) > 0
                tstResult(i,j) = "Fail";
            else
                tstResult(i,j) = "Pass";
            end
                  
            PMSMallTempBatch(i,j,1) = {allTime};
            PMSMallTempBatch(i,j,2) = {Tcoil};
            PMSMallTempBatch(i,j,3) = {Tmag};
           
        end
              
    end
    save('PMSMbatchRunTemp','PMSMallTempBatch')
    tstResultTable = array2table(tstResult,"VariableNames",testcycle,"RowNames",grr);
   end   
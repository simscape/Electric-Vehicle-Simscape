%% Function for recording Inverter Temperature for life estimation 
% The script runs MotorDriveThermalTestbench.slx with DetailedInverter option in
% for given duty cycle

% Copyright 2022 - 2023 The MathWorks, Inc.

function PeakItest = runInverterLife(dtCycle)
% Open the Simulink models for the PMSM inverter test cycle and thermal test bench
simObject1 = load_system('InverterTestCycle.slx');
simobject2 = load_system('MotorDriveThermalTestbench.slx');

% Set the file path for the PMSM thermal test bench model
fdWkPmsmMdl = 'MotorDriveThermalTestbench';

% Try setting the test cycle variable in the PMSM thermal test bench model
try
    set_param([fdWkPmsmMdl,'/Drive Cycle Source'],'cycleVar',dtCycle)

    % If the desired test cycle is not available, run the default cycle FTP75 and display a warning message
catch
    disp("Please install the desired test cycle using the 'Drive Cycle Source' block in the slx model")
    disp("Running available Default cycle FTP75")
    set_param([fdWkPmsmMdl,'/Drive Cycle Source'],'cycleVar','FTP75')
end

% Set the inverter label mode to detailed on
set_param([fdWkPmsmMdl,'/Inverter'],'LabelModeActivechoice','DetailedOn')

% Run the PMSM thermal test bench simulation
simOut = sim("MotorDriveThermalTestbench");

% Get the IGBT and diode temperatures and current values
Tigbt = simOut.simlogPmsmThermalTestbench.Inverter.DetailedInverter.Switches.PhaseCswitch.ThermalModel_IGBT_CH.Tvec.series.values;
TigbtJ = Tigbt(:,1);
allTime = simOut.simlogPmsmThermalTestbench.Inverter.DetailedInverter.Switches.PhaseCswitch.ThermalModel_IGBT_CH.Tvec.series.time;
Tdiode = simOut.simlogPmsmThermalTestbench.Inverter.DetailedInverter.Switches.PhaseCswitch.ThermalModel_BodyDiode_CH.Tvec.series.values;
TdiodeJ = Tdiode(:,1);
cur = simOut.simlogPmsmThermalTestbench.EM.CurrentMes.I.series.values;
curTime = simOut.simlogPmsmThermalTestbench.EM.CurrentMes.I.series.time;

% Save the simulation results
save('PMSMinverterTemp','allTime',"TigbtJ","TdiodeJ","curTime","cur");

% Run the PMSM inverter life test cycle simulation
simOutTst = sim ("InverterTestCycle");

% Get the IGBT junction temperature and times from the inverter life test cycle simulation
TigbtTest = simOutTst.simlogInverterTest.inverter.IGBTAH.IGBT.IGBT_junction_temperature.series.values;
allTimeTest = simOutTst.simlogInverterTest.inverter.IGBTAH.IGBT.IGBT_junction_temperature.series.time;

% Get the peak currents from the inverter life test cycle simulation
PeakItest = max(max(simOutTst.simlogInverterTest.Load.IL.series.values));

% Save the simulation results
save("PMSMtestCycleTemp","allTimeTest","TigbtTest");

% Close both the PMSM thermal test bench and PMSM inverter test cycle models
close_system (simObject1,0)
close_system (simobject2,0)
end
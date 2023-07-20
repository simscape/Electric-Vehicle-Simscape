%% Function for recording Inverter Temperature for life estimation 
% The script runs PMSMThermalTestbench.slx with DetailedInverter option in
% for given duty cycle

% Copyright 2022 - 2023 The MathWorks, Inc.

function PeakItest = PMSMrunInverterLife(dtCycle)
    % Open the Simulink models for the PMSM inverter test cycle and thermal test bench
    open_system PMSMinverterTestCycle.slx
    open_system PMSMThermalTestbench.slx
    
    % Set the file path for the PMSM thermal test bench model
    fdWkPmsmMdl = 'PMSMThermalTestbench';
    
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
    sim("PMSMThermalTestbench");
    
    % Get the IGBT and diode temperatures and current values
    Tigbt = simlogPmsmThermalTestbench.Inverter.DetailedInverter.Switches.PhaseCswitch.ThermalModel_IGBT_CH.Tvec.series.values;
    TigbtJ = Tigbt(:,1); 
    allTime = simlogPmsmThermalTestbench.Inverter.DetailedInverter.Switches.PhaseCswitch.ThermalModel_IGBT_CH.Tvec.series.time;
    Tdiode = simlogPmsmThermalTestbench.Inverter.DetailedInverter.Switches.PhaseCswitch.ThermalModel_BodyDiode_CH.Tvec.series.values;
    TdiodeJ = Tdiode(:,1); 
    cur = simlogPmsmThermalTestbench.EM.CurrentMes.I.series.values;
    curTime = simlogPmsmThermalTestbench.EM.CurrentMes.I.series.time;
    
    % Save the simulation results
    save('PMSMinverterTemp','allTime',"TigbtJ","TdiodeJ","curTime","cur");
    
    % Run the PMSM inverter life test cycle simulation
    sim ("PMSMinverterTestCycle");
    
    % Get the IGBT junction temperature and times from the inverter life test cycle simulation
    TigbtTest = simlogInverterTest.inverter.IGBTAH.IGBT.junction_temperature.series.values;
    allTimeTest = simlogInverterTest.inverter.IGBTAH.IGBT.junction_temperature.series.time;
    
    % Get the peak currents from the inverter life test cycle simulation
    PeakItest = max(max(simlogInverterTest.Load.IL.series.values));
    
    % Save the simulation results
    save("PMSMtestCycleTemp","allTimeTest","TigbtTest");
    
    % Close both the PMSM thermal test bench and PMSM inverter test cycle models
    close_system ('PMSMThermalTestbench.slx',0)
    close_system ('PMSMinverterTestCycle.slx',0)
end
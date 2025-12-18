% Copyright 2025 The MathWorks, Inc.


%% Environment setting
vehicleThermal.ambient=25+273;
vehicleThermal.cabin_T_init=25+273.15;     % [K] Cabin initial temperature
% HVAC settings
vehicleThermal.CabinSpTp=20+273.15;        % [K] Cabin set point for HVAC
vehicleThermal.AConoff=1;                  % AC on/off flag, On==1, Off==0

vehicleThermal.cabin_p_init   = 0.101325;


BatteryLumpedThermalParams;
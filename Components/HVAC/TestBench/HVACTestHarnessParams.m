%% Parameters for BEV model Thermal system - run impirical refrigeration test harness 

% Copyright 2025 The MathWorks, Inc.

%HVAC Parameters
vehicleThermal.ambient = 298.15; % [K] Ambient temperature 
HVACEmpiricalRefParams;

%Used in Harness
vehicleThermal.cabin_battVoltage = 100; % [V] Battery Voltage
vehicleThermal.cabin_SOC = 1; % Battery SOC
vehicleThermal.AConoff = 1; % Set AC compressor on/off




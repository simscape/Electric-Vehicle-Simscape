%% Parameters for HVAC Empirical Refrigeration test harness

% Copyright 2025 The MathWorks, Inc.

%% Environment Parameters
vehicleThermal.ambient       = 25 + 273.15; % [K] Ambient temperature
vehicleThermal.cabin_T_init  = 298.15;      % [K] Cabin initial temperature
vehicleThermal.cabin_p_init  = 0.101325;    % [MPa] Cabin initial pressure
vehicleThermal.cabin_RH_init = 0.4;         % Cabin initial relative humidity

%% Component Parameters
HVACEmpiricalRefParams;

%% Scenario Parameters
vehicleThermal.CabinSpTp = 20 + 273.15; % [K] Cabin setpoint temperature
vehicleThermal.AConoff   = 1;           % AC compressor on/off (1=On, 0=Off)

%% Harness Boundary
vehicleThermal.cabin_battVoltage = 100; % [V] Battery voltage
vehicleThermal.cabin_SOC         = 1;   % Battery SOC




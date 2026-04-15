% Copyright 2025 The MathWorks, Inc.

%% Environment Parameters
vehicleThermal.ambient        = 25 + 273.15;  % [K] Ambient temperature
vehicleThermal.coolant_T_init = 25 + 273.15;  % [K] Coolant initial temperature
vehicleThermal.coolant_p_init = 0.101325;      % [MPa] Coolant initial pressure
vehicleThermal.cabin_p_init   = 0.101325;      % [MPa] Cabin air initial pressure
vehicleThermal.cabin_RH_init  = 0.4;           % Cabin initial relative humidity
vehicleThermal.cabin_CO2_init = 4e-4;          % Cabin initial CO2 mole fraction

%% Component Parameters
RadiatorParams;

%% Harness Boundary
vehicleThermal.coolant_channel_D = 0.0092; % [m] Coolant jacket channels diameter (reservoir blocks)


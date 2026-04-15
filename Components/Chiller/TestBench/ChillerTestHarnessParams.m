% Copyright 2025 The MathWorks, Inc.

%% Environment Parameters
vehicleThermal.coolant_T_init = 25 + 273.15;  % [K] Coolant initial temperature
vehicleThermal.coolant_p_init = 0.101325;      % [MPa] Coolant initial pressure

%% Chiller parameters
ChillerParams;

%% Vehicle Parameters
vehicleThermal.coolant_channel_D = 0.0092; % [m] Coolant jacket channels diameter
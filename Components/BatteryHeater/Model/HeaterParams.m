% Copyright 2025 The MathWorks, Inc.

%% Required Environment Parameters
% These parameters must be defined before running this script.
% In standalone use, define them in your workspace or harness script.
% In the BEV system model, they are set by BEVSystemModelParams.m
%
%   vehicleThermal.coolant_T_init = 25 + 273.15;  % [K] Coolant initial temperature
%   vehicleThermal.coolant_p_init = 0.101325;      % [MPa] Coolant initial pressure

%% Component Parameters
batteryHeater.heaterMaxPower = 4000; % [W] Heater max power

%% Coolant Geometry
batteryHeater.coolant_pipe_D = 0.019; % [m] Coolant pipe diameter
batteryHeater.coolant_channel_D = 0.0092; % [m] Coolant jacket channels diameter
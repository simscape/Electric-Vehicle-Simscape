% Copyright 2025 The MathWorks, Inc.

%% Required Environment Parameters
% These parameters must be defined before running this script.
% In standalone use, define them in your workspace or harness script.
% In the BEV system model, they are set by BEVSystemModelParams.m
%
%   vehicleThermal.coolant_T_init = 25 + 273.15;  % [K] Coolant initial temperature
%   vehicleThermal.coolant_p_init = 0.101325;      % [MPa] Coolant initial pressure

%% Component Parameters
batteryCharger.MaxVolt = 4.2; % Maximum voltage for batteryCharger V
batteryCharger.Kp = 1; % Charger controller proportional gain
batteryCharger.Ki = 1; % Charger controller integral gain
batteryCharger.Kaw = 1; % Charger controller anti-windup gain
batteryCharger.CC_A = 50; % Charger constant current value (A)

%% Coolant Geometry
batteryCharger.coolant_channel_D = 0.0092; % [m] Coolant jacket channels diameter

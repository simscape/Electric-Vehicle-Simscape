% Copyright 2025 The MathWorks, Inc.

%% Required Environment Parameters
% These parameters must be defined before running this script.
% In standalone use, define them in your workspace or harness script.
% In the BEV system model, they are set by BEVSystemModelParams.m
%
%   vehicleThermal.ambient        = 25 + 273.15;  % [K] Ambient temperature
%   vehicleThermal.cabin_T_init   = 298.15;       % [K] Cabin initial temperature
%   vehicleThermal.cabin_p_init   = 0.101325;     % [MPa] Cabin initial pressure
%   vehicleThermal.cabin_RH_init  = 0.4;          % Cabin initial relative humidity

%% Cabin Geometry
HVAC.cabin_duct_area         = 0.04;   % [m^2] Air duct cross-sectional area
HVAC.cabin_duct_volume       = 0.0015; % [m^3] Air duct volume

%% Cabin Occupant Parameters
HVAC.cabin_numberPassanger   = 1;    % Number of onboard passengers
HVAC.cabin_airRecirculation  = 0.5;  % Cabin air recirculation fraction
HVAC.cabin_perPersonMoisture = 0.04; % [g/s] Adult moisture exhale rate
HVAC.cabin_perPersonHeat     = 70;   % [W] Average heat transfer from human body
HVAC.cabin_exhaleTemperature = 30;   % [degC] Adult exhale air temperature






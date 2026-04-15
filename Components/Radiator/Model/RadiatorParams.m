% Copyright 2025 The MathWorks, Inc.

%% Required Environment Parameters
% These parameters must be defined before running this script.
% In standalone use, define them in your workspace or harness script.
% In the BEV system model, they are set by BEVSystemModelParams.m
%
%   vehicleThermal.ambient        = 25 + 273.15;  % [K] Ambient temperature
%   vehicleThermal.coolant_T_init = 25 + 273.15;  % [K] Coolant initial temperature
%   vehicleThermal.coolant_p_init = 0.101325;      % [MPa] Coolant initial pressure
%   vehicleThermal.cabin_p_init   = 0.101325;      % [MPa] Cabin air initial pressure
%   vehicleThermal.cabin_RH_init  = 0.4;           % Cabin initial relative humidity
%   vehicleThermal.cabin_CO2_init = 4e-4;          % Cabin initial CO2 mole fraction

%% Radiator Geometry
radiator.L = 0.6;                  % [m] Overall radiator length
radiator.W = 0.015;                % [m] Overall radiator width
radiator.H = 0.2;                  % [m] Overall radiator height
radiator.N_tubes = 25;             % Number of coolant tubes
radiator.tube_H = 0.0015;          % [m] Height of each coolant tube
radiator.fin_spacing = 0.002;      % Fin spacing
radiator.wall_thickness = 1e-4;    % [m] Material thickness
radiator.wall_conductivity = 240;  % [W/m/K] Material thermal conductivity

%% Derived Radiator Geometry
radiator.gap_H = (radiator.H - radiator.N_tubes * radiator.tube_H) / (radiator.N_tubes - 1); % [m] Height between coolant tubes
radiator.air_area_flow = (radiator.N_tubes - 1) * radiator.L * radiator.gap_H; % [m^2] Air flow cross-sectional area
radiator.air_area_primary = 2 * (radiator.N_tubes - 1) * radiator.W * (radiator.L + radiator.gap_H); % [m^2] Primary air heat transfer surface area
radiator.N_fins = (radiator.N_tubes - 1) * radiator.L / radiator.fin_spacing; % Total number of fins
radiator.air_area_fins = 2 * radiator.N_fins * radiator.W * radiator.gap_H; % [m^2] Total fin surface area
radiator.tube_Leq = 2 * (radiator.H + 20 * radiator.tube_H * radiator.N_tubes); % [m] Equivalent tube length for manifold losses

%% Fan and Air Duct
radiator.fan_area = 0.25 * 2;  % [m^2] Fan flow area (2 fans)
radiator.duct_area = 0.04;     % [m^2] Air duct cross-sectional area

%% Coolant Geometry
radiator.coolant_pipe_D = 0.019; % [m] Coolant pipe diameter
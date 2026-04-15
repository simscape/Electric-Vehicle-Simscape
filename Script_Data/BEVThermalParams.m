%% Parameters for BEV Vehicle Template — Thermal Plumbing
% These params define the coolant circuit infrastructure (pipes, valves,
% pumps, tanks) used by the vehicle template models. They are NOT
% component-specific — component geometry lives in each component's
% own param file under its namespace (e.g. radiator.*, chiller.*, etc.).

% Copyright 2022 - 2025 The MathWorks, Inc.

%% Coolant Pipe Geometry
vehicleThermal.coolant_pipe_D = 0.019;    % [m] Coolant pipe diameter
vehicleThermal.coolant_channel_D = 0.0092; % [m] Coolant jacket channels diameter (DCDC)

%% Valves
vehicleThermal.coolant_valve_displacement = 0.0063; % [m] Max spool displacement
vehicleThermal.coolant_valve_offset = 0.001;        % [m] Orifice opening offset when spool is neutral
vehicleThermal.coolant_valve_D_ratio_max = 0.95;    % Max orifice diameter to pipe diameter ratio
vehicleThermal.coolant_valve_D_ratio_min = 1e-3;    % Leakage orifice diameter to pipe diameter ratio

%% Pumps
vehicleThermal.pump_displacement = 0.02;  % [l/rev] Coolant pump volumetric displacement
vehicleThermal.pump_speed_max = 1000;     % [rpm] Coolant pump max shaft speed

%% Coolant Tank
vehicleThermal.coolant_tank_volume = 2.5 / 2; % [l] Volume of each coolant tank
vehicleThermal.coolant_tank_area = 0.11^2;    % [m^2] Area of one side of coolant tank


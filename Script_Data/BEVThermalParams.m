%% Parameters for BEV Vehicle Template — Thermal Plumbing
% Shared coolant circuit infrastructure (pipes, valves, tanks) used by
% vehicle template models. Component-specific params live in each
% component's own param file (e.g. pump.*, radiator.*, chiller.*).

% Copyright 2022 - 2026 The MathWorks, Inc.

%% Coolant Pipe Geometry
vehicleThermal.coolant_pipe_D = 0.019;    % [m] Coolant pipe diameter
vehicleThermal.coolant_channel_D = 0.0092; % [m] Coolant jacket channel diameter

%% Valves
vehicleThermal.coolant_valve_displacement = 0.0063; % [m] Max spool displacement
vehicleThermal.coolant_valve_offset = 0.001;        % [m] Orifice opening offset when spool is neutral
vehicleThermal.coolant_valve_D_ratio_max = 0.95;    % Max orifice diameter to pipe diameter ratio
vehicleThermal.coolant_valve_D_ratio_min = 1e-3;    % Leakage orifice diameter to pipe diameter ratio

%% Coolant Tank
vehicleThermal.coolant_tank_volume = 2.5 / 2; % [l] Volume of each coolant tank
vehicleThermal.coolant_tank_area = 0.11^2;    % [m^2] Area of one side of coolant tank


%% Parameters for BEV model Thermal system

% Copyright 2022 - 2023 The MathWorks, Inc.

%% Initial conditions

vehicleThermal.cabin_p_init = 0.101325; % [MPa] Initial air pressure
vehicleThermal.cabin_RH_init = 0.4; % Initial relative humidity
vehicleThermal.cabin_CO2_init = 4e-4; % Initial CO2 mole fraction
vehicleThermal.coolant_p_init = 0.101325;

%% Vehicle Cabin

vehicleThermal.cabin_duct_area = 0.04; % [m^2] Air duct cross-sectional area
vehicleThermal.cabin_duct_volume= 0.0015; % [m^3] Aier duct volume
vehicleThermal.cabin_perPersonCO2 = 0.01; % [g/s] Adult CO2 exhale rate 
vehicleThermal.cabin_perPersonMoisture = 0.04; % [g/s] Adult moisture exhale rate
vehicleThermal.cabin_perPersonHeat = 70; % Average heat tranfer from human body
vehicleThermal.cabin_exhaleTemperature = 30; % [degC] Adult exhale air temperature
vehicleThermal.cabin_numberPassanger = 1; % Number of onboard passangers
vehicleThermal.cabin_airRecirculation = 0.5; % Cabin air recirculation 

%% Liquid Coolant System

vehicleThermal.coolant_pipe_D = 0.019; % [m] Coolant pipe diameter
vehicleThermal.coolant_channel_D = 0.0092; % [m] Coolant jacket channels diameter

vehicleThermal.coolant_valve_displacement = 0.0063; % [m] Max spool displacement
vehicleThermal.coolant_valve_offset = 0.001; % [m] Orifice opening offset when spool is neutral
vehicleThermal.coolant_valve_D_ratio_max = 0.95; % Max orifice diameter to pipe diameter ratio
vehicleThermal.coolant_valve_D_ratio_min = 1e-3; % Leakage orifice diameter to pipe diameter ratio

vehicleThermal.pump_displacement = 0.02; % [l/rev] Coolant pump volumetric displacement
vehicleThermal.pump_speed_max = 1000; % [rpm] Coolant pump max shaft speed

vehicleThermal.coolant_tank_volume = 2.5 / 2; % [l] Volume of each coolant tank
vehicleThermal.coolant_tank_area = 0.11^2; % [m^2] Area of one side of coolant tank


%% Radiator

vehicleThermal.radiator_L = 0.6; % [m] Overall radiator length
vehicleThermal.radiator_W = 0.015; % [m] Overall radiator width
vehicleThermal.radiator_H = 0.2; % [m] Overal radiator height
vehicleThermal.radiator_N_tubes = 25; % Number of coolant tubes
vehicleThermal.radiator_tube_H = 0.0015; % [m] Height of each coolant tube
vehicleThermal.radiator_fin_spacing = 0.002; % Fin spacing
vehicleThermal.radiator_wall_thickness = 1e-4; % [m] Material thickness
vehicleThermal.radiator_wall_conductivity = 240; % [W/m/K] Material thermal conductivity

vehicleThermal.radiator_gap_H = (vehicleThermal.radiator_H - vehicleThermal.radiator_N_tubes*vehicleThermal.radiator_tube_H) / (vehicleThermal.radiator_N_tubes - 1); % [m] Height between coolant tubes
vehicleThermal.radiator_air_area_flow = (vehicleThermal.radiator_N_tubes - 1) * vehicleThermal.radiator_L * vehicleThermal.radiator_gap_H; % [m^2] Air flow cross-sectional area
vehicleThermal.radiator_air_area_primary = 2 * (vehicleThermal.radiator_N_tubes - 1) * vehicleThermal.radiator_W * (vehicleThermal.radiator_L + vehicleThermal.radiator_gap_H); % [m^2] Primary air heat transfer surface area
vehicleThermal.radiator_N_fins = (vehicleThermal.radiator_N_tubes - 1) * vehicleThermal.radiator_L / vehicleThermal.radiator_fin_spacing; % Total number of fins
vehicleThermal.radiator_air_area_fins = 2 * vehicleThermal.radiator_N_fins * vehicleThermal.radiator_W * vehicleThermal.radiator_gap_H; % [m^2] Total fin surface area
vehicleThermal.radiator_tube_Leq = 2*(vehicleThermal.radiator_H + 20*vehicleThermal.radiator_tube_H*vehicleThermal.radiator_N_tubes); % [m] Additional equivalent tube length for losses due to manifold and splits

vehicleThermal.fan_area = 0.25 * 2; % [m^2] Fan flow area (2 fans)
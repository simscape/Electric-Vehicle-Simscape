% Copyright 2025 The MathWorks, Inc.

%% Initial conditions

vehicleThermal.cabin_p_init = 0.101325; % [MPa] Initial air pressure
vehicleThermal.cabin_T_init = 298.15; % [K] Initial Temperature
vehicleThermal.cabin_RH_init = 0.4; % Initial relative humidity
% vehicleThermal.ambient = 298.15; % [K] Ambient temperature 
vehicleThermal.CabinSpTp = 293.15 ; % [K] Cabin setpoint temperature

%% Vehicle Cabin

HVAC.cabin_duct_area = 0.04; % [m^2] Air duct cross-sectional area
HVAC.cabin_duct_volume= 0.0015; % [m^3] Air duct volume
HVAC.cabin_numberPassanger = 1; % Number of onboard passangers
HVAC.cabin_airRecirculation = 0.5; % Cabin air recirculation 
HVAC.cabin_perPersonMoisture = 0.04; % [g/s] Adult moisture exhale rate
HVAC.cabin_perPersonHeat = 70; % Average heat tranfer from human body
HVAC.cabin_exhaleTemperature = 30; % [degC] Adult exhale air temperature






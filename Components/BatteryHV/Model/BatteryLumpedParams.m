% Copyright 2025 The MathWorks, Inc.s

%% Cell Electrical
battery.T_vec=[278 293 313];       % Temperature vector T [K]
battery.AH=34;                     % [Ah] Cell capacity 
battery.AH_vec=[0.9*battery.AH battery.AH 0.9*battery.AH]; % Cell capacity vector AH(T) [Ahr]
battery.SOC_vec=[0, .1, .25, .5, .75, .9, 1]; % Cell state of charge vector SOC [-]
battery.initialPackSOC=0.75;	     % Pack intial SOC (-)
battery.cRate=[0    0    0
               1    2    2
               2    2    3
               2    3    4
               2    3    4
               3    4    5
               4    5    6]; % mac c rate for given Temp and SoC

%% Load param files
run('batt_BatteryManagementSystem_param'); % battery management parameters
run('batt_packBTMSExampleLib_param');      % battery module parameter filefile

% %% Liquid Coolant System
% battery.coolant_pipe_D = 0.019; % [m] Coolant pipe diameter
% vehicleThermal.coolant_p_init = 0.101325;
% vehicleThermal.coolant_T_init=25+273.155;  % [K] Coolant initial temperature


% Load BMS parameter
BMSParams;
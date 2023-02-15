%% BEV plant model main param file
% Parameters for BEV plant model
% Set the environment and HVAC variables
% Load battery characteristics
% Load all supporting Param files and data

% Copyright 2022 - 2023 The MathWorks, Inc.

%% Environment setting
vehicleThermal.ambient=25+273.15;          %[K] Ambient temperature in K
vehicleThermal.cabin_T_init=25+273.15;     % [K] Cabin initial temperature
vehicleThermal.coolant_T_init=25+273.155;  % [K] Coolant initial temperature
% HVAC settings
vehicleThermal.CabinSpTp=20+273.15;        % [K] Cabin set point for HVAC
vehicleThermal.AConoff=1;                  % AC on/off flag, On==1, Off==0

%% Cell Electrical
battery.T_vec=[278 293 313];       % Temperature vector T [K]
battery.AH=34;                     % [Ah] Cell capacity 
battery.AH_vec=[0.9*battery.AH battery.AH 0.9*battery.AH]; % Cell capacity vector AH(T) [Ahr]
battery.SOC_vec=[0, .1, .25, .5, .75, .9, 1]; % Cell state of charge vector SOC [-]
battery.initialPackSOC=0.98;	     % Pack intial SOC (-)
battery.cRate=[0    0    0
               1    2    2
               2    2    3
               2    3    4
               2    3    4
               3    4    5
               4    5    6]; % mac c rate for given Temp and SoC

%% Load param files
run('batt_BatteryManagementSystem_param'); % battery management parameters
run('batt_packBTMSExampleLib_param');      % battery module parameter file
run('BEVThermalManagementparam');          % Thermal management param file
run('BEVplantModelVehicleparams');         % Vehicle Param file
run('PMSMthermalParams');                  % Motor thermal param file
run('PMSMmotorDriveParms');                % Motor param file
run('PMSMinverterParams');                 % Inverter param file
% rotor parameter
electricDrive.V_frac_bridge=0.5;
electricDrive.V_fract_teeth=0.5;
dt=0.01;
% Motor parameters
electricDrive.max_torque = 220; % [Nm] max torque for motor
electricDrive.max_power = 50e3; % [W] max power for motor 

%% Thermal param
vehicleThermal.chillerMaxPower = 6000 ; % [W] max Chiller heat extracted
vehicleThermal.heaterMaxPower = 4000 ; % [W] max heater heat added

%% Load mat file
load('batt_BatteryManagementSystem_BusInspector.mat'); % BMS bus data
load('BMSbatCmdData.mat'); % Battery command data

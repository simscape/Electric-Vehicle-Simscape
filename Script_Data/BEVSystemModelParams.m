%% BEV plant model main param file
% Parameters for BEV plant model
% Set the environment and HVAC variables
% Load battery characteristics
% Load all supporting Param files and data
%
% Copyright 2022 - 2025 The MathWorks, Inc.

%% Environment setting
% Scenario settings
vehicleThermal.ambient   = 25+273.15;          % [K] Ambient temperature in K

%% Ensure Param script folders are on path

%% Component params
BatteryTableBasedParams;
MotorDriveGearThParams;
MotorDriveGearThParams;
HVACsimpleThParams;
ChargerThermalParams;
ChillerParams;
HeaterParams;
DrivelineParams;

%%VehicleThermal based parameters
% (Place any derived vehicle thermal params here if needed)

%% Initialization from the UI for thermal and HVAC, only used when present
vehicleThermal.CabinSpTp = 20+273.15;        % [K] Cabin set point for HVAC
vehicleThermal.AConoff   = false;        % AC on/off flag, On==1, Off==0
vehicleThermal.coolant_T_init  = vehicleThermal.ambient;   % [K] Coolant initital temp
vehicleThermal.cabin_CO2_init  = 4.000000e-04;   % Cabin initital CO2
vehicleThermal.cabin_RH_init  = 5.000000e-01;   % Cabin initital humidity
vehicleThermal.cabin_p_init  = 1/10;   % [Mpa] Cabin initital pressure
vehicleThermal.coolant_P_init  = 1/10;   % [Mpa] Coolant initital pressure


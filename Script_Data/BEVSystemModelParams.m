%% BEV plant model main param file
% Parameters for BEV plant model
% Set the environment and HVAC variables
% Load battery characteristics
% Load all supporting Param files and data
%
% Copyright 2022 - 2026 The MathWorks, Inc.

%% Environment setting
% Scenario settings
vehicleThermal.ambient   = 25+273.15;          % [K] Ambient temperature



%% Initialization from the UI for thermal and HVAC
vehicleThermal.CabinSpTp = 20+273.15;        % [K] Cabin set point for HVAC
vehicleThermal.AConoff   = true;        % AC on/off flag, On==1, Off==0
vehicleThermal.cabin_T_init    = vehicleThermal.ambient;   % [K] Cabin initial temp
vehicleThermal.coolant_T_init  = vehicleThermal.ambient;   % [K] Coolant initial temp
vehicleThermal.cabin_CO2_init  = 0.0004;   % Cabin initial CO2
vehicleThermal.cabin_RH_init   = 0.3;   % Cabin initial humidity
vehicleThermal.cabin_p_init    = 1/10;   % [MPa] Cabin initial pressure
vehicleThermal.coolant_p_init  = 1/10;   % [MPa] Coolant initial pressure

%% Component params
BatteryTableBasedParams;
MotorDriveGearThParams;
HVACsimpleThParams;
ChargerThermalParams;
ChillerParams;
HeaterParams;
DrivelineParams;
PumpParams;
RadiatorParams;

%% Controller params
ControllerParams;

%% System parameters
BEVThermalParams;


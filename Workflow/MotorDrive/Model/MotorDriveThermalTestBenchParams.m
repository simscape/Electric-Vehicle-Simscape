%% Parameters for PMSM ,its control & vehicle level model parameters

% Copyright 2022 - 2025 The MathWorks, Inc.

%Other Parameters
ControllerParams;
EmotorLibParams;
InverterParams;
InverterThermalParams;
DrivelineParams;

vehicleThermal.coolant_T_init = 300;
%% Test Environment/Plant Model Parameters
% Vehicle parameters
electricDrive.VehicleParams.rolling_res_ratio = 0.03;
electricDrive.VehicleParams.vehicle_mass = 1000; %Kg
electricDrive.VehicleParams.wheel_radius = 0.3;% m
electricDrive.VehicleParams.Gear_ratio = 4.2;
electricDrive.VehicleParams.Frontalarea = 2.9;% m^2
% Test Environment parameters
electricDrive.drag_coefficient = 0.185;
electricDrive.air_density = 1.02; % kg/m^3
electricDrive.gravity = 9.81;% accilaration due to gravity m/sec^2 

%% Motor Parameters
electricDrive.max_torque = 220;
electricDrive.max_power = 100e3; 
electricDrive.Tctc = 0.001; % Motor torque control time constant(s)
% electricDrive.motor_loss_map = load('MotorLossMap.mat');
% electricDrive.inverter_loss_map = load("InverterLossMap.mat");

%% Battery Parameter 
electricDrive.Vnom = 500; %Nominal battery Voltage in Volts 
 
%% Control Parameters
electricDrive.PmsmControlParams.Kp_omega = 0.25;
electricDrive.PmsmControlParams.Ki_omega = 0.5;
electricDrive.Tmax = 200; % Maximum rated torque(N-m) at zero speed 
electricDrive.Pmax = 100000; % Maximum rated power (Watts)
dt = 0.01;

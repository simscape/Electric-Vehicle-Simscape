%% Parameters for PMSM ,its control & vehicle level model parameters

% Copyright 2022 - 2023 The MathWorks, Inc.

%% Test Environment/Plant Model Parameters
% Vehicle parameters
electricDrive.VehicleParams.rolling_res_ratio = 0.03;
electricDrive.VehicleParams.vehicle_mass = 1000; %Kg
electricDrive.VehicleParams.wheel_radius = 0.25;% m
electricDrive.VehicleParams.Gear_ratio = 5.15;
electricDrive.VehicleParams.Frontalarea = 2.9;% m^2
% Test Environment parameters
electricDrive.drag_coefficient = 0.25;
electricDrive.air_density = 1.02; % kg/m^3
electricDrive.gravity = 9.81;% accilaration due to gravity m/sec^2 

%% Motor Parameters
electricDrive.max_torque = 220;
electricDrive.max_power = 100e3; 
electricDrive.Tctc= 0.002; % Motor torque control time constant(s)
electricDrive.motor_loss_map=load('PMSMmotorLossMap.mat');

%% Battery Parameter 
electricDrive.Vnom = 500; %Nominal battery Voltage in Volts 
 
%% Control Parameters
electricDrive.PmsmControlParams.Kp_omega=2.5;
electricDrive.PmsmControlParams.Ki_omega=75.0;
electricDrive.Tmax = 180; % Maximum rated torque(N-m) at zero speed 
electricDrive.Pmax = 100000; % Maximum rated power (Watts)
dt = 0.01;

%% Motor Parameters for Motor & Drive (System Level)

% Copyright 2022 - 2025 The MathWorks, Inc.

electricDrive.max_torque = 220;
electricDrive.max_power = 50e3; 
electricDrive.Tctc= 0.002; % Motor torque control time constant(s)
electricDrive.motor_loss_map=load('MotorLossMap.mat');

%% Motor Thermal parameters 
% Script to generate PMSM Motor Thermal Parameters.

MotorThermalParams;

% Inverter params
InverterParams;
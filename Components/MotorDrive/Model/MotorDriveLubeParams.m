%% Motor Parameters for Motor & Drive (System Level)

% Copyright 2022 - 2026 The MathWorks, Inc.

%% Required Environment Parameters
% These parameters must be defined before running this script.
% In standalone use, define them in your workspace or harness script.
% In the BEV system model, they are set by BEVSystemModelParams.m
%
%   vehicleThermal.coolant_T_init  = 25 + 273.15;  % [K] Coolant initial temperature
%   vehicleThermal.coolant_p_init  = 0.101325;      % [MPa] Coolant initial pressure

%% Motor Drive Parameters
electricDrive.max_torque = 220;
electricDrive.max_power = 50e3;
electricDrive.Tctc= 0.002; % Motor torque control time constant(s)
electricDrive.motor_loss_map=load('MotorLossMap.mat');

%% Coolant Geometry
electricDrive.coolant_channel_D = 0.0092; % [m] Coolant jacket channels diameter

%% Motor Thermal parameters
% Script to generate PMSM Motor Thermal Parameters.

MotorThermalParams;

% Inverter params
InverterMotorDriveParam;
%% MotorDriveGear3WParams — Parameters for MotorDriveGear (Piaggio Ape E-City)
% MotorDriveGear3WParams Motor and drive parameters for the
% three-wheel BEV.
%
%   Max Power: 5.44 kW @ 3500 rpm
%   Max Torque: 29 Nm
%   Transmission: Constant Mesh 2-Stage Reduction with Integrated Differential
%
% Copyright 2026 The MathWorks, Inc.

%% Motor and Drive
electricDrive.max_torque = 29;       % [Nm] peak torque
electricDrive.max_power = 5.44e3;    % [W] peak power
electricDrive.Tctc = 0.002;          % [s] torque control time constant
electricDrive.maxPowerSpd_rpm = 3500; % [rpm] speed at peak power
electricDrive.motor_loss_map = load('MotorLossMap.mat');

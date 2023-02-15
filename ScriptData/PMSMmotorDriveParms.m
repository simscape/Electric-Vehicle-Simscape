%% Motor Parameters for Motor & Drive (System Level)

% Copyright 2022 - 2023 The MathWorks, Inc.

electricDrive.max_torque = 220;
electricDrive.max_power = 100e3; 
electricDrive.Tctc= 0.002; % Motor torque control time constant(s)
electricDrive.loss_maps=load('PMSMmotorLossMap.mat');


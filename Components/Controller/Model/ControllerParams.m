%% Model Parameters for BEV Drive Cycle with detail battery module
% Data for the two battery packs, HV1 and HV2, in parallel are same
% To run scenarios with different parameter values, run the script again

% Copyright 2022 - 2025 The MathWorks, Inc.

%% Vehicle level parameters

%BEV Model
controller.tireRollingRadius_cm = 30;
controller.BrakeFactor = 0.4;
controller.MaxSpeed = 140/0.06; % [m/min] max speed for controller 140 km/h
controller.motorDriveTrqMax = 360;

BMSParams;
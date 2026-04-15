% Inverter parameters for MotorDriveGearTh component model
% Subset of InverterParams.m — only params used by the .slx blocks.

% Copyright 2022 - 2025 The MathWorks, Inc.

%% Required Environment Parameters
% These parameters must be defined before running this script.
%
%   vehicleThermal.coolant_T_init = 25 + 273.15;  % [K] Coolant initial temperature

%% Inverter Cauer Thermal Model
electricDrive.PMparams.RthDiode    = [0.017,0.12,0.1,0.038]/6;
electricDrive.PMparams.RthIGBT    = [0.01,0.07,0.08,0.045]/6;
electricDrive.PMparams.tauthDiode  = [0.001,0.03,0.25,1.5]*6;
electricDrive.PMparams.tauthIGBT   = [0.001,0.03,0.25,1.5]*6;
electricDrive.PMparams.TinitDiode  = vehicleThermal.coolant_T_init * ones(1,4);
electricDrive.PMparams.TinitIGBT   = vehicleThermal.coolant_T_init * ones(1,4);

%% Heatsink
electricDrive.HeatsinkParams.Height  = 0.05;
electricDrive.HeatsinkParams.Thick   = 0.0015;
electricDrive.HeatsinkParams.Depth   = 0.0015;
electricDrive.HeatsinkParams.Gap     = 0.0030;
electricDrive.HeatsinkParams.NumFins = 225;
electricDrive.HeatsinkParams.Mass    = 0.2268;

%% Inverter Loss Map
electricDrive.inverter_loss_map = load("InverterLossMap.mat");

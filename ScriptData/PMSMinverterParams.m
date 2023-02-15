% Inverter parameters

% Copyright 2022 - 2023 The MathWorks, Inc.

electricDrive.PMparams.RthDiode= [0.0016,0.0043,0.0013,0.0014]/6;
electricDrive.PMparams.RthIGBT = [0.0016,0.0043,0.0013,0.0014]/6;
electricDrive.PMparams.tauthDiode = [0.0068,0.064,0.32,2]*6;
electricDrive.PMparams.tauthIGBT = [0.0068,0.064,0.32,2]*6;
electricDrive.PMparams.TinitDiode = [298.15,298.15,298.15,298.15];
electricDrive.PMparams.TinitIGBT= [298.15,298.15,298.15,298.15];

electricDrive.HeatsinkParams.Height = 0.05;
electricDrive.HeatsinkParams.Thick = 0.0015;
electricDrive.HeatsinkParams.Depth = 0.0015;
electricDrive.HeatsinkParams.Gap = 0.0030;
electricDrive.HeatsinkParams.NumFins = 225;
electricDrive.HeatsinkParams.Mass = 0.2268;

electricDrive.loss_maps_inv=load('PMSMinverterLossMap.mat'); % Inverter thermal map

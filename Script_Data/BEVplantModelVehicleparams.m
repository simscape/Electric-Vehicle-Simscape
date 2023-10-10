%% Model Parameters for BEV Drive Cycle with detail battery module
% Data for the two battery packs, HV1 and HV2, in parallel are same
% To run scenarios with different parameter values, run the script again

% Copyright 2022 - 2023 The MathWorks, Inc.

%% Vehicle level parameters

vehicle.vehMass_kg = 1600;
vehicle.tireRollingRadius_cm = 30;
vehicle.roadGrade=0;
vehicle.BrakeFactor = 0.4;
vehicle.MaxSpeed = 140/0.06; % [m/min] max speed for vehicle 140 km/h

% Motor Drive
vehicle.max_torque = 220;
vehicle.max_power = 50000;
vehicle.motorDrive.simplePmsmDrv_trqMax_Nm = 360;

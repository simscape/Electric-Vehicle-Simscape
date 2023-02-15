%% Model Parameters for BEV Drive Cycle with detail battery module
% Data for the two battery packs, HV1 and HV2, in parallel are same
% To run scenarios with different parameter values, run the script again

% Copyright 2022 - 2023 The MathWorks, Inc.

%% Vehicle level parameters

vehicle.vehMass_kg = 1600;
vehicle.tireRollingRadius_cm = 30;
vehicle.roadGrade=0;
vehicle.BrakeFactor = 0.4;

% Motor Drive
vehicle.max_torque = 220;
vehicle.max_power = 50000;
vehicle.motorDrive.simplePmsmDrv_trqMax_Nm = 360;
vehicle.motorDrive.simplePmsmDrv_powMax_W = 150e+3;
vehicle.motorDrive.simplePmsmDrv_timeConst_s = 0.02;

vehicle.motorDrive.simplePmsmDrv_spdVec_rpm = [100, 450, 800, 1150, 1500];
vehicle.motorDrive.simplePmsmDrv_trqVec_Nm = [10, 45, 80, 115, 150];
vehicle.motorDrive.simplePmsmDrv_LossTbl_W = ...
[ 16.02, 251,   872.8, 2230, 4998; ...
  29.77, 262,   875.7, 2217, 4950; ...
  45.35, 281.2, 900,   2217, 4796; ...
  62.14, 299,   924.8, 2191, 4567; ...
  81.1,  320.9, 943.1, 2146, 4379];

vehicle.motorDrive.simplePmsmDrv_rotorInertia_kg_m2 = 3.93*0.01^2;
vehicle.motorDrive.simplePmsmDrv_rotorDamping_Nm_per_radps = 1e-5;
vehicle.motorDrive.simplePmsmDrv_initialRotorSpd_rpm = 0;

vehicle.motorDrive.spdCtl_trqMax_Nm = vehicle.motorDrive.simplePmsmDrv_trqMax_Nm;


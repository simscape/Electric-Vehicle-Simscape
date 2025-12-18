%% Parameters for PMSM

% Copyright 2022 - 2023 The MathWorks, Inc.

%% Parameters

% PMSM & Vehicle parameters
electricDrive.PmsmParams = getPMSMParams('PMSMsaturationLossMap'); 
electricDrive.PmsmParams.RotorInertia = 0.025; % [kg*m^2]
electricDrive.PmsmParams.InitialRotorAngle_rad = -pi/2/electricDrive.PmsmParams.NumPolePairs;

%%Test Environment/Plant Model Parameters
electricDrive.VehicleParams.rolling_res_ratio=0.03;
electricDrive.VehicleParams.vehicle_mass=1000; %Kg
electricDrive.VehicleParams.wheel_radius=0.25;% m
electricDrive.VehicleParams.Gear_ratio=5.2725;
electricDrive.VehicleParams.Frontalarea=2.9;% m^2
electricDrive.drag_coefficient=0.25;
electricDrive.air_density=1.02; % kg/m^3
electricDrive.gravity=9.81;% accilaration due to gravity m/sec^2 
electricDrive.tout=180;% Instentenious motor torqe (N-m) 
electricDrive.Tmax=180;%Maximum rated torque(N-m) at zero speed( the max allowed torque is scaled down during field weaking)    
electricDrive.Pmax=100000;%Maximum rated power (Watts)
%Battery Parameters
electricDrive.battery.currentReference =100;
electricDrive.battery.initialSOC =0.995;
electricDrive.battery.AHRating= 50;
electricDrive.battery.inductance = 0.0050;
electricDrive.battery.cellsInSeries = 120;
electricDrive.battery.batteryStringsInParallel = 250;
electricDrive.Vnom=500; %Nominal battery Voltage in Volts 
 
%%Control Parameters
electricDrive.PmsmControlParams=struct();
electricDrive.PmsmControlParams.Tso=1e-3;
electricDrive.PmsmControlParams.Tsi=1e-4;
electricDrive.PmsmControlParams.Ts=5e-5;
electricDrive.PmsmControlParams.psim=0.084;
electricDrive.Lq=6.2241e-4;
electricDrive.Ld=1.9766e-4;
electricDrive.PmsmControlParams.Kp_omega=4.5;
electricDrive.PmsmControlParams.Kp_iq=1.5800;
electricDrive.PmsmControlParams.Kp_id=0.9;
electricDrive.PmsmControlParams.Ki_omega=99.0;
electricDrive.PmsmControlParams.Ki_iq=1063.0;
electricDrive.PmsmControlParams.Ki_id=710.3004;
electricDrive.PmsmControlParams.Ki_fw=130;
electricDrive.PmsmControlParams.Kaw_fw=100.0;
electricDrive.Jm=0.025;
electricDrive.PmsmControlParams.fsw=10000;
electricDrive.Cdc=1.0000e-3;

%% Zero-Cancellation Transfer Functions
electricDrive.PmsmControlParams.numd_id = electricDrive.PmsmControlParams.Tsi/(...
    electricDrive.PmsmControlParams.Kp_id/electricDrive.PmsmControlParams.Ki_id);
electricDrive.PmsmControlParams.dend_id = [1 (electricDrive.PmsmControlParams.Tsi-...
    (electricDrive.PmsmControlParams.Kp_id/electricDrive.PmsmControlParams.Ki_id))/...
    (electricDrive.PmsmControlParams.Kp_id/electricDrive.PmsmControlParams.Ki_id)];
electricDrive.PmsmControlParams.numd_iq = electricDrive.PmsmControlParams.Tsi/...
    (electricDrive.PmsmControlParams.Kp_iq/electricDrive.PmsmControlParams.Ki_iq);
electricDrive.PmsmControlParams.dend_iq = [1 (electricDrive.PmsmControlParams.Tsi-...
    (electricDrive.PmsmControlParams.Kp_iq/electricDrive.PmsmControlParams.Ki_iq))/...
    (electricDrive.PmsmControlParams.Kp_iq/electricDrive.PmsmControlParams.Ki_iq)];

electricDrive.PmsmControlParams.numd_omega = electricDrive.PmsmControlParams.Tso/...
    (electricDrive.PmsmControlParams.Kp_omega/electricDrive.PmsmControlParams.Ki_omega);
electricDrive.PmsmControlParams.dend_omega = [1 (electricDrive.PmsmControlParams.Tso-...
    (electricDrive.PmsmControlParams.Kp_omega/electricDrive.PmsmControlParams.Ki_omega))/...
    (electricDrive.PmsmControlParams.Kp_omega/electricDrive.PmsmControlParams.Ki_omega)];

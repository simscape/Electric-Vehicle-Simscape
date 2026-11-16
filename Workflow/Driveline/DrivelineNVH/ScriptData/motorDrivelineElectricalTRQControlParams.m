%motorDrivelineElectricalTRQControlParams Parameter initialization for motorDrivelineElectricalTRQControl model.
%   Loads all parameters into the elecTRQParams struct and loads
%   FlexibleDriveline referenced-model parameters (flexDLParams struct and
%   bare gear-ratio aliases) so the model workspace remains isolated.

% Copyright 2026 The MathWorks, Inc.

%% FlexibleDriveline referenced-model parameters
FlexibleDrivelineParams;

%% Control Parameters
elecTRQParams.control.ts = 2e-6;
elecTRQParams.control.fsw = 2e3;
elecTRQParams.control.fc = elecTRQParams.control.fsw * 10;
elecTRQParams.control.tsc = 1 / elecTRQParams.control.fc;
elecTRQParams.control.tsi = 1 / elecTRQParams.control.fc;

%% PI Controller Gains (d-axis current)
elecTRQParams.piId.ki = 710.3004;
elecTRQParams.piId.kp = 0.8779;
elecTRQParams.piId.dend = [1, -0.9191];
elecTRQParams.piId.numd = 0.0988;

%% PI Controller Gains (q-axis current)
elecTRQParams.piIq.ki = 1061.5;
elecTRQParams.piIq.kp = 1.0744;
elecTRQParams.piIq.dend = [1, -0.9012];
elecTRQParams.piIq.numd = 0.0809;

%% Motor (PMSM)
elecTRQParams.motor.j = 0.2;
elecTRQParams.motor.psim = 0.046;
elecTRQParams.motor.p = 8;
elecTRQParams.motor.ld = 2e-4;
elecTRQParams.motor.lq = 2e-4;
elecTRQParams.motor.l0 = 2e-4;
elecTRQParams.motor.rs = 0.008;
elecTRQParams.motor.imax = 600;
elecTRQParams.motor.tmax = 1.5 * elecTRQParams.motor.p * elecTRQParams.motor.psim * elecTRQParams.motor.imax;
elecTRQParams.motor.fnom = 300;
elecTRQParams.motor.rpmNom = 60 * elecTRQParams.motor.fnom / elecTRQParams.motor.p;
elecTRQParams.motor.omegamNom = 2 * pi * elecTRQParams.motor.fnom / elecTRQParams.motor.p;
elecTRQParams.motor.pmax = elecTRQParams.motor.omegamNom * elecTRQParams.motor.tmax;

%% Motor Mechanical
elecTRQParams.motorMech.bearing1ID = 35;
elecTRQParams.motorMech.bearing2ID = 35;
elecTRQParams.motorMech.bearing1Length = 14;
elecTRQParams.motorMech.bearing2Length = 14;
elecTRQParams.motorMech.speedRPM = [10, 2500, 5000, 10000, 25000];
elecTRQParams.motorMech.frictionCoff = [0.0040, 0.0050, 0.0005, 0.0020, 0.0021];
elecTRQParams.motorMech.bearingSpan12 = 280;
elecTRQParams.motorMech.shaftDiaAtRotor = 45;
elecTRQParams.motorMech.shaftLength = 365;
elecTRQParams.motorMech.stackLength = 152;
elecTRQParams.motorMech.shaftOverHang = elecTRQParams.motorMech.shaftLength ...
    - elecTRQParams.motorMech.bearingSpan12 ...
    - elecTRQParams.motorMech.bearing1Length ...
    - elecTRQParams.motorMech.bearing2Length;
elecTRQParams.motorMech.shaftLengthBearing = (elecTRQParams.motorMech.bearingSpan12 ...
    - elecTRQParams.motorMech.stackLength) / 2;

%% Gear Box
elecTRQParams.gearBox.overAllGearRatio = 7.5;
elecTRQParams.gearBox.motorToCSGearRatio = 2.5;
elecTRQParams.gearBox.csToMSGearRatio = 1;
elecTRQParams.gearBox.gear1Inertia = 0.1;
elecTRQParams.gearBox.gear2Inertia = 0.11;
elecTRQParams.gearBox.gear1BackLash = 1e-3;
elecTRQParams.gearBox.gear1BaseRadius = 100;
elecTRQParams.gearBox.gear1Stiffness = 1e6;
elecTRQParams.gearBox.gear1Damping = 1e3;
elecTRQParams.gearBox.gear1ViscousDampingCoefficients = [0, 0];
elecTRQParams.gearBox.gear2BackLash = 1e-3;
elecTRQParams.gearBox.gear2BaseRadius = 100;
elecTRQParams.gearBox.gear2Stiffness = 1e6;
elecTRQParams.gearBox.gear2Damping = 1e3;
elecTRQParams.gearBox.gear2ViscousDampingCoefficients = [0, 0];
elecTRQParams.gearBox.counterShaft1TorsionalStiffness = 2e5;
elecTRQParams.gearBox.counterShaft2TorsionalStiffness = 2e5;
elecTRQParams.gearBox.counterShaft3TorsionalStiffness = 2e5;
elecTRQParams.gearBox.counterShaft1TorsionalInertia = 0.02;
elecTRQParams.gearBox.counterShaft2TorsionalInertia = 0.02;
elecTRQParams.gearBox.counterShaft3TorsionalInertia = 0.02;
elecTRQParams.gearBox.finalDriveGearRatio = elecTRQParams.gearBox.overAllGearRatio ...
    / (elecTRQParams.gearBox.motorToCSGearRatio * elecTRQParams.gearBox.csToMSGearRatio);
elecTRQParams.gearBox.sunAndCarrierEfficiency = [0.85, 0.8];
elecTRQParams.gearBox.finalGearInertia = 0.1;
elecTRQParams.gearBox.tireR = 0.33;

%% Battery
elecTRQParams.battery.cdc = 1e-3;
elecTRQParams.battery.vnom = 550;
elecTRQParams.battery.ah0 = 280;

%% Optimization variables (bare aliases for FlexibleDriveline gear ratio blocks)
motorToCSGearRatio = elecTRQParams.gearBox.motorToCSGearRatio;
CSToMSGearRatio = elecTRQParams.gearBox.csToMSGearRatio;
overAllgearRatio = elecTRQParams.gearBox.overAllGearRatio;
finalDriveGearRatio = elecTRQParams.gearBox.finalDriveGearRatio;

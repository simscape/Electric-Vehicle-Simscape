%mechanicalDLTorsionOrderMapParams Parameter initialization for mechanicalDLTorsionOrderMap model.
%   Loads all parameters into the mechDLParams struct and loads
%   FlexibleDriveline referenced-model parameters (flexDLParams struct and
%   bare gear-ratio aliases) so the model workspace remains isolated.

% Copyright 2026 The MathWorks, Inc.

%% FlexibleDriveline referenced-model parameters
FlexibleDrivelineParams;

%% Common / PMSM Control
mechDLParams.common.ts = 2e-6;
mechDLParams.common.fsw = 2e3;
mechDLParams.common.fc = mechDLParams.common.fsw * 10;
mechDLParams.common.tsc = 1 / mechDLParams.common.fc;
mechDLParams.common.pm = 0.03;
mechDLParams.common.ld = 2e-4;
mechDLParams.common.lq = 2e-4;
mechDLParams.common.l0 = 2e-4;
mechDLParams.common.rs = 0.013;
mechDLParams.common.n = 6;
mechDLParams.common.j = 0.2;
mechDLParams.common.imax = 100;
mechDLParams.common.tmax = 1.5 * mechDLParams.common.n * mechDLParams.common.pm * mechDLParams.common.imax;
mechDLParams.common.fnom = 100;
mechDLParams.common.rpmNom = 60 * mechDLParams.common.fnom / mechDLParams.common.n;
mechDLParams.common.omegamNom = 2 * pi * mechDLParams.common.fnom / mechDLParams.common.n;
mechDLParams.common.pmax = mechDLParams.common.omegamNom * mechDLParams.common.tmax;

%% Motor Mechanical
mechDLParams.motorMech.bearing1ID = 35;
mechDLParams.motorMech.bearing2ID = 35;
mechDLParams.motorMech.bearing1Length = 14;
mechDLParams.motorMech.bearing2Length = 14;
mechDLParams.motorMech.speedRPM = [10, 2500, 5000, 10000, 25000];
mechDLParams.motorMech.frictionCoff = [0.0040, 0.0050, 0.0005, 0.0020, 0.0021];
mechDLParams.motorMech.bearingSpan12 = 280;
mechDLParams.motorMech.shaftDiaAtRotor = 45;
mechDLParams.motorMech.shaftLength = 365;
mechDLParams.motorMech.stackLength = 152;
mechDLParams.motorMech.shaftOverHang = mechDLParams.motorMech.shaftLength ...
    - mechDLParams.motorMech.bearingSpan12 ...
    - mechDLParams.motorMech.bearing1Length ...
    - mechDLParams.motorMech.bearing2Length;
mechDLParams.motorMech.shaftLengthBearing = (mechDLParams.motorMech.bearingSpan12 ...
    - mechDLParams.motorMech.stackLength) / 2;

%% Gear Box
mechDLParams.gearBox.overAllGearRatio = 7.5;
mechDLParams.gearBox.motorToCSGearRatio = 2.5;
mechDLParams.gearBox.csToMSGearRatio = 1;
mechDLParams.gearBox.gear1Inertia = 0.1;
mechDLParams.gearBox.gear2Inertia = 0.11;
mechDLParams.gearBox.gear1BackLash = 1e-3;
mechDLParams.gearBox.gear1BaseRadius = 100;
mechDLParams.gearBox.gear1Stiffness = 1e6;
mechDLParams.gearBox.gear1Damping = 1e3;
mechDLParams.gearBox.gear1ViscousDampingCoefficients = [0, 0];
mechDLParams.gearBox.gear2BackLash = 1e-3;
mechDLParams.gearBox.gear2BaseRadius = 100;
mechDLParams.gearBox.gear2Stiffness = 1e6;
mechDLParams.gearBox.gear2Damping = 1e3;
mechDLParams.gearBox.gear2ViscousDampingCoefficients = [0, 0];
mechDLParams.gearBox.counterShaft1TorsionalStiffness = 2e5;
mechDLParams.gearBox.counterShaft2TorsionalStiffness = 2e5;
mechDLParams.gearBox.counterShaft3TorsionalStiffness = 2e5;
mechDLParams.gearBox.counterShaft1TorsionalInertia = 0.02;
mechDLParams.gearBox.counterShaft2TorsionalInertia = 0.02;
mechDLParams.gearBox.counterShaft3TorsionalInertia = 0.02;
mechDLParams.gearBox.finalDriveGearRatio = mechDLParams.gearBox.overAllGearRatio ...
    / (mechDLParams.gearBox.motorToCSGearRatio * mechDLParams.gearBox.csToMSGearRatio);
mechDLParams.gearBox.sunAndCarrierEfficiency = [0.85, 0.8];
mechDLParams.gearBox.finalGearInertia = 0.1;

%% Shaft Vibrations
mechDLParams.shaftVib.lengthShaft = 0.365;
mechDLParams.shaftVib.stackLength = 0.162;
mechDLParams.shaftVib.bearingSpan12 = 0.325;
mechDLParams.shaftVib.excitationPoles = 8;
mechDLParams.shaftVib.excitationLoad = 20e3;
mechDLParams.shaftVib.wNominalForcing = 8.6 / 60 * 2 * pi;
mechDLParams.shaftVib.numModes = 10;
mechDLParams.shaftVib.wMax = 1500 * 2 * pi * mechDLParams.shaftVib.excitationPoles / 60;
mechDLParams.shaftVib.dz = mechDLParams.shaftVib.lengthShaft / 20;
mechDLParams.shaftVib.zShaft = [ ...
    (mechDLParams.shaftVib.lengthShaft - mechDLParams.shaftVib.stackLength) / 2, ...
    mechDLParams.shaftVib.stackLength, ...
    (mechDLParams.shaftVib.lengthShaft - mechDLParams.shaftVib.stackLength) / 2];
mechDLParams.shaftVib.zTLU = [0, ...
    (mechDLParams.shaftVib.lengthShaft - mechDLParams.shaftVib.stackLength) / 2, ...
    (mechDLParams.shaftVib.lengthShaft - mechDLParams.shaftVib.stackLength) / 2 + mechDLParams.shaftVib.stackLength, ...
    mechDLParams.shaftVib.lengthShaft];
mechDLParams.shaftVib.lengthsTLU = diff(mechDLParams.shaftVib.zTLU);
mechDLParams.shaftVib.diametersOuterTLU = [0.1, 0.15, 0.1];
mechDLParams.shaftVib.materialDensity = 7.8e3;
mechDLParams.shaftVib.elasticModulus = 200e9;
mechDLParams.shaftVib.shearModulus = 7.93e10;
mechDLParams.shaftVib.aDamp = 10;
mechDLParams.shaftVib.bDamp = 1e-9;
mechDLParams.shaftVib.shaftMass = 2;
mechDLParams.shaftVib.shaftInertia = 1e4;
mechDLParams.shaftVib.f0 = 9.81 * mechDLParams.shaftVib.shaftMass;
mechDLParams.shaftVib.numSupports = 2;
mechDLParams.shaftVib.zSupport = [0, mechDLParams.shaftVib.bearingSpan12];
mechDLParams.shaftVib.bearingSpeed = [1, 2.5, 5, 10];
mechDLParams.shaftVib.muViscTors = [0, 0];
mechDLParams.shaftVib.bearing.K = 1e10 * [ ...
    1.019,    0.0004,  -0.0112,  17.882; ...
    3.556,   -0.0012,  -0.0244,  52.804; ...
    6.401,   -0.0022,  -0.0440,  79.047; ...
    7.2011,  -0.0026,  -0.0488,  80.928];
mechDLParams.shaftVib.bearing.D = 1e8 * [ ...
    2.0708,  -0.0748,  -0.0748,  2.0708; ...
    4.9159,  -0.0256,  -0.0256,  4.9159; ...
    7.4907,  -0.0293,  -0.0293,  7.4907; ...
    7.5885,  -0.0498,  -0.0498,  7.5885];
mechDLParams.shaftVib.bearing.kRot = [1e2, 1e2];
mechDLParams.shaftVib.bearing.dRot = [1e2, 1e2];
mechDLParams.shaftVib.bearing.dTransSpeedFree = mechDLParams.shaftVib.bearing.D / 1e9;
mechDLParams.shaftVib.bearing.dRotFree = [1e1, 1e1];
mechDLParams.shaftVib.bearing.kTransSpeedFree = mechDLParams.shaftVib.bearing.K / 1e9;
mechDLParams.shaftVib.bearing.kRotFree = [1e1, 1e1];
mechDLParams.shaftVib.zRotor = mechDLParams.shaftVib.bearingSpan12 / 2;
mechDLParams.shaftVib.zMass = [mechDLParams.shaftVib.zRotor, mechDLParams.shaftVib.lengthShaft];
mechDLParams.shaftVib.pointMass = [20.9, 1.7];
mechDLParams.shaftVib.id = [1.7 + 3.1, 5.8];
mechDLParams.shaftVib.ipRotorHub = 8.6 + 6.2;
mechDLParams.shaftVib.ip = [mechDLParams.shaftVib.ipRotorHub, 7.4];
mechDLParams.shaftVib.ipTotal = mechDLParams.shaftVib.shaftInertia + sum(mechDLParams.shaftVib.ip);

%% Vehicle Dynamics
mechDLParams.vehicle.tireRollingFriction = 0.015;
mechDLParams.vehicle.mass = 1000;
mechDLParams.vehicle.gravity = 9.81;
mechDLParams.vehicle.dragCoefficient = 0.015;
mechDLParams.vehicle.airDensity = 1.225;
mechDLParams.vehicle.frontalArea = 1.25;
mechDLParams.vehicle.tireR = 0.3;


%% Optimization variables (bare aliases for setVariable / From Workspace)
motorToCSGearRatio = mechDLParams.gearBox.motorToCSGearRatio;
CSToMSGearRatio = mechDLParams.gearBox.csToMSGearRatio;
overAllgearRatio = mechDLParams.gearBox.overAllGearRatio;
finalDriveGearRatio = mechDLParams.gearBox.finalDriveGearRatio;
%% Torque Input Signal
load(fullfile(fileparts(mfilename('fullpath')), 'extendedMotorTorque.mat'));
% mechDLParams.simin = [EXTNTime EXTNTime]; %#ok<NODEF>
TRQTime = [EXTNTime EXTNTRQ]; %#ok<NODEF>
%FlexibleDrivelineParams Parameter initialization for FlexibleDriveline referenced model.
%   Loads all parameters into the flexDLParams struct so the model workspace
%   remains isolated from parent models.

% Copyright 2026 The MathWorks, Inc.

%% Motor Mechanical
flexDLParams.motorMech.bearing1ID = 35;
flexDLParams.motorMech.bearing2ID = 35;
flexDLParams.motorMech.bearing1Length = 14;
flexDLParams.motorMech.speedRPM = [10, 2500, 5000, 10000, 25000];
flexDLParams.motorMech.frictionCoff = [0.0040, 0.0050, 0.0005, 0.0020, 0.0021];
flexDLParams.motorMech.bearingSpan12 = 280;
flexDLParams.motorMech.shaftDiaAtRotor = 45;
flexDLParams.motorMech.shaftLength = 365;
flexDLParams.motorMech.stackLength = 152;
flexDLParams.motorMech.shaftOverHang = flexDLParams.motorMech.shaftLength ...
    - flexDLParams.motorMech.bearingSpan12 ...
    - flexDLParams.motorMech.bearing1Length ...
    - 14;
flexDLParams.motorMech.shaftLengthBearing = (flexDLParams.motorMech.bearingSpan12 ...
    - flexDLParams.motorMech.stackLength) / 2;

%% Gear Box
flexDLParams.gearBox.overAllGearRatio = 7.5;
flexDLParams.gearBox.motorToCSGearRatio = 2.5;
flexDLParams.gearBox.csToMSGearRatio = 1;
flexDLParams.gearBox.gear1Inertia = 0.1;
flexDLParams.gearBox.gear2Inertia = 0.11;
flexDLParams.gearBox.gear1BackLash = 1e-3;
flexDLParams.gearBox.gear1BaseRadius = 100;
flexDLParams.gearBox.gear1Stiffness = 1e6;
flexDLParams.gearBox.gear1Damping = 1e3;
flexDLParams.gearBox.gear1ViscousDampingCoefficients = [0, 0];
flexDLParams.gearBox.gear2BackLash = 1e-3;
flexDLParams.gearBox.gear2BaseRadius = 100;
flexDLParams.gearBox.gear2Stiffness = 1e6;
flexDLParams.gearBox.gear2Damping = 1e3;
flexDLParams.gearBox.gear2ViscousDampingCoefficients = [0, 0];
flexDLParams.gearBox.finalDriveGearRatio = flexDLParams.gearBox.overAllGearRatio ...
    / (flexDLParams.gearBox.motorToCSGearRatio * flexDLParams.gearBox.csToMSGearRatio);
flexDLParams.gearBox.sunAndCarrierEfficiency = [0.85, 0.8];
flexDLParams.gearBox.finalGearInertia = 0.1;
flexDLParams.gearBox.tireR = 0.33;

%% Motor Inertia
flexDLParams.motor.j = 0.2;

%% Bending Vibrations (Motor Shaft)
fs.lengthShaft = 0.365;
fs.stackLength = 0.162;
fs.bearingSpan12 = 0.325;
fs.excitationPoles = 8;
fs.excitationLoad = 20e3;
fs.wNominalForcing = 8.6/60*2*pi;
fs.numModes = 10;
fs.wMax = 1500*2*pi*fs.excitationPoles/60;
fs.dz = fs.lengthShaft/20;
fs.zShaft = [(fs.lengthShaft-fs.stackLength)/2, fs.stackLength, (fs.lengthShaft-fs.stackLength)/2];
fs.zTLU = [0, (fs.lengthShaft-fs.stackLength)/2, ...
    (fs.lengthShaft-fs.stackLength)/2+fs.stackLength, fs.lengthShaft];
fs.lengthsTLU = diff(fs.zTLU);
fs.diametersOuterTLU = [0.1, 0.15, 0.1];
fs.materialDensity = 7.8e3;
fs.elasticModulus = 200e9;
fs.shearModulus = 7.93e+10;
fs.aDamp = 10;
fs.bDamp = 1e-9;
fs.shaftMass = 2;
fs.shaftInertia = 1e4;
fs.F0 = 9.81*fs.shaftMass;
fs.numSupports = 2;
fs.zSupport = [0, fs.bearingSpan12];
fs.bearingSpeed = [1, 2.5, 5, 10];
fs.muViscTors = zeros(1, length(fs.zSupport));
fs.bearing.K = 1e10*[ ...
    1.019,    0.0004,  -0.0112,   17.882; ...
    3.556,   -0.0012,  -0.0244,   52.804; ...
    6.401,   -0.0022,  -0.0440,   79.047; ...
    7.2011,  -0.0026,  -0.0488,   80.928];
fs.bearing.D = 1e8*[ ...
    2.0708,  -0.0748,  -0.0748,   2.0708; ...
    4.9159,  -0.0256,  -0.0256,   4.9159; ...
    7.4907,  -0.0293,  -0.0293,   7.4907; ...
    7.5885,  -0.0498,  -0.0498,   7.5885];
fs.bearing.kRot = [1e2, 1e2];
fs.bearing.dRot = [1e2, 1e2];
fs.bearing.dTransSpeedFree = fs.bearing.D/1e9;
fs.bearing.dRotFree = [1e1, 1e1];
fs.bearing.kTransSpeedFree = fs.bearing.K/1e9;
fs.bearing.kRotFree = [1e1, 1e1];
fs.zRator = fs.bearingSpan12/2;
fs.zMass = [fs.zRator, fs.lengthShaft];
fs.pointMass = [20.9, 1.7];
fs.Id = [1.7+3.1, 5.8];
fs.Ip = [8.6+6.2, 7.4];
fs.IpTotal = fs.shaftInertia + sum(fs.Ip);
flexDLParams.bendingVibrations = fs;

%% Optimization variables (bare aliases for gear ratio block mask expressions)
motorToCSGearRatio = flexDLParams.gearBox.motorToCSGearRatio;
CSToMSGearRatio = flexDLParams.gearBox.csToMSGearRatio;
overAllgearRatio = flexDLParams.gearBox.overAllGearRatio;
finalDriveGearRatio = flexDLParams.gearBox.finalDriveGearRatio;

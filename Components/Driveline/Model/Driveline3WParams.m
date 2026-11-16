%% Driveline3WParams — Parameters for Driveline3W (Piaggio Ape E-City)
% Driveline3WParams Vehicle body and wheel parameters for the
% three-wheel BEV drivetrain.
%
%   Piaggio Ape E-City FX specifications.
%   GVW 713 kg, Kerb 413 kg, Wheelbase 1920 mm, 3 tyres 4.00-8 4PR.
%
% Copyright 2026 The MathWorks, Inc.

%% Vehicle Body
drivetrain.MaxSpeed = 55/0.06; % [m/min] max speed 55 km/h
drivetrain.kerbWeight_kg = 413;
drivetrain.batteryWeight_kg = 48;
drivetrain.vehMass_kg = drivetrain.kerbWeight_kg - drivetrain.batteryWeight_kg; % 365 kg (chassis w/o battery)
drivetrain.humanWeight_kg = 70 * 4;                                          % driver + 3 passengers
drivetrain.payload_kg = drivetrain.humanWeight_kg + drivetrain.batteryWeight_kg; % 328 kg

drivetrain.numWhlAxle = [1, 2];
% [front, rear] — 1 front wheel, 2 rear wheels.

drivetrain.overallLength_mm = 2700;
drivetrain.overallWidth_mm = 1370;
drivetrain.overallHeight_mm = 1725;
drivetrain.distCGFrontAxle_mm = drivetrain.overallLength_mm / 2;  % 1350 mm
drivetrain.distCGRearAxle_mm = drivetrain.overallLength_mm / 2;   % 1350 mm
drivetrain.cgHeight_mm = drivetrain.overallHeight_mm / 2;         % 862.5 mm
drivetrain.g_mps2 = 9.81;
drivetrain.frontalArea_m2 = 2.09;
drivetrain.dragCoeff = 0.44;
drivetrain.airDensity_kgpm3 = 1.19;
drivetrain.payloadCG = [0 0];
drivetrain.wheelbase_m = 1.920;

%% Wheel
% 4.00-8, 4PR, 70E — front and rear identical
drivetrain.ratedVerticalLoad_N = (drivetrain.vehMass_kg + drivetrain.payload_kg) / 3;
drivetrain.peakLongForce_N = drivetrain.ratedVerticalLoad_N;
drivetrain.slipPeakForce_perc = 10;
drivetrain.tireRollingRadius_m = 0.205;
drivetrain.rollingResistanceCoeff = 0.013;

%% Transmission
drivetrain.gearRatio = 5.9;          % [-] final drive ratio (Differential cd_ratio)
drivetrain.MaxSpeed = 70 / 0.06;     % [m/min] controller speed limiter

%% Brake
% Rear drum brake (modelled as Disc Brake block with equivalent parameters)
drivetrain.brakeRmean = 0.090;       % [m] mean drum radius (180 mm drum diameter)
drivetrain.brakeBore = 0.020;        % [m] wheel cylinder bore
drivetrain.brakeNPads = 2;           % [-] number of shoes
drivetrain.brakeMuCoulomb = 0.35;    % [-] lining friction coefficient

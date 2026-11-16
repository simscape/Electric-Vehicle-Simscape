% DrivelineWithBrakingParams Vehicle body, wheel, and brake parameters
% for the four-wheel BEV drivetrain with disc brakes.
%
% Copyright 2025 The MathWorks, Inc.

%% Vehicle Body
drivetrain.MaxSpeed = 140/0.06; % [m/min] max speed 140 km/h
drivetrain.vehMass_kg = 1600;
drivetrain.tireRollingRadius_cm = 30;

%% Brake
drivetrain.brakeRmean = 0.130;       % [m] mean disc radius (260 mm disc)
drivetrain.brakeBore = 0.054;        % [m] caliper piston bore
drivetrain.brakeNPads = 2;           % [-] number of pads
drivetrain.brakeMuCoulomb = 0.40;    % [-] pad friction coefficient

%FlexibleDriveLineTestHarnessParams Parameter initialization for FlexibleDriveLineTestHarness.
%   Loads all test-harness-specific parameters into the thParams struct and
%   loads FlexibleDriveline referenced-model parameters (flexDLParams struct
%   and bare gear-ratio aliases) so the model workspace remains isolated.

% Copyright 2026 The MathWorks, Inc.

%% FlexibleDriveline referenced-model parameters
run(fullfile(fileparts(mfilename('fullpath')), '..', 'Model', 'FlexibleDrivelineParams.m'));

%% Vehicle Dynamics
thParams.vehicle.mass = 600;
thParams.vehicle.tireRollingFriction = 0.015;
thParams.vehicle.gravity = 9.81;
thParams.vehicle.dragCoefficient = 0.015;
thParams.vehicle.airDensity = 1.225;
thParams.vehicle.frontalArea = 1.25;

%% Torque Input
thParams.ramp.slope = 100;
thParams.saturation.upperLimit = 80;
thParams.saturation.lowerLimit = 0;

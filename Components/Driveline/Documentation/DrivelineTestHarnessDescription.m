%% Driveline Test Harness
% Standalone test environment for the Driveline component.
%
% *Harness:* |DriveLineTestHarness.slx|
%
% *Test Case:* |DrivelinePassTests.m|
%
% *Fidelity:* DrivelineWithBraking

%% Overview
% The DriveLineTestHarness provides a standalone simulation environment for
% validating the vehicle driveline. The harness supplies front and rear
% axle torque commands and brake inputs to exercise the driveline through
% acceleration and braking maneuvers.
%
% The default fidelity in the harness is *DrivelineWithBraking*, which
% includes an integrated braking system on the rear axle for blended
% regenerative/friction braking analysis. Parameters are initialized by
% |DriveLineTestHarnessParams.m|, which loads |DrivelineWithBrakingParams.m|.
%
% The harness scope captures:
%
% * *Input Torque* - Torque commands applied to the driveline.
% * *Road Load* - Mechanical load and vehicle response.

%% Setup
% Load parameters and open the test harness.

model = 'DriveLineTestHarness';
DriveLineTestHarnessParams;
load_system(model)

%% Run Simulation and Results

simout = sim(model, 'SrcWorkspace', 'current');
plotDrivelineHarnessResults(simout.logsout)

%% Running Unit Tests
% Run the MQC test suite from the command line:
%
%   results = runtests('DrivelinePassTests');
%   disp(results)

%% See Also
% * <DrivelineDescription.html Driveline>
% * <DrivelineWithBrakingDescription.html DrivelineWithBraking>

% Copyright 2022 - 2025 The MathWorks, Inc.

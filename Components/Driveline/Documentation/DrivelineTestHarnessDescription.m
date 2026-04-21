%% Driveline Test Harness
% Standalone test environment for the Driveline component.

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
% *Harness:* <matlab:open_system('DriveLineTestHarness') DriveLineTestHarness.slx>
%
% *Parameters:* <matlab:edit('DriveLineTestHarnessParams.m') DriveLineTestHarnessParams.m>
%
% *Test Case:* <matlab:edit('DrivelinePassTests.m') DrivelinePassTests.m>
%
% *Fidelity:* DrivelineWithBraking

%% Setup
% Load parameters and open the test harness.
%
%   model = 'DriveLineTestHarness';
%   DriveLineTestHarnessParams;
%   open_system(model)

model = 'DriveLineTestHarness';
DriveLineTestHarnessParams;
open_system(model)

%% Run Simulation and Results
%
%   simout = sim(model, 'SrcWorkspace', 'current');

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

% Copyright 2022 - 2026 The MathWorks, Inc.

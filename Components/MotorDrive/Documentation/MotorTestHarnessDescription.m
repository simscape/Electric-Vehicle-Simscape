%% Motor Test Harness
% Standalone test environment for the MotorDrive component.

%% Overview
% The MotorTestHarness provides a standalone simulation environment for
% validating the electric motor drive unit. The harness supplies torque
% commands, control signals, battery state, and coolant boundary conditions
% to exercise the motor through acceleration and load profiles.
%
% The default fidelity in the harness is *MotorDriveGearTh*, which includes
% full thermal coupling for motor windings, inverter, and coolant jacket.
% The core motor model is provided by the EmotorLib library. Parameters are
% initialized by |MotorTestHarnessParams.m|, which loads
% |MotorDriveGearThParams.m| and |InverterMotorDriveParam.m|.
%
% *Harness:* <matlab:open_system('MotorTestHarness') MotorTestHarness.slx>
%
% *Parameters:* <matlab:edit('MotorTestHarnessParams.m') MotorTestHarnessParams.m>
%
% *Test Case:* <matlab:edit('MotorDrivePassTests.m') MotorDrivePassTests.m>
%
% *Fidelity:* MotorDriveGearTh

%% Setup
% Load parameters and open the test harness.
%
%   model = 'MotorTestHarness';
%   MotorTestHarnessParams;
%   open_system(model)

model = 'MotorTestHarness';
MotorTestHarnessParams;
open_system(model)

%% Run Simulation and Results
%
%   simout = sim(model, 'SrcWorkspace', 'current');

simout = sim(model, 'SrcWorkspace', 'current');
plotMotorHarnessResults(simout.logsout)

%% Running Unit Tests
% Run the MQC test suite from the command line:
%
%   results = runtests('MotorDrivePassTests');
%   disp(results)

%% See Also
% * <MotorDriveGearDescription.html MotorDriveGear>
% * <MotorDriveGearThDescription.html MotorDriveGearTh>
% * <MotorDriveLubeDescription.html MotorDriveLube>
% * <EmotorLibDescription.html EmotorLib Library>

% Copyright 2022 - 2026 The MathWorks, Inc.

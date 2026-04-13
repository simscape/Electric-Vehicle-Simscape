%% Motor Test Harness
% Standalone test environment for the MotorDrive component.
%
% *Harness:* |MotorTestHarness.slx|
%
% *Test Case:* |MotorDrivePassTests.m|
%
% *Fidelity:* MotorDriveGearTh

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
% |EmotorLibParams.m| and |MotorThermalParams.m|.
%
% The harness scopes capture:
%
% * *Motor Current* - Phase current drawn by the motor.
% * *Motor Speed* - Rotor speed in rpm.
% * *Motor Voltage* - Terminal voltage.
% * *Coil Temperature* - Stator winding temperature.
% * *Magnet Temperature* - Rotor magnet temperature.
% * *Input / Load* - Torque command and mechanical load profiles.

%% Setup
% Load parameters and open the test harness.

model = 'MotorTestHarness';
MotorTestHarnessParams;
load_system(model)

%% Run Simulation and Results

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

% Copyright 2022 - 2025 The MathWorks, Inc.

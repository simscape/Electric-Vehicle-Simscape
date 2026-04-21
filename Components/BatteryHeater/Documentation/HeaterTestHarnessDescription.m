%% Heater Test Harness
% Standalone test environment for the BatteryHeater component.

%% Overview
% The HeaterTestHarness provides a standalone simulation environment for
% validating the battery pack heater. The harness supplies battery status
% signals, heater control commands, and coolant boundary conditions to
% exercise the heater through cold-start and warm-up scenarios.
%
% The harness uses the *Heater* model which draws power from the HV bus
% through a controlled current source and rejects heat into the coolant
% loop via a thermal mass and coolant jacket. Parameters are initialized by
% |HeaterTestHarnessParams.m|, which loads heater electrical and coolant
% system settings from |HeaterParams.m|.
%
% *Harness:* <matlab:open_system('HeaterTestHarness') HeaterTestHarness.slx>
%
% *Parameters:* <matlab:edit('HeaterTestHarnessParams.m') HeaterTestHarnessParams.m>
%
% *Test Case:* <matlab:edit('BatteryHeaterPassTests.m') BatteryHeaterPassTests.m>
%
% *Fidelity:* Heater

%% Setup
% Load parameters and open the test harness.
%
%   model = 'HeaterTestHarness';
%   HeaterTestHarnessParams;
%   open_system(model)

model = 'HeaterTestHarness';
HeaterTestHarnessParams;
open_system(model)

%% Run Simulation and Results
%
%   simout = sim(model, 'SrcWorkspace', 'current');

simout = sim(model, 'SrcWorkspace', 'current');
plotHeaterHarnessResults(simout.logsout)

%% Running Unit Tests
% Run the MQC test suite from the command line:
%
%   results = runtests('BatteryHeaterPassTests');
%   disp(results)

%% See Also
% * <HeaterDescription.html Heater>

% Copyright 2022 - 2026 The MathWorks, Inc.

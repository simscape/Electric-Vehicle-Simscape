%% PumpDriver Test Harness
% Standalone test environment for the PumpDriver component.

%% Overview
% The PumpDriverTestHarness provides a standalone simulation environment
% for validating the pump driver controller. The harness supplies a DC
% voltage input, coolant boundary conditions, and pump enable signals.
%
% Parameters are initialized by |PumpDriverTestHarnessParams.m|, which
% loads |PumpDriverParams.m|.
%
% *Harness:* <matlab:open_system('PumpDriverTestHarness') PumpDriverTestHarness.slx>
%
% *Parameters:* <matlab:edit('PumpDriverTestHarnessParams.m') PumpDriverTestHarnessParams.m>
%
% *Test Case:* <matlab:edit('PumpDriverPassTests.m') PumpDriverPassTests.m>
%
% *Fidelity:* PumpDriver

%% Setup
% Load parameters and open the test harness.

model = 'PumpDriverTestHarness';
PumpDriverTestHarnessParams;
load_system(model)

%% Run Simulation and Results

simout = sim(model, 'SrcWorkspace', 'current');
plotPumpDriverHarnessResults(simout.logsout)

%% Running Unit Tests
% Run the MQC test suite from the command line:
%
%   results = runtests('PumpDriverPassTests');
%   disp(results)

%% See Also
% * <PumpDriverDescription.html PumpDriver>

% Copyright 2022 - 2025 The MathWorks, Inc.

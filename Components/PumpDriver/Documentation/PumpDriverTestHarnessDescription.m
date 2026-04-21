%% PumpDriverTh Test Harness
% Standalone test environment for the DCDC (PumpDriver) component.

%% Overview
% The PumpDriverTestHarness provides a standalone simulation environment
% for validating the pump driver controller. The harness supplies a DC
% voltage input, coolant boundary conditions, and pump enable signals.
%
% Parameters are initialized by |PumpDriverTestHarnessParams.m|, which
% loads |PumpDriverThParams.m|.
%
% *Harness:* <matlab:open_system('PumpDriverTestHarness') PumpDriverTestHarness.slx>
%
% *Parameters:* <matlab:edit('PumpDriverTestHarnessParams.m') PumpDriverTestHarnessParams.m>
%
% *Test Case:* <matlab:edit('PumpDriverPassTests.m') PumpDriverPassTests.m>
%
% *Fidelity:* PumpDriverTh

%% Setup
% Load parameters and open the test harness.
%
%   model = 'PumpDriverTestHarness';
%   PumpDriverTestHarnessParams;
%   open_system(model)

model = 'PumpDriverTestHarness';
PumpDriverTestHarnessParams;
open_system(model)

%% Run Simulation and Results
%
%   simout = sim(model, 'SrcWorkspace', 'current');

simout = sim(model, 'SrcWorkspace', 'current');
plotPumpDriverHarnessResults(simout.logsout)

%% Running Unit Tests
% Run the MQC test suite from the command line:
%
%   results = runtests('PumpDriverPassTests');
%   disp(results)

%% See Also
% * <PumpDriverDescription.html PumpDriver>
% * <PumpDriverThDescription.html PumpDriverTh>

% Copyright 2022 - 2026 The MathWorks, Inc.

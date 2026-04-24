%% Pump Test Harness
% Standalone test environment for the Pump component.

%% Overview
% The PumpTestHarness provides a standalone simulation environment for
% validating the coolant circulation pump. The harness supplies a DC
% voltage input to drive the pump and provides coolant boundary conditions
% at the inlet and outlet.
%
% Parameters are initialized by |PumpTestHarnessParams.m|, which loads
% |PumpParams.m|.
%
% *Harness:* <matlab:open_system('PumpTestHarness') PumpTestHarness.slx>
%
% *Parameters:* <matlab:edit('PumpTestHarnessParams.m') PumpTestHarnessParams.m>
%
% *Test Case:* <matlab:edit('PumpPassTests.m') PumpPassTests.m>
%
% *Fidelity:* Pump

%% Setup
% Load parameters and open the test harness.
%
%   model = 'PumpTestHarness';
%   PumpTestHarnessParams;
%   open_system(model)

model = 'PumpTestHarness';
PumpTestHarnessParams;
open_system(model)

%% Run Simulation and Results
%
%   simout = sim(model, 'SrcWorkspace', 'current');

simout = sim(model, 'SrcWorkspace', 'current');
plotPumpHarnessResults(simout.logsout)

%% Running Unit Tests
% Run the MQC test suite from the command line:
%
%   results = runtests('PumpPassTests');
%   disp(results)

%% See Also
% * <PumpDescription.html Pump>

% Copyright 2022 - 2026 The MathWorks, Inc.

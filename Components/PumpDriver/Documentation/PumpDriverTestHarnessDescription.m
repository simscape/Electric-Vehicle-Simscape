%% PumpDriver Test Harness
% Standalone test environment for the PumpDriver component.
%
% *Harness:* |PumpDriverTestHarness.slx|
%
% *Test Case:* |PumpDriverPassTests.m|

%% Overview
% The PumpDriverTestHarness provides a standalone simulation environment
% for validating the pump driver controller. The harness supplies a DC
% voltage input, coolant boundary conditions, and pump enable signals.
% Scoped outputs capture voltage levels and coolant temperatures.
%
% Parameters are initialized by |PumpDriverTestHarnessParams.m|, which
% loads |PumpDriverParams.m|.
%
% The harness scopes capture:
%
% * *DC Input Voltage* - Supply voltage to the pump driver.
% * *DC Output Voltage* - Voltage output from the driver.
% * *Coolant Inlet Temperature* - Coolant temperature entering the system.
% * *Coolant Outlet Temperature* - Coolant temperature leaving the system.

%% Setup

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

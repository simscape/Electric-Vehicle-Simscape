%% Pump Test Harness
% Standalone test environment for the Pump component.
%
% *Harness:* |PumpTestHarness.slx|
%
% *Test Case:* |PumpPassTests.m|

%% Overview
% The PumpTestHarness provides a standalone simulation environment for
% validating the coolant circulation pump. The harness supplies a DC
% voltage input to drive the pump and provides coolant boundary conditions
% at the inlet and outlet. Scoped outputs capture pump current draw and
% coolant temperatures.
%
% Parameters are initialized by |PumpTestHarnessParams.m|, which loads
% |PumpParams.m|.
%
% The harness scopes capture:
%
% * *Pump Current* - Electrical current drawn by the pump motor.
% * *DC Input Voltage* - Supply voltage to the pump.
% * *Coolant Inlet Temperature* - Coolant temperature entering the pump.
% * *Coolant Outlet Temperature* - Coolant temperature leaving the pump.

%% Setup

model = 'PumpTestHarness';
PumpTestHarnessParams;
load_system(model)

%% Run Simulation and Results

simout = sim(model, 'SrcWorkspace', 'current');
plotPumpHarnessResults(simout.logsout)

%% Running Unit Tests
% Run the MQC test suite from the command line:
%
%   results = runtests('PumpPassTests');
%   disp(results)

%% See Also
% * <PumpDescription.html Pump>

% Copyright 2022 - 2025 The MathWorks, Inc.

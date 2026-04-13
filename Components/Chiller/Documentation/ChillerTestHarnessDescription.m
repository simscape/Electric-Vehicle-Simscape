%% Chiller Test Harness
% Standalone test environment for the Chiller component.
%
% *Harness:* |ChillerTestHarness.slx|
%
% *Test Case:* |ChillerPassTests.m|
%
% *Fidelity:* Chiller

%% Overview
% The ChillerTestHarness provides a standalone simulation environment for
% validating the battery coolant chiller. The harness supplies battery
% status signals, chiller bypass commands, HV bus power, and coolant
% boundary conditions to exercise the chiller during cooling scenarios.
%
% The default fidelity in the harness is *Chiller*, which includes thermal
% dynamics coupled to the coolant loop. The chiller draws current from the
% HV bus and removes heat from the coolant to maintain battery temperature.
% Parameters are initialized by |ChillerTestHarnessParams.m|, which loads
% |ChillerParams.m|.
%
% The harness scopes capture:
%
% * *DC Input Voltage* - HV bus voltage supplied to the chiller.
% * *Chiller Current* - Current drawn from the HV bus.
% * *Coolant Inlet Temperature* - Coolant temperature entering the chiller.
% * *Coolant Outlet Temperature* - Coolant temperature leaving the chiller.

%% Setup
% Load parameters and open the test harness.

model = 'ChillerTestHarness';
ChillerTestHarnessParams;
load_system(model)

%% Run Simulation and Results

simout = sim(model, 'SrcWorkspace', 'current');
plotChillerHarnessResults(simout.logsout)

%% Running Unit Tests
% Run the MQC test suite from the command line:
%
%   results = runtests('ChillerPassTests');
%   disp(results)

%% See Also
% * <ChillerDescription.html Chiller>
% * <ChillerNoCoolantDescription.html ChillerNoCoolant>

% Copyright 2022 - 2025 The MathWorks, Inc.

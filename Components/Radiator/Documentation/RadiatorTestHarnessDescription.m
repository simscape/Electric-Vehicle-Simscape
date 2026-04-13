%% Radiator Test Harness
% Standalone test environment for the Radiator component.
%
% *Harness:* |RadiatorTestHarness.slx|
%
% *Test Case:* |RadiatorPassTests.m|

%% Overview
% The RadiatorTestHarness provides a standalone simulation environment for
% validating the radiator heat exchanger. The harness supplies ambient air
% temperature, fan airflow, and hot coolant at the inlet. Scoped outputs
% capture coolant temperatures at the inlet and outlet to verify heat
% rejection performance.
%
% Parameters are initialized by |RadiatorTestHarnessParams.m|, which loads
% |RadiatorParams.m|.
%
% The harness scopes capture:
%
% * *Coolant Inlet Temperature* - Hot coolant temperature entering the radiator.
% * *Coolant Outlet Temperature* - Cooled coolant temperature leaving the radiator.

%% Setup

model = 'RadiatorTestHarness';
RadiatorTestHarnessParams;
load_system(model)

%% Run Simulation and Results

simout = sim(model, 'SrcWorkspace', 'current');
plotRadiatorHarnessResults(simout.logsout)

%% Running Unit Tests
% Run the MQC test suite from the command line:
%
%   results = runtests('RadiatorPassTests');
%   disp(results)

%% See Also
% * <RadiatorDescription.html Radiator>

% Copyright 2022 - 2025 The MathWorks, Inc.

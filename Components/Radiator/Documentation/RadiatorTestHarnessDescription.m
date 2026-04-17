%% Radiator Test Harness
% Standalone test environment for the Radiator component.

%% Overview
% The RadiatorTestHarness provides a standalone simulation environment for
% validating the radiator heat exchanger. The harness supplies ambient air
% temperature, fan airflow, and hot coolant at the inlet.
%
% Parameters are initialized by |RadiatorTestHarnessParams.m|, which loads
% |RadiatorParams.m|.
%
% *Harness:* <matlab:open_system('RadiatorTestHarness') RadiatorTestHarness.slx>
%
% *Parameters:* <matlab:edit('RadiatorTestHarnessParams.m') RadiatorTestHarnessParams.m>
%
% *Test Case:* <matlab:edit('RadiatorPassTests.m') RadiatorPassTests.m>
%
% *Fidelity:* Radiator

%% Setup
% Load parameters and open the test harness.
%
%   model = 'RadiatorTestHarness';
%   RadiatorTestHarnessParams;
%   open_system(model)

model = 'RadiatorTestHarness';
RadiatorTestHarnessParams;
open_system(model)

%% Run Simulation and Results
%
%   simout = sim(model, 'SrcWorkspace', 'current');

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

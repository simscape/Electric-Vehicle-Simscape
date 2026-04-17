%% Chiller Test Harness
% Standalone test environment for the Chiller component.

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
% *Harness:* <matlab:open_system('ChillerTestHarness') ChillerTestHarness.slx>
%
% *Parameters:* <matlab:edit('ChillerTestHarnessParams.m') ChillerTestHarnessParams.m>
%
% *Test Case:* <matlab:edit('ChillerPassTests.m') ChillerPassTests.m>
%
% *Fidelity:* Chiller

%% Setup
% Load parameters and open the test harness.
%
%   model = 'ChillerTestHarness';
%   ChillerTestHarnessParams;
%   open_system(model)

model = 'ChillerTestHarness';
ChillerTestHarnessParams;
open_system(model)

%% Run Simulation and Results
%
%   simout = sim(model, 'SrcWorkspace', 'current');

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

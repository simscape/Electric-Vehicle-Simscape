%% Charger Test Harness
% Standalone test environment for the Charger component.

%% Overview
% The ChargerTestHarness provides a standalone simulation environment for
% validating the onboard charger. The harness supplies relay commands,
% battery cell voltage feedback, charging state signals, and coolant
% boundary conditions to exercise the charger through a full CC-CV
% charging cycle.
%
% The default fidelity in the harness is *ChargerThermal*, which includes
% thermal dynamics for the power converter. The converter coolant jacket
% is coupled to the thermal-liquid loop so heat rejection can be observed
% during extended charging events. Parameters are initialized by
% |ChargerTestHarnessParams.m|, which loads |ChargerThermalParams.m|.
%
% *Harness:* <matlab:open_system('ChargerTestHarness') ChargerTestHarness.slx>
%
% *Parameters:* <matlab:edit('ChargerTestHarnessParams.m') ChargerTestHarnessParams.m>
%
% *Test Case:* <matlab:edit('ChargerPassTests.m') ChargerPassTests.m>
%
% *Fidelity:* ChargerThermal

%% Setup
% Load parameters and open the test harness.

model = 'ChargerTestHarness';
ChargerTestHarnessParams;
load_system(model)

%% Run Simulation and Results

simout = sim(model, 'SrcWorkspace', 'current');
plotChargerHarnessResults(simout.logsout)

%% Running Unit Tests
% Run the MQC test suite from the command line:
%
%   results = runtests('ChargerPassTests');
%   disp(results)

%% See Also
% * <ChargerDescription.html Charger>
% * <ChargerThermalDescription.html ChargerThermal>

% Copyright 2022 - 2025 The MathWorks, Inc.

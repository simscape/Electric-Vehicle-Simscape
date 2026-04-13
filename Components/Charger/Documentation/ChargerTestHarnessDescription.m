%% Charger Test Harness
% Standalone test environment for the Charger component.
%
% *Harness:* |ChargerTestHarness.slx|
%
% *Test Case:* |ChargerPassTests.m|
%
% *Fidelity:* ChargerThermal

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
% The harness scope captures:
%
% * *Charging Current* - Current delivered to the battery during CC-CV.
% * *Coolant Inlet Temperature* - Coolant temperature entering the charger.
% * *Coolant Outlet Temperature* - Coolant temperature leaving the charger.

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
% * <ChargerWithThermalDescription.html ChargerWithThermal>

% Copyright 2022 - 2025 The MathWorks, Inc.

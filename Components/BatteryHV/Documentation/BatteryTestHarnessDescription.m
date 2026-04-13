%% Battery Test Harness
% Standalone test environment for the BatteryHV component.
%
% *Harness:* |BatteryTestHarness.slx|
%
% *Test Case:* |BatteryHVPassTests.m|
%
% *Fidelity:* BatteryLumpedThermal

%% Overview
% The BatteryTestHarness provides a standalone simulation environment for
% validating the high-voltage battery pack. The harness drives the battery
% through charge and discharge cycles by supplying relay commands, a current
% load profile, and coolant boundary conditions.
%
% The default fidelity in the harness is *BatteryLumpedThermal*, which
% represents the pack as a lumped equivalent circuit with a single thermal
% mass node. The thermal node is coupled to the coolant loop through a
% thermal-liquid interface, allowing the harness to capture
% temperature-dependent electrical behavior and heat rejection to coolant.
%
% Parameters are initialized by |BatteryTestHarnessParams.m|, which loads
% cell electrical data, BMS limits, and coolant system settings from
% |BatteryLumpedThermalParams.m|, |BMSParams.m|, and |BEVThermalParams.m|.

%% Setup
% Load parameters and open the test harness.

model = 'BatteryTestHarness';
BatteryTestHarnessParams;
load_system(model)

%% Run Simulation

simout = sim(model, 'SrcWorkspace', 'current');
logsout = simout.logsout;

%% Simulation Results
% The following plots show all logged signals from the harness run.

for k = 1:logsout.numElements
    el = logsout.getElement(k);
    plotHarnessSignal(logsout, k, el.Name, '')
end

%% Running Unit Tests
% Run the MQC test suite from the command line:
%
%   results = runtests('BatteryHVPassTests');
%   disp(results)

%% See Also
% * <BatteryLumpedDescription.html BatteryLumped>
% * <BatteryLumpedThermalDescription.html BatteryLumpedThermal>
% * <BatteryTableBasedDescription.html BatteryTableBased>

% Copyright 2022 - 2025 The MathWorks, Inc.

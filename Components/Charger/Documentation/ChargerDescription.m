%% Charger
% Constant-current / constant-voltage (CC-CV) charging controller without
% thermal dynamics.

%% Overview
% The Charger block implements a CC-CV charging algorithm that generates a
% charging current command and applies it to the HV bus. The controller
% transitions from constant-current to constant-voltage mode based on
% battery cell voltage feedback. No thermal dynamics are modeled, making
% this fidelity suitable for fast electrical-only charging studies.
%
% *Model:* <matlab:open_system('Charger') Charger.slx>
%
% *Parameters:* <matlab:edit('ChargerParams.m') ChargerParams.m>
%
% *Thermal Coupling:* None

%% Open Model

open_system('Charger')

%% Ports
%
% <html>
% <h3>Input Bus &mdash; <code>s</code></h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Signal</th><th>Description</th></tr>
% <tr><td>Batt.Relay.RelayChg</td><td>Charge relay command</td></tr>
% <tr><td>Batt.BattSensor.CellVoltMax</td><td>Maximum cell voltage for CC-CV transition</td></tr>
% </table>
% <h3>Output Bus</h3>
% <p>No output bus. Operates via physical HV port only.</p>
% <h3>Physical Ports</h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Port</th><th>Domain</th><th>Description</th></tr>
% <tr><td>HV</td><td>Electrical</td><td>High-voltage bus connection</td></tr>
% </table>
% </html>

%% Workflows
% The Charger block is listed in the *VehicleElectric* and *VehicleElecAux*
% templates in |VehicleTemplateConfig.json|. It is suitable for electrical-only charging studies
% without thermal management.

%% Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Maximum voltage</td><td>4.2 V</td><td>Cell voltage limit for CV mode</td></tr>
% <tr><td>Constant current (CC)</td><td>50 A</td><td>Charging current during CC phase</td></tr>
% <tr><td>Controller Kp</td><td>1</td><td>Proportional gain for voltage regulation</td></tr>
% <tr><td>Controller Ki</td><td>1</td><td>Integral gain for voltage regulation</td></tr>
% </table>
% </html>
%
% See |ChargerParams.m| for a complete list of parameters.

%% See Also
% * <ChargerDummyDescription.html ChargerDummy>
% * <ChargerThermalDescription.html ChargerThermal>
% * <ChargerThermalDummyDescription.html ChargerThermalDummy>
% * <ChargerTestHarnessDescription.html Charger Test Harness>

% Copyright 2022 - 2026 The MathWorks, Inc.

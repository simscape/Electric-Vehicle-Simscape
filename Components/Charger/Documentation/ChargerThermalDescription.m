%% ChargerThermal
% CC-CV charger with a thermal representation of the power converter.

%% Overview
% The ChargerThermal block extends the CC-CV charger with a thermal model
% of the power converter. The controlled current source charges the battery
% through the HV bus while heat generated in the converter is dissipated
% through a coolant jacket. This fidelity enables thermal management
% studies during charging events.
%
% *Model:* <matlab:open_system('ChargerThermal') ChargerThermal.slx>
%
% *Parameters:* <matlab:edit('ChargerThermalParams.m') ChargerThermalParams.m>
%
% *Thermal Coupling:* Yes (converter thermal mass, coolant jacket)

%% Open Model

open_system('ChargerThermal')

%% Ports
%
% <html>
% <h3>Input Bus &mdash; <code>s</code></h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Signal</th><th>Description</th></tr>
% <tr><td>Batt.Relay.RelayChg</td><td>Charge relay command</td></tr>
% <tr><td>BattSensor.CellVoltMax</td><td>Maximum cell voltage for CC-CV transition</td></tr>
% </table>
% <h3>Output Bus</h3>
% <p>No output bus.</p>
% <h3>Physical Ports</h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Port</th><th>Domain</th><th>Description</th></tr>
% <tr><td>HV</td><td>Electrical</td><td>High-voltage bus connection</td></tr>
% <tr><td>A</td><td>Thermal liquid</td><td>Coolant port</td></tr>
% <tr><td>B</td><td>Thermal liquid</td><td>Coolant port</td></tr>
% </table>
% </html>

%% Workflows
% The ChargerThermal block is used in the *VehicleElectroThermal* template
% for full-thermal charging studies. It is validated through
% |ChargerTestHarness.slx|.

%% Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Maximum voltage</td><td>4.2 V</td><td>Cell voltage limit for CV mode</td></tr>
% <tr><td>Constant current (CC)</td><td>50 A</td><td>Charging current during CC phase</td></tr>
% <tr><td>Controller Kp</td><td>1</td><td>Proportional gain for voltage regulation</td></tr>
% <tr><td>Controller Ki</td><td>1</td><td>Integral gain for voltage regulation</td></tr>
% <tr><td>Coolant jacket channel diameter</td><td>0.0092 m</td><td>Diameter of coolant channels in the converter jacket</td></tr>
% <tr><td>Initial coolant temperature</td><td>298.15 K</td><td>Coolant temperature at simulation start</td></tr>
% </table>
% </html>
%
% See |ChargerThermalParams.m| for a complete list of parameters.

%% See Also
% * <ChargerDescription.html Charger>
% * <ChargerDummyDescription.html ChargerDummy>
% * <ChargerThermalDummyDescription.html ChargerThermalDummy>
% * <ChargerTestHarnessDescription.html Charger Test Harness>

% Copyright 2022 - 2026 The MathWorks, Inc.

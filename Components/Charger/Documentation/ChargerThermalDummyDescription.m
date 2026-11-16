%% ChargerThermalDummy
% Dummy variant of the thermal charger with coolant port pass-through.

%% Overview
% The ChargerThermalDummy block exposes the same thermal ports as
% ChargerThermal so the coolant loop remains closed, but requires no
% internal parameter data. It is used when real charger thermal data is not
% yet available or when the charger thermal behavior is not the focus of
% the study.
%
% *Model:* <matlab:open_system('ChargerThermalDummy') ChargerThermalDummy.slx>
%
% *Parameters:* <matlab:edit('ChargerThermalDummyParams.m') ChargerThermalDummyParams.m>
%
% *Thermal Coupling:* Yes (port-compatible pass-through)

%% Open Model

open_system('ChargerThermalDummy')

%% Ports
%
% <html>
% <h3>Input Bus &mdash; <code>s</code></h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Signal</th><th>Description</th></tr>
% <tr><td>Batt.Relay.RelayChg</td><td>Charge relay command</td></tr>
% <tr><td>Batt.BattSensor.CellVoltMax</td><td>Maximum cell voltage</td></tr>
% </table>
% <h3>Output Bus</h3>
% <p>No output bus.</p>
% <h3>Physical Ports</h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Port</th><th>Domain</th><th>Description</th></tr>
% <tr><td>HV</td><td>Electrical</td><td>High-voltage bus connection</td></tr>
% <tr><td>A</td><td>Thermal liquid</td><td>Coolant port (pass-through)</td></tr>
% <tr><td>B</td><td>Thermal liquid</td><td>Coolant port (pass-through)</td></tr>
% </table>
% </html>

%% Workflows
% The ChargerThermalDummy block is a placeholder for thermal-loop
% integration testing when real charger thermal parameters are unavailable.

%% See Also
% * <ChargerDescription.html Charger>
% * <ChargerDummyDescription.html ChargerDummy>
% * <ChargerThermalDescription.html ChargerThermal>
% * <ChargerTestHarnessDescription.html Charger Test Harness>

% Copyright 2022 - 2026 The MathWorks, Inc.

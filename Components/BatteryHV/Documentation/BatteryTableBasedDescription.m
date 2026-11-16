%% BatteryTableBased
% High-fidelity table-based battery model with full thermal coupling.

%% Overview
% The BatteryTableBased block provides the highest-fidelity battery
% representation. Electrical characteristics come from lookup tables
% mapping SOC and temperature to open-circuit voltage and internal
% resistance. The block includes a thermal port for coupling with the
% coolant loop and battery heater. Positive and negative relays manage
% HV bus connectivity.
%
% *Model:* <matlab:open_system('BatteryTableBased') BatteryTableBased.slx>
%
% *Parameters:* <matlab:edit('BatteryTableBasedParams.m') BatteryTableBasedParams.m>
%
% *Thermal Coupling:* Yes (lookup-table-driven, coolant port)

%% Open Model

open_system('BatteryTableBased')

%% Ports
%
% <html>
% <h3>Input Bus &mdash; <code>s</code></h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Signal</th><th>Description</th></tr>
% <tr><td>RelayPos</td><td>Positive relay command</td></tr>
% <tr><td>RelayNeg</td><td>Negative relay command</td></tr>
% </table>
% <h3>Output Bus &mdash; <code>m</code></h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Signal</th><th>Description</th></tr>
% <tr><td>BattSens.SoC</td><td>State of charge</td></tr>
% <tr><td>BattSens.Current</td><td>Pack current</td></tr>
% <tr><td>BattSens.Cellvolt</td><td>Cell voltage</td></tr>
% <tr><td>BattSens.ParVolt</td><td>Parallel string voltage</td></tr>
% <tr><td>BattSens.temp</td><td>Pack temperature</td></tr>
% <tr><td>CoolTp</td><td>Coolant temperature</td></tr>
% </table>
% <h3>Physical Ports</h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Port</th><th>Domain</th><th>Description</th></tr>
% <tr><td>HV</td><td>Electrical</td><td>High-voltage bus connection</td></tr>
% <tr><td>A</td><td>Thermal liquid</td><td>Coolant port (inlet)</td></tr>
% <tr><td>B</td><td>Thermal liquid</td><td>Coolant port (outlet)</td></tr>
% </table>
% </html>

%% Workflows
% BatteryTableBased is the *default battery fidelity* in the assembled
% BEV system model (|BEVsystemModel.slx|). It is used in range estimation
% (NEDC, WLTC, EPA) and battery sizing workflows.

%% Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Cell capacity</td><td>34 Ah</td><td>Nominal capacity of a single cell</td></tr>
% <tr><td>Temperature vector</td><td>[278, 293, 313] K</td><td>Breakpoints for temperature-dependent lookup tables</td></tr>
% <tr><td>SOC vector</td><td>[0, 0.1, 0.25, 0.5, 0.75, 0.9, 1]</td><td>Breakpoints for SOC-dependent lookup tables</td></tr>
% <tr><td>Initial pack SOC</td><td>0.75</td><td>Pack state of charge at simulation start</td></tr>
% <tr><td>Coolant pipe diameter</td><td>0.019 m</td><td>Inner diameter of coolant piping to the battery jacket</td></tr>
% <tr><td>Initial coolant temperature</td><td>298.15 K</td><td>Coolant temperature at simulation start</td></tr>
% </table>
% </html>
%
% See |BatteryTableBasedParams.m| for a complete list of parameters.

%% See Also
% * <BatteryLumpedDescription.html BatteryLumped>
% * <BatteryLumpedThermalDescription.html BatteryLumpedThermal>
% * <BatteryTestHarnessDescription.html Battery Test Harness>

% Copyright 2022 - 2026 The MathWorks, Inc.

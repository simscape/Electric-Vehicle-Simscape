%% PumpDummyTh
% Minimal pump stub with fixed electrical load.

%% Overview
% The PumpDummyTh block is a minimal stub that maintains the same port
% interface as the full Pump model. It draws a fixed electrical current
% from the LV bus proportional to the pump command signal and zero current
% when the command is zero. Coolant ports A and B are connected through
% a simple pipe so the coolant loop stays closed, but no active pumping
% occurs.
%
% This fidelity is used when the pump subsystem is not the focus of
% the study but the system model needs a connected pump block to
% simulate without errors.
%
% *Model:* <matlab:open_system('PumpDummyTh') PumpDummyTh.slx>
%
% *Parameters:* <matlab:edit('PumpDummyThParams.m') PumpDummyThParams.m>
%
% *Thermal Coupling:* No (coolant pass-through, no active pumping)

%% Open Model

open_system('PumpDummyTh')

%% Ports
%
% <html>
% <h3>Input Bus &mdash; <code>s</code></h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Signal</th><th>Description</th></tr>
% <tr><td>BatSt</td><td>Battery status (terminated internally)</td></tr>
% <tr><td>cmdPump</td><td>Pump speed command</td></tr>
% </table>
% <h3>Output Bus &mdash; <code>m</code></h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Signal</th><th>Description</th></tr>
% <tr><td>PumpCurr</td><td>Pump current draw</td></tr>
% <tr><td>LowVolt</td><td>Low-voltage bus measurement</td></tr>
% <tr><td>energy</td><td>Cumulative energy consumed</td></tr>
% </table>
% <h3>Physical Ports</h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Port</th><th>Domain</th><th>Description</th></tr>
% <tr><td>LV</td><td>Electrical</td><td>Low-voltage bus connection</td></tr>
% <tr><td>A</td><td>Thermal liquid</td><td>Coolant port (pass-through)</td></tr>
% <tr><td>B</td><td>Thermal liquid</td><td>Coolant port (pass-through)</td></tr>
% </table>
% </html>

%% Workflows
% The PumpDummyTh block is a placeholder variant for integration testing
% or fast simulations. It can replace the full Pump in the
% *VehicleElectroThermal* template without breaking the coolant loop.
% Parameters are set via the model mask, with defaults from |PumpDummyThParams.m|.

%% Mask Parameters
% The model exposes the following mask parameters. Defaults are read from
% the |pump| struct defined in |PumpDummyThParams.m|.
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Mask Variable</th><th>Default Source</th><th>Unit</th><th>Description</th></tr>
% <tr><td><tt>pumpMaxCurrent</tt></td><td><tt>pump.pumpMaxCurrent</tt></td><td>A</td><td>Fixed current draw at full command</td></tr>
% </table>
% </html>

%% See Also
% * <PumpDescription.html Pump>
% * <PumpDummyDescription.html PumpDummy>
% * <PumpTestHarnessDescription.html Pump Test Harness>

% Copyright 2022 - 2026 The MathWorks, Inc.

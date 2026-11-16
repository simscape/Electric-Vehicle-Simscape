%% PumpDummy
% Minimal pump stub with fixed electrical load (no coolant ports).

%% Overview
% The PumpDummy block is a minimal stub that draws a fixed electrical
% current from the LV bus proportional to the pump command signal and zero
% current when the command is zero. Unlike PumpDummyTh, this variant has
% no thermal-liquid ports — it is purely an electrical placeholder.
%
% This fidelity is used when the pump subsystem is not the focus of
% the study and no coolant loop is present in the vehicle template.
%
% *Model:* <matlab:open_system('PumpDummy') PumpDummy.slx>
%
% *Parameters:* <matlab:edit('PumpDummyParams.m') PumpDummyParams.m>
%
% *Thermal Coupling:* No (no coolant ports)

%% Open Model

open_system('PumpDummy')

%% Ports
%
% <html>
% <h3>Input Bus</h3>
% <p>No input bus (no inports).</p>
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
% </table>
% </html>

%% Workflows
% The PumpDummy block is a placeholder variant in the *VehicleElecAux*
% template for auxiliary configurations without a coolant loop. Parameters
% are set via the model mask, with defaults from |PumpDummyParams.m|.

%% Mask Parameters
% The model exposes the following mask parameters. Defaults are read from
% the |pump| struct defined in |PumpDummyParams.m|.
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Mask Variable</th><th>Default Source</th><th>Unit</th><th>Description</th></tr>
% <tr><td><tt>pumpMaxCurrent</tt></td><td><tt>pump.pumpMaxCurrent</tt></td><td>A</td><td>Fixed current draw at full command</td></tr>
% </table>
% </html>

%% See Also
% * <PumpDescription.html Pump>
% * <PumpDummyThDescription.html PumpDummyTh>
% * <PumpTestHarnessDescription.html Pump Test Harness>

% Copyright 2022 - 2026 The MathWorks, Inc.

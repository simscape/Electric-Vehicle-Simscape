%% ChillerDummy
% Minimal chiller stub with fixed electrical load.

%% Overview
% The ChillerDummy block is a minimal stub that maintains the same port
% interface as the full Chiller model. It draws a fixed electrical current
% from the HV bus when the chiller is active (|cmdChillerByp = 0|) and
% zero current when bypassed. Coolant ports A and B are connected through
% a simple pipe so the coolant loop stays closed, but no heat is exchanged.
%
% This fidelity is used when the chiller subsystem is not the focus of
% the study but the system model needs a connected chiller block to
% simulate without errors.
%
% *Model:* <matlab:open_system('ChillerDummy') ChillerDummy.slx>
%
% *Parameters:* <matlab:edit('ChillerDummyParams.m') ChillerDummyParams.m>
%
% *Thermal Coupling:* No (coolant pass-through, no heat exchange)

%% Open Model

open_system('ChillerDummy')

%% Ports
%
% <html>
% <h3>Input Bus &mdash; <code>s</code></h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Signal</th><th>Description</th></tr>
% <tr><td>cmdChillerByp</td><td>Chiller bypass command (0 = active, 1 = bypass)</td></tr>
% <tr><td>Batt.BatSt</td><td>Battery status signal</td></tr>
% </table>
% <h3>Output Bus &mdash; <code>m</code></h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Signal</th><th>Description</th></tr>
% <tr><td>ChillerCurrent</td><td>Fixed current when active, zero when bypassed</td></tr>
% <tr><td>energy</td><td>Cumulative energy consumed</td></tr>
% </table>
% <h3>Physical Ports</h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Port</th><th>Domain</th><th>Description</th></tr>
% <tr><td>HV</td><td>Electrical</td><td>High-voltage bus connection</td></tr>
% <tr><td>A</td><td>Thermal liquid</td><td>Coolant port (pass-through)</td></tr>
% <tr><td>B</td><td>Thermal liquid</td><td>Coolant port (pass-through)</td></tr>
% </table>
% </html>

%% Workflows
% The ChillerDummy block is a placeholder variant for integration testing
% or fast simulations. It can replace the full Chiller in the
% *VehicleElectroThermal* template without breaking the coolant loop.
% Parameters are loaded by |ChillerDummyParams.m|.

%% Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Maximum chiller power</td><td>6000 W</td><td>Fixed electrical power draw when active</td></tr>
% <tr><td>Coolant pipe diameter</td><td>0.019 m</td><td>Inner diameter of coolant piping (pass-through)</td></tr>
% <tr><td>Initial coolant temperature</td><td>298.15 K</td><td>Coolant temperature at simulation start</td></tr>
% <tr><td>Initial coolant pressure</td><td>0.101325 MPa</td><td>Coolant pressure at simulation start</td></tr>
% </table>
% </html>
%
% See |ChillerDummyParams.m| for a complete list of parameters.

%% See Also
% * <ChillerDescription.html Chiller>
% * <ChillerNoCoolantDescription.html ChillerNoCoolant>
% * <ChillerTestHarnessDescription.html Chiller Test Harness>

% Copyright 2022 - 2026 The MathWorks, Inc.

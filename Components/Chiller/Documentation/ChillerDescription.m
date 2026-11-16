%% Chiller
% Battery coolant chiller with HV bus power draw and coolant loop coupling.

%% Overview
% The Chiller block models the battery coolant chiller as a controlled
% current source drawing power from the HV bus. A thermal mass block
% captures heat absorption and storage, and the chiller volume is coupled
% to the coolant loop for active heat exchange. Energy drawn from the HV
% bus is tracked for efficiency and range studies.
%
% During hot-ambient simulations (e.g., 35 degC) the chiller actively
% cools the battery pack by removing heat from the coolant loop, keeping
% cell temperatures within safe operating limits.
%
% *Model:* <matlab:open_system('Chiller') Chiller.slx>
%
% *Parameters:* <matlab:edit('ChillerParams.m') ChillerParams.m>
%
% *Thermal Coupling:* Yes (thermal mass, coolant loop)

%% Open Model

open_system('Chiller')

%% Ports
%
% <html>
% <h3>Input Bus &mdash; <code>s</code></h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Signal</th><th>Description</th></tr>
% <tr><td>cmdChillerByp</td><td>Chiller bypass command (0 = active, 1 = bypass)</td></tr>
% <tr><td>BatSt</td><td>Battery status signal</td></tr>
% </table>
% <h3>Output Bus &mdash; <code>m</code></h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Signal</th><th>Description</th></tr>
% <tr><td>ChillerCurrent</td><td>Current drawn from the HV bus</td></tr>
% <tr><td>energy</td><td>Cumulative energy consumed</td></tr>
% </table>
% <h3>Physical Ports</h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Port</th><th>Domain</th><th>Description</th></tr>
% <tr><td>HV</td><td>Electrical</td><td>High-voltage bus connection</td></tr>
% <tr><td>A</td><td>Thermal liquid</td><td>Coolant port</td></tr>
% <tr><td>B</td><td>Thermal liquid</td><td>Coolant port</td></tr>
% </table>
% </html>

%% Workflows
% The Chiller block is part of the *VehicleElectroThermal* template for
% full-thermal vehicle simulations. It is active during hot-ambient range
% estimation runs. The model is validated through |ChillerTestHarness.slx|.

%% Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Maximum chiller power</td><td>6000 W</td><td>Peak electrical power draw from the HV bus</td></tr>
% <tr><td>Coolant pipe diameter</td><td>0.019 m</td><td>Inner diameter of coolant piping</td></tr>
% <tr><td>Initial coolant temperature</td><td>298.15 K</td><td>Coolant temperature at simulation start</td></tr>
% <tr><td>Initial coolant pressure</td><td>0.101325 MPa</td><td>Coolant pressure at simulation start</td></tr>
% </table>
% </html>
%
% See |ChillerParams.m| for a complete list of parameters.

%% See Also
% * <ChillerNoCoolantDescription.html ChillerNoCoolant>
% * <ChillerDummyDescription.html ChillerDummy>
% * <ChillerTestHarnessDescription.html Chiller Test Harness>

% Copyright 2022 - 2026 The MathWorks, Inc.

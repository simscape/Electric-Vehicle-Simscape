%% ChillerNoCoolant
% Simplified chiller model without coolant loop coupling.

%% Overview
% The ChillerNoCoolant block represents the chiller electrical load on the
% HV bus without thermal-liquid ports. The power draw is modeled but there
% is no coolant loop interaction. This fidelity is used when the vehicle
% model does not include a coolant loop but the chiller power consumption
% still needs to be accounted for in range and efficiency calculations.
%
% *Model:* <matlab:open_system('ChillerNoCoolant') ChillerNoCoolant.slx>
%
% *Parameters:* <matlab:edit('ChillerNoCoolantParams.m') ChillerNoCoolantParams.m>
%
% *Thermal Coupling:* None

%% Open Model

open_system('ChillerNoCoolant')

%% Ports
%
% <html>
% <h3>Input Bus &mdash; <code>s</code></h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Signal</th><th>Description</th></tr>
% <tr><td>cmdChillerByp</td><td>Chiller bypass command</td></tr>
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
% </table>
% </html>

%% Workflows
% The ChillerNoCoolant block is a simplified variant used as a standalone
% auxiliary load model where the coolant loop is not modeled, suitable for
% fast electrical-only simulations where auxiliary power consumption matters.

%% See Also
% * <ChillerDescription.html Chiller>
% * <ChillerDummyDescription.html ChillerDummy>
% * <ChillerTestHarnessDescription.html Chiller Test Harness>

% Copyright 2022 - 2026 The MathWorks, Inc.

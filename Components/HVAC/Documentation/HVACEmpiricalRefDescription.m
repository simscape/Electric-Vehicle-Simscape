%% HVACEmpiricalRef
% Empirical-based HVAC model with cabin and refrigeration subsystems using
% lookup tables.

%% Overview
% The HVACEmpiricalRef block models the HVAC system using empirical
% performance curves rather than physical refrigerant dynamics. Cabin
% blower, PTC heater, and compressor are driven by control commands, and
% their performance is captured through lookup tables. A controlled current
% source represents the HVAC electrical power draw from the HV bus, and an
% energy monitoring block tracks total HVAC consumption.
%
% *Model:* <matlab:open_system('HVACEmpiricalRef') HVACEmpiricalRef.slx>
%
% *Parameters:* <matlab:edit('HVACEmpiricalRefParams.m') HVACEmpiricalRefParams.m>
%
% *Thermal Coupling:* No (empirical performance curves, no physical fluid dynamics)

%% Open Model

open_system('HVACEmpiricalRef')

%% Ports
%
% <html>
% <h3>Input Bus &mdash; <code>s</code></h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Signal</th><th>Description</th></tr>
% <tr><td>Env.Tenv</td><td>Environment temperature</td></tr>
% <tr><td>Env</td><td>Environment bus (full struct)</td></tr>
% <tr><td>Batt.BatSt</td><td>Battery status</td></tr>
% <tr><td>Batt</td><td>Battery bus (voltage)</td></tr>
% <tr><td>Cntrl.CmdBlower</td><td>Blower speed command</td></tr>
% <tr><td>Cntrl.CmdPTC</td><td>PTC heater command</td></tr>
% <tr><td>Cntrl.acOnOff</td><td>AC on/off command</td></tr>
% </table>
% <h3>Output Bus &mdash; <code>m</code></h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Signal</th><th>Description</th></tr>
% <tr><td>energy</td><td>Cumulative HVAC energy consumption</td></tr>
% <tr><td>Tcabin</td><td>Cabin air temperature</td></tr>
% <tr><td>TacVent</td><td>AC vent temperature</td></tr>
% <tr><td>Tptc</td><td>PTC heater temperature</td></tr>
% </table>
% <h3>Physical Ports</h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Port</th><th>Domain</th><th>Description</th></tr>
% <tr><td>HV</td><td>Electrical</td><td>High-voltage bus connection</td></tr>
% </table>
% </html>

%% Workflows
% The HVACEmpiricalRef block is listed in the *VehicleElecAux* and
% *VehicleElectroThermal* templates in |VehicleTemplateConfig.json|. It is
% suitable for cabin comfort studies and HVAC energy-demand evaluation
% without modeling the refrigerant loop. It is the default fidelity in the HVAC test harness.

%% Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Cabin initial temperature</td><td>298.15 K</td><td>Cabin air temperature at simulation start</td></tr>
% <tr><td>Cabin initial pressure</td><td>0.101325 MPa</td><td>Cabin air pressure at simulation start</td></tr>
% <tr><td>Cabin setpoint temperature</td><td>293.15 K</td><td>Target cabin temperature for HVAC control</td></tr>
% <tr><td>Number of passengers</td><td>1</td><td>Passenger count for metabolic heat load</td></tr>
% <tr><td>Per-person heat transfer</td><td>70 W</td><td>Metabolic heat per passenger</td></tr>
% </table>
% </html>
%
% See |HVACEmpiricalRefParams.m| for a complete list of parameters.

%% See Also
% * <HVACSimpleThDescription.html HVACsimpleTh>
% * <HVACTestHarnessDescription.html HVAC Test Harness>

% Copyright 2022 - 2026 The MathWorks, Inc.

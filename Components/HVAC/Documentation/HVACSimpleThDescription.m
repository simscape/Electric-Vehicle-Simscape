%% HVACsimpleTh
% HVAC model with a cabin thermal plant including blower, cooler, and PTC
% heater interactions.

%% Overview
% The HVACsimpleTh block models the HVAC system with a cabin thermal
% plant. The cabin air volume is linked with cabin heat transfer and the
% external environment. A blower, cooler, and PTC heater interact with the
% cabin air mass to regulate temperature. A controlled current source
% models the HVAC electrical load, and an HVAC demand block computes the
% required cooling or heating power. Energy monitoring tracks HVAC
% consumption from the HV bus.
%
% *Model:* <matlab:open_system('HVACsimpleTh') HVACsimpleTh.slx>
%
% *Parameters:* <matlab:edit('HVACsimpleThParams.m') HVACsimpleThParams.m>
%
% *Thermal Coupling:* Yes (cabin thermal plant)

%% Open Model

open_system('HVACsimpleTh')

%% Ports
%
% <html>
% <h3>Input Bus &mdash; <code>s</code></h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Signal</th><th>Description</th></tr>
% <tr><td>Env.Tenv</td><td>Environment temperature</td></tr>
% <tr><td>Batt.BatSt</td><td>Battery status</td></tr>
% <tr><td>Batt</td><td>Battery bus (voltage)</td></tr>
% <tr><td>Cntrl.CmdBlower</td><td>Blower speed command</td></tr>
% <tr><td>Cntrl.CmdPTC</td><td>PTC heater command</td></tr>
% <tr><td>Cntrl.CmdCool</td><td>Cooler/compressor command</td></tr>
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
% HVACsimpleTh is the *default HVAC fidelity* for the
% *VehicleElectroThermal* template. It is used in range estimation
% workflows for hot and cold ambient scenarios. The model is validated
% through |HVACTestHarness.slx|.

%% Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Cabin initial temperature</td><td>298.15 K</td><td>Cabin air temperature at simulation start</td></tr>
% <tr><td>Cabin initial pressure</td><td>0.101325 MPa</td><td>Cabin air pressure at simulation start</td></tr>
% <tr><td>Cabin initial relative humidity</td><td>0.4</td><td>Relative humidity of cabin air at start</td></tr>
% <tr><td>Cabin setpoint temperature</td><td>293.15 K</td><td>Target cabin temperature for HVAC control</td></tr>
% <tr><td>Cabin duct area</td><td>0.04 m^2</td><td>Cross-section area of HVAC duct to cabin</td></tr>
% <tr><td>Number of passengers</td><td>1</td><td>Passenger count for metabolic heat load</td></tr>
% <tr><td>Per-person heat transfer</td><td>70 W</td><td>Metabolic heat per passenger</td></tr>
% </table>
% </html>
%
% See |HVACsimpleThParams.m| for a complete list of parameters.

%% See Also
% * <HVACEmpiricalRefDescription.html HVACEmpiricalRef>
% * <HVACTestHarnessDescription.html HVAC Test Harness>

% Copyright 2022 - 2026 The MathWorks, Inc.

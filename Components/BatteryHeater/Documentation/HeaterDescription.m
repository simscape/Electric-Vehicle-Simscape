%% Heater
% Battery pack heater model with HV bus power draw and coolant loop
% coupling.

%% Overview
% The Heater block models the battery pack heater as a controlled current
% source drawing power from the HV bus. A thermal mass block captures heat
% storage and transfer, and the heater volume is coupled to the coolant
% loop for heat exchange with the battery pack. Energy consumption is
% tracked for range and efficiency studies.
%
% During cold-ambient simulations (e.g., -20 degC) the heater is activated
% to keep battery temperature within operating limits, preventing capacity
% loss and protecting the cells from low-temperature charging damage.
%
% *Model:* <matlab:open_system('Heater') Heater.slx>
%
% *Parameters:* <matlab:edit('HeaterParams.m') HeaterParams.m>
%
% *Thermal Coupling:* Yes (thermal mass, coolant jacket)

%% Open Model

open_system('Heater')

%% Ports
%
% <html>
% <h3>Input Bus &mdash; <code>s</code></h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Signal</th><th>Description</th></tr>
% <tr><td>BatSt</td><td>Battery status (temperature, SOC)</td></tr>
% <tr><td>cmdHeater</td><td>Heater on/off command from thermal controller</td></tr>
% </table>
% <h3>Output Bus &mdash; <code>m</code></h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Signal</th><th>Description</th></tr>
% <tr><td>HeaterCurrent</td><td>Current drawn from the HV bus</td></tr>
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
% The Heater block is part of the *VehicleElectroThermal* template used in
% range estimation and battery sizing workflows. The heater is active
% primarily in cold-ambient drive-cycle simulations where battery warm-up
% is required.

%% Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Maximum heater power</td><td>4000 W</td><td>Peak electrical power draw from the HV bus</td></tr>
% <tr><td>Coolant pipe diameter</td><td>0.019 m</td><td>Inner diameter of coolant piping</td></tr>
% <tr><td>Coolant jacket channel diameter</td><td>0.0092 m</td><td>Diameter of coolant channels in the heater jacket</td></tr>
% <tr><td>Initial coolant temperature</td><td>298.15 K</td><td>Coolant temperature at simulation start</td></tr>
% <tr><td>Initial coolant pressure</td><td>0.101325 MPa</td><td>Coolant pressure at simulation start</td></tr>
% </table>
% </html>
%
% See |HeaterParams.m| for a complete list of parameters.

%% See Also
% * <HeaterDummyDescription.html HeaterDummy>
% * <HeaterTestHarnessDescription.html Heater Test Harness>

% Copyright 2022 - 2026 The MathWorks, Inc.

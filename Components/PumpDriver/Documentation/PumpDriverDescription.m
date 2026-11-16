%% PumpDriver
% DC-DC pump driver without thermal coupling.

%% Overview
% The PumpDriver is a simplified DC-DC converter model that translates
% thermal management status signals and pump enable commands into shaft
% speed setpoints for the coolant circulation pump. This variant has no
% coolant ports or thermal coupling - it provides only the electrical
% conversion and control logic.
%
% *Model:* <matlab:open_system('PumpDriver') PumpDriver.slx>
%
% *Parameters:* <matlab:edit('PumpDriverParams.m') PumpDriverParams.m>
%
% *Thermal Coupling:* No

%% Open Model

open_system('PumpDriver')

%% Ports
%
% <html>
% <h3>Input / Output Bus</h3>
% <p>No Simulink signal bus interface. Operates entirely through physical connections.</p>
% <h3>Physical Ports</h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Port</th><th>Domain</th><th>Description</th></tr>
% <tr><td>HV</td><td>Electrical</td><td>High-voltage bus input</td></tr>
% <tr><td>LV</td><td>Electrical</td><td>Low-voltage bus output</td></tr>
% </table>
% </html>

%% Workflows
% The PumpDriver is the non-thermal DCDC variant used in the
% *VehicleElecAux* template. It pairs with PumpDummy to provide pump
% control without coolant loop modelling.

%% Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Output voltage</td><td>24 V</td><td>DC-DC converter output voltage</td></tr>
% <tr><td>Output power</td><td>2400 W</td><td>DC-DC converter output power</td></tr>
% </table>
% </html>
%
% See |PumpDriverParams.m| for a complete list.

%% See Also
% * <PumpDriverThDescription.html PumpDriverTh (thermal)>
% * <PumpDriverTestHarnessDescription.html PumpDriver Test Harness>

% Copyright 2022 - 2026 The MathWorks, Inc.

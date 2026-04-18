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
% *Inputs*
%
% * *Thermal status* - System temperatures and thermal controller commands.
% * *Pump enable* - Enable signal from the thermal management controller.
%
% *Outputs*
%
% * *Pump speed command* - Shaft speed setpoint for the Pump.

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

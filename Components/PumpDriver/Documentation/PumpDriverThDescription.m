%% PumpDriverTh
% DC-DC pump driver with thermal coupling for the BEV coolant system.

%% Overview
% The PumpDriverTh translates thermal management status signals and pump
% enable commands into shaft speed setpoints for the coolant circulation
% pump. It determines the required coolant flow rate based on the thermal
% state of the system (battery temperature, motor temperature, etc.) and
% drives the Pump component accordingly. Includes thermal coupling for
% coolant interaction.
%
% *Model:* <matlab:open_system('PumpDriverTh') PumpDriverTh.slx>
%
% *Parameters:* <matlab:edit('PumpDriverThParams.m') PumpDriverThParams.m>
%
% *Thermal Coupling:* Yes (coolant system interface)

%% Open Model

open_system('PumpDriverTh')

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
% The PumpDriverTh is part of the coolant loop in the
% *VehicleElectroThermal* template. It pairs with the Pump component to
% form the coolant circulation subsystem. Parameters include coolant pipe
% and jacket dimensions shared with other thermal components.

%% Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Output voltage</td><td>24 V</td><td>DC-DC converter output voltage</td></tr>
% <tr><td>Output power</td><td>2400 W</td><td>DC-DC converter output power</td></tr>
% <tr><td>Coolant pipe diameter</td><td>0.019 m</td><td>Diameter of coolant piping</td></tr>
% <tr><td>Coolant jacket channel diameter</td><td>0.0092 m</td><td>Diameter of coolant jacket channels</td></tr>
% </table>
% </html>
%
% See |PumpDriverThParams.m| for a complete list.

%% See Also
% * <PumpDriverDescription.html PumpDriver (non-thermal)>
% * <PumpDriverTestHarnessDescription.html PumpDriverTh Test Harness>

% Copyright 2022 - 2026 The MathWorks, Inc.

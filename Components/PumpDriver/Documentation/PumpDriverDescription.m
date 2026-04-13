%% PumpDriver
% Pump driver controller for the BEV thermal management system.
%
% *Model:* |PumpDriver.slx|
%
% *Parameters:* |PumpDriverParams.m|
%
% *Thermal Coupling:* Yes (coolant system interface)

%% Overview
% The PumpDriver translates thermal management status signals and pump
% enable commands into shaft speed setpoints for the coolant circulation
% pump. It determines the required coolant flow rate based on the thermal
% state of the system (battery temperature, motor temperature, etc.) and
% drives the Pump component accordingly.

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
% The PumpDriver is part of the coolant loop in the
% *VehicleElectroThermal* template. It pairs with the Pump component to
% form the coolant circulation subsystem. Parameters include coolant pipe
% and jacket dimensions shared with other thermal components.

%% Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Coolant pipe diameter</td><td>0.019 m</td><td>Diameter of coolant piping</td></tr>
% <tr><td>Coolant jacket channel diameter</td><td>0.0092 m</td><td>Diameter of coolant jacket channels</td></tr>
% <tr><td>Initial coolant temperature</td><td>298.15 K</td><td>Coolant temperature at simulation start</td></tr>
% <tr><td>Initial coolant pressure</td><td>0.101325 MPa</td><td>Coolant pressure at simulation start</td></tr>
% </table>
% </html>
%
% See |PumpDriverParams.m| for a complete list.

%% See Also
% * <PumpDriverTestHarnessDescription.html PumpDriver Test Harness>

% Copyright 2022 - 2025 The MathWorks, Inc.

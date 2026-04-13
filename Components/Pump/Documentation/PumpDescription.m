%% Pump
% Coolant circulation pump for the BEV thermal management system.
%
% *Model:* |Pump.slx|
%
% *Parameters:* |PumpParams.m|
%
% *Thermal Coupling:* N/A (supporting thermal infrastructure component)

%% Overview
% The Pump block is a volumetric displacement pump that circulates coolant
% through the BEV thermal management loop. The pump speed is controlled by
% the thermal management controller (via the PumpDriver) and determines the
% coolant flow rate through the battery, motor drive, charger, chiller,
% heater, and radiator subsystems.

open_system('Pump')

%% Ports
% *Inputs*
%
% * *Pump speed command* - Shaft speed from the PumpDriver.
% * *Coolant inlet port* - Thermal-liquid inlet from the coolant loop.
%
% *Outputs*
%
% * *Coolant outlet port* - Pressurized coolant flow to downstream components.
% * *Pump power* - Mechanical power consumed.

%% Workflows
% The Pump block is part of the coolant loop in the *VehicleElectroThermal*
% template. It works in conjunction with the PumpDriver component, which
% translates thermal controller commands into pump speed. Parameters are
% loaded by |BEVThermalParams.m|.

%% Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Pump displacement</td><td>0.02 L/rev</td><td>Coolant pump volumetric displacement</td></tr>
% <tr><td>Max pump speed</td><td>1000 rpm</td><td>Maximum pump shaft speed</td></tr>
% <tr><td>Coolant pipe diameter</td><td>0.019 m</td><td>Diameter of coolant piping</td></tr>
% </table>
% </html>
%
% See |PumpParams.m| for a complete list.

%% See Also
% * <PumpTestHarnessDescription.html Pump Test Harness>

% Copyright 2022 - 2025 The MathWorks, Inc.

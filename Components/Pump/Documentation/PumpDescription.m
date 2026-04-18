%% Pump
% Coolant circulation pump for the BEV thermal management system.

%% Overview
% The Pump block is a volumetric displacement pump that circulates coolant
% through the BEV thermal management loop. The pump speed is controlled by
% the thermal management controller (via the PumpDriver) and determines the
% coolant flow rate through the battery, motor drive, charger, chiller,
% heater, and radiator subsystems.
%
% *Model:* <matlab:open_system('Pump') Pump.slx>
%
% *Parameters:* <matlab:edit('PumpParams.m') PumpParams.m>
%
% *Thermal Coupling:* N/A (supporting thermal infrastructure component)

%% Open Model

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
% set via the model mask, with defaults from |PumpParams.m|.

%% Mask Parameters
% The model exposes the following mask parameters. Defaults are read from
% the |pump| struct defined in |PumpParams.m|.
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Mask Variable</th><th>Default Source</th><th>Unit</th><th>Description</th></tr>
% <tr><td><tt>pump_displacement</tt></td><td><tt>pump.pump_displacement</tt></td><td>L/rev</td><td>Coolant pump volumetric displacement</td></tr>
% <tr><td><tt>pump_speed_max</tt></td><td><tt>pump.pump_speed_max</tt></td><td>rpm</td><td>Maximum pump shaft speed</td></tr>
% <tr><td><tt>coolant_pipe_D</tt></td><td><tt>pump.coolant_pipe_D</tt></td><td>m</td><td>Diameter of coolant piping</td></tr>
% </table>
% </html>

%% See Also
% * <PumpDummyDescription.html PumpDummy>
% * <PumpDummyThDescription.html PumpDummyTh>
% * <PumpTestHarnessDescription.html Pump Test Harness>

% Copyright 2022 - 2025 The MathWorks, Inc.

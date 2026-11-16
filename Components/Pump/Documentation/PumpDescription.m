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
%
% <html>
% <h3>Input Bus &mdash; <code>s</code></h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Signal</th><th>Description</th></tr>
% <tr><td>BatSt</td><td>Battery status signal</td></tr>
% <tr><td>cmdPump</td><td>Pump speed command</td></tr>
% </table>
% <h3>Output Bus &mdash; <code>m</code></h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Signal</th><th>Description</th></tr>
% <tr><td>PumpCurr</td><td>Pump current draw</td></tr>
% <tr><td>LowVolt</td><td>Low-voltage bus measurement</td></tr>
% <tr><td>energy</td><td>Cumulative energy consumed</td></tr>
% </table>
% <h3>Physical Ports</h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Port</th><th>Domain</th><th>Description</th></tr>
% <tr><td>LV</td><td>Electrical</td><td>Low-voltage bus connection</td></tr>
% <tr><td>A</td><td>Thermal liquid</td><td>Coolant port</td></tr>
% <tr><td>B</td><td>Thermal liquid</td><td>Coolant port</td></tr>
% </table>
% </html>

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

% Copyright 2022 - 2026 The MathWorks, Inc.

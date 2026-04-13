%% BatteryLumpedThermal
% Lumped battery model with a single thermal mass node and coolant loop
% coupling.

%% Overview
% The BatteryLumpedThermal block extends the lumped battery model with a
% single thermal mass node. The electrical behavior is temperature-dependent,
% and the block includes a coolant port for heat exchange with the vehicle
% thermal management loop. This fidelity balances simulation speed with
% basic thermal response.
%
% *Model:* |BatteryLumpedThermal.slx|
%
% *Parameters:* |BatteryLumpedThermalParams.m|
%
% *Thermal Coupling:* Yes (single thermal mass, coolant port)

%% Open Model

open_system('BatteryLumpedThermal')

%% Ports
% *Inputs*
%
% * *Positive relay command* - HV bus positive connection.
% * *Negative relay command* - HV bus negative connection.
% * *Coolant port* - Thermal-liquid interface for coolant loop heat exchange.
%
% *Outputs*
%
% * *Voltage* - Pack terminal voltage.
% * *Current* - Pack current.
% * *SOC* - State of charge.
% * *Temperature* - Lumped pack temperature.
% * *Cell Voltage* - Individual cell voltage estimate.

%% Workflows
% The BatteryLumpedThermal block is used in the *VehicleElectroThermal*
% template when a fast thermal approximation is sufficient. It is
% referenced in the battery test harness (|BatteryTestHarness.slx|) for
% component-level validation. Parameters are loaded by
% |BatteryTestHarnessParams.m| during test bench runs.

%% Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Cell capacity</td><td>34 Ah</td><td>Nominal capacity of a single cell</td></tr>
% <tr><td>Temperature vector</td><td>[278, 293, 313] K</td><td>Breakpoints for temperature-dependent lookup tables</td></tr>
% <tr><td>SOC vector</td><td>[0, 0.1, 0.25, 0.5, 0.75, 0.9, 1]</td><td>Breakpoints for SOC-dependent lookup tables</td></tr>
% <tr><td>Initial pack SOC</td><td>0.75</td><td>Pack state of charge at simulation start</td></tr>
% <tr><td>Coolant pipe diameter</td><td>0.019 m</td><td>Inner diameter of coolant piping to the battery jacket</td></tr>
% <tr><td>Initial coolant temperature</td><td>298.15 K</td><td>Coolant temperature at simulation start</td></tr>
% </table>
% </html>
%
% See |BatteryLumpedThermalParams.m| for a complete list of parameters.

%% See Also
% * <BatteryLumpedDescription.html BatteryLumped>
% * <BatteryTableBasedDescription.html BatteryTableBased>

% Copyright 2022 - 2025 The MathWorks, Inc.

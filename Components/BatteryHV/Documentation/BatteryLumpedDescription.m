%% BatteryLumped
% Simplified lumped-parameter battery model without thermal dynamics.

%% Overview
% The BatteryLumped block models the high-voltage battery pack using a
% lumped equivalent circuit with a constant or externally fixed temperature.
% Positive and negative relay commands control the HV bus connection. This
% is the simplest battery fidelity, designed for fast drive-cycle
% simulations where thermal effects are not required.
%
% *Model:* <matlab:open_system('BatteryLumped') BatteryLumped.slx>
%
% *Parameters:* <matlab:edit('BatteryLumpedParams.m') BatteryLumpedParams.m>
%
% *Thermal Coupling:* None

%% Open Model

open_system('BatteryLumped')

%% Ports
% *Inputs*
%
% * *Positive relay command* - Connects the battery positive terminal to the HV bus.
% * *Negative relay command* - Connects the battery negative terminal to the HV bus.
%
% *Outputs*
%
% * *Voltage* - Pack terminal voltage.
% * *Current* - Pack current.
% * *SOC* - State of charge.
% * *Temperature* - Fixed or externally supplied temperature.
% * *Cell Voltage* - Individual cell voltage estimate.

%% Workflows
% The BatteryLumped block is used in the *VehicleElectric* vehicle template
% for electrical-only simulations. It is suitable for controller development,
% quick range sweeps, and parameter studies that do not require thermal
% coupling. Select this fidelity in the BEV Setup App when thermal
% management is not under study.

%% Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Cell capacity</td><td>34 Ah</td><td>Nominal capacity of a single cell</td></tr>
% <tr><td>Temperature vector</td><td>[278, 293, 313] K</td><td>Breakpoints for temperature-dependent lookup tables</td></tr>
% <tr><td>SOC vector</td><td>[0, 0.1, 0.25, 0.5, 0.75, 0.9, 1]</td><td>Breakpoints for SOC-dependent lookup tables</td></tr>
% <tr><td>Initial pack SOC</td><td>0.75</td><td>Pack state of charge at simulation start</td></tr>
% </table>
% </html>
%
% See |BatteryLumpedParams.m| for a complete list of parameters.

%% See Also
% * <BatteryLumpedThermalDescription.html BatteryLumpedThermal>
% * <BatteryTableBasedDescription.html BatteryTableBased>
% * <BatteryTestHarnessDescription.html Battery Test Harness>

% Copyright 2022 - 2025 The MathWorks, Inc.

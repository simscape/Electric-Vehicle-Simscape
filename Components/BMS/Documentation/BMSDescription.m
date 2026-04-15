%% BMS
% Battery management system with voltage, current, and thermal fault
% monitoring for the BEV high-voltage battery.

%% Overview
% The BMS monitors cell voltages, currents, and temperatures against
% configurable safety limits. It issues positive and negative relay
% commands, provides SOC estimation, and raises fault flags when operating
% limits are exceeded. Thermal monitoring includes coolant switch-on/off
% temperature thresholds for thermal management coordination.
%
% *Model:* <matlab:open_system('BMS') BMS.slx>
%
% *Parameters:* <matlab:edit('BMSParams.m') BMSParams.m>
%
% *Thermal Coupling:* Yes (temperature monitoring and thermal fault limits)

%% Open Model

open_system('BMS')

%% Ports
% *Inputs*
%
% * *Cell voltage* - Measured cell terminal voltage.
% * *Pack current* - Measured pack current.
% * *Cell temperature* - Measured cell temperature.
% * *Charge command* - Requested charge/discharge mode.
%
% *Outputs*
%
% * *Positive relay command* - Connects battery positive terminal.
% * *Negative relay command* - Connects battery negative terminal.
% * *SOC estimate* - Estimated state of charge.
% * *Fault flags* - Over-voltage, under-voltage, over-current, over-temperature.
% * *Coolant command* - Thermal management enable based on temperature thresholds.

%% Workflows
% The BMS is the core protection and monitoring subsystem used in all
% vehicle configurations that include a high-voltage battery. It is
% referenced by the BMS test harness (|BMS/TestBench/BMSTestHarness.slx|).
% Parameters are loaded by |BMSParams.m|.

%% Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Min cell voltage limit</td><td>3.0 V</td><td>Under-voltage fault threshold</td></tr>
% <tr><td>Max cell voltage limit</td><td>4.2 V</td><td>Over-voltage fault threshold</td></tr>
% <tr><td>Max charging current</td><td>100 A</td><td>Charging current protection limit</td></tr>
% <tr><td>Max discharging current</td><td>120 A</td><td>Discharging current protection limit</td></tr>
% <tr><td>Charger CC value</td><td>50 A</td><td>Constant-current charging setpoint</td></tr>
% <tr><td>Min thermal limit</td><td>233.15 K (-40 &deg;C)</td><td>Low temperature fault threshold</td></tr>
% <tr><td>Max thermal limit</td><td>333.15 K (60 &deg;C)</td><td>High temperature fault threshold</td></tr>
% <tr><td>Series strings</td><td>110</td><td>Number of series-connected strings</td></tr>
% <tr><td>Parallel cells per string</td><td>3</td><td>Cells in parallel per string</td></tr>
% <tr><td>Coolant switch-on temperature</td><td>320 K</td><td>Temp to activate coolant flow</td></tr>
% <tr><td>Coolant switch-off temperature</td><td>303 K</td><td>Temp to deactivate coolant flow</td></tr>
% </table>
% </html>
%
% See |BMSParams.m| for a complete list.

%% See Also
% * <BMSSoCDirectDescription.html BMSSoCDirect>
% * <BMSSoCEKFDescription.html BMSSoCEKF>
% * <matlab:web('ControllerDescription.html') Controller>

% Copyright 2022 - 2025 The MathWorks, Inc.

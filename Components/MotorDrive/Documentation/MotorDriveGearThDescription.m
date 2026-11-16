%% MotorDriveGearTh
% Electric motor drive with fixed gear including full thermal coupling for
% motor windings, inverter, and coolant jacket.

%% Overview
% The MotorDriveGearTh block extends MotorDriveGear with full thermal
% coupling. The motor plant has electrical, mechanical, and thermal ports.
% A coolant jacket manages motor temperature, and inverter thermal dynamics
% capture semiconductor heating. The gear block transmits torque to the
% axle. This is the default motor fidelity for electro-thermal vehicle
% configurations.
%
% The core motor model is provided by the *EmotorLib* library
% (|Library/EmotorLib.slx|). See <EmotorLibDescription.html EmotorLib> for
% details on the underlying PMSM model and loss map.
%
% *Model:* <matlab:open_system('MotorDriveGearTh') MotorDriveGearTh.slx>
%
% *Parameters:* <matlab:edit('MotorDriveGearThParams.m') MotorDriveGearThParams.m>
%
% *Thermal Coupling:* Yes (motor windings, inverter, coolant jacket)

%% Open Model

open_system('MotorDriveGearTh')

%% Ports
%
% <html>
% <h3>Input Bus &mdash; <code>s</code></h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Signal</th><th>Description</th></tr>
% <tr><td>EMtrq</td><td>Motor torque command</td></tr>
% <tr><td>Batt</td><td>Battery status sub-bus (Relay.RelayDchg, BattSensor.BatVolt)</td></tr>
% <tr><td>EMrpm</td><td>Motor speed feedback</td></tr>
% </table>
% <h3>Output Bus &mdash; <code>m</code></h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Signal</th><th>Description</th></tr>
% <tr><td>EM</td><td>Motor measurement sub-bus</td></tr>
% <tr><td>energy</td><td>Cumulative energy consumed</td></tr>
% </table>
% <h3>Physical Ports</h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Port</th><th>Domain</th><th>Description</th></tr>
% <tr><td>HV</td><td>Electrical</td><td>High-voltage bus connection</td></tr>
% <tr><td>Ax</td><td>Mechanical rotational</td><td>Axle output shaft</td></tr>
% <tr><td>A</td><td>Thermal liquid</td><td>Coolant port</td></tr>
% <tr><td>B</td><td>Thermal liquid</td><td>Coolant port</td></tr>
% </table>
% </html>

%% Workflows
% MotorDriveGearTh is the *default motor fidelity* for the
% *VehicleElectroThermal* template. It is used in all electro-thermal
% range estimation runs (NEDC, WLTC, EPA). Motor
% losses contribute to EM1 and EM2 energy tracking in range results.
% Inverter thermal output feeds the inverter life prediction workflow.
% The model is validated through |MotorTestHarness.slx|.

%% Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Max motor torque</td><td>220 Nm</td><td>Peak torque capability</td></tr>
% <tr><td>Max motor power</td><td>50 kW</td><td>Continuous power rating</td></tr>
% <tr><td>Torque control time constant</td><td>0.002 s</td><td>First-order lag on torque command</td></tr>
% <tr><td>Initial coolant temperature</td><td>298.15 K</td><td>Coolant temperature at simulation start</td></tr>
% <tr><td>Motor loss map</td><td>MotorLossMap.mat</td><td>Speed-torque-loss lookup table from Library</td></tr>
% </table>
% </html>
%
% See |MotorDriveGearThParams.m| for a complete list of parameters.

%% See Also
% * <MotorDriveGearDescription.html MotorDriveGear>
% * <MotorDriveLubeDescription.html MotorDriveLube>
% * <EmotorLibDescription.html EmotorLib Library>
% * <MotorTestHarnessDescription.html Motor Test Harness>

% Copyright 2022 - 2026 The MathWorks, Inc.

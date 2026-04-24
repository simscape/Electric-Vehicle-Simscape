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
% *Inputs*
%
% * *Torque command* - Requested motor torque.
% * *Control signals* - Enable, mode, and limit signals.
% * *Battery signals* - HV bus voltage and current.
% * *Coolant port* - Thermal-liquid interface for motor and inverter cooling.
%
% *Outputs*
%
% * *Motor Torque* - Delivered mechanical torque.
% * *Motor Speed* - Rotor speed.
% * *Electrical Power* - Power drawn from the HV bus.
% * *Thermal States* - Motor winding temperature, inverter junction temperature.
% * *Energy* - Cumulative energy consumption.

%% Workflows
% MotorDriveGearTh is the *default motor fidelity* loaded by
% |BEVSystemModelParams.m| via |MotorDriveGearThParams.m|. It is used in
% all electro-thermal range estimation runs (NEDC, WLTC, EPA). Motor
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

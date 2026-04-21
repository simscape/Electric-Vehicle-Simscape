%% MotorDriveLube
% Motor drive with fixed gear including thermal coupling and gearbox
% lubrication losses.

%% Overview
% The MotorDriveLube block extends MotorDriveGearTh by adding a gearbox
% thermal interface and oil-related friction and churning losses. The
% motor, inverter, and gearbox each have thermal ports connected to the
% coolant loop. This provides the highest fidelity powertrain efficiency
% and thermal model, suitable for evaluating the effect of lubricant
% viscosity and gear losses on vehicle range.
%
% The core motor model is provided by the *EmotorLib* library
% (|Library/EmotorLib.slx|). See <EmotorLibDescription.html EmotorLib> for
% details on the underlying PMSM model and loss map.
%
% *Model:* <matlab:open_system('MotorDriveLube') MotorDriveLube.slx>
%
% *Parameters:* <matlab:edit('MotorDriveLubeParams.m') MotorDriveLubeParams.m>, |MotorDriveGearThParams.m|
%
% *Thermal Coupling:* Yes (motor, inverter, gearbox, oil cooling)

%% Open Model

open_system('MotorDriveLube')

%% Ports
% *Inputs*
%
% * *Torque command* - Requested motor torque.
% * *Control signals* - Enable, mode, and limit signals.
% * *Battery signals* - HV bus voltage and current.
% * *Coolant port* - Thermal-liquid interface for motor, inverter, and gearbox cooling.
%
% *Outputs*
%
% * *Motor Torque* - Delivered mechanical torque.
% * *Motor Speed* - Rotor speed.
% * *Electrical Power* - Power drawn from the HV bus.
% * *Thermal States* - Motor, inverter, and gearbox temperatures.
% * *Energy* - Cumulative energy consumption.

%% Workflows
% The MotorDriveLube block is used in high-fidelity powertrain studies
% where gearbox efficiency and thermal behavior matter. It is suitable for
% evaluating the effect of lubricant viscosity and gear losses on vehicle
% range.

%% Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Max motor torque</td><td>220 Nm</td><td>Peak torque capability</td></tr>
% <tr><td>Max motor power</td><td>50 kW</td><td>Continuous power rating</td></tr>
% <tr><td>Torque control time constant</td><td>0.002 s</td><td>First-order lag on torque command</td></tr>
% <tr><td>Initial coolant temperature</td><td>298.15 K</td><td>Coolant temperature at simulation start</td></tr>
% <tr><td>Oil flow rate</td><td>5/60000 m^3/s</td><td>ATF oil flow rate for winding cooling</td></tr>
% <tr><td>Oil density</td><td>850 kg/m^3</td><td>ATF lubricant density</td></tr>
% </table>
% </html>
%
% See |MotorDriveGearParams.m| and |MotorDriveGearThParams.m| for a
% complete list of parameters.

%% See Also
% * <MotorDriveGearDescription.html MotorDriveGear>
% * <MotorDriveGearThDescription.html MotorDriveGearTh>
% * <EmotorLibDescription.html EmotorLib Library>
% * <MotorTestHarnessDescription.html Motor Test Harness>

% Copyright 2022 - 2026 The MathWorks, Inc.

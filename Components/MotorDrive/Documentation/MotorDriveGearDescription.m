%% MotorDriveGear
% Electric motor with lumped electrical and mechanical dynamics and a fixed
% gear for torque transmission to the axle.

%% Overview
% The MotorDriveGear block models an electric motor with lumped electrical
% and mechanical dynamics and a fixed-ratio gear for torque transmission.
% The motor input block accepts torque commands, control signals, and
% battery state. No thermal dynamics are modeled -- temperature is treated
% as a fixed input. Internal signals include current, voltage, motor speed,
% and energy consumption.
%
% The core motor model is provided by the *EmotorLib* library
% (|Library/EmotorLib.slx|). See <EmotorLibDescription.html EmotorLib> for
% details on the underlying PMSM model and loss map.
%
% *Model:* <matlab:open_system('MotorDriveGear') MotorDriveGear.slx>
%
% *Parameters:* <matlab:edit('MotorDriveGearParams.m') MotorDriveGearParams.m>
%
% *Thermal Coupling:* None

%% Open Model

open_system('MotorDriveGear')

%% Ports
% *Inputs*
%
% * *Torque command* - Requested motor torque from the controller.
% * *Control signals* - Enable, mode, and limit signals.
% * *Battery signals* - HV bus voltage and current availability.
%
% *Outputs*
%
% * *Motor Torque* - Delivered mechanical torque.
% * *Motor Speed* - Rotor speed.
% * *Electrical Power* - Power drawn from the HV bus.
% * *Energy* - Cumulative energy consumption.

%% Workflows
% The MotorDriveGear block is listed in the *VehicleElectric* and
% *VehicleElecAux* templates in |VehicleTemplateConfig.json| as an available
% motor variant. It is used when fast simulation is needed without thermal
% effects.

%% Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Max motor torque</td><td>220 Nm</td><td>Peak torque capability</td></tr>
% <tr><td>Max motor power</td><td>50 kW</td><td>Continuous power rating</td></tr>
% <tr><td>Torque control time constant</td><td>0.002 s</td><td>First-order lag on torque command</td></tr>
% </table>
% </html>
%
% See |MotorDriveGearParams.m| for a complete list of parameters.

%% See Also
% * <MotorDriveGearThDescription.html MotorDriveGearTh>
% * <MotorDriveLubeDescription.html MotorDriveLube>
% * <EmotorLibDescription.html EmotorLib Library>
% * <MotorTestHarnessDescription.html Motor Test Harness>

% Copyright 2022 - 2026 The MathWorks, Inc.

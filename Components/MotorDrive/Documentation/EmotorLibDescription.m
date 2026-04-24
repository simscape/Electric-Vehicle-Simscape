%% EmotorLib
% Shared electric motor library containing reusable motor subsystem blocks
% for the MotorDrive component.
%
% *Library:* |Library/EmotorLib.slx|
%
% *Parameters:* <matlab:edit('MotorDriveGearThParams.m') MotorDriveGearThParams.m>, |InverterMotorDriveParam.m|
%
% *Loss Map:* |MotorLossMap.mat|

%% Library Overview
% The EmotorLib library provides two motor subsystem blocks that are
% referenced by all MotorDrive fidelity models. The library separates the
% motor plant into a non-thermal variant (*Emotor*) and a thermal variant
% (*Emotor Thermal*) so that each vehicle-level fidelity can select the
% appropriate level of detail.
%
% Motor losses are defined by a speed-torque-loss lookup table stored in
% |MotorLossMap.mat|. Electrical parameters (max torque, max power, time
% constant) are defined in |MotorDriveGearThParams.m|. Inverter thermal
% and heatsink properties are defined in |InverterMotorDriveParam.m|.

open_system('EmotorLib')

%% Emotor (Non-Thermal)
% The *Emotor* block is the non-thermal variant of the motor plant. It
% models the electrical and mechanical behavior of the motor without any
% temperature dependence or thermal coupling.

open_system('EmotorLib/Emotor')
captureSubsystemImage('EmotorLib/Emotor')

%%
% The Emotor block contains the following subsystems:
%
% * *Motor & Drive* - Simscape block implementing the electric motor and
%   drive electronics. Accepts a torque command through a bus input and
%   produces mechanical torque on the shaft.
% * *Motor Inertia* - Rotational inertia on the motor shaft.
% * *Bus Selector / Bus Creator* - Unpacks the control bus (torque command,
%   enable, limits) and repacks measured outputs (current, voltage, speed,
%   energy).
%
% *Ports:*
%
% * One Simulink input (control bus)
% * One Simulink output (measurement bus)
% * One Simscape mechanical rotational port (connects to gear and driveline)
%
% Temperature is treated as a fixed constant. There is no thermal port or
% coolant coupling.
%
% *Used by:* <MotorDriveGearDescription.html MotorDriveGear>, which wraps
% this block with a fixed gear ratio for axle torque transmission.

%% Electrical Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Max motor torque</td><td>220 Nm</td><td>Peak torque capability</td></tr>
% <tr><td>Max motor power</td><td>50 kW</td><td>Continuous power rating</td></tr>
% <tr><td>Torque control time constant</td><td>0.002 s</td><td>First-order lag on torque command</td></tr>
% <tr><td>Initial coolant temperature</td><td>298.15 K</td><td>Coolant temperature at simulation start</td></tr>
% <tr><td>Motor loss map</td><td>MotorLossMap.mat</td><td>Speed-torque-loss lookup table</td></tr>
% </table>
% </html>
%
% See |MotorDriveGearThParams.m| for a complete list.

%% Emotor Thermal
% The *Emotor Thermal* block extends the non-thermal variant with full
% thermal dynamics. In addition to the electrical and mechanical model it
% includes loss estimation and thermal coupling for motor windings, rotor,
% and coolant jacket.

open_system('EmotorLib/Emotor Thermal')
captureSubsystemImage('EmotorLib/Emotor Thermal')

%%
% The Emotor Thermal block adds the following subsystems on top of the base
% Emotor model:
%
% * *Loss Estimation* - Computes copper, iron, and magnet losses from the
%   motor operating point using the speed-torque-loss lookup table in
%   |MotorLossMap.mat|.
% * *Air HTC Calculation* - Rotor-side and Taylor-Couette convective heat
%   transfer coefficient estimation based on rotor speed and air-gap
%   geometry.
% * *Current Sensor* - Measures phase current for loss computation.
% * *Thermal Ports (LConn / RConn)* - Five Simscape conserving ports that
%   connect to the coolant jacket, stator thermal nodes, and rotor thermal
%   nodes. These ports allow the MotorDrive models to couple with the
%   vehicle coolant loop.
%
% *Ports:*
%
% * One Simulink input (control bus)
% * One Simulink output (measurement bus)
% * Two left-side conserving ports (LConn) for coolant interface
% * Three right-side conserving ports (RConn) for thermal and mechanical coupling
%
% The thermal model captures stator winding temperature, rotor magnet
% temperature, and inverter junction temperature. Coolant flow through the
% jacket removes heat from the motor and inverter assemblies.


%% Thermal Parameters (Emotor Thermal only)
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Number of pole pairs</td><td>4</td><td>PM pole pairs on the rotor</td></tr>
% <tr><td>Number of stator slots</td><td>48</td><td>Stator slot count</td></tr>
% <tr><td>Stator bore ID</td><td>130.96 mm</td><td>Inner diameter of stator bore</td></tr>
% <tr><td>Stator OD</td><td>198.12 mm</td><td>Outer diameter of stator</td></tr>
% <tr><td>Stack length</td><td>151.38 mm</td><td>Axial length of the stator stack</td></tr>
% <tr><td>Slot packing factor</td><td>0.4</td><td>Copper fill fraction in the slots</td></tr>
% <tr><td>Coolant jacket channel turns</td><td>5</td><td>Number of spiral coolant channel turns</td></tr>
% <tr><td>Winding overhang</td><td>0.2</td><td>Fraction of stator stack length</td></tr>
% <tr><td>Oil flow rate</td><td>5/60000 m^3/s</td><td>ATF flow rate for winding cooling</td></tr>
% </table>
% </html>
%
% See |MotorDriveGearThParams.m| for a complete list.


%% Differences Between Variants
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Feature</th><th>Emotor</th><th>Emotor Thermal</th></tr>
% <tr><td>Thermal dynamics</td><td>No (fixed temperature)</td><td>Yes (stator, rotor, winding nodes)</td></tr>
% <tr><td>Loss estimation</td><td>Efficiency map only</td><td>Detailed copper, iron, magnet losses</td></tr>
% <tr><td>Coolant coupling</td><td>None</td><td>Coolant jacket via conserving ports</td></tr>
% <tr><td>Air-gap convection</td><td>None</td><td>Taylor-Couette and rotor-side HTC</td></tr>
% <tr><td>Simscape conserving ports</td><td>1 (mechanical)</td><td>5 (mechanical + thermal)</td></tr>
% <tr><td>Used by</td><td>MotorDriveGear</td><td>MotorDriveGearTh, MotorDriveLube</td></tr>
% </table>
% </html>



%% See Also
% * <MotorDriveGearDescription.html MotorDriveGear>
% * <MotorDriveGearThDescription.html MotorDriveGearTh>
% * <MotorDriveLubeDescription.html MotorDriveLube>
% * <MotorTestHarnessDescription.html Motor Test Harness>

% Copyright 2022 - 2026 The MathWorks, Inc.

%% ControllerHVAC
% Controller variant with integrated HVAC thermal management control logic
% in addition to standard drivetrain torque control.
%
% *Model:* |ControllerHVAC.slx|
%
% *Parameters:* |ControllerParams.m|
%
% *Thermal Coupling:* No

%% Overview
% The ControllerHVAC adds HVAC thermal management control logic on top of
% the standard drivetrain torque control. It coordinates cabin temperature
% setpoints, blower commands, and compressor operation alongside motor
% torque management. This variant is used in vehicle configurations that
% include active HVAC thermal models.

open_system('ControllerHVAC')

%% Ports
% *Inputs*
%
% * *Drive cycle speed reference* - Target vehicle speed from the drive cycle source.
% * *Vehicle speed feedback* - Measured vehicle speed from the driveline.
% * *Battery status* - SOC, voltage, and current from the BMS.
% * *BMS relay commands* - Battery connection state.
% * *Cabin temperature feedback* - Measured cabin air temperature.
% * *HVAC setpoint* - Target cabin temperature.
%
% *Outputs*
%
% * *Front axle torque command* - Torque request to front motor (EM1).
% * *Rear axle torque command* - Torque request to rear motor (EM2).
% * *Brake command* - Mechanical braking torque request.
% * *Battery command* - Charge/discharge mode signal.
% * *Blower command* - HVAC blower speed/enable.
% * *Compressor command* - AC compressor enable.
% * *PTC heater command* - Cabin heater enable.

%% Workflows
% The ControllerHVAC is used in vehicle configurations that include active
% HVAC thermal models (HVACsimpleTh, HVACThermal). It enables coordinated
% drivetrain and cabin comfort studies.

%% Parameters
% The ControllerHVAC shares the same parameter file as the full Controller.
%
% See |ControllerParams.m| for a complete list.

%% See Also
% * <ControllerDescription.html Controller>
% * <ControllerFRMDescription.html ControllerFRM>
% * <matlab:web('BMSDescription.html') BMS>

% Copyright 2022 - 2025 The MathWorks, Inc.

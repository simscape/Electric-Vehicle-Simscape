%% Controller
% Full vehicle controller with torque control, motor torque split, and
% regenerative braking for the BEV system model.

%% Overview
% The Controller implements torque control with motor torque split between
% front and rear axles, AWD/FWD mode selection, regenerative braking logic,
% and drive-cycle speed tracking. This is the default controller used in
% the electro-thermal vehicle configuration.
%
% *Model:* <matlab:open_system('Controller') Controller.slx>
%
% *Parameters:* <matlab:edit('ControllerParams.m') ControllerParams.m>
%
% *Thermal Coupling:* No

%% Open Model

open_system('Controller')

%% Ports
% *Inputs*
%
% * *Drive cycle speed reference* - Target vehicle speed from the drive cycle source.
% * *Vehicle speed feedback* - Measured vehicle speed from the driveline.
% * *Battery status* - SOC, voltage, and current from the BMS.
% * *BMS relay commands* - Battery connection state.
%
% *Outputs*
%
% * *Front axle torque command* - Torque request to front motor (EM1).
% * *Rear axle torque command* - Torque request to rear motor (EM2).
% * *Brake command* - Mechanical braking torque request.
% * *Battery command* - Charge/discharge mode signal.

%% Workflows
% The Controller is the *default vehicle controller* selected by
% |SetupPlantElectroThermal.m| for the VehicleElectroThermal template. It
% is used in all range estimation workflows (NEDC, WLTC, EPA) and battery
% sizing workflows. Dashboard parameters (AWD, regen, charging mode) are
% set by |modelDashboardSetup.m| in the BEV Setup App.

%% Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Tire rolling radius</td><td>30 cm</td><td>Effective tire radius for speed calculation</td></tr>
% <tr><td>Brake factor</td><td>0.4</td><td>Fraction of braking from mechanical brakes</td></tr>
% <tr><td>Max vehicle speed</td><td>140 km/h</td><td>Speed limiter threshold</td></tr>
% <tr><td>Motor drive max torque</td><td>360 Nm</td><td>Combined motor torque limit</td></tr>
% </table>
% </html>
%
% See |ControllerParams.m| for a complete list.

%% See Also
% * <ControllerFRMDescription.html ControllerFRM>
% * <ControllerHVACDescription.html ControllerHVAC>
% * <matlab:web('BMSDescription.html') BMS>

% Copyright 2022 - 2025 The MathWorks, Inc.

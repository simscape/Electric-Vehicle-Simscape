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
%
% <html>
% <h3>Inputs</h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Port</th><th>Type</th><th>Description</th></tr>
% <tr><td>Spd</td><td>Scalar</td><td>Drive cycle speed reference</td></tr>
% <tr><td>(measurement bus)</td><td>Bus</td><td>Feedback: m.DV.VehSpd, m.M1.EM.EMrpm, m.M1.EM.coilT, m.BA.CoolTp, BA.BattSens, Env.Tenv, VA.Tcabin</td></tr>
% <tr><td>BMS</td><td>Bus element</td><td>BMS sensor signals (faults, limits, SOC)</td></tr>
% <tr><td>AWD</td><td>Bus element</td><td>AWD mode flag</td></tr>
% </table>
% <h3>Output Bus &mdash; <code>s</code></h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Sub-bus</th><th>Key Signals</th><th>Description</th></tr>
% <tr><td>DV</td><td>BrkCmd</td><td>Driveline brake command</td></tr>
% <tr><td>Battery</td><td>RelayPos, RelayNeg</td><td>Battery relay commands</td></tr>
% <tr><td>EM1</td><td>EMtrq, Batt</td><td>Front motor torque command</td></tr>
% <tr><td>EM2</td><td>EMtrq, Batt</td><td>Rear motor torque command</td></tr>
% <tr><td>Charger</td><td>Batt</td><td>Charger mode signal</td></tr>
% <tr><td>Radiator</td><td>cmdFan, Env, VehSpd</td><td>Radiator fan control</td></tr>
% <tr><td>MotorPump</td><td>cmdPump, BatSt</td><td>Motor coolant pump</td></tr>
% <tr><td>BatteryPump</td><td>cmdPump, BatSt</td><td>Battery coolant pump</td></tr>
% <tr><td>Heater</td><td>cmdHeater, BatSt</td><td>Battery heater</td></tr>
% <tr><td>HVAC</td><td>Env, Batt, Cntrl</td><td>HVAC cabin commands</td></tr>
% <tr><td>ChillerValve</td><td>cmdChillerByp</td><td>Chiller bypass valve</td></tr>
% <tr><td>ControlValve</td><td>cmdParallelSerieal</td><td>Coolant control valve</td></tr>
% </table>
% </html>

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

% Copyright 2022 - 2026 The MathWorks, Inc.

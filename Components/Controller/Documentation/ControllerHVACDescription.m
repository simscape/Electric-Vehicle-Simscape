%% ControllerHVAC
% Controller variant with integrated HVAC thermal management control logic
% in addition to standard drivetrain torque control.

%% Overview
% The ControllerHVAC adds HVAC thermal management control logic on top of
% the standard drivetrain torque control. It coordinates cabin temperature
% setpoints, blower commands, and compressor operation alongside motor
% torque management. This variant is used in vehicle configurations that
% include active HVAC thermal models.
%
% *Model:* <matlab:open_system('ControllerHVAC') ControllerHVAC.slx>
%
% *Parameters:* <matlab:edit('ControllerParams.m') ControllerParams.m>
%
% *Thermal Coupling:* No

%% Open Model

open_system('ControllerHVAC')

%% Ports
%
% <html>
% <h3>Inputs</h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Port</th><th>Type</th><th>Description</th></tr>
% <tr><td>Spd</td><td>Scalar</td><td>Drive cycle speed reference</td></tr>
% <tr><td>(measurement bus)</td><td>Bus</td><td>Feedback: m.DV.VehSpd, m.M1.EM.EMrpm, m.M1.EM.coilT, m.BA.CoolTp, BA.BattSens, Env.Tenv, VA.Tcabin, VA.Tptc, VA.TacVent</td></tr>
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
% <tr><td>MotorPump</td><td>cmdMotorPump, BatSt</td><td>Motor coolant pump</td></tr>
% <tr><td>BatteryPump</td><td>cmdBatteryPump, BatSt</td><td>Battery coolant pump</td></tr>
% <tr><td>Heater</td><td>cmdHeater, BatSt</td><td>Battery heater</td></tr>
% <tr><td>HVAC</td><td>Env, Batt, Cntrl</td><td>HVAC cabin commands</td></tr>
% <tr><td>ChillerValve</td><td>cmdChillerByp</td><td>Chiller bypass valve</td></tr>
% <tr><td>ControlValve</td><td>cmdParallelSerieal</td><td>Coolant control valve</td></tr>
% </table>
% </html>

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

% Copyright 2022 - 2026 The MathWorks, Inc.

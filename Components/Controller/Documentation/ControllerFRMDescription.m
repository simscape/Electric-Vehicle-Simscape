%% ControllerFRM
% Fast-running model (FRM) variant of the vehicle controller with
% simplified control logic for reduced simulation time.

%% Overview
% The ControllerFRM uses simplified control logic to reduce simulation time
% while preserving the same port interface as the full Controller. It is
% suitable for parameter sweeps and quick trade studies where controller
% fidelity is secondary to simulation throughput.
%
% *Model:* <matlab:open_system('ControllerFRM') ControllerFRM.slx>
%
% *Parameters:* <matlab:edit('ControllerParams.m') ControllerParams.m>
%
% *Thermal Coupling:* No

%% Open Model

open_system('ControllerFRM')

%% Ports
%
% <html>
% <h3>Inputs</h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Port</th><th>Type</th><th>Description</th></tr>
% <tr><td>Spd</td><td>Scalar</td><td>Drive cycle speed reference</td></tr>
% <tr><td>(measurement bus)</td><td>Bus</td><td>Feedback: m.DV.VehSpd, m.M1.EM.EMrpm, BA.BattSens</td></tr>
% <tr><td>BMS</td><td>Bus element</td><td>BMS sensor signals (faults, limits, SOC)</td></tr>
% <tr><td>AWD</td><td>Bus element</td><td>AWD mode flag</td></tr>
% </table>
% <h3>Output Bus &mdash; <code>s</code></h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Sub-bus</th><th>Key Signals</th><th>Description</th></tr>
% <tr><td>DV</td><td>BrakeCmd</td><td>Driveline brake command</td></tr>
% <tr><td>Battery</td><td>RelayPos, RelayNeg</td><td>Battery relay commands</td></tr>
% <tr><td>EM1</td><td>EMtrq, Batt</td><td>Front motor torque command</td></tr>
% <tr><td>EM2</td><td>EMtrq, Batt</td><td>Rear motor torque command</td></tr>
% <tr><td>Charger</td><td>Batt</td><td>Charger mode signal</td></tr>
% </table>
% </html>

%% Workflows
% The ControllerFRM is selected by |SetupPlantAbstract.m| for the
% VehicleElectric (abstract) template. It is used when simulation speed is
% prioritized over controller fidelity.

%% Parameters
% The ControllerFRM shares the same parameter file as the full Controller.
%
% See |ControllerParams.m| for a complete list.

%% See Also
% * <ControllerDescription.html Controller>
% * <ControllerHVACDescription.html ControllerHVAC>
% * <matlab:web('BMSDescription.html') BMS>

% Copyright 2022 - 2026 The MathWorks, Inc.

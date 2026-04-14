%% Charger
% Constant-current / constant-voltage (CC-CV) charging controller without
% thermal dynamics.

%% Overview
% The Charger block implements a CC-CV charging algorithm that generates a
% charging current command and applies it to the HV bus. The controller
% transitions from constant-current to constant-voltage mode based on
% battery cell voltage feedback. No thermal dynamics are modeled, making
% this fidelity suitable for fast electrical-only charging studies.
%
% *Model:* |Charger.slx|
%
% *Parameters:* |ChargerParams.m|
%
% *Thermal Coupling:* None

%% Open Model

open_system('Charger')

%% Ports
% *Inputs*
%
% * *Relay command* - Enables charger connection to the HV bus.
% * *Battery cell voltage* - Feedback for CC-CV transition.
% * *Charging state* - Charge enable and mode signal from the BMS.
%
% *Outputs*
%
% * *Charging Current* - Current delivered to the battery pack.
% * *HV Power* - Electrical power drawn from the grid.

%% Workflows
% The Charger block is listed in the *VehicleElectric* and *VehicleElecAux*
% templates in |VehicleTemplateConfig.json|. It is suitable for electrical-only charging studies
% without thermal management.

%% Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Maximum voltage</td><td>4.2 V</td><td>Cell voltage limit for CV mode</td></tr>
% <tr><td>Constant current (CC)</td><td>50 A</td><td>Charging current during CC phase</td></tr>
% <tr><td>Controller Kp</td><td>1</td><td>Proportional gain for voltage regulation</td></tr>
% <tr><td>Controller Ki</td><td>1</td><td>Integral gain for voltage regulation</td></tr>
% </table>
% </html>
%
% See |ChargerParams.m| for a complete list of parameters.

%% See Also
% * <ChargerDummyDescription.html ChargerDummy>
% * <ChargerThermalDescription.html ChargerThermal>
% * <ChargerThermalDummyDescription.html ChargerThermalDummy>
% * <ChargerTestHarnessDescription.html Charger Test Harness>

% Copyright 2022 - 2025 The MathWorks, Inc.

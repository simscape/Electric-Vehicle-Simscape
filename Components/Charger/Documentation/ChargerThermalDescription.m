%% ChargerThermal
% CC-CV charger with a thermal representation of the power converter.

%% Overview
% The ChargerThermal block extends the CC-CV charger with a thermal model
% of the power converter. The controlled current source charges the battery
% through the HV bus while heat generated in the converter is dissipated
% through a coolant jacket. This fidelity enables thermal management
% studies during charging events.
%
% *Model:* |ChargerThermal.slx|
%
% *Parameters:* |ChargerThermalParams.m|
%
% *Thermal Coupling:* Yes (converter thermal mass, coolant jacket)

%% Open Model

open_system('ChargerThermal')

%% Ports
% *Inputs*
%
% * *Relay command* - Charger enable.
% * *Battery cell voltage* - CC-CV transition feedback.
% * *Charging status* - Charge mode from BMS.
% * *Coolant port* - Thermal-liquid interface for converter cooling.
%
% *Outputs*
%
% * *Charging Current* - Current delivered to the battery.
% * *HV Power* - Electrical power consumed.
% * *Converter Thermal States* - Converter temperature and heat flow to coolant.

%% Workflows
% The ChargerThermal block is used in the *VehicleElectroThermal* template
% for full-thermal charging studies. Parameters are loaded by
% |BEVSystemModelParams.m| via |ChargerThermalParams.m|. It is referenced
% by the charger test harness (|ChargerTestHarness.slx|).

%% Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Maximum voltage</td><td>4.2 V</td><td>Cell voltage limit for CV mode</td></tr>
% <tr><td>Constant current (CC)</td><td>50 A</td><td>Charging current during CC phase</td></tr>
% <tr><td>Controller Kp</td><td>1</td><td>Proportional gain for voltage regulation</td></tr>
% <tr><td>Controller Ki</td><td>1</td><td>Integral gain for voltage regulation</td></tr>
% <tr><td>Coolant jacket channel diameter</td><td>0.0092 m</td><td>Diameter of coolant channels in the converter jacket</td></tr>
% <tr><td>Initial coolant temperature</td><td>298.15 K</td><td>Coolant temperature at simulation start</td></tr>
% </table>
% </html>
%
% See |ChargerThermalParams.m| for a complete list of parameters.

%% See Also
% * <ChargerDescription.html Charger>
% * <ChargerDummyDescription.html ChargerDummy>
% * <ChargerThermalDummyDescription.html ChargerThermalDummy>
% * <ChargerWithThermalDescription.html ChargerWithThermal>
% * <ChargerTestHarnessDescription.html Charger Test Harness>

% Copyright 2022 - 2025 The MathWorks, Inc.

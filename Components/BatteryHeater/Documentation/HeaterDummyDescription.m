%% HeaterDummy
% Minimal battery heater stub with fixed electrical load.

%% Overview
% The HeaterDummy block is a minimal stub that maintains the same port
% interface as the full Heater model. It draws a fixed electrical current
% from the HV bus when the heater is active (|cmdHeater = 1|) and zero
% current when off. Coolant ports A and B are connected through a simple
% pipe so the coolant loop stays closed, but no heat is exchanged.
%
% This fidelity is used when the heater subsystem is not the focus of
% the study but the system model needs a connected heater block to
% simulate without errors.
%
% *Model:* |HeaterDummy.slx|
%
% *Parameters:* |HeaterDummyParams.m|
%
% *Thermal Coupling:* No (coolant pass-through, no heat exchange)

%% Open Model

open_system('HeaterDummy')

%% Ports
% *Inputs*
%
% * *Battery status* - Pack state signals (terminated internally).
% * *Heater command* - 1 = active (draws load), 0 = off (no load).
% * *HV bus connection* - Electrical connection for fixed power draw.
% * *Coolant port* - Thermal-liquid interface (pass-through, no heat exchange).
%
% *Outputs*
%
% * *Heater Current* - Fixed current when active, zero when off.

%% Workflows
% The HeaterDummy block is a placeholder variant for integration testing
% or fast simulations. It can replace the full Heater in the
% *VehicleElectroThermal* template without breaking the coolant loop.
% Parameters are loaded by |HeaterDummyParams.m|.

%% Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Maximum heater power</td><td>4000 W</td><td>Fixed electrical power draw when active</td></tr>
% <tr><td>Coolant pipe diameter</td><td>0.019 m</td><td>Inner diameter of coolant piping (pass-through)</td></tr>
% <tr><td>Initial coolant temperature</td><td>298.15 K</td><td>Coolant temperature at simulation start</td></tr>
% <tr><td>Initial coolant pressure</td><td>0.101325 MPa</td><td>Coolant pressure at simulation start</td></tr>
% </table>
% </html>
%
% See |HeaterDummyParams.m| for a complete list of parameters.

%% See Also
% * <HeaterDescription.html Heater>
% * <HeaterTestHarnessDescription.html Heater Test Harness>

% Copyright 2022 - 2025 The MathWorks, Inc.

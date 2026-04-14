%% PumpDummy
% Minimal pump stub with fixed electrical load.

%% Overview
% The PumpDummy block is a minimal stub that maintains the same port
% interface as the full Pump model. It draws a fixed electrical current
% from the LV bus proportional to the pump command signal and zero current
% when the command is zero. Coolant ports A and B are connected through
% a simple pipe so the coolant loop stays closed, but no active pumping
% occurs.
%
% This fidelity is used when the pump subsystem is not the focus of
% the study but the system model needs a connected pump block to
% simulate without errors.
%
% *Model:* |PumpDummy.slx|
%
% *Parameters:* |PumpDummyParams.m|
%
% *Thermal Coupling:* No (coolant pass-through, no active pumping)

%% Open Model

open_system('PumpDummy')

%% Ports
% *Inputs*
%
% * *Battery status* - Pack state signals (terminated internally).
% * *Pump command* - Normalized command (0 = off, 1 = full current draw).
% * *LV bus connection* - Low-voltage electrical connection for current draw.
% * *Coolant port A* - Thermal-liquid inlet (pass-through, no active pumping).
%
% *Outputs*
%
% * *Pump Current* - Current drawn from the LV bus (I_fixed x PumpCmd).
% * *Low Voltage* - Measured LV bus voltage.
% * *Coolant port B* - Thermal-liquid outlet (pass-through).

%% Workflows
% The PumpDummy block is a placeholder variant for integration testing
% or fast simulations. It can replace the full Pump in the
% *VehicleElectroThermal* template without breaking the coolant loop.
% Parameters are loaded by |PumpDummyParams.m|.

%% Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Maximum pump current</td><td>10 A</td><td>Fixed current draw at full command</td></tr>
% <tr><td>Coolant pipe diameter</td><td>0.019 m</td><td>Inner diameter of coolant piping (pass-through)</td></tr>
% </table>
% </html>
%
% See |PumpDummyParams.m| for a complete list of parameters.

%% See Also
% * <PumpDescription.html Pump>
% * <PumpTestHarnessDescription.html Pump Test Harness>

% Copyright 2022 - 2025 The MathWorks, Inc.

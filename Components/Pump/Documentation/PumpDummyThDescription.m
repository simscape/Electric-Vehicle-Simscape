%% PumpDummyTh
% Minimal pump stub with fixed electrical load.

%% Overview
% The PumpDummyTh block is a minimal stub that maintains the same port
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
% *Model:* <matlab:open_system('PumpDummyTh') PumpDummyTh.slx>
%
% *Parameters:* <matlab:edit('PumpDummyThParams.m') PumpDummyThParams.m>
%
% *Thermal Coupling:* No (coolant pass-through, no active pumping)

%% Open Model

open_system('PumpDummyTh')

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
% The PumpDummyTh block is a placeholder variant for integration testing
% or fast simulations. It can replace the full Pump in the
% *VehicleElectroThermal* template without breaking the coolant loop.
% Parameters are set via the model mask, with defaults from |PumpDummyThParams.m|.

%% Mask Parameters
% The model exposes the following mask parameters. Defaults are read from
% the |pump| struct defined in |PumpDummyThParams.m|.
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Mask Variable</th><th>Default Source</th><th>Unit</th><th>Description</th></tr>
% <tr><td><tt>pumpMaxCurrent</tt></td><td><tt>pump.pumpMaxCurrent</tt></td><td>A</td><td>Fixed current draw at full command</td></tr>
% </table>
% </html>

%% See Also
% * <PumpDescription.html Pump>
% * <PumpDummyDescription.html PumpDummy>
% * <PumpTestHarnessDescription.html Pump Test Harness>

% Copyright 2022 - 2026 The MathWorks, Inc.

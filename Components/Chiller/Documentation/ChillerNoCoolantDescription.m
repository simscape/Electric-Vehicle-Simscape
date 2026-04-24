%% ChillerNoCoolant
% Simplified chiller model without coolant loop coupling.

%% Overview
% The ChillerNoCoolant block represents the chiller electrical load on the
% HV bus without thermal-liquid ports. The power draw is modeled but there
% is no coolant loop interaction. This fidelity is used when the vehicle
% model does not include a coolant loop but the chiller power consumption
% still needs to be accounted for in range and efficiency calculations.
%
% *Model:* <matlab:open_system('ChillerNoCoolant') ChillerNoCoolant.slx>
%
% *Parameters:* <matlab:edit('ChillerNoCoolantParams.m') ChillerNoCoolantParams.m>
%
% *Thermal Coupling:* None

%% Open Model

open_system('ChillerNoCoolant')

%% Ports
% *Inputs*
%
% * *Battery status* - Pack state signals.
% * *Chiller bypass control* - Enable command.
% * *HV bus connection* - Electrical connection for power draw.
%
% *Outputs*
%
% * *Chiller Current* - Current drawn from the HV bus.
% * *HV Power* - Electrical power consumed.

%% Workflows
% The ChillerNoCoolant block is a simplified variant used as a standalone
% auxiliary load model where the coolant loop is not modeled, suitable for
% fast electrical-only simulations where auxiliary power consumption matters.

%% See Also
% * <ChillerDescription.html Chiller>
% * <ChillerDummyDescription.html ChillerDummy>
% * <ChillerTestHarnessDescription.html Chiller Test Harness>

% Copyright 2022 - 2026 The MathWorks, Inc.

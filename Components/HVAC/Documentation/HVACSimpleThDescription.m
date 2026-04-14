%% HVACsimpleTh
% HVAC model with a cabin thermal plant including blower, cooler, and PTC
% heater interactions.

%% Overview
% The HVACsimpleTh block models the HVAC system with a cabin thermal
% plant. The cabin air volume is linked with cabin heat transfer and the
% external environment. A blower, cooler, and PTC heater interact with the
% cabin air mass to regulate temperature. A controlled current source
% models the HVAC electrical load, and an HVAC demand block computes the
% required cooling or heating power. Energy monitoring tracks HVAC
% consumption from the HV bus.
%
% *Model:* |HVACsimpleTh.slx|
%
% *Parameters:* |HVACsimpleThParams.m|
%
% *Thermal Coupling:* Yes (cabin thermal plant)

%% Open Model

open_system('HVACsimpleTh')

%% Ports
% *Inputs*
%
% * *Environment temperature* - Ambient air temperature.
% * *Blower command* - Blower speed or enable signal.
% * *PTC command* - Cabin heater power command.
% * *Compressor command* - AC compressor enable.
%
% *Outputs*
%
% * *Cabin Temperature* - Cabin air temperature from thermal dynamics.
% * *HVAC Energy* - Cumulative HVAC energy consumption.
% * *Blower/Cooler/PTC Thermal States* - Thermal operating states of HVAC actuators.

%% Workflows
% HVACsimpleTh is the *default HVAC fidelity* loaded by
% |BEVSystemModelParams.m| via |HVACsimpleThParams.m|. It is used in range
% estimation workflows for hot and cold ambient scenarios. The model is
% validated through |HVACTestHarness.slx|.

%% Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Cabin initial temperature</td><td>298.15 K</td><td>Cabin air temperature at simulation start</td></tr>
% <tr><td>Cabin initial pressure</td><td>0.101325 MPa</td><td>Cabin air pressure at simulation start</td></tr>
% <tr><td>Cabin initial relative humidity</td><td>0.4</td><td>Relative humidity of cabin air at start</td></tr>
% <tr><td>Cabin setpoint temperature</td><td>293.15 K</td><td>Target cabin temperature for HVAC control</td></tr>
% <tr><td>Cabin duct area</td><td>0.04 m^2</td><td>Cross-section area of HVAC duct to cabin</td></tr>
% <tr><td>Number of passengers</td><td>1</td><td>Passenger count for metabolic heat load</td></tr>
% <tr><td>Per-person heat transfer</td><td>70 W</td><td>Metabolic heat per passenger</td></tr>
% </table>
% </html>
%
% See |HVACsimpleThParams.m| for a complete list of parameters.

%% See Also
% * <HVACEmpiricalRefDescription.html HVACEmpiricalRef>
% * <HVACTestHarnessDescription.html HVAC Test Harness>

% Copyright 2022 - 2025 The MathWorks, Inc.

%% HVACThermal
% Full thermal HVAC model with detailed cabin and refrigerant loop
% dynamics.

%% Overview
% The HVACThermal block provides the highest fidelity cabin comfort and
% thermal management representation. It includes physical modeling of the
% refrigerant cycle, evaporator, and condenser in addition to cabin air
% volume dynamics. This fidelity is used for HVAC control strategy
% development and detailed thermal management analysis.
%
% *Model:* |HVACThermal.slx|
%
% *Parameters:* |HVACThermalParams.m|
%
% *Thermal Coupling:* Yes (refrigerant loop, cabin thermal plant, coolant port)

%% Open Model

open_system('HVACThermal')

%% Ports
% *Inputs*
%
% * *Environment temperature* - Ambient air temperature.
% * *Blower command* - Blower speed or enable signal.
% * *PTC command* - Cabin heater power command.
% * *Compressor command* - AC compressor enable.
% * *Coolant port* - Thermal-liquid interface for HVAC-coolant interaction.
%
% *Outputs*
%
% * *Cabin Temperature* - Cabin air temperature.
% * *HVAC Energy* - Cumulative energy consumption.
% * *Refrigerant States* - Evaporator and condenser thermal states.
% * *Blower/Cooler/PTC Thermal States* - Actuator thermal operating states.

%% Workflows
% The HVACThermal block is compatible with the *VehicleElecAux* and
% *VehicleElectroThermal* templates defined in |VehicleTemplateConfig.json|.
% It is used for HVAC control strategy development and detailed thermal
% management analysis. Parameters are loaded via |HVACThermalParams.m| and
% |BEVThermalManagementparam.m|.

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
% See |HVACThermalParams.m| for a complete list of parameters.

%% See Also
% * <HVACEmpiricalRefDescription.html HVACEmpiricalRef>
% * <HVACSimpleThDescription.html HVACsimpleTh>
% * <HVACTestHarnessDescription.html HVAC Test Harness>

% Copyright 2022 - 2025 The MathWorks, Inc.

%% Radiator
% Cross-flow heat exchanger for the BEV thermal management system.
%
% *Model:* |Radiator.slx|
%
% *Parameters:* |RadiatorParams.m|
%
% *Thermal Coupling:* Yes

%% Overview
% The Radiator dissipates heat from the coolant loop to the ambient
% environment. It is modeled as a cross-flow heat exchanger with multiple
% coolant tubes, air fins, and fan-driven airflow. Heat transfer is
% computed from the primary surface area (tube walls) and the fin surface
% area. Two fans provide forced-air convection. The radiator connects to
% the coolant loop downstream of the thermal components (battery, motor,
% charger) and upstream of the coolant tank and pump.

open_system('Radiator')

%% Ports
% *Inputs*
%
% * *Coolant inlet* - Hot coolant from the thermal management loop.
% * *Ambient temperature* - External air temperature.
% * *Fan airflow* - Forced-air flow driven by radiator fans.
% * *Vehicle speed* - Ram-air contribution to airflow at higher speeds.
%
% *Outputs*
%
% * *Coolant outlet* - Cooled coolant returned to the loop.
% * *Heat dissipation rate* - Thermal power rejected to ambient.

%% Workflows
% The Radiator is a critical part of the *VehicleElectroThermal* template
% coolant loop, balancing heat input from the battery, motor, and charger
% against ambient dissipation. Fan power consumption contributes to
% auxiliary energy draw in range estimation runs.

%% Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Radiator length</td><td>0.6 m</td><td>Overall radiator length</td></tr>
% <tr><td>Radiator width</td><td>0.015 m</td><td>Overall radiator width</td></tr>
% <tr><td>Radiator height</td><td>0.2 m</td><td>Overall radiator height</td></tr>
% <tr><td>Number of coolant tubes</td><td>25</td><td>Number of coolant tubes in the core</td></tr>
% <tr><td>Coolant tube height</td><td>0.0015 m</td><td>Height of each coolant tube</td></tr>
% <tr><td>Fin spacing</td><td>0.002 m</td><td>Spacing between air-side fins</td></tr>
% <tr><td>Wall thickness</td><td>1e-4 m</td><td>Material thickness of tube walls</td></tr>
% <tr><td>Wall thermal conductivity</td><td>240 W/m/K</td><td>Thermal conductivity of wall material</td></tr>
% <tr><td>Fan flow area</td><td>0.5 m^2</td><td>Total fan flow area (2 fans)</td></tr>
% </table>
% </html>
%
% See |RadiatorParams.m| for a complete list.

%% See Also
% * <RadiatorTestHarnessDescription.html Radiator Test Harness>

% Copyright 2022 - 2025 The MathWorks, Inc.

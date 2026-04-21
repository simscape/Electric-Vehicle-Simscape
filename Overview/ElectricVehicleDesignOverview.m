%% Electric Vehicle Design with Simscape(TM)
% 
% This repository contains model and code to help engineers design battery electric
% vehicle (BEV), including range estimation and battery sizing workflows.
%
% Copyright 2022 - 2026 The MathWorks, Inc.



%% Overview
%
% Battery electric vehicles (BEV) are gaining popularity as the prices of
% battery cells fall and the consumer demand for a clean mobility solution
% increases. The key challenges in their adoption lie in addressing the
% vehicle range anxiety, safety, and the total ownership cost for the
% consumer. Li-ion based batteries and electric drivetrains with permanent
% magnet synchronous motors (PMSM) and/or induction motors power modern BEV
% systems. Modeling and simulation helps you design vehicles that meet the
% desired range on the road and perform under all environmental conditions.
% Virtual design of a BEV platform requires a coupled electro-thermal
% system model for performance evaluation. In this example repository, you
% *learn how to simulate a BEV AWD/FWD model to estimate its on-road range*.
% You also *learn how to size your HV battery pack* to achieve your desired
% range with the vehicle.
%
% <html>
% <img vspace="5" hspace="5" src="../Image/BatteryElectricVehicleModelOverview_01.png" alt="BEV System Model" width="100%">
% </html>

%% Getting Started
%
% Before running the engineering workflows, you configure a vehicle model
% setup — selecting a template, choosing component fidelities, and setting
% initial design parameters. The diagram below shows the overall flow from
% model setup to workflow execution.
%
% <html>
% <img src="../Image/BEVWorkflow.png" alt="BEV Design Workflow" width="100%">
% </html>
%
% The project supports two ways to configure and load the vehicle model.
% Choose the one that fits your workflow.
%
% <html>
% <table border="1" cellpadding="8" cellspacing="0" style="border-collapse:collapse; width:100%;">
% <tr>
%   <th>Getting Started</th>
%   <th>What It Does</th>
%   <th>When to Use</th>
% </tr>
% <tr>
%   <td><strong>Preferred way</strong> (Preset)</td>
%   <td>Use the <a href="matlab:run('OpenPresetPicker')">Preset Picker</a> to browse and apply a shipped vehicle configuration. Three defaults are available: <em>VehicleElectric</em>, <em>VehicleElecAux</em>, and <em>VehicleElectroThermal</em>. Each preset configures the model references, loads the correct parameters, and opens the model ready to simulate.</td>
%   <td>Quick start with a known-good setup. No manual configuration needed.</td>
% </tr>
% <tr>
%   <td><strong>Custom configuration</strong></td>
%   <td>Launch the <a href="matlab:BEVapp">BEV Setup App</a> to select a template, choose component fidelities, link parameter files, and configure environment, HVAC, and driver settings.</td>
%   <td>When you need specific fidelities, custom environment settings, or non-default operating modes.</td>
% </tr>
% </table>
% </html>
%
% The configured model is then used as the starting point for the design
% workflows below. For a detailed overview of the reusable component
% packages, see the
% <matlab:web('ElectricVehicleComponentOverview.html') Component Overview>.

%% Design Workflows
%
% <html>
% <h3 style="margin:16px 0 6px 0;">System-Level Workflows</h3>
% <ul style="list-style:disc; padding-left:20px;">
% <li><a href="matlab:open('BEVRangeEstimationMain.mlx')"><b>Range Estimation Workflow</b></a> :<br>
% Estimate vehicle range over <b>NEDC</b>, <b>WLTC</b>, and <b>EPA</b> drive cycles. The actual
% range depends on <b>ambient temperature</b>, <b>HVAC load</b>, and <b>driver profile</b>.
% Evaluate subsystem losses under hot and cold conditions.</li>
% <li><a href="matlab:open('BEVBatterySizingMain.mlx')"><b>Battery Sizing Workflow</b></a> :<br>
% Size the HV battery pack to achieve a target driving range. Compare
% different <b>cell capacities</b> and <b>pack weights</b> over the NEDC cycle with HVAC
% on to find the right trade-off between range and vehicle mass.</li>
% </ul>
% <h3 style="margin:20px 0 6px 0;">Component-Level Workflows</h3>
% <ul style="list-style:disc; padding-left:20px;">
% <li><a href="matlab:open('generateDULossMap.mlx')"><b>Motor Inverter Loss Map Workflow</b></a> :<br>
% Generate <b>copper</b>, <b>iron</b>, <b>IGBT</b>, and <b>diode</b> loss maps by sweeping the
% FOC-controlled PMSM across speed, torque, and temperature points.</li>
% <li><a href="matlab:open('minimumRequiredGearRatio.mlx')"><b>Gear Ratio Selection Workflow</b></a> :<br>
% Sweep candidate gear ratios over EUDC and US06 cycles on the thermal test
% bench and compare <b>magnet</b> and <b>winding temperatures</b> to find the best ratio.</li>
% <li><a href="matlab:open('inverterPowerModuleLife.mlx')"><b>Inverter Power Module Life Workflow</b></a> :<br>
% Capture IGBT and diode <b>junction temperatures</b> from drive-cycle simulations,
% apply <b>rainflow cycle counting</b>, and estimate semiconductor lifetime.</li>
% <li><a href="matlab:open('DUThermalDurability.mlx')"><b>Motor Thermal Durability Workflow</b></a> :<br>
% Run the thermal test bench over extended duty cycles at multiple <b>coolant
% sump temperatures</b> to assess winding and magnet thermal margins.</li>
% <li><a href="matlab:open('VirtualSensorNeuralNetModel.mlx')"><b>Battery Virtual Sensor Workflow</b></a> :<br>
% Train a <b>neural network</b> to predict battery cell temperature from current,
% voltage, and SOC inputs. A pre-trained model is included for verification.</li>
% <li><a href="matlab:open('MotorDriveThermalTestBenchDescription.mlx')"><b>Motor Thermal Test Bench Workflow</b></a> :<br>
% Shared test bench model used by the gear-ratio, inverter-life, and
% thermal-durability workflows. Set up parameters and thermal fidelity.</li>
% </ul>
% </html>
%

%% Documentation
%
% * <matlab:web('BatteryElectricVehicleModelOverview.html','-new') Battery Electric Vehicle Model>
% * <matlab:web('ElectricVehicleComponentOverview.html','-new') Component Overview>
% * <matlab:web('helpAppDetail.html','-new') BEV Setup App>
% * <matlab:open('MotorDriveThermalTestBenchDescription.mlx') PMSM Thermal Model>
% 

%% Models
%
% * <matlab:open_system('BEVsystemModel.slx') Battery Electric Vehicle>

%%

%% Acronyms
% * BEV   : Battery Electric Vehicle
% * PMSM : Permanent Magnet Synchronous Motor
% * AWD   : All Wheel Drive
% * FWD   : Forward Wheel Drive

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


%%
open_system('BEVsystemModel')
%%

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
% There are three ways to begin:
%
% <html>
% <table border="1" cellpadding="8" cellspacing="0" style="border-collapse:collapse; width:100%;">
% <tr>
%   <th>Entry Point</th>
%   <th>What It Does</th>
%   <th>Best For</th>
% </tr>
% <tr>
%   <td><strong>Open the base model</strong></td>
%   <td>Load <a href="matlab:open_system('BEVsystemModel')">BEVsystemModel.slx</a> directly to inspect the reference vehicle architecture and subsystem reference wiring.</td>
%   <td>Quick exploration of the model structure without changing any configuration.</td>
% </tr>
% <tr>
%   <td><strong>Start from a preset</strong></td>
%   <td>Use a shipped vehicle configuration from <strong>APP/Config/Preset/</strong> as a ready-made component and fidelity selection.</td>
%   <td>Running workflows with a known-good configuration (electrical-only, electro-thermal, or cold-climate).</td>
% </tr>
% <tr>
%   <td><strong>Use the BEV Setup App</strong></td>
%   <td>Launch the <a href="matlab:BEVapp">BEV Setup App</a> to select a template, choose component variants, and configure initial design parameters.</td>
%   <td>Custom studies where you need to pick specific fidelities, environment settings, or operating modes.</td>
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
% * <matlab:open('BEVRangeEstimationMain.mlx') Range Estimation for Battery Electric Vehicles>
% * <matlab:open('BEVBatterySizingMain.mlx') Sizing Battery for Electric Vehicles>
% * <matlab:open('VirtualSensorNeuralNetModel.mlx') Battery Neural Network Model for Temperature Prediction>
% * <matlab:open('generateDULossMap.mlx') Generate loss map for PMSM (BEV)>
%

%% Documentation
% 
% * <matlab:web('BatteryElectricVehicleModelOverview.html') Battery Electric Vehicle Model>
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

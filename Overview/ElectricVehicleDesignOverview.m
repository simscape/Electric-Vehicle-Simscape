%% Electric Vehicle Design with Simscape(TM)
% 
% This repository contains model and code to help engineers design battery electric
% vehicle (BEV), including range estimation and battery sizing workflows.
%
% Copyright 2022 - 2025 The MathWorks, Inc.



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

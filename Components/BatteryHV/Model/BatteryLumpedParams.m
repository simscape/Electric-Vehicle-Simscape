% Copyright 2025 The MathWorks, Inc.

%% Required Environment Parameters
% These parameters must be defined before running this script.
% In standalone use, define them in your workspace or harness script.
% In the BEV system model, they are set by BEVSystemModelParams.m
%
%   (No environment parameters required for BatteryLumped — no thermal coupling)

%% Cell Electrical
battery.T_vec=[278 293 313];       % Temperature vector T [K]
battery.AH=34;                     % [Ah] Cell capacity 
battery.AH_vec=[0.9*battery.AH battery.AH 0.9*battery.AH]; % Cell capacity vector AH(T) [Ahr]
battery.SOC_vec=[0, .1, .25, .5, .75, .9, 1]; % Cell state of charge vector SOC [-]
battery.initialPackSOC=0.75;	     % Pack intial SOC (-)
battery.cRate=[0    0    0
               1    2    2
               2    2    3
               2    3    4
               2    3    4
               3    4    5
               4    5    6]; % mac c rate for given Temp and SoC

%% Load param files
batt_BatteryManagementSystem_param; % battery management parameters
batt_packBTMSExampleLib_param;      % battery module parameter filefile



%% Battery sizing Workflow
% BEV model is run with 1 NEDC cycles 
% Simulation is run at 25 degC ambient condition
% HVAC is On

% Copyright 2022 - 2023 The MathWorks, Inc.

%% Model Setup
open_system("BEVsystemModel")
SetupPlantElectroThermal; % Setup plant for ElectroThermal configuration
BEVplantModelParam; % Load model parameters
driveCycle='NEDC'; % drive cycle type, choose from drive cycle source block in model
SimulationTime='1180'; % drive simulation time, put as per the drive cycle selection
speedBlock=find_system('BEVsystemModel','Name','Drive Cycle Source'); % Get the block handle
set(getSimulinkBlockHandle(speedBlock),'cycleVar',driveCycle); % set the block to the drive cycle of choice

% Ambient setting
vehicleThermal.ambient=25 +273.15; % [K] Ambient temperature 
vehicleThermal.coolant_T_init=25 + 273.15;  % [K] Coolant initial temperature
vehicleThermal.CabinSpTp=20 + 273.15;       % [K] Cabin setpoint temperature
vehicleThermal.cabin_T_init=25 +273.15;    % [K] Cabin initial temperature
vehicleThermal.AConoff=1;          % AC on/off variable, 0 AC off, 1 AC On

%% Setup the model for NEDC cycle with 40KWh battery 
% Battery setting
battery.T_vec=[278 293 313];                 % [K] Temperature vector T 
battery.AH=34;    % [Ahr] Cell capacity for 40KWh battery
battery.AH_vec=[0.9*battery.AH battery.AH 0.9*battery.AH];    % [Ahr] Cell capacity vector AH(T) 
battery.SOC_vec=[0, .1, .25, .5, .75, .9, 1]; % Cell state of charge vector SOC [-]
battery.initialPackSOC=0.75;	% Pack intial SOC (-)
% Run parameter file for battery
batt_BatteryManagementSystem_param;
batt_packBTMSExampleLib_param;
% Vehicle weight 
vehicle.vehMass_kg= 1600; % [Kg] Vehicle mass for 40KWh battery

% Run the simulation for the specified Simulation time
simoutPack=sim('BEVsystemModel','StopTime',SimulationTime);
timeDetailed=simoutPack.SimulationMetadata.TimingInfo.ExecutionElapsedWallTime;

% record data
NEDC40KWhData = simoutPack.logsout;
Vals = getValuesFromLogsout(simoutPack.logsout.get("EnergyCons"));
NEDC40KWh.EnergyCons = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("EM1energy"));
NEDC40KWh.EM1energy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("EM2energy"));
NEDC40KWh.EM2energy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("HVACenergy"));
NEDC40KWh.HVACenergy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("AuxEnergy"));
NEDC40KWh.AuxEnergy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("Distance"));
NEDC40KWh.Distance = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("RangeRating"));
NEDC40KWh.RangeRating = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("Energy"));
NEDC40KWh.Energy = Vals.Data(end);

%% Setup the model for NEDC cycle with 45KWh battery 
% Battery setting
battery.T_vec=[278 293 313];                 % [K] Temperature vector T
battery.AH=37.5;    % [Ahr] Cell capacity for 45KWh battery
battery.AH_vec=[0.9*battery.AH battery.AH 0.9*battery.AH];    % [Ahr] Cell capacity vector AH(T)
battery.SOC_vec=[0, .1, .25, .5, .75, .9, 1]; % Cell state of charge vector SOC [-]
battery.initialPackSOC=0.75;	% Pack intial SOC (-)
% Run parameter file for battery
batt_BatteryManagementSystem_param;
batt_packBTMSExampleLib_param;
% Vehicle weight 
vehicle.vehMass_kg= 1736; % [Kg] Vehicle mass for 40KWh battery

% Run the simulation for the specified Simulation time
simoutPack=sim('BEVsystemModel','StopTime',SimulationTime);
timeDetailed=simoutPack.SimulationMetadata.TimingInfo.ExecutionElapsedWallTime;

% Record data
NEDC45KWhData = simoutPack.logsout;
Vals = getValuesFromLogsout(simoutPack.logsout.get("EnergyCons"));
NEDC45KWh.EnergyCons = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("EM1energy"));
NEDC45KWh.EM1energy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("EM2energy"));
NEDC45KWh.EM2energy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("HVACenergy"));
NEDC45KWh.HVACenergy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("AuxEnergy"));
NEDC45KWh.AuxEnergy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("Distance"));
NEDC45KWh.Distance = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("RangeRating"));
NEDC45KWh.RangeRating = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("Energy"));
NEDC45KWh.Energy = Vals.Data(end);

% Save the data to mat file
save('NEDCsizingData.mat','NEDC40KWhData','NEDC40KWh','NEDC45KWhData','NEDC45KWh');

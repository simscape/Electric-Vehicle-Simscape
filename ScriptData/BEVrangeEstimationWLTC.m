%% WLTC range calculation workflow
% BEV model is run with WLTC cycle
% Two scenarios are run 
% 1. -5 degC ambient with AC ON
% 2. 35 degC ambient with AC ON
% To see the effect of ambient temperature and cooling on range

% Copyright 2022 - 2023 The MathWorks, Inc.

%% Setup the model for WLTC cycle
open_system("BEVplantModel")
driveCycle = 'WLTP Class 3'; % drive cycle type, choose from drive cycle source block in model
SimulationTime = '1800'; % drive simulation time, put as per the drive cycle selection
speedBlock = find_system('BEVplantModel','Name','Drive Cycle Source'); % Get the block handle
set(getSimulinkBlockHandle(speedBlock),'cycleVar',driveCycle); % set the block to the drive cycle of choice
% Battery setting
battery.T_vec = [278 293 313];                 % Temperature vector T [K]
battery.AH = 34;    % Cell capacity 
battery.AH_vec = [0.9*battery.AH battery.AH 0.9*battery.AH];    % Cell capacity vector AH(T) [Ahr]
battery.SOC_vec = [0, .1, .25, .5, .75, .9, 1]; % Cell state of charge vector SOC [-]
battery.initialPackSOC = 0.75;	% Pack intial SOC (-)
% Run parameter file for battery
batt_BatteryManagementSystem_param;
batt_packBTMSExampleLib_param;


%% Sub Zero run with AC ON
% Ambient setting
vehicleThermal.ambient = -5+273.15;        % [K]  Ambient temperature in K
vehicleThermal.coolant_T_init = -5+273.15;  % [K]  Coolant initial temperature
vehicleThermal.CabinSpTp = 20+273.15;       % [K]  Cabin setpoint temperature
vehicleThermal.cabin_T_init = -5+273.15;    % [K]  Cabin initial temperature
vehicleThermal.AConoff = 1;          % AC on/off variable, 0 AC off, 1 AC On


% Run the simulation for the specified Simulation time
simoutPack = sim('BEVplantModel','StopTime',SimulationTime);
timeDetailed = simoutPack.SimulationMetadata.TimingInfo.ExecutionElapsedWallTime;


% record data
WLTCloTpACdata = simoutPack.logsout;
Vals = getValuesFromLogsout(simoutPack.logsout.get("EnergyCons"));
WLTCloTpAC.EnergyCons = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("EM1energy"));
WLTCloTpAC.EM1energy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("EM2energy"));
WLTCloTpAC.EM2energy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("HVACenergy"));
WLTCloTpAC.HVACenergy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("AuxEnergy"));
WLTCloTpAC.AuxEnergy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("Distance"));
WLTCloTpAC.Distance = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("RangeRating"));
WLTCloTpAC.RangeRating = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("Energy"));
WLTCloTpAC.Energy = Vals.Data(end);

%% Sub Zero run with AC off
vehicleThermal.AConoff = 0;          % AC on/off variable, 0 AC off, 1 AC On

% Run the simulation for the specified Simulation time
simoutPack = sim('BEVplantModel','StopTime',SimulationTime);
timeDetailed = simoutPack.SimulationMetadata.TimingInfo.ExecutionElapsedWallTime;

% record data
WLTCloTpNoACdata = simoutPack.logsout;
Vals = getValuesFromLogsout(simoutPack.logsout.get("EnergyCons"));
WLTCloTpNoAC.EnergyCons = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("EM1energy"));
WLTCloTpNoAC.EM1energy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("EM2energy"));
WLTCloTpNoAC.EM2energy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("HVACenergy"));
WLTCloTpNoAC.HVACenergy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("AuxEnergy"));
WLTCloTpNoAC.AuxEnergy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("Distance"));
WLTCloTpNoAC.Distance = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("RangeRating"));
WLTCloTpNoAC.RangeRating = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("Energy"));
WLTCloTpNoAC.Energy = Vals.Data(end);


%% Hot ambient condition run
% Ambient setting
vehicleThermal.ambient = 35+273.15;        % [K]  Ambient temperature in K
vehicleThermal.coolant_T_init = 35+273.15;  % [K]  Coolant initial temperature
vehicleThermal.CabinSpTp = 20+273.15;       % [K]  Cabin setpoint temperature
vehicleThermal.cabin_T_init = 35+273.15;    % [K]  Cabin initial temperature
vehicleThermal.AConoff = 1;          % AC on/off variable, 0 AC off, 1 AC On

% Run parameter file for battery
batt_BatteryManagementSystem_param;
batt_packBTMSExampleLib_param;

% Run the simulation for the specified Simulation time
simoutPack = sim('BEVplantModel','StopTime',SimulationTime);
timeDetailed = simoutPack.SimulationMetadata.TimingInfo.ExecutionElapsedWallTime;

% record data
WLTChiTpACdata = simoutPack.logsout;
Vals = getValuesFromLogsout(simoutPack.logsout.get("EnergyCons"));
WLTChiTpAC.EnergyCons = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("EM1energy"));
WLTChiTpAC.EM1energy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("EM2energy"));
WLTChiTpAC.EM2energy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("HVACenergy"));
WLTChiTpAC.HVACenergy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("AuxEnergy"));
WLTChiTpAC.AuxEnergy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("Distance"));
WLTChiTpAC.Distance = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("RangeRating"));
WLTChiTpAC.RangeRating = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("Energy"));
WLTChiTpAC.Energy = Vals.Data(end);

%% Sub Zero run with AC off
vehicleThermal.AConoff=0;          % AC on/off variable, 0 AC off, 1 AC On

% Run the simulation for the specified Simulation time
simoutPack=sim('BEVplantModel','StopTime',SimulationTime);
timeDetailed=simoutPack.SimulationMetadata.TimingInfo.ExecutionElapsedWallTime;

% record data
WLTChiTpNoACdata = simoutPack.logsout;
Vals = getValuesFromLogsout(simoutPack.logsout.get("EnergyCons"));
WLTChiTpNoAC.EnergyCons = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("EM1energy"));
WLTChiTpNoAC.EM1energy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("EM2energy"));
WLTChiTpNoAC.EM2energy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("HVACenergy"));
WLTChiTpNoAC.HVACenergy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("AuxEnergy"));
WLTChiTpNoAC.AuxEnergy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("Distance"));
WLTChiTpNoAC.Distance = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("RangeRating"));
WLTChiTpNoAC.RangeRating = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("Energy"));
WLTChiTpNoAC.Energy = Vals.Data(end);


%% Save the data to mat file
proj = matlab.project.rootProject;
save(proj.RootFolder+'\ScriptData\WLTCrangeData.mat','WLTCloTpACdata','WLTCloTpNoACdata','WLTChiTpACdata','WLTChiTpNoACdata', ...
      'WLTCloTpAC','WLTCloTpNoAC','WLTChiTpAC','WLTChiTpNoAC')
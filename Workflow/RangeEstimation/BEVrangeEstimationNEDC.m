%% NEDC range calculation workflow
% BEV model is run with 1 NEDC cycles 
% Three scenarios are run 
% 1. -5 degC ambient with AC ON
% 2. 35 degC ambient with AC ON
% To see the effect of ambient temperature and cooling on range

% Copyright 2022 - 2023 The MathWorks, Inc.

%% Setup the model for NEDC cycle
open_system("BEVsystemModel")
BEVplantModelParam; % Load model parameters
driveCycle='NEDC'; % drive cycle type, choose from drive cycle source block in model
SimulationTime='1180'; % drive simulation time, put as per the drive cycle selection
speedBlock=find_system('BEVsystemModel','Name','Drive Cycle Source'); % Get the block handle

% Select drive cycle if available
try
    set(getSimulinkBlockHandle(speedBlock),'cycleVar',driveCycle);
catch
    error('To run this simulation, install the Powertrain Blockset Drive Profile Data');
end

% Battery setting
battery.T_vec=[278 293 313];  % Temperature vector T [K]
battery.AH=34;    % Cell capacity [Ahr]
battery.AH_vec=[0.9*battery.AH battery.AH 0.9*battery.AH];    % Cell capacity vector AH(T) [Ahr]
battery.SOC_vec=[0, .1, .25, .5, .75, .9, 1]; % Cell state of charge vector SOC [-]
battery.initialPackSOC=0.75;	% Pack intial SOC (-)
% Run parameter file for battery
batt_BatteryManagementSystem_param;
batt_packBTMSExampleLib_param;


%% Sub Zero run with AC ON
% Ambient setting
vehicleThermal.ambient=-5 +273.15;        % [K] Ambient temperature
vehicleThermal.coolant_T_init=-5 +273.15;  % [K] Coolant initial temperature
vehicleThermal.CabinSpTp=20 +273.15;       % [K] Cabin setpoint temperature
vehicleThermal.cabin_T_init=-5 +273.15;    % [K] Cabin initial temperature
vehicleThermal.AConoff=1;          % AC on/off variable, 0 AC off, 1 AC On


% Run the simulation for the specified Simulation time
simoutPack=sim('BEVsystemModel','StopTime',SimulationTime);
timeDetailed=simoutPack.SimulationMetadata.TimingInfo.ExecutionElapsedWallTime;


% record data
NEDCloTpACdata = simoutPack.logsout;
Vals = getValuesFromLogsout(simoutPack.logsout.get("EnergyCons"));
NEDCloTpAC.EnergyCons = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("EM1energy"));
NEDCloTpAC.EM1energy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("EM2energy"));
NEDCloTpAC.EM2energy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("HVACenergy"));
NEDCloTpAC.HVACenergy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("AuxEnergy"));
NEDCloTpAC.AuxEnergy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("Distance"));
NEDCloTpAC.Distance = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("RangeRating"));
NEDCloTpAC.RangeRating = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("Energy"));
NEDCloTpAC.Energy = Vals.Data(end);

%% Sub Zero run with AC off
vehicleThermal.AConoff=0;          % AC on/off variable, 0 AC off, 1 AC On

% Run the simulation for the specified Simulation time
simoutPack=sim('BEVsystemModel','StopTime',SimulationTime);
timeDetailed=simoutPack.SimulationMetadata.TimingInfo.ExecutionElapsedWallTime;

% record data
NEDCloTpNoACdata = simoutPack.logsout;
Vals = getValuesFromLogsout(simoutPack.logsout.get("EnergyCons"));
NEDCloTpNoAC.EnergyCons = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("EM1energy"));
NEDCloTpNoAC.EM1energy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("EM2energy"));
NEDCloTpNoAC.EM2energy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("HVACenergy"));
NEDCloTpNoAC.HVACenergy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("AuxEnergy"));
NEDCloTpNoAC.AuxEnergy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("Distance"));
NEDCloTpNoAC.Distance = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("RangeRating"));
NEDCloTpNoAC.RangeRating = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("Energy"));
NEDCloTpNoAC.Energy = Vals.Data(end);


%% Hot ambient condition run
% Ambient setting
vehicleThermal.ambient=35 +273.15;         % [K] Ambient temperature in
vehicleThermal.coolant_T_init=35 +273.15;  % [K] Coolant initial temperature
vehicleThermal.CabinSpTp=20 +273.15;       % [K] Cabin setpoint temperature
vehicleThermal.cabin_T_init=35 +273.15;    % [K] Cabin initial temperature
vehicleThermal.AConoff=1;                  % AC on/off variable, 0 AC off, 1 AC On

% Run parameter file for battery
batt_BatteryManagementSystem_param;
batt_packBTMSExampleLib_param;

% Run the simulation for the specified Simulation time
simoutPack=sim('BEVsystemModel','StopTime',SimulationTime);
timeDetailed=simoutPack.SimulationMetadata.TimingInfo.ExecutionElapsedWallTime;

% record data
NEDChiTpACdata = simoutPack.logsout;
Vals = getValuesFromLogsout(simoutPack.logsout.get("EnergyCons"));
NEDChiTpAC.EnergyCons = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("EM1energy"));
NEDChiTpAC.EM1energy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("EM2energy"));
NEDChiTpAC.EM2energy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("HVACenergy"));
NEDChiTpAC.HVACenergy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("AuxEnergy"));
NEDChiTpAC.AuxEnergy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("Distance"));
NEDChiTpAC.Distance = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("RangeRating"));
NEDChiTpAC.RangeRating = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("Energy"));
NEDChiTpAC.Energy = Vals.Data(end);

%% Sub Zero run with AC off
vehicleThermal.AConoff=0;          % AC on/off variable, 0 AC off, 1 AC On

% Run the simulation for the specified Simulation time
simoutPack=sim('BEVsystemModel','StopTime',SimulationTime);
bdclose('BEVsystemModel');
timeDetailed=simoutPack.SimulationMetadata.TimingInfo.ExecutionElapsedWallTime;

% record data
NEDChiTpNoACdata = simoutPack.logsout;
Vals = getValuesFromLogsout(simoutPack.logsout.get("EnergyCons"));
NEDChiTpNoAC.EnergyCons = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("EM1energy"));
NEDChiTpNoAC.EM1energy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("EM2energy"));
NEDChiTpNoAC.EM2energy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("HVACenergy"));
NEDChiTpNoAC.HVACenergy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("AuxEnergy"));
NEDChiTpNoAC.AuxEnergy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("Distance"));
NEDChiTpNoAC.Distance = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("RangeRating"));
NEDChiTpNoAC.RangeRating = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("Energy"));
NEDChiTpNoAC.Energy = Vals.Data(end);

%% Save the data to mat file
proj = matlab.project.rootProject;
save(proj.RootFolder+'\Workflow\RangeEstimation\NEDCrangeData.mat', ...
      'NEDCloTpAC','NEDCloTpNoAC','NEDChiTpAC','NEDChiTpNoAC')
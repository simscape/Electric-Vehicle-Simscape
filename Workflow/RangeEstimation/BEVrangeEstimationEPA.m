%% EPA range estimation workflow

% Copyright 2022 - 2023 The MathWorks, Inc.

%% Setup the model for EPA cycle

open_system("BEVsystemModel")
SetupPlantElectroThermal;
load('EPADriveCycle.mat')
driveCycle='DriveCycleEPA'; % drive cycle type, choose from drive cycle source block in model
SimulationTime=inf; % drive simulation time, put as per the drive cycle selection
speedBlock=find_system('BEVsystemModel','Name','Drive Cycle Source');
set(getSimulinkBlockHandle(speedBlock),'cycleVar','Workspace Variable' ...
    ,'wsVar',driveCycle,'srcUnit','km/h');

vehicleThermal.CabinSpTp=15 +273.15;
vehicleThermal.cabin_T_init=15 +273.15;
vehicleThermal.AConoff=1;
vehicleThermal.coolant_T_init=15 +273.15;
vehicleThermal.ambient=15+273.15;       

%% Cell Electrical
battery.T_vec=[278 293 313];                 % [K] Temperature vector T
battery.AH=34;    % [Ahr] Cell capacity 
battery.AH_vec=[0.9*battery.AH battery.AH 0.9*battery.AH];    % [Ahr] Cell capacity vector AH(T)
battery.SOC_vec=[0, .1, .25, .5, .75, .9, 1]; % Cell state of charge vector SOC [-]
battery.initialPackSOC=0.98;	% Pack intial SOC (-)

% Load module data
batt_BatteryManagementSystem_param;
batt_packBTMSExampleLib_param;


%% the model is setup to stop simulation when the SoC value reaches '0'
% Run the simulation for the specified Simulation time 
simoutPack=sim('BEVsystemModel','StopTime','inf');
bdclose('BEVsystemModel');
timeDetailed=simoutPack.SimulationMetadata.TimingInfo.ExecutionElapsedWallTime;

% record data
EPArangedata = simoutPack.logsout;
Vals = getValuesFromLogsout(simoutPack.logsout.get("EnergyCons"));
EPArange.EnergyCons = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("EM1energy"));
EPArange.EM1energy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("EM2energy"));
EPArange.EM2energy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("HVACenergy"));
EPArange.HVACenergy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("AuxEnergy"));
EPArange.AuxEnergy = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("Distance"));
EPArange.Distance = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("RangeRating"));
EPArange.RangeRating = Vals.Data(end);
Vals = getValuesFromLogsout(simoutPack.logsout.get("Energy"));
EPArange.Energy = Vals.Data(end);

%% Save the data to mat file
proj = matlab.project.rootProject;
save(proj.RootFolder+'\Workflow\RangeEstimation\EPArangedata.mat','EPArange')
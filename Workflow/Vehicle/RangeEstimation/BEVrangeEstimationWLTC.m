%% WLTC range calculation workflow
% BEV model is run with WLTC cycle
% Four scenarios are run
% 1. -20 degC ambient with AC ON
% 2. -20 degC ambient with AC OFF
% 3. 35 degC ambient with AC ON
% 4. 35 degC ambient with AC OFF
% To see the effect of ambient temperature and cooling on range
%
% Copyright 2022 - 20 25 The MathWorks, Inc.

%% WLTC range calculation workflow

mdl = "BEVsystemModel";
open_system(mdl);

%% Setup the model for WLTC cycle
SetupPlantElectroThermal;     % Setup plant for ElectroThermal configuration
BEVSystemModelParams;         % Load model parameters

driveCycle      = 'WLTP Class 3'; % drive cycle type, choose from drive cycle source block in model
SimulationTime  = "1800";         % drive simulation time, put as per the drive cycle selection
speedBlock = find_system(mdl, ...
    'MatchFilter', @Simulink.match.allVariants, ...
    'Name', 'Drive Cycle Source'); % Get the block handle

% Select drive cycle if available
try
    set(getSimulinkBlockHandle(speedBlock),'cycleVar',driveCycle);
catch
    error('To run this simulation, install the Powertrain Blockset Drive Profile Data');
end

% Battery setting
battery.T_vec=[278 293 313];                 % Temperature vector T [K]
battery.AH=34;                               % Cell capacity [Ahr]
battery.AH_vec=[0.9*battery.AH battery.AH 0.9*battery.AH];    % Cell capacity vector AH(T) [Ahr]
battery.SOC_vec=[0, .1, .25, .5, .75, .9, 1]; % Cell state of charge vector SOC [-]
battery.initialPackSOC=0.75;                 % Pack intial SOC (-)

% Run parameter file for battery
batt_BatteryManagementSystem_param;
batt_packBTMSExampleLib_param;

% Baseline simIn
baseIn = Simulink.SimulationInput(mdl);
baseIn = baseIn.setModelParameter('StopTime', SimulationTime);

% Base workspace vars
baseIn = baseIn.setVariable('battery', battery);
baseIn = baseIn.setVariable('vehicleThermal', vehicleThermal);  % current struct from params

%%  Scenario runner
runScenario = @(vehicleThermal) sim( baseIn.setVariable('vehicleThermal', vehicleThermal) );

extractWLTC = @(simoutPack) localExtractWLTC(simoutPack);

%% Scenario 1: -20C, AC ON
vehicleThermal.ambient          = -20 + 273.15;
vehicleThermal.coolant_T_init   = -20 + 273.15;
vehicleThermal.CabinSpTp        =  20 + 273.15;
vehicleThermal.cabin_T_init     = -20 + 273.15;
vehicleThermal.AConoff          = 1;

simoutPack = runScenario(vehicleThermal);

WLTCloTpACdata = simoutPack.logsout;
WLTCloTpAC     = extractWLTC(simoutPack);

%% Scenario 2: -20C, AC OFF
vehicleThermal.AConoff = 0;

simoutPack = runScenario(vehicleThermal);

WLTCloTpNoACdata = simoutPack.logsout;
WLTCloTpNoAC     = extractWLTC(simoutPack);

%% Scenario 3: 35C, AC ON
vehicleThermal.ambient          = 35 + 273.15;
vehicleThermal.coolant_T_init   = 35 + 273.15;
vehicleThermal.CabinSpTp        = 20 + 273.15;
vehicleThermal.cabin_T_init     = 35 + 273.15;
vehicleThermal.AConoff          = 1;

simoutPack = runScenario(vehicleThermal);

WLTChiTpACdata = simoutPack.logsout;
WLTChiTpAC     = extractWLTC(simoutPack);

%% Scenario 4: 35C, AC OFF
vehicleThermal.AConoff = 0;

simoutPack = runScenario(vehicleThermal);
timeDetailed = simoutPack.SimulationMetadata.TimingInfo.ExecutionElapsedWallTime;

WLTChiTpNoACdata = simoutPack.logsout;
WLTChiTpNoAC     = extractWLTC(simoutPack);

bdclose(mdl);

%% Save the data to mat file
proj = matlab.project.rootProject;
save(proj.RootFolder + "\Workflow\Vehicle\RangeEstimation\WLTCrangeData.mat", ...
     'WLTCloTpAC','WLTCloTpNoAC','WLTChiTpAC','WLTChiTpNoAC');

%% -------- Local function --------
function out = localExtractWLTC(simoutPack)
    lo = simoutPack.logsout;

    Vals = getValuesFromLogsout(lo.get("EnergyCons"));  out.EnergyCons  = Vals.Data(end);
    Vals = getValuesFromLogsout(lo.get("EM1energy"));   out.EM1energy   = Vals.Data(end);
    Vals = getValuesFromLogsout(lo.get("EM2energy"));   out.EM2energy   = Vals.Data(end);
    Vals = getValuesFromLogsout(lo.get("HVACenergy"));  out.HVACenergy  = Vals.Data(end);
    Vals = getValuesFromLogsout(lo.get("AuxEnergy"));   out.AuxEnergy   = Vals.Data(end);
    Vals = getValuesFromLogsout(lo.get("Distance"));    out.Distance    = Vals.Data(end);
    Vals = getValuesFromLogsout(lo.get("RangeRating")); out.RangeRating = Vals.Data(end);
    Vals = getValuesFromLogsout(lo.get("Energy"));      out.Energy      = Vals.Data(end);
end

% Auto-generated BEV model creator script
% Generated: 2026-04-20 14:46:07
% Vehicle block detected at export: BEVsystemModel/Vehicle
% Control block detected at export: BEVsystemModel/Controller
% Copyright 2026 The MathWorks, Inc.

% ---- Project root and model path ----
try root = matlab.project.rootProject().RootFolder; catch, root = pwd; end
topModelName = 'BEVsystemModel';
topModelFile = fullfile(root, 'Model', 'BEVsystemModel.slx');

% ---- Open model ----
open_system(topModelFile);

% ---- Set Vehicle template and Control ----
vehBlk    = 'BEVsystemModel/Vehicle';
controlBlk = 'BEVsystemModel/Controller';
vehTarget = 'VehicleElectroThermal';
setRef(vehBlk, vehTarget);
saveAll(topModelName);

% ---- Apply component references ----
setRef('BEVsystemModel/Vehicle/Battery', 'BatteryTableBased');
alignMaskFields('BEVsystemModel/Vehicle/Battery', {'T_vec','AH','AH_vec','SOC_vec','initialPackSOC','cRate','coolant_pipe_D'}, {'battery','battery','battery','battery','battery','battery','battery'});
setRef('BEVsystemModel/Vehicle/Rear Motor (EM2)', 'MotorDriveGearTh');
alignMaskFields('BEVsystemModel/Vehicle/Rear Motor (EM2)', {'max_torque','max_power','Tctc','motor_loss_map','coolant_channel_D'}, {'electricDrive','electricDrive','electricDrive','electricDrive','electricDrive'});
setRef('BEVsystemModel/Vehicle/Front Motor (EM1)', 'MotorDriveGearTh');
alignMaskFields('BEVsystemModel/Vehicle/Front Motor (EM1)', {'max_torque','max_power','Tctc','motor_loss_map','coolant_channel_D'}, {'electricDrive','electricDrive','electricDrive','electricDrive','electricDrive'});
setRef('BEVsystemModel/Vehicle/HVAC', 'HVACsimpleTh');
alignMaskFields('BEVsystemModel/Vehicle/HVAC', {'cabin_duct_area','cabin_duct_volume'}, {'HVAC','HVAC'});
setRef('BEVsystemModel/Vehicle/Charger', 'ChargerThermal');
alignMaskFields('BEVsystemModel/Vehicle/Charger', {'MaxVolt','Kp','Ki','Kaw','CC_A','coolant_channel_D'}, {'batteryCharger','batteryCharger','batteryCharger','batteryCharger','batteryCharger','batteryCharger'});
setRef('BEVsystemModel/Vehicle/Chiller', 'Chiller');
alignMaskFields('BEVsystemModel/Vehicle/Chiller', {'chillerMaxPower','coolant_pipe_D'}, {'chiller','chiller'});
setRef('BEVsystemModel/Vehicle/Heater', 'Heater');
alignMaskFields('BEVsystemModel/Vehicle/Heater', {'heaterMaxPower','coolant_pipe_D','coolant_channel_D'}, {'batteryHeater','batteryHeater','batteryHeater'});
setRef('BEVsystemModel/Vehicle/Driveline', 'Driveline');
alignMaskFields('BEVsystemModel/Vehicle/Driveline', {'tireRollingRadius_cm','vehMass_kg','MaxSpeed','BrakeFactor'}, {'driveline','driveline','driveline','vehicle'});
setRef('BEVsystemModel/Vehicle/Battery Pump', 'Pump');
alignMaskFields('BEVsystemModel/Vehicle/Battery Pump', {'pump_displacement','pump_speed_max','coolant_pipe_D'}, {'pump','pump','pump'});
setRef('BEVsystemModel/Vehicle/Motor Pump', 'Pump');
alignMaskFields('BEVsystemModel/Vehicle/Motor Pump', {'pump_displacement','pump_speed_max','coolant_pipe_D'}, {'pump','pump','pump'});
setRef('BEVsystemModel/Vehicle/DCDC', 'PumpDriverTh');
alignMaskFields('BEVsystemModel/Vehicle/DCDC', {'outputVoltage','outputPower','coolant_pipe_D','coolant_channel_D'}, {'pumpDriver','pumpDriver','pumpDriver','pumpDriver'});
setRef('BEVsystemModel/Vehicle/Radiator', 'Radiator');
alignMaskFields('BEVsystemModel/Vehicle/Radiator', {'L','W','H','N_tubes','tube_H','fin_spacing','wall_thickness','wall_conductivity','gap_H','air_area_flow','air_area_primary','N_fins','air_area_fins','tube_Leq','fan_area','duct_area','coolant_pipe_D'}, {'radiator','radiator','radiator','radiator','radiator','radiator','radiator','radiator','radiator','radiator','radiator','radiator','radiator','radiator','radiator','radiator','radiator'});
setRef('BEVsystemModel/Controller', 'Controller');
set_param('BEVsystemModel/Drive Cycle Source','cycleVar','FTP72');
saveAll(topModelName);
disp('Setup complete and saved.');

% ================= Helpers =================
function setRef(blockPath, refTarget)
    set_param(blockPath, 'ReferencedSubsystem', refTarget);
end

function saveAll(mdl)
    try save_system(mdl, 'SaveDirtyReferencedModels', 'on');
    catch, save_system(mdl);
    end
end

function alignMaskFields(blockPath, targetFields, targetNs)
% Field-aware mask alignment with per-field namespace.
% targetFields and targetNs are parallel cell arrays from the param file.
% For each mask value of form ns.field, if field is in targetFields,
% rewrite to targetNs{idx}.field. Leaves all other values unchanged.
    mask = Simulink.Mask.get(blockPath);
    if isempty(mask) || isempty(mask.Parameters), return; end
    for k = 1:numel(mask.Parameters)
        val = strtrim(mask.Parameters(k).Value);
        tok = regexp(val, '^([A-Za-z]\w*)\.([A-Za-z]\w*)$', 'tokens', 'once');
        if isempty(tok), continue; end
        varName = tok{2};
        idx = find(strcmp(varName, targetFields), 1);
        if ~isempty(idx)
            mask.Parameters(k).Value = [targetNs{idx} '.' varName];
        end
    end
end

% Auto-generated BEV model creator script
% Generated: 2026-04-20 15:09:50
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
vehTarget = 'VehicleElectric';
setRef(vehBlk, vehTarget);
saveAll(topModelName);

% ---- Apply component references ----
setRef('BEVsystemModel/Vehicle/Battery', 'BatteryLumped');
alignMaskFields('BEVsystemModel/Vehicle/Battery', {'T_vec','AH','AH_vec','SOC_vec','initialPackSOC','cRate'}, {'battery','battery','battery','battery','battery','battery'});
setRef('BEVsystemModel/Vehicle/Rear Motor (EM2)', 'MotorDriveGear');
alignMaskFields('BEVsystemModel/Vehicle/Rear Motor (EM2)', {'max_torque','max_power','Tctc','motor_loss_map'}, {'electricDrive','electricDrive','electricDrive','electricDrive'});
setRef('BEVsystemModel/Vehicle/Front Motor (EM1)', 'MotorDriveGear');
alignMaskFields('BEVsystemModel/Vehicle/Front Motor (EM1)', {'max_torque','max_power','Tctc','motor_loss_map'}, {'electricDrive','electricDrive','electricDrive','electricDrive'});
setRef('BEVsystemModel/Vehicle/Charger', 'Charger');
alignMaskFields('BEVsystemModel/Vehicle/Charger', {'MaxVolt','Kp','Ki','Kaw','CC_A'}, {'batteryCharger','batteryCharger','batteryCharger','batteryCharger','batteryCharger'});
setRef('BEVsystemModel/Vehicle/Driveline', 'Driveline');
alignMaskFields('BEVsystemModel/Vehicle/Driveline', {'tireRollingRadius_cm','vehMass_kg','MaxSpeed','BrakeFactor'}, {'driveline','driveline','driveline','vehicle'});
setRef('BEVsystemModel/Controller', 'ControllerFRM');
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

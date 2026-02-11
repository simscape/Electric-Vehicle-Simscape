function cfg = BEV_configs()
% BEV_configs  (JSON → .m conversion)
% Returns a struct with the same schema and values as your JSON.
% Some components are structs with Instances/Models; others are just model lists.

cfg = struct();

% ---------------- VehicleElec ----------------
cfg.VehicleElec = struct();
cfg.VehicleElec.Description = "Electric Vehicle without Thermal";

cfg.VehicleElec.Components = struct();

cfg.VehicleElec.Components.BatteryHV = struct();
cfg.VehicleElec.Components.BatteryHV.Instances = ["Battery"];
cfg.VehicleElec.Components.BatteryHV.Models    = ["BatteryLumped","BatteryLumpedThermal","BatteryTableBased"];

cfg.VehicleElec.Components.MotorDrive = struct();
cfg.VehicleElec.Components.MotorDrive.Instances = ["Rear Motor (EM2)", "Front Motor (EM1)"];
cfg.VehicleElec.Components.MotorDrive.Models    = ["MotorDriveGear","MotorDriveGear_NoTh"];

cfg.VehicleElec.Components.Charger = struct();
cfg.VehicleElec.Components.Charger.Instances = ["Charger"];
cfg.VehicleElec.Components.Charger.Models    = ["Charger"];

cfg.VehicleElec.Components.HVAC = struct();
cfg.VehicleElec.Components.HVAC.Instances = ["HVAC"];
cfg.VehicleElec.Components.HVAC.Models    = ["HVACNoCoolant"];

cfg.VehicleElec.Components.Chiller = struct();
cfg.VehicleElec.Components.Chiller.Instances = ["Chiller"];
cfg.VehicleElec.Components.Chiller.Models    = ["ChillerNoCoolant"];

% ---------------- VehicleElectroThermal ----------------
cfg.VehicleElectroThermal = struct();
cfg.VehicleElectroThermal.Description = "Electric Vehicle with Full Thermal";

cfg.VehicleElectroThermal.Components = struct();

cfg.VehicleElec.Components.BatteryHV = struct();
cfg.VehicleElec.Components.BatteryHV.Instances = ["Battery"];
cfg.VehicleElec.Components.BatteryHV.Models    = ["BatteryLumped","BatteryLumpedThermal","BatteryTableBased"];

cfg.VehicleElectroThermal.Components.MotorDrive = struct();
cfg.VehicleElectroThermal.Components.MotorDrive.Instances = ["FrontMotor", "RearMotor", "RearMotor2", "RearMotor3"];
cfg.VehicleElectroThermal.Components.MotorDrive.Models    = ["MotorDriveGear","MotorDriveGear_NoTh"];

% In JSON: "HVAC": ["HVACthermal","HVACEmpiricalRef"]
cfg.VehicleElectroThermal.Components.HVAC = ["HVACthermal","HVACEmpiricalRef"];

% ---------------- VehicleElectric ----------------
cfg.VehicleElectric = struct();
cfg.VehicleElectric.Description = "Electric Vehicle without Thermal";

cfg.VehicleElectric.Components = struct();

cfg.VehicleElectric.Components.BatteryHV = struct();
cfg.VehicleElectric.Components.BatteryHV.Instances = ["Battery"];
cfg.VehicleElectric.Components.BatteryHV.Models    = ["BatteryLumped","BatteryLumpedThermal","BatteryTableBased"];

cfg.VehicleElectric.Components.MotorDrive = struct();
cfg.VehicleElectric.Components.MotorDrive.Instances = ["Rear Motor (EM2)", "Front Motor (EM1)"];
cfg.VehicleElectric.Components.MotorDrive.Models    = ["MotorDriveGear","MotorDriveGear_NoTh"];

cfg.VehicleElec.Components.Charger = struct();
cfg.VehicleElec.Components.Charger.Instances = ["Charger"];
cfg.VehicleElec.Components.Charger.Models    = ["Charger"];

end

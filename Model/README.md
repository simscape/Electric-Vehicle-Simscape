# Model

System-level vehicle model and configuration for the BEV Simscape project. `BEVsystemModel.slx` assembles components from `Components/` via subsystem references.

---

## Folder Structure

```
Model/
  BEVsystemModel.slx              - Main system model (top-level wiring diagram)
  VehicleTemplateConfig.json       - Template-to-component fidelity mapping
  ThermalDesignSolutionConfig.json - Thermal design solution mapping
  VehicleTemplate/                 - Pre-configured vehicle templates
  Display/                         - Energy flow display subsystems
```

Vehicle templates are documented in [VehicleTemplate/README.md](VehicleTemplate/README.md). Display models (`EnergyElectric`, `EnergyElectroThermal`) provide energy flow visualization during simulation.

---

## VehicleTemplateConfig.json

Maps each vehicle template to its component fidelity selections:

| Component | VehicleElectric | VehicleElecAux | VehicleElectroThermal |
|-----------|----------------|----------------|----------------------|
| BatteryHV | BatteryLumped | BatteryLumped | BatteryTableBased, BatteryLumpedThermal |
| MotorDrive | MotorDriveGear | MotorDriveGear | MotorDriveGearTh, MotorDriveLube |
| Charger | Charger, ChargerDummy | Charger, ChargerDummy | ChargerThermal, ChargerThermalDummy |
| Controller | ControllerFRM | ControllerHVAC | Controller |
| Driveline | Driveline, DrivelineWithBraking | Driveline, DrivelineWithBraking | Driveline, DrivelineWithBraking |
| HVAC | -- | HVACsimpleTh, HVACEmpiricalRef | HVACsimpleTh, HVACEmpiricalRef |
| Chiller | -- | -- | Chiller |
| BatteryHeater | -- | -- | Heater |

## ThermalDesignSolutionConfig.json

Defines the thermal-only design solution for `VehicleElectroThermal`:

| Component | VehicleElectroThermal |
|-----------|-----------------|
| BatteryHV | BatteryTableBased, BatteryLumpedThermal |
| MotorDrive | MotorDriveGear, MotorDriveLube |
| Charger | ChargerThermal |
| HVAC | HVACsimpleTh, HVACEmpiricalRef |
| Chiller | Chiller |
| BatteryHeater | Heater |
| Driveline | Driveline, DrivelineWithBraking |

Copyright 2026 The MathWorks, Inc.

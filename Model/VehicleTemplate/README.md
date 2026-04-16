# Vehicle Templates

Pre-configured vehicle models at different fidelity levels. Each template is a complete vehicle assembled from components in `Components/` via subsystem references. Templates differ in which components are included and which fidelity level is used for each.

---

## Templates

| Template | Description | Thermal | Auxiliary |
|----------|-------------|:-------:|:---------:|
| VehicleElectric | Minimal electrical powertrain -- battery, motor, charger, driveline | No | No |
| VehicleElecAux | Electrical powertrain with HVAC and auxiliary loads | No | Yes |
| VehicleElectroThermal | Full electro-thermal vehicle with coolant loop, chiller, heater, radiator | Yes | Yes |
| VehicleElectroThermalLowTemp | Electro-thermal configured for cold-climate studies | Yes | Yes |

---

## Component Fidelity Selection

Each template selects component fidelities appropriate to its simulation scope:

| Component | VehicleElectric | VehicleElecAux | VehicleElectroThermal |
|-----------|----------------|----------------|----------------------|
| BatteryHV | BatteryLumped | BatteryLumped | BatteryTableBased / BatteryLumpedThermal |
| MotorDrive | MotorDriveGear | MotorDriveGear | MotorDriveGearTh / MotorDriveLube |
| Controller | ControllerFRM | ControllerHVAC | Controller |
| Charger | Charger | Charger | ChargerThermal |
| HVAC | -- | HVACsimpleTh | HVACsimpleTh |
| Chiller | -- | -- | Chiller |
| BatteryHeater | -- | -- | Heater |

Fidelity mapping is defined in config JSON files under `APP/Config/Preset/`.

Copyright 2026 The MathWorks, Inc.

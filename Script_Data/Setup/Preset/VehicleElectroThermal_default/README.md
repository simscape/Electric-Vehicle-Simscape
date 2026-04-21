# VehicleElectroThermal — Default Preset

Full electro-thermal vehicle model with thermal-aware battery, motor-drives, charger, and complete coolant loop (radiator, chiller, heater, pumps). Use this preset for thermal management studies, cold-start and hot-climate scenarios, coolant flow analysis, and evaluating how thermal conditions affect range and component performance.

## Build Overview

| Field | Value |
|-------|-------|
| Timestamp | 2026-04-20 14:46:02 |
| Model | BEVsystemModel |
| Model Path | Model/BEVsystemModel.slx |

## Selected Template

| Field | Value |
|-------|-------|
| Template | VehicleElectroThermal |
| Config Source | APP/Config/Preset/VehicleTemplateConfig.json |
| Description | Electric Vehicle with Full Thermal |

## Model Configuration

| Instance | Selection |
|----------|-----------|
| Battery | BatteryTableBased |
| Rear Motor (EM2) | MotorDriveGearTh |
| Front Motor (EM1) | MotorDriveGearTh |
| HVAC | HVACsimpleTh |
| Charger | ChargerThermal |
| Chiller | Chiller |
| Heater | Heater |
| Driveline | Driveline |
| Battery Pump | Pump |
| Motor Pump | Pump |
| DCDC | PumpDriverTh |
| Radiator | Radiator |
| Controller | Controller |
| Drive Cycle | FTP75 |

## Loaded Parameter Files

| Instance | Parameter File | Namespace | Path | Type |
|----------|---------------|-----------|------|------|
| Battery | BatteryTableBasedParams | battery | Components/BatteryHV/Model/BatteryTableBasedParams.m | Default |
| Rear Motor (EM2) | MotorDriveGearThParams | electricDrive | Components/MotorDrive/Model/MotorDriveGearThParams.m | Default |
| Front Motor (EM1) | MotorDriveGearThParams | electricDrive | Components/MotorDrive/Model/MotorDriveGearThParams.m | Default |
| HVAC | HVACsimpleThParams | HVAC | Components/HVAC/Model/HVACsimpleThParams.m | Default |
| Charger | ChargerThermalParams | batteryCharger | Components/Charger/Model/ChargerThermalParams.m | Default |
| Chiller | ChillerParams | chiller | Components/Chiller/Model/ChillerParams.m | Default |
| Heater | HeaterParams | batteryHeater | Components/BatteryHeater/Model/HeaterParams.m | Default |
| Driveline | DrivelineParams | driveline | Components/Driveline/Model/DrivelineParams.m | Default |
| Battery Pump | PumpParams | pump | Components/Pump/Model/PumpParams.m | Default |
| Motor Pump | PumpParams | pump | Components/Pump/Model/PumpParams.m | Default |
| DCDC | PumpDriverThParams | pumpDriver | Components/PumpDriver/Model/PumpDriverThParams.m | Default |
| Radiator | RadiatorParams | radiator | Components/Radiator/Model/RadiatorParams.m | Default |

## Environment and Dashboard Settings

| Setting | Value |
|---------|-------|
| Ambient Temp | 25 C |
| Cabin Setpoint | 20 C |
| Ambient Pressure | 1 atm |
| Relative Humidity | 0.3 |
| CO2 Fraction | 0.0004 |
| AC Enabled | On |
| AC On | Off |
| AWD | On |
| Regen | On |
| Charging | Off |

## Generated Files

| File | Path |
|------|------|
| BEVsystemModel_ssr_setup.m | Script_Data/Setup/Preset/VehicleElectroThermal_default/BEVsystemModel_ssr_setup.m |
| BEVsystemModel_params_setup.m | Script_Data/Setup/Preset/VehicleElectroThermal_default/BEVsystemModel_params_setup.m |
| README.md | Script_Data/Setup/Preset/VehicleElectroThermal_default/README.md |


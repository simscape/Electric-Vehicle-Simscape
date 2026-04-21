# VehicleElecAux — Default Preset

Electric powertrain with auxiliary systems including HVAC, coolant pumps, and pump driver. Use this preset to study cabin comfort impact on range, auxiliary power draw, and HVAC control strategies. Thermal fluid loops are not modeled — component thermal behavior uses simplified empirical models.

## Build Overview

| Field | Value |
|-------|-------|
| Timestamp | 2026-04-20 15:02:19 |
| Model | BEVsystemModel |
| Model Path | Model/BEVsystemModel.slx |

## Selected Template

| Field | Value |
|-------|-------|
| Template | VehicleElecAux |
| Config Source | APP/Config/Preset/VehicleTemplateConfig.json |
| Description | Electric Vehicle with Auxiliary (HVAC, pumps) and without Thermal |

## Model Configuration

| Instance | Selection |
|----------|-----------|
| Battery | BatteryLumped |
| Rear Motor (EM2) | MotorDriveGear |
| Front Motor (EM1) | MotorDriveGear |
| Charger | Charger |
| HVAC | HVACsimpleTh |
| Driveline | Driveline |
| Battery Pump | PumpDummy |
| Motor Pump | PumpDummy |
| DCDC | PumpDriver |
| Controller | ControllerHVAC |
| Drive Cycle | FTP75 |

## Loaded Parameter Files

| Instance | Parameter File | Namespace | Path | Type |
|----------|---------------|-----------|------|------|
| Battery | BatteryLumpedParams | battery | Components/BatteryHV/Model/BatteryLumpedParams.m | Default |
| Rear Motor (EM2) | MotorDriveGearParams | electricDrive | Components/MotorDrive/Model/MotorDriveGearParams.m | Default |
| Front Motor (EM1) | MotorDriveGearParams | electricDrive | Components/MotorDrive/Model/MotorDriveGearParams.m | Default |
| Charger | ChargerParams | batteryCharger | Components/Charger/Model/ChargerParams.m | Default |
| HVAC | HVACsimpleThParams | HVAC | Components/HVAC/Model/HVACsimpleThParams.m | Default |
| Driveline | DrivelineParams | driveline | Components/Driveline/Model/DrivelineParams.m | Default |
| Battery Pump | PumpDummyParams | pump | Components/Pump/Model/PumpDummyParams.m | Default |
| Motor Pump | PumpDummyParams | pump | Components/Pump/Model/PumpDummyParams.m | Default |
| DCDC | PumpDriverParams | pumpDriver | Components/PumpDriver/Model/PumpDriverParams.m | Default |

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
| BEVsystemModel_ssr_setup.m | Script_Data/Setup/Preset/VehicleElecAux_default/BEVsystemModel_ssr_setup.m |
| BEVsystemModel_params_setup.m | Script_Data/Setup/Preset/VehicleElecAux_default/BEVsystemModel_params_setup.m |
| README.md | Script_Data/Setup/Preset/VehicleElecAux_default/README.md |


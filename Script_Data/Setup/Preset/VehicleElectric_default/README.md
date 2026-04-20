# VehicleElectric — Default Preset

Basic electric powertrain with battery, dual motor-drives, charger, and driveline. No thermal management or auxiliary systems. Use this preset for pure electrical studies such as range estimation, drive cycle analysis, and powertrain sizing where thermal effects are not required.

## Build Overview

| Field | Value |
|-------|-------|
| Timestamp | 2026-04-20 15:09:40 |
| Model | BEVsystemModel |
| Model Path | Model/BEVsystemModel.slx |

## Selected Template

| Field | Value |
|-------|-------|
| Template | VehicleElectric |
| Config Source | APP/Config/Preset/VehicleTemplateConfig.json |
| Description | Electric Vehicle without Thermal and Auxiliary |

## Model Configuration

| Instance | Selection |
|----------|-----------|
| Battery | BatteryLumped |
| Rear Motor (EM2) | MotorDriveGear |
| Front Motor (EM1) | MotorDriveGear |
| Charger | Charger |
| Driveline | Driveline |
| Controller | ControllerFRM |
| Drive Cycle | FTP72 |

## Loaded Parameter Files

| Instance | Parameter File | Namespace | Path | Type |
|----------|---------------|-----------|------|------|
| Battery | BatteryLumpedParams | battery | Components/BatteryHV/Model/BatteryLumpedParams.m | Default |
| Rear Motor (EM2) | MotorDriveGearParams | electricDrive | Components/MotorDrive/Model/MotorDriveGearParams.m | Default |
| Front Motor (EM1) | MotorDriveGearParams | electricDrive | Components/MotorDrive/Model/MotorDriveGearParams.m | Default |
| Charger | ChargerParams | batteryCharger | Components/Charger/Model/ChargerParams.m | Default |
| Driveline | DrivelineParams | driveline | Components/Driveline/Model/DrivelineParams.m | Default |

## Environment and Dashboard Settings

| Setting | Value |
|---------|-------|
| Ambient Temp | 25 C |
| Cabin Setpoint | 20 C |
| Ambient Pressure | 1 atm |
| Relative Humidity | 0.3 |
| CO2 Fraction | 0.0004 |
| AC Enabled | Off |
| AC On | Off |
| AWD | On |
| Regen | On |
| Charging | Off |

## Generated Files

| File | Path |
|------|------|
| BEVsystemModel_ssr_setup.m | Script_Data/Setup/Preset/VehicleElectric_default/BEVsystemModel_ssr_setup.m |
| BEVsystemModel_params_setup.m | Script_Data/Setup/Preset/VehicleElectric_default/BEVsystemModel_params_setup.m |
| README.md | Script_Data/Setup/Preset/VehicleElectric_default/README.md |


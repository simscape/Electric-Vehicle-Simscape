# Preset

Read-only design scenario files used by the BEV App. Each file maps vehicle templates to their allowed components, fidelities, and controllers.

## Files

| File | Vehicle Templates | Description |
|------|-------------------|-------------|
| `VehicleTemplateConfig.json` | VehicleElectric, VehicleElecAux, VehicleElectroThermal | Main config covering all three templates |
| `ThermalDesignSolutionConfig.json` | VehicleElectroThermal | Thermal-focused config with reduced charger options |

## Structure

Each JSON file contains one or more vehicle template keys. Each template defines:

| Field | Purpose |
|-------|---------|
| `Description` | Short description shown in the app |
| `Components` | Component types, their instances, and available fidelities |
| `Controls` | Controller instances and available controller models |
| `SystemParameter` | Parameter file run at system level (`NA` if none) |

## Vehicle Templates

| Template | Components | Controller |
|----------|------------|------------|
| VehicleElectric | BatteryHV, MotorDrive, Charger, Driveline | ControllerFRM |
| VehicleElecAux | BatteryHV, MotorDrive, Charger, HVAC, Driveline, Pump, PumpDriver | ControllerHVAC |
| VehicleElectroThermal | BatteryHV, MotorDrive, HVAC, Charger, Chiller, BatteryHeater, Driveline, Pump, PumpDriver, Radiator | Controller |

## Adding a New Preset

1. Create a JSON file following the same structure.
2. Place it in this folder.
3. It will appear in the Design Scenario dropdown automatically.

Do not edit preset files to save user selections. Use **Save Setup** in the app instead, which writes to `../User/`.

Copyright 2022 - 2025 The MathWorks, Inc.

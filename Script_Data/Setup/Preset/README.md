# Setup Presets

Default model setups for each vehicle template. Each folder contains everything needed to configure and run the BEV system model with one command.

## Presets

| Folder | Template | Description |
|--------|----------|-------------|
| `VehicleElectric_default` | VehicleElectric | Basic electric powertrain (battery, motors, charger, driveline). No thermal. |
| `VehicleElecAux_default` | VehicleElecAux | Electric powertrain with auxiliary systems (HVAC, pumps). No thermal loop. |
| `VehicleElectroThermal_default` | VehicleElectroThermal | Full electro-thermal model with coolant loop (radiator, chiller, heater, pumps). |

## Files in Each Preset

| File | Purpose |
|------|---------|
| `applyPreset.m` | Run this to apply the preset. Calls the two scripts below. |
| `BEVsystemModel_ssr_setup.m` | Sets subsystem references to the correct component fidelities. |
| `BEVsystemModel_params_setup.m` | Loads all component parameter files and sets environment values. |
| `README.md` | Build summary showing selected fidelities, parameter files, and settings. |

## Usage

```matlab
run('Script_Data/Setup/Preset/VehicleElectroThermal_default/applyPreset.m')
```

This sets up the model so it is ready to simulate. Pick the preset that matches your Vehicle Config.

Copyright 2022 - 2025 The MathWorks, Inc.

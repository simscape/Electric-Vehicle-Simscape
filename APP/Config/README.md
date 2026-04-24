# Config

JSON configuration files for the BEV Setup App.

## Folders

| Folder | Purpose |
|--------|---------|
| `Preset/` | Shipped template configs -- define which components and fidelities are available per vehicle template |
| `User/` | User-saved setups -- snapshot of a configured session including component selections, environment, and operating modes |

## Preset

Read-only configs that map vehicle templates to component fidelities. These drive the app dropdowns.

| File | Description |
|------|-------------|
| `VehicleTemplateConfig.json` | Main config with VehicleElectric, VehicleElecAux, and VehicleElectroThermal templates |
| `ThermalDesignSolutionConfig.json` | Thermal-focused config for VehicleElectroThermal |

## User

Created by the **Save Setup** button in the app. Each file is a superset of a preset config -- it includes the same component/model listings plus the user's selections, environment settings, and operating modes. User setups appear below a separator in the Config dropdown and can be loaded back to restore a full session.

Copyright 2022 - 2025 The MathWorks, Inc.

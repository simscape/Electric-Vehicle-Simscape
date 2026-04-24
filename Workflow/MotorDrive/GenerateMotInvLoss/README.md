# PMSM Loss Map Generation

Generate motor and inverter loss maps from a detailed PMSM field-oriented control simulation for use in system-level electro-thermal models.

| Item | Detail |
|------|--------|
| **Entry point** | `generateDULossMap.mlx` |
| **Template** | Standalone — uses its own detailed PMSM models |
| **Key outputs** | Motor loss map, inverter loss map, efficiency tables |

## Files

| File | Purpose |
|------|---------|
| `generateDULossMap.mlx` | Main live script — open this to run the workflow |
| `PMSMdetailTestbench.slx` | Detailed PMSM motor characterization model |
| `PMSMfocControlLossMapGen.slx` | FOC controller for loss map generation |
| `PMSMSystemParams.m` | PMSM system parameters |
| `getLossTable.m` | Loss table extraction utility |
| `getPMSMParams.m` | PMSM parameter parser (supports MotorCAD FEM exports) |
| `PMSMsaturationLossMap.mat` | Pre-computed saturation loss map |

Copyright 2022 - 2026 The MathWorks, Inc.

# Battery Sizing

Size the high-voltage battery pack to achieve a desired driving range by comparing packs with different capacities and weights.

| Item | Detail |
|------|--------|
| **Entry point** | `BEVBatterySizingMain.mlx` |
| **Template** | Any (calls `SetupPlantElectroThermal` internally) |
| **Drive cycle** | NEDC |
| **Key outputs** | Range vs battery capacity comparison, SOC profiles |

## Files

| File | Purpose |
|------|---------|
| `BEVBatterySizingMain.mlx` | Main live script — open this to run the workflow |
| `BEVbatterySizing.m` | Simulation setup and batch run logic |
| `NEDCsizingData.mat` | Pre-computed sizing results |
| `OpenBatterySizingLiveScript.m` | Helper to open the live script |

Copyright 2022 - 2026 The MathWorks, Inc.

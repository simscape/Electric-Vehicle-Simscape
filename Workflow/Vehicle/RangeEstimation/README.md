# Range Estimation

Estimate the on-road driving range of the BEV under different drive cycles and ambient conditions.

| Item | Detail |
|------|--------|
| **Entry point** | `BEVRangeEstimationMain.mlx` |
| **Template** | Any (calls `SetupPlantElectroThermal` internally) |
| **Drive cycles** | EPA, NEDC, WLTC |
| **Key outputs** | Range estimates per cycle, SOC depletion profiles, ambient condition comparison |

## Files

| File | Purpose |
|------|---------|
| `BEVRangeEstimationMain.mlx` | Main live script — open this to run the workflow |
| `BEVrangeEstimationEPA.m` | EPA cycle simulation runner |
| `BEVrangeEstimationNEDC.m` | NEDC cycle simulation runner |
| `BEVrangeEstimationWLTC.m` | WLTC cycle simulation runner |
| `EPADriveCycle.mat` | EPA drive cycle data |
| `EPArangedata.mat` | Pre-computed EPA range results |
| `NEDCrangeData.mat` | Pre-computed NEDC range results |
| `WLTCrangeData.mat` | Pre-computed WLTC range results |
| `OpenBEVrangeEstLiveScript.m` | Helper to open the live script |

Copyright 2022 - 2026 The MathWorks, Inc.

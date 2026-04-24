# Cell Characterization

Extract equivalent-circuit battery cell parameters from HPPC test data and verify against a drive profile.

| Item | Detail |
|------|--------|
| **Entry point** | `CellCharacterizationForBEV.mlx` |
| **Template** | Standalone — uses its own test models |
| **Key outputs** | Fitted cell parameters, verification plots against drive profile |

## Files

| File | Purpose |
|------|---------|
| `CellCharacterizationForBEV.mlx` | Main live script — open this to run the workflow |
| `CellCharacterizationHPPC.slx` | HPPC parameter extraction model |
| `CellCharacterizationVerify.slx` | Verification model against drive profile |
| `origCellDataHPPCdataGen.mat` | Raw HPPC test data |
| `driveProfileBatteryElectricVehicle400V.mat` | Drive profile for verification |
| `battCellCharacterizationResult.mat` | Pre-computed characterization results |

Copyright 2022 - 2026 The MathWorks, Inc.

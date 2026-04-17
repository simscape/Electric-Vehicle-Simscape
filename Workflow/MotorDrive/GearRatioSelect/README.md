# Gear Ratio Selection

Determine an efficient fixed gear ratio for the electric drive by sweeping gear ratios across drive cycles and evaluating motor thermal performance.

| Item | Detail |
|------|--------|
| **Entry point** | `minimumRequiredGearRatio.mlx` |
| **Template** | Electro-thermal (uses `MotorDriveThermalTestbench`) |
| **Drive cycles** | EUDC, US06 |
| **Key outputs** | Motor winding and magnet temperature vs gear ratio, optimal ratio selection |

## Files

| File | Purpose |
|------|---------|
| `minimumRequiredGearRatio.mlx` | Main live script — open this to run the workflow |
| `testThermalBenchRun.m` | Batch simulation runner for gear ratio sweep |
| `plotMotTemperature.m` | Temperature result plotting utility |
| `BatchRunTemp.mat` | Pre-computed batch run results |

Copyright 2022 - 2026 The MathWorks, Inc.

# Gear Ratio Selection

Compare candidate fixed gear ratios against winding and magnet thermal limits.

| Item | Detail |
|------|--------|
| **Entry point** | `minimumRequiredGearRatio.mlx` |
| **Template** | Electro-thermal (uses `MotorDriveThermalTestbench`) |
| **Drive cycles** | EUDC, US06 |
| **Key outputs** | Winding and magnet temperatures; thermal Pass/Fail for each ratio and cycle |

## Files

| File | Purpose |
|------|---------|
| `minimumRequiredGearRatio.mlx` | Main live script — open this to run the workflow |
| `testThermalBenchRun.m` | Batch simulation runner for gear ratio sweep |
| `plotMotTemperature.m` | Temperature result plotting utility |
| `BatchRunTemp.mat` | Pre-computed batch run results |

Copyright 2022 - 2026 The MathWorks, Inc.

# Inverter Power Module Life

Estimate inverter power module semiconductor lifetime from junction temperature cycling under drive cycle loads.

| Item | Detail |
|------|--------|
| **Entry point** | `inverterPowerModuleLife.mlx` |
| **Template** | Electro-thermal (uses `MotorDriveThermalTestbench`) |
| **Key outputs** | Junction temperature profiles, rainflow cycle counts, lifetime estimate |

## Files

| File | Purpose |
|------|---------|
| `inverterPowerModuleLife.mlx` | Main live script — open this to run the workflow |
| `InverterTestCycle.slx` | Inverter thermal test cycle model |
| `runInverterLife.m` | Simulation runner for inverter life estimation |
| `countEqTest.m` | Equivalent cycle counting (rainflow) |
| `getDutyLife.m` | Duty-based lifetime calculation |
| `InverterTemp.mat` | Pre-computed inverter temperature data |
| `TestCycleTemp.mat` | Pre-computed test cycle temperature data |

Copyright 2022 - 2026 The MathWorks, Inc.

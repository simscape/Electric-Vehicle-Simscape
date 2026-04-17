# Motor Drive Thermal Test Benches

Shared thermal test bench models used by the MotorDrive workflows (GearRatioSelect, InverterLife, ThermalDurability).

| Item | Detail |
|------|--------|
| **Entry point** | `MotorDriveThermalTestBenchDescription.mlx` |
| **Template** | Electro-thermal |
| **Key outputs** | Test bench documentation and parameter setup |

## Files

| File | Purpose |
|------|---------|
| `MotorDriveThermalTestBenchDescription.mlx` | Test bench description and usage guide |
| `MotorDriveThermalTestbench.slx` | System-level thermal test bench (used by GearRatio, Inverter, Durability workflows) |
| `MotorDriveDetailTestbench.slx` | Detailed PMSM test bench for characterization |
| `MotorDriveThermalTestBenchParams.m` | Parameter setup — calls ControllerParams, MotorDriveGearThParams, InverterThermalParams, DrivelineParams |
| `InverterParams.m` | Inverter electrical parameters |
| `InverterThermalParams.m` | Inverter thermal parameters |

Copyright 2022 - 2026 The MathWorks, Inc.

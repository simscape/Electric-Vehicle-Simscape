# Engineering Workflows

Run battery, motor-drive, vehicle-range, and driveline studies. Open `ElectricVehicleSimscape.prj` first, then follow the selected workflow's setup instructions.

## Workflow Inventory

| Domain | Workflow | Purpose | Entry point |
|--------|----------|---------|-------------|
| Battery | [Battery sizing](Battery/BatterySizing/README.md) | Compare battery capacity, mass, and range | `BEVBatterySizingMain.mlx` |
| Battery | [Virtual sensor](Battery/VirtualSensorNeuralNetModel/README.md) | Predict battery temperature with a neural network | `VirtualSensorNeuralNetModel.mlx` |
| MotorDrive | [Gear ratio selection](MotorDrive/GearRatioSelect/README.md) | Compare thermal Pass/Fail across candidate ratios | `minimumRequiredGearRatio.mlx` |
| MotorDrive | [Loss map generation](MotorDrive/GenerateMotInvLoss/README.md) | Generate PMSM and inverter loss maps | `generateDULossMap.mlx` |
| MotorDrive | [Inverter life](MotorDrive/InverterLife/README.md) | Estimate life from equivalent temperature cycles | `inverterPowerModuleLife.mlx` |
| MotorDrive | [Thermal durability](MotorDrive/ThermalDurability/README.md) | Evaluate winding and magnet thermal limits | `DUThermalDurability.mlx` |
| Vehicle | [Range estimation](Vehicle/RangeEstimation/README.md) | Compare range over EPA, NEDC, and WLTC cycles | `BEVRangeEstimationMain.mlx` |
| Driveline | [NVH](Driveline/DrivelineNVH/README.md) | Analyze order maps and optimize launch gear ratios | `generateOrderMap.mlx`, `optimizeVehicleLaunch.mlx` |

Motor-drive studies share the [thermal test benches](MotorDrive/Model/README.md).

## Before Running

- Load the workflow's parameter files and required drive-cycle profiles.
- Check operation-specific toolbox requirements.
- Distinguish bundled results from new simulation runs.
- Confirm input conditions and acceptance criteria before interpreting results.

Copyright 2022 - 2026 The MathWorks, Inc.

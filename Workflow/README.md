# Workflow

Design workflows and analysis scripts for the BEV project. Each workflow is a self-contained study organized by subsystem.

---

## Folder Structure

```
Workflow/
  Battery/
    BatterySizing/                  - Battery pack sizing for range targets
    CellCharacterization/           - Cell parameter extraction from HPPC data
    VirtualSensorNeuralNetModel/    - Neural network-based virtual battery sensor
  MotorDrive/
    GearRatioSelect/                - Optimal gear ratio sweep
    GenerateMotInvLoss/             - Motor and inverter loss map generation
    InverterLife/                    - Power module lifetime estimation
    Model/                          - Motor drive thermal and detailed test benches
    ScriptsData/                    - PMSM motor characterization scripts
    ThermalDurability/              - Drive unit thermal stress analysis
  Vehicle/
    RangeEstimation/                - Vehicle range over EPA, NEDC, WLTC drive cycles
```

---

## Workflow Inventory

### Battery

| Workflow | Description | Entry Point |
|----------|-------------|-------------|
| BatterySizing | Sweep battery configurations against range targets using NEDC drive cycle data | `BEVBatterySizingMain.mlx` |
| CellCharacterization | Extract equivalent-circuit parameters from HPPC pulse test data and verify against drive profile | `CellCharacterizationForBEV.mlx` |
| VirtualSensorNeuralNetModel | Train and verify a neural network model for battery state estimation | `VirtualSensorNeuralNetModel.mlx` |

### MotorDrive

| Workflow | Description | Entry Point |
|----------|-------------|-------------|
| GearRatioSelect | Batch-sweep gear ratios to find the most efficient fixed ratio for a drive cycle | `minimumRequiredGearRatio.mlx` |
| GenerateMotInvLoss | Generate motor and inverter loss maps from detailed PMSM FOC simulation. Includes `PMSMdetailTestbench.slx` for motor-level characterization | `generateDULossMap.mlx` |
| InverterLife | Estimate inverter power module lifetime from thermal cycling data | `inverterPowerModuleLife.mlx` |
| Model | Motor drive thermal and detailed test benches | `MotorDriveThermalTestBenchDescription.mlx` |
| ScriptsData | PMSM motor characterization | `PMSMmotorTestBench.mlx` |
| ThermalDurability | Evaluate drive unit thermal behavior over extended duty cycles | `DUThermalDurability.mlx` |

### Vehicle

| Workflow | Description | Entry Point |
|----------|-------------|-------------|
| RangeEstimation | Estimate vehicle range over standard drive cycles (EPA, NEDC, WLTC) | `BEVRangeEstimationMain.mlx` |

---

Open the MATLAB project (`ElectricVehicleSimscape.prj`) before running any workflow.

Copyright 2022 - 2025 The MathWorks, Inc.

# Workflow

Design workflows and analysis scripts for the BEV project. Each workflow is a self-contained study that uses the component models and vehicle templates to answer a specific engineering question. Workflows are organized by subsystem.

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

| Workflow | Description | Key Files |
|----------|-------------|-----------|
| BatterySizing | Sweep battery configurations against range targets using NEDC drive cycle data | `BEVBatterySizingMain.mlx`, `BEVbatterySizing.m` |
| CellCharacterization | Extract equivalent-circuit parameters from HPPC pulse test data and verify against drive profile | `CellCharacterizationForBEV.mlx`, `CellCharacterizationHPPC.slx` |
| VirtualSensorNeuralNetModel | Train and verify a neural network model for battery state estimation | `VirtualSensorNeuralNetModel.mlx` |

### MotorDrive

| Workflow | Description | Key Files |
|----------|-------------|-----------|
| GearRatioSelect | Batch-sweep gear ratios to find the most efficient fixed ratio for a drive cycle | `minimumRequiredGearRatio.mlx` |
| GenerateMotInvLoss | Generate motor and inverter loss maps from detailed PMSM FOC simulation | `generateDULossMap.mlx`, `PMSMfocControlLossMapGen.slx` |
| InverterLife | Estimate inverter power module lifetime from thermal cycling data | `inverterPowerModuleLife.mlx`, `InverterTestCycle.slx` |
| ThermalDurability | Evaluate drive unit thermal behavior over extended duty cycles | `DUThermalDurability.mlx` |

### Vehicle

| Workflow | Description | Key Files |
|----------|-------------|-----------|
| RangeEstimation | Estimate vehicle range over standard drive cycles (EPA, NEDC, WLTC) | `BEVRangeEstimationMain.mlx`, `BEVrangeEstimation*.m` |

---

## Workflow Pattern

Each workflow folder typically contains:

- **Live script** (`.mlx`) -- interactive entry point with documentation, code, and results
- **Simulink models** (`.slx`) -- simulation environments specific to the study
- **Support scripts** (`.m`) -- computation functions and automation
- **Data files** (`.mat`) -- drive cycle data, pre-computed results, and parameters

Workflows depend on the component models in `Components/` and the vehicle templates in `Model/`. Open the MATLAB project (`ElectricVehicleSimscape.prj`) before running any workflow.

Copyright 2026 The MathWorks, Inc.

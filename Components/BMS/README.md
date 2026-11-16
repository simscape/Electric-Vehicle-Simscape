# BMS

Battery management system (BMS) for battery protection, relay control, and state-of-charge (SOC) reporting.

## Model Fidelities

| Model | Description | Thermal | Use Case |
|-------|-------------|:-------:|----------|
| [BMS](Model/README.md#bms) | Battery protection, relay control, and SOC reporting. | Yes | Vehicle integration. |

## SOC Algorithms

Internal BMS blocks; `BMSSoCDirect` is the default.

| Model | Method |
|-------|--------|
| [BMSSoCDirect](Model/README.md#bmssocdirect) | Reads cell SOC values. |
| [BMSSoCEKF](Model/README.md#bmssocekf) | Extended Kalman filter (EKF) SOC estimation. |

## Component Interface

| Model | Inputs | Outputs |
|-------|--------|---------|
| BMS | `s`, `Cmd` | `ToBat`, `info`, `ToTh`, `Fault` |
| SOC algorithms | `BatSensor` | `SoC` |

## Folder Structure

```
BMS/
  Model/           - BMS model and parameter script
    SOC/           - SOC estimation algorithm variants
  TestBench/       - Test harness (BMSTestHarness.slx)
  TestCase/        - Unit tests (BMSPassTests.m)
  Documentation/   - Published documentation and images
```

## Related Workflows

- **Range Estimation** (`Workflow/Vehicle/RangeEstimation/`) -- The BMS monitors battery health and issues relay commands during drive-cycle runs.
- **Battery Sizing** (`Workflow/Battery/BatterySizing/`) -- BMS parameters (cell limits, thermal thresholds) affect the feasible operating range during sizing sweeps.

Copyright 2022 - 2025 The MathWorks, Inc.

# BMS

Battery management system component for the BEV high-voltage battery. The BMS monitors cell voltages, currents, and temperatures against configurable safety limits, issues relay commands, provides SOC estimation, and raises fault flags when operating limits are exceeded.

## Model Fidelities

| Model | Description | Thermal | Use Case |
|-------|-------------|:-------:|----------|
| [BMS](Model/README.md#bms) | Battery management system with voltage, current, and thermal fault monitoring. Issues relay commands and provides SOC estimation. | Yes | All vehicle configurations requiring battery protection, relay management, and SOC reporting. |
| [BMSSoCDirect](Model/README.md#bmssocdirect) | BMS with direct (coulomb-counting) SOC estimation. Simple integrator-based SOC tracking. | Yes | Simulations where SOC estimation accuracy is secondary or as a baseline for comparison. |
| [BMSSoCEKF](Model/README.md#bmssocekf) | BMS with extended Kalman filter (EKF) SOC estimation. Provides improved SOC accuracy under noisy measurements. | Yes | Studies focused on SOC estimation performance, observer tuning, or BMS algorithm development. |

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

# Chiller

Chiller component for the BEV thermal management system. The chiller removes heat from the battery coolant loop when the pack temperature rises above safe limits, particularly during hot-ambient driving or fast charging. Three fidelity levels are available depending on whether coolant-loop dynamics are needed.

## Model Fidelities

| Model | Description | Thermal | Use Case |
|-------|-------------|:-------:|----------|
| [Chiller](Model/README.md#chiller) | Controlled current source with thermal mass and coolant volume coupling. Models chiller electrical load, heat absorption, and coolant heat exchange for full thermal management studies. | Yes | Hot-climate range estimation and thermal management strategy evaluation where coolant loop dynamics are important. |
| [ChillerNoCoolant](Model/README.md#chillernocoolant) | Simplified chiller without coolant loop coupling. Models electrical load on the HV bus but does not include thermal-liquid interactions. | No | Fast vehicle-level simulations where the chiller electrical load matters but coolant loop dynamics are not needed. |
| [ChillerDummy](Model/README.md#chillerdummy) | Minimal stub with same port interface as Chiller. Draws a fixed electrical load when active; coolant passes through with no heat exchange. No internal parameter tuning needed. | No | Integration testing or fast simulations where chiller behavior is not under study but the model needs a connected chiller block. |

## Folder Structure

```
Chiller/
  Model/        - Simulink models and parameter scripts
  TestBench/    - Test harness (ChillerTestHarness.slx)
  TestCase/     - Unit tests (ChillerPassTests.m)
```

## Related Workflows

- **Range Estimation** (`Workflow/Vehicle/RangeEstimation/`) -- The chiller is active during high-ambient simulations (e.g., 35 degC) to cool the battery pack. Its energy draw impacts vehicle range.
- **Electro-Thermal Vehicle Studies** -- The full-thermal chiller is part of the VehicleElectroThermal template where coolant loop interactions with the battery, radiator, and pump are modeled.

Copyright 2022 - 2025 The MathWorks, Inc.

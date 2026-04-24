# Radiator

Radiator component for the BEV thermal management system. The radiator dissipates heat from the coolant loop to the ambient air, maintaining coolant temperature within acceptable limits for battery, motor, and charger operation.

## Model Fidelities

| Model | Description | Thermal | Use Case |
|-------|-------------|:-------:|----------|
| [Radiator](Model/README.md#radiator) | Cross-flow heat exchanger with coolant tubes, air fins, and fan-driven airflow. Models heat transfer between coolant and ambient air through primary surface and fin surface areas. | Yes | All electro-thermal vehicle configurations that include a coolant loop. Essential for maintaining thermal balance during sustained driving and charging. |

## Folder Structure

```
Radiator/
  Model/        - Simulink model and parameter script
  TestBench/    - Test harness (RadiatorTestHarness.slx)
  TestCase/     - Unit tests (RadiatorPassTests.m)
```

## Related Workflows

- **Range Estimation** (`Workflow/Vehicle/RangeEstimation/`) -- The radiator rejects heat from the coolant loop during drive-cycle runs. Fan power consumption contributes to auxiliary energy draw.
- **Electro-Thermal Vehicle Studies** -- The radiator is a critical part of the VehicleElectroThermal template coolant loop, balancing heat input from the battery, motor, and charger against ambient dissipation.

Copyright 2022 - 2025 The MathWorks, Inc.

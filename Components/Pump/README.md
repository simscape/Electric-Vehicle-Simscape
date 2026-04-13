# Pump

Coolant circulation pump component for the BEV thermal management system. The pump drives coolant through the thermal loop connecting the battery, motor drive, charger, chiller, heater, and radiator.

## Model Fidelities

| Model | Description | Thermal | Use Case |
|-------|-------------|:-------:|----------|
| [Pump](Model/README.md#pump) | Volumetric displacement pump with configurable speed and displacement. Circulates coolant through the thermal management loop at a flow rate set by the pump controller. | N/A | All electro-thermal vehicle configurations that include a coolant loop. Required whenever thermal-coupled battery, motor, or charger models are used. |

## Folder Structure

```
Pump/
  Model/        - Simulink model and parameter script
  TestBench/    - Test harness (PumpTestHarness.slx)
  TestCase/     - Unit tests (PumpPassTests.m)
```

## Related Workflows

- **Electro-Thermal Vehicle Studies** -- The pump is part of the coolant loop in the VehicleElectroThermal template, circulating coolant between thermal components and the radiator.

Copyright 2022 - 2025 The MathWorks, Inc.

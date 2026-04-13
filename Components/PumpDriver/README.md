# PumpDriver

Pump driver controller component for the BEV thermal management system. The PumpDriver translates thermal management commands into pump speed signals for the coolant circulation pump.

## Model Fidelities

| Model | Description | Thermal | Use Case |
|-------|-------------|:-------:|----------|
| [PumpDriver](Model/README.md#pumpdriver) | Controller that converts thermal status signals and pump enable commands into shaft speed setpoints for the coolant pump. Includes coolant system interface parameters. | Yes | All electro-thermal vehicle configurations that include a coolant loop. Pairs with the Pump component to form the coolant circulation subsystem. |

## Folder Structure

```
PumpDriver/
  Model/        - Simulink model and parameter script
  Testbench/    - Test harness (PumpDriverTestHarness.slx)
  TestCase/     - Unit tests (PumpDriverPassTests.m)
```

## Related Workflows

- **Electro-Thermal Vehicle Studies** -- The PumpDriver controls coolant flow rate in response to thermal conditions, working alongside the Pump, Radiator, and other thermal components.

Copyright 2022 - 2025 The MathWorks, Inc.

# DCDC (PumpDriver)

DC-DC converter component for the BEV system. Translates thermal management commands into pump speed signals for the coolant circulation pump.

## Model Fidelities

| Model | Description | Thermal | Use Case |
|-------|-------------|:-------:|----------|
| [PumpDriver](Model/README.md#pumpdriver) | Simplified DC-DC converter with electrical conversion and control logic only. No coolant ports or thermal coupling. | No | Non-thermal auxiliary configurations (VehicleElecAux). Pairs with PumpDummy. |
| [PumpDriverTh](Model/README.md#pumpdriverth) | DC-DC converter with coolant system interface and thermal coupling. Includes coolant pipe and jacket geometry parameters. | Yes | Electro-thermal configurations (VehicleElectroThermal). Pairs with the Pump component for full coolant loop. |

## Folder Structure

```
PumpDriver/
  Model/        - Simulink models and parameter scripts
  Testbench/    - Test harness (PumpDriverTestHarness.slx)
  TestCase/     - Unit tests (PumpDriverPassTests.m)
```

## Related Workflows

- **Auxiliary Vehicle Studies** -- PumpDriver (non-thermal) is used in VehicleElecAux alongside PumpDummy.
- **Electro-Thermal Vehicle Studies** -- PumpDriverTh controls coolant flow rate in response to thermal conditions, working alongside the Pump, Radiator, and other thermal components in VehicleElectroThermal.

Copyright 2022 - 2026 The MathWorks, Inc.

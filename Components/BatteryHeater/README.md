# BatteryHeater

Battery heater component for the BEV thermal management system. The heater draws power from the HV bus to warm the battery pack in cold ambient conditions, ensuring the cells operate within their optimal temperature window.

## Model Fidelities

| Model | Description | Thermal | Use Case |
|-------|-------------|:-------:|----------|
| [Heater](Model/README.md#heater) | Controlled current source with thermal mass and coolant loop coupling. Models heater electrical load, heat storage, and transfer to the coolant system. | Yes | Cold-climate range estimation, thermal management strategy evaluation, and auxiliary power consumption studies. |
| [HeaterDummy](Model/README.md#heaterdummy) | Minimal stub with same port interface as Heater. Draws a fixed electrical load when active; coolant passes through with no heat exchange. | No | Integration testing or fast simulations where heater behavior is not under study but the model needs a connected heater block. |

## Folder Structure

```
BatteryHeater/
  Model/        - Simulink model and parameter script
  TestBench/    - Test harness for standalone validation
  TestCase/     - Unit tests (BatteryHeaterPassTests.m)
```

## Related Workflows

- **Range Estimation** (`Workflow/Vehicle/RangeEstimation/`) -- The heater activates during cold-ambient drive cycles to keep the battery pack at an operable temperature. Its energy consumption directly impacts the vehicle range in low-temperature scenarios.
- **Electro-Thermal Vehicle Studies** -- The heater is part of the full thermal plant used in the VehicleElectroThermal template.

Copyright 2022 - 2025 The MathWorks, Inc.

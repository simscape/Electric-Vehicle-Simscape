# BatteryHeater

Battery heater for the thermal-management system. It draws HV bus power to warm the coolant and battery pack in cold conditions.

## Model Fidelities

| Model | Description | Thermal | Use Case |
|-------|-------------|:-------:|----------|
| [Heater](Model/README.md#heater) | Controlled current source with thermal mass and coolant loop coupling. Models heater electrical load, heat storage, and transfer to the coolant system. | Yes | Cold-climate range estimation, thermal management strategy evaluation, and auxiliary power consumption studies. |
| [HeaterDummy](Model/README.md#heaterdummy) | Minimal stub with same port interface as Heater. Draws a fixed electrical load when active; coolant passes through with no heat exchange. | No | Integration testing or fast simulations where heater behavior is not under study but the model needs a connected heater block. |

## Component Interface

The table below lists the interface exposed by this component. A custom fidelity or replacement subsystem should preserve the required ports and signal names to remain compatible with the vehicle templates.

### Bus Element Name

| Direction | Element | Full Path |
|---|---|---|
| Input | `HE` | `s.HE` |
| Output | `HE` | `m.HE` |

### Input Bus — `s`

| Signal | Unit | Description | Required | Used by |
|---|---|---|---|---|
| BatSt | — | Battery status signal | Yes | Heater |
| cmdHeater | — | Heater command | Yes | Heater, HeaterDummy |

### Output Bus — `m`

| Signal | Unit | Description | Required | Used by |
|---|---|---|---|---|
| HeaterCurrent | A | Heater current draw | Yes | All fidelities |
| energy | J | Cumulative energy consumed | Yes | All fidelities |

### Physical Interface

| Port name | Domain | Description | Required | Used by |
|---|---|---|---|---|
| HV | Electrical | High-voltage bus connection | Yes | All fidelities |
| A | Thermal liquid | Coolant port | Yes | All fidelities |
| B | Thermal liquid | Coolant port | Yes | All fidelities |

### Interface Notes

- Required ports should be preserved when creating a custom fidelity or replacement subsystem.
- HeaterDummy terminates internal signals but maintains the same external port interface.
- Internal Simscape connection handles such as `LConn` and `RConn` are intentionally not shown.

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

Copyright 2022 - 2026 The MathWorks, Inc.

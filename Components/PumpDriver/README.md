# DCDC (PumpDriver)

DC-DC converter supplying the low-voltage bus from the high-voltage battery.

## Model Fidelities

| Model | Description | Thermal | Use Case |
|-------|-------------|:-------:|----------|
| [PumpDriver](Model/README.md#pumpdriver) | DC-DC conversion without coolant ports. | No | VehicleElecAux; supplies PumpDummy. |
| [PumpDriverTh](Model/README.md#pumpdriverth) | DC-DC converter with coolant system interface and thermal coupling. Includes coolant pipe and jacket geometry parameters. | Yes | Electro-thermal configurations (VehicleElectroThermal). Pairs with the Pump component for full coolant loop. |

## Component Interface

The table below lists the interface exposed by this component. A custom fidelity or replacement subsystem should preserve the required ports and signal names to remain compatible with the vehicle templates.

### Input / Output Bus

No Simulink signal bus interface. PumpDriver operates entirely through physical connections.

### Physical Interface

| Port name | Domain | Description | Required | Used by |
|---|---|---|---|---|
| HV | Electrical | High-voltage bus input | Yes | All fidelities |
| LV | Electrical | Low-voltage bus output | Yes | All fidelities |
| A | Thermal liquid | Coolant port | Optional | Thermal fidelity (PumpDriverTh) |
| B | Thermal liquid | Coolant port | Optional | Thermal fidelity (PumpDriverTh) |

### Interface Notes

- Required ports should be preserved when creating a custom fidelity or replacement subsystem.
- PumpDriver is a pure physical component with no bus signals.
- Internal Simscape connection handles such as `LConn` and `RConn` are intentionally not shown.

## Folder Structure

```
PumpDriver/
  Model/        - Simulink models and parameter scripts
  TestBench/    - Test harness (PumpDriverTestHarness.slx)
  TestCase/     - Unit tests (PumpDriverPassTests.m)
```

## Related Workflows

- **Auxiliary Vehicle Studies** -- PumpDriver (non-thermal) is used in VehicleElecAux alongside PumpDummy.
- **Electro-Thermal Vehicle Studies** -- PumpDriverTh supplies the LV bus and exchanges converter heat with the coolant loop.

Copyright 2022 - 2026 The MathWorks, Inc.

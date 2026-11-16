# Pump

Coolant circulation pump component for the BEV thermal management system. The pump drives coolant through the thermal loop connecting the battery, motor drive, charger, chiller, heater, and radiator. All three fidelities use a system mask for per-instance parameterization, with defaults read from the `pump` struct.

## Model Fidelities

| Model | Description | Thermal | Use Case |
|-------|-------------|:-------:|----------|
| Pump | Volumetric displacement pump with configurable speed and displacement. Circulates coolant through the thermal management loop at a flow rate set by the pump controller. | N/A | Electro-thermal configurations with a coolant loop. |
| PumpDummy | Minimal stub with fixed electrical load on the LV bus. No coolant ports. | No | Non-thermal templates or integration testing where no coolant loop is present. |
| PumpDummyTh | Minimal stub with fixed electrical load on the LV bus. Coolant passes through with no active pumping. | No | Electro-thermal templates where the pump is not the focus but coolant loop must stay closed. |

## Component Interface

The table below lists the interface exposed by this component. A custom fidelity or replacement subsystem should preserve the required ports and signal names to remain compatible with the vehicle templates.

### Bus Element Name

| Direction | Element | Full Path | Notes |
|---|---|---|---|
| Input | `BP` | `s.BP` | Battery pump instance |
| Output | `BP` | `m.BP` | Battery pump instance |
| Input | `MP` | `s.MP` | Motor pump instance |
| Output | `MP` | `m.MP` | Motor pump instance |

### Input Bus — `s`

| Signal | Unit | Description | Required | Used by |
|---|---|---|---|---|
| BatSt | — | Battery status signal | Yes | Pump |
| cmdPump | — | Pump speed command | Yes | Pump, PumpDummyTh |

### Output Bus — `m`

| Signal | Unit | Description | Required | Used by |
|---|---|---|---|---|
| PumpCurr | A | Pump current draw | Yes | All fidelities |
| LowVolt | V | Low-voltage bus measurement | Yes | All fidelities |
| energy | J | Cumulative energy consumed | Yes | All fidelities |

### Physical Interface

| Port name | Domain | Description | Required | Used by |
|---|---|---|---|---|
| LV | Electrical | Low-voltage bus connection | Yes | All fidelities |
| A | Thermal liquid | Coolant port | Optional | Thermal fidelities (Pump, PumpDummyTh) |
| B | Thermal liquid | Coolant port | Optional | Thermal fidelities (Pump, PumpDummyTh) |

### Interface Notes

- Required ports should be preserved when creating a custom fidelity or replacement subsystem.
- PumpDummy has no command input. PumpDummyTh consumes `cmdPump` and terminates `BatSt`.
- Internal Simscape connection handles such as `LConn` and `RConn` are intentionally not shown.

## Mask Parameters

**Pump.slx**

| Mask Variable | Default Source | Unit | Description |
|---------------|---------------|------|-------------|
| `pump_displacement` | `pump.pump_displacement` | L/rev | Volumetric displacement |
| `pump_speed_max` | `pump.pump_speed_max` | rpm | Maximum shaft speed |
| `coolant_pipe_D` | `pump.coolant_pipe_D` | m | Coolant pipe diameter |

**PumpDummy.slx**

| Mask Variable | Default Source | Unit | Description |
|---------------|---------------|------|-------------|
| `pumpMaxCurrent` | `pump.pumpMaxCurrent` | A | Fixed current draw at full command |

**PumpDummyTh.slx**

| Mask Variable | Default Source | Unit | Description |
|---------------|---------------|------|-------------|
| `pumpMaxCurrent` | `pump.pumpMaxCurrent` | A | Fixed current draw at full command |

## Parameter Files

| File | Location | Description |
|------|----------|-------------|
| PumpParams.m | Model/ | Pump struct defaults (displacement, speed, pipe diameter) |
| PumpDummyParams.m | Model/ | PumpDummy struct defaults (max current) |
| PumpDummyThParams.m | Model/ | PumpDummyTh struct defaults (max current, pipe diameter) |
| PumpTestHarnessParams.m | TestBench/ | Environment params + component params for standalone testing |

## Folder Structure

```
Pump/
  Model/        - Simulink models and parameter scripts
  TestBench/    - Test harness (PumpTestHarness.slx)
  TestCase/     - Unit tests (PumpPassTests.m)
```

## Related Workflows

- **Electro-Thermal Vehicle Studies** -- Pump and PumpDummyTh are part of the coolant loop in the VehicleElectroThermal template, circulating coolant between thermal components and the radiator.
- **Auxiliary Vehicle Studies** -- PumpDummy is available in the VehicleElecAux template as a non-thermal electrical placeholder.

Copyright 2022 - 2026 The MathWorks, Inc.

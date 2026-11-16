# Chiller

Chiller component for the BEV thermal management system. The chiller removes heat from the battery coolant loop when the pack temperature rises above safe limits, particularly during hot-ambient driving or fast charging. Three fidelity levels are available depending on whether coolant-loop dynamics are needed.

## Model Fidelities

| Model | Description | Thermal | Use Case |
|-------|-------------|:-------:|----------|
| [Chiller](Model/README.md#chiller) | Controlled current source with thermal mass and coolant volume coupling. Models chiller electrical load, heat absorption, and coolant heat exchange for full thermal management studies. | Yes | Hot-climate range estimation and thermal management strategy evaluation where coolant loop dynamics are important. |
| [ChillerNoCoolant](Model/README.md#chillernocoolant) | Simplified chiller without coolant loop coupling. Models electrical load on the HV bus but does not include thermal-liquid interactions. | No | Fast vehicle-level simulations where the chiller electrical load matters but coolant loop dynamics are not needed. |
| [ChillerDummy](Model/README.md#chillerdummy) | Minimal stub with same port interface as Chiller. Draws a fixed electrical load when active; coolant passes through with no heat exchange. No internal parameter tuning needed. | No | Integration testing or fast simulations where chiller behavior is not under study but the model needs a connected chiller block. |

## Component Interface

The table below lists the interface exposed by this component. A custom fidelity or replacement subsystem should preserve the required ports and signal names to remain compatible with the vehicle templates.

### Bus Element Name

| Direction | Element | Full Path |
|---|---|---|
| Input | `CH` | `s.CH` |
| Output | `CH` | `m.CH` |

### Input Bus — `s`

| Signal | Unit | Description | Required | Used by |
|---|---|---|---|---|
| cmdChillerByp | — | Chiller bypass command | Yes | Chiller, ChillerNoCoolant |
| BatSt | — | Battery status signal | Yes | Chiller, ChillerNoCoolant |

### Output Bus — `m`

| Signal | Unit | Description | Required | Used by |
|---|---|---|---|---|
| ChillerCurrent | A | Chiller current draw | Yes | All fidelities |
| energy | J | Cumulative energy consumed | Yes | All fidelities |

### Physical Interface

| Port name | Domain | Description | Required | Used by |
|---|---|---|---|---|
| HV | Electrical | High-voltage bus connection | Yes | All fidelities |
| A | Thermal liquid | Coolant port | Optional | Thermal fidelities (Chiller, ChillerDummy) |
| B | Thermal liquid | Coolant port | Optional | Thermal fidelities (Chiller, ChillerDummy) |

### Interface Notes

- Required ports should be preserved when creating a custom fidelity or replacement subsystem.
- ChillerDummy terminates internal signals but maintains the same external port interface.
- Warning: ChillerDummy reads `Batt.BatSt` (with `Batt.` prefix) while Chiller and ChillerNoCoolant read `BatSt`. Recommend aligning for consistency.
- Internal Simscape connection handles such as `LConn` and `RConn` are intentionally not shown.

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

Copyright 2022 - 2026 The MathWorks, Inc.

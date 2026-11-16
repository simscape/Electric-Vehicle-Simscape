# Charger

Onboard charger component for the BEV system model. The charger implements constant-current / constant-voltage (CC-CV) charging control and connects to the HV bus to replenish the battery pack. Multiple fidelity levels cover purely electrical through fully thermal representations, plus lightweight dummy variants for rapid integration testing.

## Model Fidelities

| Model | Description | Thermal | Use Case |
|-------|-------------|:-------:|----------|
| [Charger](Model/README.md#charger) | CC-CV charging control without thermal dynamics. Simplified model focused on electrical charging behavior with relay and cell-voltage inputs. | No | Fast charging simulations where thermal effects are not needed, controller algorithm development. |
| [ChargerDummy](Model/README.md#chargerdummy) | Inactive charger stub with no internal parameter requirements. | No | Integration testing without charging behavior. |
| [ChargerThermal](Model/README.md#chargerthermal) | CC-CV charger with a thermal representation of the power converter. Heat generation and coolant jacket coupling allow thermal management studies. | Yes | Charging scenarios where converter temperature and heat rejection to the coolant loop are important. |
| [ChargerThermalDummy](Model/README.md#chargerthermaldummy) | Thermal-capable dummy charger with the same thermal ports as ChargerThermal but no internal parameter requirements. | Yes | Placeholder when the thermal loop must remain closed but real charger thermal data is unavailable. |

## Component Interface

The table below lists the interface exposed by this component. A custom fidelity or replacement subsystem should preserve the required ports and signal names to remain compatible with the vehicle templates.

### Bus Element Name

| Direction | Element | Full Path |
|---|---|---|
| Input | `CG` | `s.CG` |
| Output | — | No output bus |

### Input Bus — `s`

| Signal | Unit | Description | Required | Used by |
|---|---|---|---|---|
| Batt.Relay.RelayChg | — | Charge relay command | Yes | Charger, ChargerThermal |
| Batt.BattSensor.CellVoltMax | V | Maximum cell voltage | Yes | Charger, ChargerThermal |

### Output Bus

No output bus. Charger operates via physical ports only.

### Physical Interface

| Port name | Domain | Description | Required | Used by |
|---|---|---|---|---|
| HV | Electrical | High-voltage bus connection | Yes | All fidelities |
| A | Thermal liquid | Coolant port | Optional | Thermal fidelities (ChargerThermal, ChargerThermalDummy) |
| B | Thermal liquid | Coolant port | Optional | Thermal fidelities (ChargerThermal, ChargerThermalDummy) |

### Interface Notes

- Required ports should be preserved when creating a custom fidelity or replacement subsystem.
- ChargerDummy terminates input bus `s` (no active charging logic).
- ChargerThermalDummy maintains thermal port interface but has no internal parameter requirements.
- Internal Simscape connection handles such as `LConn` and `RConn` are intentionally not shown.

## Folder Structure

```
Charger/
  Model/        - Simulink models and parameter scripts
  TestBench/    - Test harness (ChargerTestHarness.slx)
  TestCase/     - Unit tests (ChargerPassTests.m)
```

## Related Workflows

- **Range Estimation** (`Workflow/Vehicle/RangeEstimation/`) -- The charger is included in the BEV system model for charge-discharge scenario studies.
- **Electro-Thermal Vehicle Studies** -- ChargerThermal is used in the VehicleElectroThermal template where coolant loop interactions matter.
- **BEV Setup App** (`utils/APP/`) -- The app configuration lists available charger fidelities for the VehicleElectric template.

Copyright 2022 - 2026 The MathWorks, Inc.

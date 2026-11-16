# Radiator

Radiator component for the BEV thermal management system. The radiator dissipates heat from the coolant loop to the ambient air, maintaining coolant temperature within acceptable limits for battery, motor, and charger operation.

## Model Fidelities

| Model | Description | Thermal | Use Case |
|-------|-------------|:-------:|----------|
| [Radiator](Model/README.md#radiator) | Cross-flow heat exchanger with coolant tubes, air fins, and fan-driven airflow. Models heat transfer between coolant and ambient air through primary surface and fin surface areas. | Yes | All electro-thermal vehicle configurations that include a coolant loop. Essential for maintaining thermal balance during sustained driving and charging. |

## Component Interface

The table below lists the interface exposed by this component. A custom fidelity or replacement subsystem should preserve the required ports and signal names to remain compatible with the vehicle templates.

### Bus Element Name

| Direction | Element | Full Path |
|---|---|---|
| Input | `RA` | `s.RA` |
| Output | — | No output bus |

### Input Bus — `s`

| Signal | Unit | Description | Required | Used by |
|---|---|---|---|---|
| Env | — | Environment conditions sub-bus (Tenv, Penv, RHenv, CO2env) | Yes | Radiator |
| VehSpd | m/s | Vehicle speed (for ram air effect) | Yes | Radiator |
| cmdFan | — | Fan speed command | Yes | Radiator |

### Output Bus

No output bus. Radiator operates via physical ports only.

### Physical Interface

| Port name | Domain | Description | Required | Used by |
|---|---|---|---|---|
| A | Thermal liquid | Coolant port (inlet) | Yes | Radiator |
| B | Thermal liquid | Coolant port (outlet) | Yes | Radiator |

### Interface Notes

- Required ports should be preserved when creating a custom fidelity or replacement subsystem.
- Only one fidelity exists. All ports are required.
- Internal Simscape connection handles such as `LConn` and `RConn` are intentionally not shown.

## Folder Structure

```
Radiator/
  Model/        - Simulink model and parameter script
  TestBench/    - Test harness (RadiatorTestHarness.slx)
  TestCase/     - Unit tests (RadiatorPassTests.m)
```

## Related Workflows

- **Range Estimation** (`Workflow/Vehicle/RangeEstimation/`) -- The radiator rejects heat from the coolant loop during drive-cycle runs. The fan command controls airflow, but this component does not model or report fan electrical power.
- **Electro-Thermal Vehicle Studies** -- The radiator is a critical part of the VehicleElectroThermal template coolant loop, balancing heat input from the battery, motor, and charger against ambient dissipation.

Copyright 2022 - 2026 The MathWorks, Inc.

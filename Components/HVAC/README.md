# HVAC

Heating, ventilation, and air conditioning component for the BEV system model. The HVAC subsystem manages cabin comfort by controlling blower airflow, PTC heating, and compressor-based cooling. It draws power from the HV bus and has a significant impact on vehicle range, especially under extreme ambient conditions. Two fidelity levels are available.

## Model Fidelities

| Model | Description | Thermal | Use Case |
|-------|-------------|:-------:|----------|
| [HVACEmpiricalRef](Model/README.md#hvacempiricalref) | Empirical-based HVAC with cabin and refrigeration subsystems. Uses lookup-table-driven performance curves rather than physical fluid dynamics. | No | Fast cabin-comfort and HVAC energy-demand studies where refrigerant loop dynamics are not needed. |
| [HVACsimpleTh](Model/README.md#hvacsimpleth) | HVAC with a cabin thermal model including air volume, cabin heat transfer, and environment coupling. Blower, cooler, and PTC heater interact with the cabin air mass. | Yes | System-level range estimation studies where cabin temperature response and HVAC energy consumption matter. |

## Component Interface

The table below lists the interface exposed by this component. A custom fidelity or replacement subsystem should preserve the required ports and signal names to remain compatible with the vehicle templates.

### Bus Element Name

| Direction | Element | Full Path |
|---|---|---|
| Input | `VA` | `s.VA` |
| Output | `VA` | `m.VA` |

### Input Bus — `s`

| Signal | Unit | Description | Required | Used by |
|---|---|---|---|---|
| Env.Tenv | K | Environment temperature | Yes | All fidelities |
| Env | — | Environment bus (full struct) | Optional | HVACEmpiricalRef |
| Batt.BatSt | — | Battery status | Yes | All fidelities |
| Batt | — | Battery bus (voltage) | Yes | All fidelities |
| Cntrl.CmdBlower | — | Blower speed command | Yes | All fidelities |
| Cntrl.CmdPTC | — | PTC heater command | Yes | All fidelities |
| Cntrl.CmdCool | — | Cooler/compressor command | Optional | HVACsimpleTh |
| Cntrl.acOnOff | — | AC on/off command | Optional | HVACEmpiricalRef |

### Output Bus — `m`

| Signal | Unit | Description | Required | Used by |
|---|---|---|---|---|
| energy | J | Cumulative HVAC energy consumption | Yes | All fidelities |
| Tcabin | K | Cabin air temperature | Yes | All fidelities |
| TacVent | K | AC vent temperature | Yes | All fidelities |
| Tptc | K | PTC heater temperature | Yes | All fidelities |

### Physical Interface

| Port name | Domain | Description | Required | Used by |
|---|---|---|---|---|
| HV | Electrical | High-voltage bus connection | Yes | All fidelities |

### Interface Notes

- Required ports should be preserved when creating a custom fidelity or replacement subsystem.
- HVACsimpleTh uses `Cntrl.CmdCool` while HVACEmpiricalRef uses `Cntrl.acOnOff` for cooling control.
- HVACEmpiricalRef reads the full `Env` struct; HVACsimpleTh reads only `Env.Tenv`.
- Internal Simscape connection handles such as `LConn` and `RConn` are intentionally not shown.

## Folder Structure

```
HVAC/
  Model/        - Simulink models and parameter scripts
  TestBench/    - Test harness (HVACTestHarness.slx)
  TestCase/     - Unit tests (HVACPassTests.m)
```

## Related Workflows

- **Range Estimation** (`Workflow/Vehicle/RangeEstimation/`) -- HVAC power consumption is a major factor in range under cold (heating) and hot (cooling) ambient conditions. The AC on/off flag directly toggles HVAC load in the simulation.
- **Electro-Thermal Vehicle Studies** -- HVACsimpleTh and HVACEmpiricalRef are used in the VehicleElectroThermal template.
- **BEV Setup App** (`utils/APP/`) -- The app configuration lists HVACsimpleTh and HVACEmpiricalRef for the electro-thermal template. The AC button and cabin setpoint controls in the app map to HVAC parameters.

## Vehicle Configurations

- **VehicleElecAux** and **VehicleElectroThermal**: Uses HVACsimpleTh or HVACEmpiricalRef (configured via `VehicleTemplateConfig.json`).
- **ControllerHVAC**: The HVAC-aware controller variant coordinates blower, compressor, and PTC commands with drivetrain torque control.

Copyright 2022 - 2026 The MathWorks, Inc.

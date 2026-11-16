# BatteryHV

High-voltage battery pack component for the BEV system model. This component represents the main energy storage device and provides electrical power to the drivetrain, HVAC, and auxiliary loads. Multiple fidelity levels are available to trade off simulation speed against thermal and electrical detail.

## Model Fidelities

| Model | Description | Thermal | Use Case |
|-------|-------------|:-------:|----------|
| [BatteryLumped](Model/README.md#batterylumped) | Simplified lumped-parameter battery with fixed temperature. Provides SOC, terminal voltage, current, and power estimation without thermal coupling. | No | Fast vehicle-level simulations where thermal dynamics are not required, such as quick range sweeps or controller tuning. |
| [BatteryLumpedThermal](Model/README.md#batterylumpedthermal) | Lumped battery with a single thermal mass and coolant port. Tracks SOC, voltage, current, and one-node temperature for heat exchange with the cooling loop. | Yes | System-level studies where battery temperature response matters but detailed cell-level dynamics are not needed. |
| [BatteryEq](Model/README.md#batteryeq) | Simplified equivalent-circuit battery. Provides SOC, voltage, current, and temperature without relay logic. | No | Rapid prototyping and early integration where relay control is not yet needed. |
| [BatteryTableBased](Model/README.md#batterytablebased) | Table-based battery using SOC-OCV and resistance lookup tables indexed by SOC and temperature. Includes thermal port for coolant and heater coupling. | Yes | High-fidelity drive cycle simulations, thermal management studies, and battery sizing workflows where accurate electrical and thermal behavior is required. |

## Component Interface

The table below lists the interface exposed by this component. A custom fidelity or replacement subsystem should preserve the required ports and signal names to remain compatible with the vehicle templates.

### Bus Element Name

| Direction | Element | Full Path |
|---|---|---|
| Input | `BA` | `s.BA` |
| Output | `BA` | `m.BA` |

### Input Bus — `s`

| Signal | Unit | Description | Required | Used by |
|---|---|---|---|---|
| RelayPos | — | Positive relay command | Yes | BatteryLumped, BatteryLumpedThermal, BatteryTableBased |
| RelayNeg | — | Negative relay command | Yes | BatteryLumped, BatteryLumpedThermal, BatteryTableBased |

### Output Bus — `m`

| Signal | Unit | Description | Required | Used by |
|---|---|---|---|---|
| BattSens.SoC | — | State of charge | Yes | All fidelities |
| BattSens.Current | A | Pack current | Yes | All fidelities |
| BattSens.Cellvolt | V | Cell voltage | Yes | All fidelities |
| BattSens.ParVolt | V | Parallel string voltage | Yes | All fidelities |
| BattSens.temp | K | Pack temperature | Yes | All fidelities |
| CoolTp | K | Coolant temperature | Yes | All fidelities |

### Physical Interface

| Port name | Domain | Description | Required | Used by |
|---|---|---|---|---|
| HV | Electrical | High-voltage bus connection | Yes | All fidelities |
| A | Thermal liquid | Coolant port (inlet) | Optional | Thermal fidelities (BatteryLumpedThermal, BatteryTableBased) |
| B | Thermal liquid | Coolant port (outlet) | Optional | Thermal fidelities (BatteryLumpedThermal, BatteryTableBased) |

### Interface Notes

- Required ports should be preserved when creating a custom fidelity or replacement subsystem.
- Optional ports are used only by specific fidelity types, such as thermal variants.
- BatteryEq currently terminates input bus `s` (relay commands not yet implemented). Output bus `m` is fully populated.
- Template-level signal line names are documented with the vehicle templates; this table focuses on the component subsystem interface.
- Internal Simscape connection handles such as `LConn` and `RConn` are intentionally not shown.

## Folder Structure

```
BatteryHV/
  Model/              - Simulink models and parameter scripts
  Library/            - Reusable library blocks (pack BTMS, module)
  TestBench/          - Test harness for component-level validation
  TestCase/           - Unit tests (BatteryHVPassTests.m)
```

## Related Workflows

- **Range Estimation** (`Workflow/Vehicle/RangeEstimation/`) -- Uses BatteryTableBased in the full electro-thermal vehicle model to estimate driving range under NEDC, WLTC, and EPA cycles.
- **Battery Sizing** (`Workflow/Battery/BatterySizing/`) -- Sweeps cell capacity and vehicle mass to size the HV pack for a target range.
- **Virtual Sensor Neural Network** (`Workflow/Battery/VirtualSensorNeuralNetModel/`) -- Trains a neural network to predict battery temperature from voltage and current measurements.

## Vehicle Configurations

Three of the four models are listed in `VehicleTemplateConfig.json`. BatteryLumped is used in VehicleElectric and VehicleElecAux; BatteryTableBased and BatteryLumpedThermal are used in VehicleElectroThermal. BatteryEq exists on disk but is not selectable in the current template config.

Copyright 2022 - 2025 The MathWorks, Inc.

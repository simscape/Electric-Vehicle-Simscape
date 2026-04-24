# BatteryHV

High-voltage battery pack component for the BEV system model. This component represents the main energy storage device and provides electrical power to the drivetrain, HVAC, and auxiliary loads. Multiple fidelity levels are available to trade off simulation speed against thermal and electrical detail.

## Model Fidelities

| Model | Description | Thermal | Use Case |
|-------|-------------|:-------:|----------|
| [BatteryLumped](Model/README.md#batterylumped) | Simplified lumped-parameter battery with fixed temperature. Provides SOC, terminal voltage, current, and power estimation without thermal coupling. | No | Fast vehicle-level simulations where thermal dynamics are not required, such as quick range sweeps or controller tuning. |
| [BatteryLumpedThermal](Model/README.md#batterylumpedthermal) | Lumped battery with a single thermal mass and coolant port. Tracks SOC, voltage, current, and one-node temperature for heat exchange with the cooling loop. | Yes | System-level studies where battery temperature response matters but detailed cell-level dynamics are not needed. |
| [BatteryTableBased](Model/README.md#batterytablebased) | Table-based battery using SOC-OCV and resistance lookup tables indexed by SOC and temperature. Includes thermal port for coolant and heater coupling. | Yes | High-fidelity drive cycle simulations, thermal management studies, and battery sizing workflows where accurate electrical and thermal behavior is required. |

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

All three fidelities are listed in `VehicleTemplateConfig.json`. BatteryLumped is used in VehicleElectric and VehicleElecAux; BatteryTableBased and BatteryLumpedThermal are used in VehicleElectroThermal. The electro-thermal plant setup (`Script_Data/SetupPlantElectroThermal.m`) and the main parameter file (`Script_Data/BEVSystemModelParams.m`) default to BatteryTableBased.

Copyright 2022 - 2025 The MathWorks, Inc.

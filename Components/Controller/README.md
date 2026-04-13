# Controller

Vehicle controller for the BEV system model. Manages torque distribution, regenerative braking, and drive-mode selection. Multiple controller variants are available for different simulation fidelities.

For the battery management system, see [`Components/BMS/`](../BMS/README.md).

## Model Fidelities

| Model | Description | Thermal | Use Case |
|-------|-------------|:-------:|----------|
| [Controller](Model/README.md#controller) | Full vehicle controller with torque control, motor torque split, AWD logic, and regenerative braking. Default for electro-thermal configurations. | No | Full electro-thermal drive-cycle simulations. |
| [ControllerFRM](Model/README.md#controllerfrm) | Fast-running model (FRM) variant. Simplified control logic with the same port interface. | No | Abstract configurations for rapid sweeps and range estimation. |
| [ControllerHVAC](Model/README.md#controllerhvac) | Controller with integrated HVAC thermal management control logic. | No | Simulations requiring coordinated drivetrain and cabin HVAC control. |

## Folder Structure

```
Controller/
  Model/                          - Controller models and parameter script
  Documentation/                  - Published documentation and images
  TestCase/                       - Controller unit tests
```


## Related Workflows

- **Range Estimation** (`Workflow/Vehicle/RangeEstimation/`) -- Controller manages torque split and regenerative braking during drive-cycle runs.
- **Setup Scripts** -- `SetupPlantElectroThermal.m` selects `Controller`; `SetupPlantAbstract.m` selects `ControllerFRM`.

Copyright 2022 - 2025 The MathWorks, Inc.

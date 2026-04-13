# Controller

Vehicle controller and battery management system (BMS) components for the BEV system model. The controller manages torque distribution, regenerative braking, and drive-mode selection. The BMS monitors cell voltages, currents, and temperatures, and issues relay commands and fault flags. Multiple controller variants and SOC estimation strategies are available.

## Model Fidelities

### Vehicle Controllers (`Model/`)

| Model | Description | Thermal | Use Case |
|-------|-------------|:-------:|----------|
| [Controller](Model/README.md#controller) | Full vehicle controller with torque control, motor torque split, AWD logic, and regenerative braking. Default controller for electro-thermal vehicle configurations. | No | Full electro-thermal drive-cycle simulations with complete torque and energy management. |
| [ControllerFRM](Model/README.md#controllerfrm) | Fast-running model (FRM) controller variant. Simplified control logic for reduced simulation time while preserving the same port interface. | No | Abstract vehicle configurations for rapid parameter sweeps and early-stage range estimation. |
| [ControllerHVAC](Model/README.md#controllerhvac) | Controller variant with integrated HVAC thermal management control logic in addition to the standard torque control. | No | Vehicle simulations that require coordinated control of both the drivetrain and the cabin HVAC system. |

### Battery Management System (`BMS/Model/`)

| Model | Description | Thermal | Use Case |
|-------|-------------|:-------:|----------|
| [BMS](BMS/Model/README.md#bms) | Battery management system with voltage, current, and thermal fault monitoring. Issues relay commands and provides SOC estimation. | Yes | All vehicle configurations requiring battery protection, relay management, and SOC reporting. |
| [BMSSoCDirect](BMS/Model/README.md#bmssocdirect) | BMS with direct (coulomb-counting) SOC estimation. Simple integrator-based SOC tracking. | Yes | Simulations where SOC estimation accuracy is secondary or as a baseline for comparison. |
| [BMSSoCEKF](BMS/Model/README.md#bmssocekf) | BMS with extended Kalman filter (EKF) SOC estimation. Provides improved SOC accuracy under noisy measurements. | Yes | Studies focused on SOC estimation performance, observer tuning, or BMS algorithm development. |

## Folder Structure

```
Controller/
  Model/                  - Vehicle controller models and parameter script
  
    TestBench/            - BMS test harness
    TestCase/             - BMS unit tests (BMSPassTests.m)
  TestBench/              - Controller-level test harness
  BatteryManagementSystem.slx - Top-level BMS reference
```

## Related Workflows

- **Range Estimation** (`Workflow/Vehicle/RangeEstimation/`) -- The Controller manages torque split and regenerative braking during drive-cycle runs. The BMS monitors battery health and issues relay commands.
- **Battery Sizing** (`Workflow/Battery/BatterySizing/`) -- BMS parameters (cell limits, thermal thresholds) affect the feasible operating range during sizing sweeps.
- **Setup Scripts** -- `SetupPlantElectroThermal.m` selects `Controller`; `SetupPlantAbstract.m` selects `ControllerFRM`.

Copyright 2022 - 2025 The MathWorks, Inc.

# Driveline

Vehicle driveline component for the BEV system model. The driveline transmits torque from the front and rear motor drive units to the wheels through axle connections. It includes tire models with slip dynamics and a vehicle body subsystem for longitudinal and lateral response. Two fidelity levels are available depending on whether explicit mechanical braking is needed.

## Model Fidelities

| Model | Description | Thermal | Use Case |
|-------|-------------|:-------:|----------|
| [Driveline](Model/README.md#driveline) | Four-wheel driveline with front and rear axle torque inputs, tire slip dynamics for all four wheels, and vehicle body with longitudinal and lateral dynamics. | No | Default driveline for all drive-cycle range estimation and battery sizing workflows where mechanical braking is handled by regen only. |
| [DrivelineWithBraking](Model/README.md#drivelinewithbraking) | Extended driveline with an integrated mechanical braking system on the rear axle, capturing traction and friction braking forces for deceleration studies. | No | Vehicle studies requiring blended regenerative and friction braking analysis, or braking-specific controller validation. |

## Folder Structure

```
Driveline/
  Model/        - Simulink models and parameter scripts
  TestBench/    - Test harness (DriveLineTestHarness.slx)
  TestCase/     - Unit tests (DrivelinePassTests.m)
```

## Related Workflows

- **Range Estimation** (`Workflow/Vehicle/RangeEstimation/`) -- The driveline converts motor torque into vehicle motion and captures road load, tire losses, and vehicle speed for range calculation.
- **Battery Sizing** (`Workflow/Battery/BatterySizing/`) -- Vehicle mass (set via `driveline.vehMass_kg`) is swept to evaluate the impact of different battery pack sizes on range.
- **Gear Ratio Selection** (`Workflow/MotorDrive/GearRatioSelect/`) -- The driveline interacts with the motor gear ratio to determine overall powertrain efficiency.

Copyright 2022 - 2025 The MathWorks, Inc.

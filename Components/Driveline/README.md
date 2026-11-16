# Driveline

Vehicle driveline variants transmit motor torque to the wheels. FlexibleDriveline provides a separate flexible-shaft model for noise, vibration, and harshness (NVH) analysis.

## Model Fidelities

| Model | Description | Thermal | Use Case |
|-------|-------------|:-------:|----------|
| [Driveline](Model/README.md#driveline) | Four-wheel driveline with front and rear axle torque inputs, tire slip dynamics for all four wheels, and vehicle body with longitudinal and lateral dynamics. | No | Default driveline for all drive-cycle range estimation and battery sizing workflows where mechanical braking is handled by regen only. |
| [DrivelineWithBraking](Model/README.md#drivelinewithbraking) | Extended driveline with an integrated mechanical braking system on the rear axle, capturing traction and friction braking forces for deceleration studies. | No | Vehicle studies requiring blended regenerative and friction braking analysis, or braking-specific controller validation. |
| [Driveline3W](Model/README.md#driveline3w) | Three-wheel driveline variant with front and rear axle connections adapted for a three-wheeled vehicle layout. | No | Three-wheel range and vehicle-dynamics studies. |
| [FlexibleDriveline](Model/README.md#flexibledriveline) | Flexible shafts, gear backlash, and bearing dynamics. | No | Torsional vibration and launch studies. |

## Component Interface

The following interface applies to Driveline, DrivelineWithBraking, and Driveline3W. FlexibleDriveline uses the separate interface documented below.

### Bus Element Name

| Direction | Element | Full Path |
|---|---|---|
| Input | `DV` | `s.DV` |
| Output | `DV` | `m.DV` |

### Input Bus — `s`

| Signal | Unit | Description | Required | Used by |
|---|---|---|---|---|
| BrkCmd | — | Braking force command | Optional | DrivelineWithBraking |

### Output Bus — `m`

| Signal | Unit | Description | Required | Used by |
|---|---|---|---|---|
| VehSpd | m/s | Vehicle speed | Yes | Vehicle variants |

### Physical Interface

| Port name | Domain | Description | Required | Used by |
|---|---|---|---|---|
| FA | Mechanical rotational | Front axle connection | Yes | Vehicle variants |
| RA | Mechanical rotational | Rear axle connection | Yes | Vehicle variants |

### Interface Notes

- Required ports should be preserved when creating a custom fidelity or replacement subsystem.
- Driveline and Driveline3W terminate input bus `s` (no braking command used). DrivelineWithBraking consumes `s` for mechanical braking.
- Internal Simscape connection handles such as `LConn` and `RConn` are intentionally not shown.

### FlexibleDriveline Interface

| Port | Type | Description |
|------|------|-------------|
| `I` | Mechanical rotational | Motor shaft |
| `D1` | Mechanical rotational | Left drive shaft |
| `D2` | Mechanical rotational | Right drive shaft |
| `meas` | Output bus | Driveline measurements |

Use [FlexibleDriveLineTestHarness.slx](TestBench/FlexibleDriveLineTestHarness.slx) for standalone runs.

## Folder Structure

```
Driveline/
  Model/        - Simulink models and parameter scripts
  TestBench/    - Vehicle and flexible-driveline harnesses
  TestCase/     - Unit tests (DrivelinePassTests.m)
```

## Related Workflows

- [Driveline NVH](../../Workflow/Driveline/DrivelineNVH/README.md) -- Order maps and launch gear-ratio optimization.
- **Range Estimation** (`Workflow/Vehicle/RangeEstimation/`) -- The driveline converts motor torque into vehicle motion and captures road load, tire losses, and vehicle speed for range calculation.
- **Battery Sizing** (`Workflow/Battery/BatterySizing/`) -- Vehicle mass (set via `drivetrain.vehMass_kg`) is swept to evaluate the impact of different battery pack sizes on range.
- **Gear Ratio Selection** (`Workflow/MotorDrive/GearRatioSelect/`) -- The driveline interacts with the motor gear ratio to determine overall powertrain efficiency.

Copyright 2022 - 2026 The MathWorks, Inc.

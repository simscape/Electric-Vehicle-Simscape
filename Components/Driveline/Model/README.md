# Driveline Models

This folder contains the vehicle driveline Simulink models and their corresponding parameter scripts.

---

## Driveline

**File:** `Driveline.slx`
**Parameter File:** `DrivelineParams.m`
**Thermal Coupling:** No

### Description

Four-wheel driveline with front and rear axle connections. Includes tire models for all four wheels (FR, FL, RR, RL) with slip dynamics and a vehicle body subsystem capturing longitudinal and lateral dynamics. Torque inputs from front and rear motor drive units are transmitted through the axles to the wheels.

### Workflows

- **Default driveline** in the assembled BEV system model (`BEVsystemModel.slx`).
- Used in all range estimation workflows (NEDC, WLTC, EPA) and battery sizing workflows.
- Parameters loaded by `BEVSystemModelParams.m` via `DrivelineParams.m`.
- Validated through `DriveLineTestHarness.slx`.

### Inputs

| Signal | Description |
|--------|-------------|
| Front axle torque (FA) | Torque from the front motor drive unit |
| Rear axle torque (RA) | Torque from the rear motor drive unit |

### Outputs

| Signal | Description |
|--------|-------------|
| Vehicle Speed | Longitudinal vehicle speed |
| Wheel Dynamics | Individual wheel speeds, slip ratios |
| Body Motion States | Longitudinal and lateral vehicle response |

---

## DrivelineWithBraking

**File:** `DrivelineWithBraking.slx`
**Parameter File:** `DrivelineWithBrakingParams.m`
**Thermal Coupling:** No

### Description

Extended driveline model with an integrated braking system on the rear axle. In addition to all features of the standard Driveline, this variant captures traction and braking forces for deceleration studies and blended regenerative/friction braking analysis.

### Workflows

- Used in vehicle configurations that require explicit mechanical braking behavior.
- Tested through `DriveLineTestHarness.slx` and `DrivelinePassTests.m`.

### Inputs

| Signal | Description |
|--------|-------------|
| Front axle torque (FA) | Torque from the front motor |
| Rear axle torque (RA) | Torque from the rear motor |
| Brake command | Mechanical braking torque request |

### Outputs

| Signal | Description |
|--------|-------------|
| Vehicle Speed | Longitudinal vehicle speed |
| Wheel Dynamics | Wheel speeds, slip, traction forces |
| Braking Response | Braking force and deceleration |

---

## Key Parameters

| Parameter | Typical Value | Unit |
|-----------|--------------|------|
| Tire rolling radius | 0.30 | m |
| Vehicle mass | 1600 | kg |
| Max vehicle speed | 140 | km/h |
| Brake factor | 0.4 | - |

Copyright 2022 - 2025 The MathWorks, Inc.

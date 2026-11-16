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
- Validated through `DriveLineTestHarness.slx`.

### Input Bus — `s`

| Signal | Description |
|--------|-------------|
| (terminated) | Input bus `s` is terminated in this fidelity |

### Output Bus — `m`

| Signal | Description |
|--------|-------------|
| VehSpd | Vehicle speed |

### Physical Ports

| Port | Domain | Description |
|------|--------|-------------|
| FA | Mechanical rotational | Front axle connection |
| RA | Mechanical rotational | Rear axle connection |

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

### Input Bus — `s`

| Signal | Description |
|--------|-------------|
| BrkCmd | Mechanical braking force command |

### Output Bus — `m`

| Signal | Description |
|--------|-------------|
| VehSpd | Vehicle speed |

### Physical Ports

| Port | Domain | Description |
|------|--------|-------------|
| FA | Mechanical rotational | Front axle connection |
| RA | Mechanical rotational | Rear axle connection |

---

## Driveline3W

**File:** `Driveline3W.slx`
**Parameter File:** `Driveline3WParams.m`
**Thermal Coupling:** No

### Description

Three-wheel driveline variant with front and rear axle connections adapted for a three-wheeled vehicle layout. Includes tire models and vehicle body with appropriate weight distribution for the three-wheel configuration.

### Workflows

- Supports three-wheel range and vehicle-dynamics studies.

### Input Bus — `s`

| Signal | Description |
|--------|-------------|
| (terminated) | Input bus `s` is terminated in this fidelity |

### Output Bus — `m`

| Signal | Description |
|--------|-------------|
| VehSpd | Vehicle speed |

### Physical Ports

| Port | Domain | Description |
|------|--------|-------------|
| FA | Mechanical rotational | Front axle connection |
| RA | Mechanical rotational | Rear axle connection |

---

## FlexibleDriveline

**File:** `FlexibleDriveline.slx`
**Parameter File:** [FlexibleDrivelineParams.m](FlexibleDrivelineParams.m)
**Thermal Coupling:** No

Flexible shafts, gear backlash, and bearing dynamics for torsional NVH and launch studies.

| Port | Type | Description |
|------|------|-------------|
| `I` | Mechanical rotational | Motor shaft |
| `D1`, `D2` | Mechanical rotational | Left/right drive shafts |
| `meas` | Output bus | Driveline measurements |

Use [FlexibleDriveLineTestHarness.slx](../TestBench/FlexibleDriveLineTestHarness.slx) with [its parameter script](../TestBench/FlexibleDriveLineTestHarnessParams.m). See [Driveline NVH](../../../Workflow/Driveline/DrivelineNVH/README.md).

---

## Vehicle Variant Parameters

| Parameter | Typical Value | Unit |
|-----------|--------------|------|
| Tire rolling radius | 0.30 | m |
| Vehicle mass | 1600 | kg |
| Max vehicle speed | 140 | km/h |
| Brake factor | 0.4 | - |

Copyright 2022 - 2026 The MathWorks, Inc.

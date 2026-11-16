# Controller Models

Vehicle supervisory controllers share [ControllerParams.m](ControllerParams.m) and contain BMS.

## Inputs

Logical inputs are `Spd`, `Env`, `Cabin`, `m`, and `HMI.BMS`. The two-motor controllers also receive `HMI.AWD`. HMI.BMS supplies the battery operating-mode command.

## Controller

**File:** `Controller.slx`
**Parameter File:** `ControllerParams.m`
**Thermal Coupling:** No

Two-motor controller with regenerative braking, battery relay control, and thermal-management commands. Selected by the VehicleElectroThermal preset.

### Output Bus Groups — `s`

| Element | Purpose |
|---------|---------|
| `DV` | Brake command |
| `BA` | Battery relay commands |
| `M1`, `M2` | Front/rear motor commands |
| `CG` | Charger commands |
| `RA` | Radiator fan command |
| `MP`, `BP` | Coolant pump commands |
| `CV`, `MV`, `RV` | Coolant valve commands |
| `HE`, `CH` | Heater and chiller commands |
| `VA` | Cabin-control commands |

## ControllerFRM

**File:** `ControllerFRM.slx`
**Parameter File:** `ControllerParams.m`
**Thermal Coupling:** No

Core two-motor control for VehicleElectric. Outputs `DV`, `BA`, `M1`, `M2`, and `CG`; thermal groups are omitted.

## ControllerHVAC

**File:** `ControllerHVAC.slx`
**Parameter File:** `ControllerParams.m`
**Thermal Coupling:** No

Cabin-aware controller selected by the VehicleElecAux preset. Its output groups match [Controller](#controller).

## Controller3w

**File:** `Controller3w.slx`
**Parameter File:** `ControllerParams.m`
**Thermal Coupling:** No

Single-motor control. Outputs `DV`, `BA`, `M`, and `CG`.

Input blocks EnvBus, CabinBus, Meas, and BMSSensor carry logical inputs Env, Cabin, m, and HMI.BMS. There is no AWD input.

## Shared Parameter Defaults

| Parameter | Value | Unit |
|-----------|-------|------|
| Tire rolling radius | 30 | cm |
| Brake factor | 0.4 | — |
| Speed limit | 140 | km/h |
| Motor torque limit | 360 | N·m |

ControllerParams loads BMSParams. Model dashboards and setup scripts can override operating modes.

Copyright 2022 - 2026 The MathWorks, Inc.

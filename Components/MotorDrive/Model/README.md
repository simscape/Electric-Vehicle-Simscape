# MotorDrive Models

This folder contains the electric motor drive unit Simulink models and their corresponding parameter scripts.

---

## MotorDriveGear

**File:** `MotorDriveGear.slx`
**Parameter File:** `MotorDriveGearParams.m`
**Thermal Coupling:** No
**System Mask:** Yes -- 4 params (`max_torque`, `max_power`, `Tctc`, `motor_loss_map`)

### Description

Electric motor with lumped electrical and mechanical dynamics and a fixed gear for torque transmission to the axle. The motor input block accepts torque commands, control signals, and battery state. No thermal dynamics are modeled -- temperature is treated as a fixed input. Internal signals include current, voltage, motor speed, and energy consumption. All parameters are exposed on the mask.

### Workflows

- Listed in the **VehicleElectric** and **VehicleElecAux** templates in `VehicleTemplateConfig.json` as an available motor variant.
- Used when fast simulation is needed without thermal effects.

### Input Bus — `s`

| Signal | Description |
|--------|-------------|
| EMtrq | Motor torque command |
| Batt | Battery status sub-bus (Relay.RelayDchg, BattSensor.BatVolt) |

### Output Bus — `m`

| Signal | Description |
|--------|-------------|
| EM | Motor measurement sub-bus |
| energy | Cumulative energy consumed |
| CoolTp | Coolant temperature (fixed constant) |

### Physical Ports

| Port | Domain | Description |
|------|--------|-------------|
| HV | Electrical | High-voltage bus connection |
| Ax | Mechanical rotational | Axle output shaft |

---

## MotorDriveGearTh

**File:** `MotorDriveGearTh.slx`
**Parameter File:** `MotorDriveGearThParams.m`
**Thermal Coupling:** Yes
**System Mask:** Yes -- 5 top-level params (`max_torque`, `max_power`, `Tctc`, `motor_loss_map`, `coolant_channel_D`). All thermal sub-parameters (`MotorThermalParams`, `InverterMotorDriveParam`) are loaded by the param file into the workspace, not exposed on the mask.

### Description

Electric motor drive with fixed gear including full thermal coupling. The motor plant has electrical, mechanical, and thermal ports. A coolant jacket manages motor temperature, and inverter thermal dynamics capture semiconductor heating. The gear block transmits torque to the axle. This is the default motor fidelity for electro-thermal vehicle configurations.

### Workflows

- **Default motor fidelity** for the VehicleElectroThermal template.
- Used in all electro-thermal range estimation runs (NEDC, WLTC, EPA).
- Motor losses contribute to EM1 and EM2 energy tracking in range results.
- Inverter thermal output feeds the inverter life prediction workflow.
- Validated through `MotorTestHarness.slx`.

### Input Bus — `s`

| Signal | Description |
|--------|-------------|
| EMtrq | Motor torque command |
| Batt | Battery status sub-bus (Relay.RelayDchg, BattSensor.BatVolt) |
| EMrpm | Motor speed feedback |

### Output Bus — `m`

| Signal | Description |
|--------|-------------|
| EM | Motor measurement sub-bus |
| energy | Cumulative energy consumed |

### Physical Ports

| Port | Domain | Description |
|------|--------|-------------|
| HV | Electrical | High-voltage bus connection |
| Ax | Mechanical rotational | Axle output shaft |
| A | Thermal liquid | Coolant port |
| B | Thermal liquid | Coolant port |

---

## MotorDriveLube

**File:** `MotorDriveLube.slx`
**Parameter File:** `MotorDriveLubeParams.m`
**Thermal Coupling:** Yes
**System Mask:** Yes -- 5 top-level params (same as MotorDriveGearTh). All thermal and lubrication sub-parameters are loaded by the param file into the workspace, not exposed on the mask.

### Description

Motor drive with fixed gear including thermal coupling and gearbox lubrication losses. Extends MotorDriveGearTh by adding a gearbox thermal interface and oil-related friction and churning losses. The motor, inverter, and gearbox each have thermal ports connected to the coolant loop. Provides the highest fidelity powertrain efficiency and thermal model.

### Workflows

- Used in high-fidelity powertrain studies where gearbox efficiency and thermal behavior matter.
- Suitable for evaluating the effect of lubricant viscosity and gear losses on vehicle range.

### Input Bus — `s`

| Signal | Description |
|--------|-------------|
| EMtrq | Motor torque command |
| Batt | Battery status sub-bus (Relay.RelayDchg, BattSensor.BatVolt) |
| EMrpm | Motor speed feedback |

### Output Bus — `m`

| Signal | Description |
|--------|-------------|
| EM | Motor measurement sub-bus |
| energy | Cumulative energy consumed |
| CoolTp | Coolant temperature (from sensor) |

### Physical Ports

| Port | Domain | Description |
|------|--------|-------------|
| HV | Electrical | High-voltage bus connection |
| Ax | Mechanical rotational | Axle output shaft |
| A | Thermal liquid | Coolant port |
| B | Thermal liquid | Coolant port |

---

## Key Parameters

| Parameter | Typical Value | Unit |
|-----------|--------------|------|
| Max motor torque | 220 | Nm |
| Max motor power | 50 | kW |
| Torque control time constant | 0.002 | s |
| Initial coolant temperature | 298.15 | K |
| Motor loss map | Loaded from `MotorLossMap.mat` | - |

Copyright 2022 - 2026 The MathWorks, Inc.

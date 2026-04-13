# MotorDrive Models

This folder contains the electric motor drive unit Simulink models and their corresponding parameter scripts.

---

## MotorDriveGear

**File:** `MotorDriveGear.slx`
**Parameter File:** `MotorDriveGearParams.m`
**Thermal Coupling:** No

### Description

Electric motor with lumped electrical and mechanical dynamics and a fixed gear for torque transmission to the axle. The motor input block accepts torque commands, control signals, and battery state. No thermal dynamics are modeled -- temperature is treated as a fixed input. Internal signals include current, voltage, motor speed, and energy consumption.

### Workflows

- Listed in the **VehicleElectric** and **VehicleElecAux** templates in `VehicleTemplateConfig.json` as an available motor variant.
- Used when fast simulation is needed without thermal effects.

### Inputs

| Signal | Description |
|--------|-------------|
| Torque command | Requested motor torque from the controller |
| Control signals | Enable, mode, and limit signals |
| Battery signals | HV bus voltage and current availability |

### Outputs

| Signal | Description |
|--------|-------------|
| Motor Torque | Delivered mechanical torque |
| Motor Speed | Rotor speed |
| Electrical Power | Power drawn from the HV bus |
| Energy | Cumulative energy consumption |

---

## MotorDriveGearTh

**File:** `MotorDriveGearTh.slx`
**Parameter File:** `MotorDriveGearThParams.m`
**Thermal Coupling:** Yes

### Description

Electric motor drive with fixed gear including full thermal coupling. The motor plant has electrical, mechanical, and thermal ports. A coolant jacket manages motor temperature, and inverter thermal dynamics capture semiconductor heating. The gear block transmits torque to the axle. This is the default motor fidelity for electro-thermal vehicle configurations.

### Workflows

- **Default motor fidelity** loaded by `BEVSystemModelParams.m` (via `MotorDriveGearThParams.m`).
- Used in all electro-thermal range estimation runs (NEDC, WLTC, EPA).
- Motor losses contribute to EM1 and EM2 energy tracking in range results.
- Inverter thermal output feeds the inverter life prediction workflow.
- Validated through `MotorTestHarness.slx`.

### Inputs

| Signal | Description |
|--------|-------------|
| Torque command | Requested motor torque |
| Control signals | Enable, mode, and limit signals |
| Battery signals | HV bus voltage and current |
| Coolant port | Thermal-liquid interface for motor and inverter cooling |

### Outputs

| Signal | Description |
|--------|-------------|
| Motor Torque | Delivered mechanical torque |
| Motor Speed | Rotor speed |
| Electrical Power | Power drawn from the HV bus |
| Thermal States | Motor winding temperature, inverter junction temperature |
| Energy | Cumulative energy consumption |

---

## MotorDriveLube

**File:** `MotorDriveLube.slx`
**Parameter File:** `MotorDriveGearParams.m`, `MotorDriveGearThParams.m`
**Thermal Coupling:** Yes

### Description

Motor drive with fixed gear including thermal coupling and gearbox lubrication losses. Extends MotorDriveGearTh by adding a gearbox thermal interface and oil-related friction and churning losses. The motor, inverter, and gearbox each have thermal ports connected to the coolant loop. Provides the highest fidelity powertrain efficiency and thermal model.

### Workflows

- Used in high-fidelity powertrain studies where gearbox efficiency and thermal behavior matter.
- Suitable for evaluating the effect of lubricant viscosity and gear losses on vehicle range.

### Inputs

| Signal | Description |
|--------|-------------|
| Torque command | Requested motor torque |
| Control signals | Enable, mode, and limit signals |
| Battery signals | HV bus voltage and current |
| Coolant port | Thermal-liquid interface for motor, inverter, and gearbox cooling |

### Outputs

| Signal | Description |
|--------|-------------|
| Motor Torque | Delivered mechanical torque |
| Motor Speed | Rotor speed |
| Electrical Power | Power drawn from the HV bus |
| Thermal States | Motor, inverter, and gearbox temperatures |
| Energy | Cumulative energy consumption |

---

## Key Parameters

| Parameter | Typical Value | Unit |
|-----------|--------------|------|
| Max motor torque | 220 | Nm |
| Max motor power | 50 | kW |
| Torque control time constant | 0.002 | s |
| Initial coolant temperature | 298.15 | K |
| Motor loss map | Loaded from `MotorLossMap.mat` | - |

Copyright 2022 - 2025 The MathWorks, Inc.

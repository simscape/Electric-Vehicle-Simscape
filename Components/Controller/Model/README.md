# Controller Models

This folder contains the vehicle-level controller Simulink models and the shared parameter script.

---

## Controller

**File:** `Controller.slx`
**Parameter File:** `ControllerParams.m`
**Thermal Coupling:** No

### Description

Full vehicle controller for the BEV system model. Implements torque control with motor torque split between front and rear axles, AWD/FWD mode selection, regenerative braking logic, and drive-cycle speed tracking. This is the default controller used in the electro-thermal vehicle configuration.

### Workflows

- **Default controller** selected by `SetupPlantElectroThermal.m` for the VehicleElectroThermal template.
- Used in all range estimation workflows (NEDC, WLTC, EPA) and battery sizing workflows.
- Dashboard parameters (AWD, regen, charging mode) are set by `modelDashboardSetup.m` in the BEV Setup App.

### Inputs

| Signal | Description |
|--------|-------------|
| Drive cycle speed reference | Target vehicle speed from the drive cycle source |
| Vehicle speed feedback | Measured vehicle speed from driveline |
| Battery status | SOC, voltage, and current from BMS |
| BMS relay commands | Battery connection state |

### Outputs

| Signal | Description |
|--------|-------------|
| Front axle torque command | Torque request to front motor (EM1) |
| Rear axle torque command | Torque request to rear motor (EM2) |
| Brake command | Mechanical braking torque request |
| Battery command | Charge/discharge mode signal |

---

## ControllerFRM

**File:** `ControllerFRM.slx`
**Parameter File:** `ControllerParams.m`
**Thermal Coupling:** No

### Description

Fast-running model (FRM) variant of the vehicle controller. Uses simplified control logic to reduce simulation time while preserving the same port interface as the full Controller. Suitable for parameter sweeps and quick trade studies.

### Workflows

- Selected by `SetupPlantAbstract.m` for the VehicleElectric (abstract) template.
- Used when simulation speed is prioritized over controller fidelity.

### Inputs / Outputs

Same port interface as [Controller](#controller).

---

## ControllerHVAC

**File:** `ControllerHVAC.slx`
**Parameter File:** `ControllerParams.m`
**Thermal Coupling:** No

### Description

Controller variant that adds HVAC thermal management control logic on top of the standard drivetrain torque control. Coordinates cabin temperature setpoints, blower commands, and compressor operation alongside motor torque management.

### Workflows

- Used in vehicle configurations that include active HVAC thermal models (HVACsimpleTh, HVACThermal).
- Enables coordinated drivetrain and cabin comfort studies.

### Inputs

| Signal | Description |
|--------|-------------|
| All standard Controller inputs | Drive cycle, vehicle speed, battery status |
| Cabin temperature feedback | Measured cabin air temperature |
| HVAC setpoint | Target cabin temperature |

### Outputs

| Signal | Description |
|--------|-------------|
| All standard Controller outputs | Torque commands, brake, battery command |
| Blower command | HVAC blower speed/enable |
| Compressor command | AC compressor enable |
| PTC heater command | Cabin heater enable |

---

## Key Parameters

| Parameter | Typical Value | Unit |
|-----------|--------------|------|
| Tire rolling radius | 0.30 | m |
| Brake factor | 0.4 | - |
| Max vehicle speed | 140 | km/h |
| Motor drive max torque | 360 | Nm |

Copyright 2022 - 2025 The MathWorks, Inc.

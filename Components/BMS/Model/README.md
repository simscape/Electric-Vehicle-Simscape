# BMS Models

BMS component, internal SOC algorithms, and shared parameters.

---

## BMS

**File:** `BMS.slx`
**Parameter File:** `BMSParams.m`
**Thermal Coupling:** Yes (temperature monitoring and thermal fault limits)

### Description

Monitors battery limits and controls relays. Uses `BMSSoCDirect` by default.

### Interface

| Port | Direction | Description |
|------|-----------|-------------|
| `s` | Input | Battery measurements |
| `Cmd` | Input | Charge/discharge command |
| `ToBat` | Output | Relay commands |
| `info` | Output | SOC and battery status |
| `ToTh` | Output | Thermal management commands |
| `Fault` | Output | Fault flags |

---

## BMSSoCDirect

**File:** `SOC/BMSSoCDirect.slx`
**Parameter File:** `BMSParams.m`

### Description

Internal BMS algorithm that reads cell SOC values and reports their minimum and maximum.

### Inputs / Outputs

Input: `BatSensor`. Output: `SoC`.

---

## BMSSoCEKF

**File:** `SOC/BMSSoCEKF.slx`
**Parameter File:** `BMSParams.m`

### Description

Internal BMS algorithm using an extended Kalman filter (EKF) to estimate SOC.

### Inputs / Outputs

Input: `BatSensor`. Output: `SoC`.

---

## Key Parameters

| Parameter | Typical Value | Unit |
|-----------|--------------|------|
| Min cell voltage limit | 3.0 | V |
| Max cell voltage limit | 4.2 | V |
| Max charging current | 100 | A |
| Max discharging current | 120 | A |
| Charger CC value | 50 | A |
| Min thermal limit | 243.15 (-30 degC) | K |
| Max thermal limit | 333.15 (60 degC) | K |
| Series strings | 110 | - |
| Parallel cells per string | 3 | - |
| Coolant switch-on temperature | 320 | K |
| Coolant switch-off temperature | 303 | K |

Copyright 2022 - 2025 The MathWorks, Inc.

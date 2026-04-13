# BMS Models

This folder contains the battery management system Simulink models, SOC estimation variants, and the shared parameter script.

---

## BMS

**File:** `BMS.slx`
**Parameter File:** `BMSParams.m`
**Thermal Coupling:** Yes (temperature monitoring and thermal fault limits)

### Description

Battery management system controller that monitors cell voltages, currents, and temperatures against configurable safety limits. The BMS issues positive and negative relay commands, provides SOC estimation, and raises fault flags when operating limits are exceeded. Thermal monitoring includes coolant switch-on/off temperature thresholds.

### Inputs

| Signal | Description |
|--------|-------------|
| Cell voltage | Measured cell terminal voltage |
| Pack current | Measured pack current |
| Cell temperature | Measured cell temperature |
| Charge command | Requested charge/discharge mode |

### Outputs

| Signal | Description |
|--------|-------------|
| Positive relay command | Connects battery positive terminal |
| Negative relay command | Connects battery negative terminal |
| SOC estimate | Estimated state of charge |
| Fault flags | Over-voltage, under-voltage, over-current, over-temperature |
| Coolant command | Thermal management enable based on temperature thresholds |

---

## BMSSoCDirect

**File:** `SOC/BMSSoCDirect.slx`
**Parameter File:** `BMSParams.m`
**Thermal Coupling:** Yes

### Description

BMS variant using direct (coulomb-counting) SOC estimation. SOC is computed by integrating pack current over time from a known initial condition. Simple and computationally inexpensive but subject to drift over long simulations without periodic recalibration.

### Inputs / Outputs

Same interface as [BMS](#bms). The SOC output is computed via coulomb counting.

---

## BMSSoCEKF

**File:** `SOC/BMSSoCEKF.slx`
**Parameter File:** `BMSParams.m`
**Thermal Coupling:** Yes

### Description

BMS variant using an extended Kalman filter (EKF) for SOC estimation. Combines a battery equivalent-circuit model with noisy voltage and current measurements to produce a filtered SOC estimate with improved accuracy compared to direct coulomb counting.

### Inputs / Outputs

Same interface as [BMS](#bms). The SOC output is computed via EKF observer.

---

## Key Parameters

| Parameter | Typical Value | Unit |
|-----------|--------------|------|
| Min cell voltage limit | 3.0 | V |
| Max cell voltage limit | 4.2 | V |
| Max charging current | 100 | A |
| Max discharging current | 120 | A |
| Charger CC value | 50 | A |
| Min thermal limit | 263.15 (10 degC) | K |
| Max thermal limit | 333.15 (60 degC) | K |
| Series strings | 110 | - |
| Parallel cells per string | 3 | - |
| Coolant switch-on temperature | 320 | K |
| Coolant switch-off temperature | 303 | K |

Copyright 2022 - 2025 The MathWorks, Inc.

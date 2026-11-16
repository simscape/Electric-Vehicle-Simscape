# BatteryHeater Models

This folder contains the battery heater Simulink model and its parameter script.

---

## Heater

**File:** `Heater.slx`
**Parameter File:** `HeaterParams.m`
**Thermal Coupling:** Yes

### Description

Models the battery pack heater as a controlled current source drawing power from the HV bus. A thermal mass block captures heat storage and transfer, and the heater volume is coupled to the coolant loop for heat exchange with the battery pack. Energy consumption is tracked for range and efficiency studies.

### Workflows

- Part of the **VehicleElectroThermal** template used in range estimation and battery sizing workflows.
- Activated during cold-ambient simulations (e.g., -10 degC in the current range workflows) to keep battery temperature within operating limits.

### Input Bus — `s`

| Signal | Description |
|--------|-------------|
| BatSt | Battery status (temperature, SOC) |
| cmdHeater | Heater on/off command from thermal controller |

### Output Bus — `m`

| Signal | Description |
|--------|-------------|
| HeaterCurrent | Current drawn from the HV bus |
| energy | Cumulative energy consumed |

### Physical Ports

| Port | Domain | Description |
|------|--------|-------------|
| HV | Electrical | High-voltage bus connection |
| A | Thermal liquid | Coolant port |
| B | Thermal liquid | Coolant port |

---

## HeaterDummy

**File:** `HeaterDummy.slx`
**Parameter File:** `HeaterDummyParams.m`
**Thermal Coupling:** No (coolant pass-through, no heat exchange)

### Description

Minimal heater stub with the same port interface as the full Heater model. Internally draws a fixed electrical current from the HV bus when the heater is active (`cmdHeater = 1`). Coolant ports A and B are connected through a simple pipe so the coolant loop stays closed but no heat is exchanged. Used when the heater subsystem is not the focus but the system model needs a connected heater block to simulate.

### Workflows

- Placeholder variant for integration testing or fast electrical-only studies.
- Can replace `Heater` in the VehicleElectroThermal template without breaking the coolant loop.

### Input Bus — `s`

| Signal | Description |
|--------|-------------|
| BatSt | Battery status (terminated internally) |
| cmdHeater | Heater command: 1 = active, 0 = off |

### Output Bus — `m`

| Signal | Description |
|--------|-------------|
| HeaterCurrent | Fixed current when active, zero when off |
| energy | Cumulative energy consumed |

### Physical Ports

| Port | Domain | Description |
|------|--------|-------------|
| HV | Electrical | High-voltage bus connection |
| A | Thermal liquid | Coolant port (pass-through) |
| B | Thermal liquid | Coolant port (pass-through) |

---

### Key Parameters

| Parameter | Typical Value | Unit |
|-----------|--------------|------|
| Maximum heater power | 4000 | W |
| Coolant pipe diameter | 0.019 | m |
| Coolant jacket channel diameter | 0.0092 | m |
| Initial coolant temperature | 298.15 | K |

Copyright 2022 - 2026 The MathWorks, Inc.

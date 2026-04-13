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
- Activated during cold-ambient simulations (e.g., -20 degC) to keep battery temperature within operating limits.
- Referenced by `BEVSystemModelParams.m` which loads `HeaterParams.m`.

### Inputs

| Signal | Description |
|--------|-------------|
| Battery status | Pack voltage, current, temperature, and SOC from the BMS |
| Heater control command | On/off or proportional command from the thermal controller |
| HV bus connection | Electrical connection to draw heater current |

### Outputs

| Signal | Description |
|--------|-------------|
| Heater Current | Current drawn from the HV bus |
| HV Power | Electrical power consumed by the heater |
| Thermal States | Heater temperature and heat flow to coolant |

### Key Parameters

| Parameter | Typical Value | Unit |
|-----------|--------------|------|
| Maximum heater power | 4000 | W |
| Coolant pipe diameter | 0.019 | m |
| Coolant jacket channel diameter | 0.0092 | m |
| Initial coolant temperature | 298.15 | K |

Copyright 2022 - 2025 The MathWorks, Inc.

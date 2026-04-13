# PumpDriver Models

This folder contains the pump driver controller Simulink model and its parameter script.

---

## PumpDriver

**File:** `PumpDriver.slx`
**Parameter File:** `PumpDriverParams.m`
**Thermal Coupling:** Yes (coolant system interface)

### Description

Controller that converts thermal management status signals and pump enable commands into shaft speed setpoints for the coolant circulation pump. The PumpDriver determines the required coolant flow rate based on the thermal state of the system (battery temperature, motor temperature, etc.) and drives the Pump component accordingly.

### Workflows

- Part of the **VehicleElectroThermal** template coolant loop.
- Pairs with the Pump component to form the coolant circulation subsystem.
- Parameters include coolant pipe and jacket dimensions shared with other thermal components.

### Inputs

| Signal | Description |
|--------|-------------|
| Thermal status | System temperatures and thermal controller commands |
| Pump enable | Enable signal from the thermal management controller |

### Outputs

| Signal | Description |
|--------|-------------|
| Pump speed command | Shaft speed setpoint for the Pump |

### Key Parameters

| Parameter | Typical Value | Unit |
|-----------|--------------|------|
| Coolant pipe diameter | 0.019 | m |
| Coolant jacket channel diameter | 0.0092 | m |
| Initial coolant temperature | 298.15 | K |
| Initial coolant pressure | 0.101325 | MPa |

Copyright 2022 - 2025 The MathWorks, Inc.

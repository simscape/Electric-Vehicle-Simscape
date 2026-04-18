# DCDC Models

This folder contains the DC-DC pump driver Simulink models and parameter scripts.

---

## PumpDriver

**File:** `PumpDriver.slx`
**Parameter File:** `PumpDriverParams.m`
**Thermal Coupling:** No

### Description

Simplified DC-DC converter that translates thermal management status signals and pump enable commands into shaft speed setpoints for the coolant circulation pump. This variant has no coolant ports or thermal coupling - it provides only the electrical conversion and control logic.

### Workflows

- Non-thermal DCDC variant used in the **VehicleElecAux** template.
- Pairs with PumpDummy to provide pump control without coolant loop modelling.

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
| Output voltage | 24 | V |
| Output power | 2400 | W |

---

## PumpDriverTh

**File:** `PumpDriverTh.slx`
**Parameter File:** `PumpDriverThParams.m`
**Thermal Coupling:** Yes (coolant system interface)

### Description

Controller that converts thermal management status signals and pump enable commands into shaft speed setpoints for the coolant circulation pump. The PumpDriverTh determines the required coolant flow rate based on the thermal state of the system (battery temperature, motor temperature, etc.) and drives the Pump component accordingly. Includes thermal coupling for coolant interaction.

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
| Output voltage | 24 | V |
| Output power | 2400 | W |
| Coolant pipe diameter | 0.019 | m |
| Coolant jacket channel diameter | 0.0092 | m |

Copyright 2022 - 2026 The MathWorks, Inc.

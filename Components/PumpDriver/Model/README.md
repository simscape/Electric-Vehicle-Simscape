# DCDC Models

This folder contains the DC-DC pump driver Simulink models and parameter scripts.

---

## PumpDriver

**File:** `PumpDriver.slx`
**Parameter File:** `PumpDriverParams.m`
**Thermal Coupling:** No

### Description

DC-DC converter supplying the LV bus from HV electrical power. No coolant ports or signal commands.

### Workflows

- Non-thermal DCDC variant used in the **VehicleElecAux** template.
- Supplies PumpDummy's electrical load.

### Input / Output Bus

No Simulink signal bus interface. Operates entirely through physical connections.

### Physical Ports

| Port | Domain | Description |
|------|--------|-------------|
| HV | Electrical | High-voltage bus input |
| LV | Electrical | Low-voltage bus output |

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

DC-DC converter with converter thermal mass and coolant-jacket heat exchange. Supplies LV electrical power; pump commands come from the vehicle controller.

### Workflows

- Part of the **VehicleElectroThermal** template coolant loop.
- Pairs with the Pump component to form the coolant circulation subsystem.
- Parameters include coolant pipe and jacket dimensions shared with other thermal components.

### Input / Output Bus

No Simulink signal bus interface. Operates entirely through physical connections.

### Physical Ports

| Port | Domain | Description |
|------|--------|-------------|
| HV | Electrical | High-voltage bus input |
| LV | Electrical | Low-voltage bus output |
| A | Thermal liquid | Coolant port |
| B | Thermal liquid | Coolant port |

### Key Parameters

| Parameter | Typical Value | Unit |
|-----------|--------------|------|
| Output voltage | 24 | V |
| Output power | 2400 | W |
| Coolant pipe diameter | 0.019 | m |
| Coolant jacket channel diameter | 0.0092 | m |

Copyright 2022 - 2026 The MathWorks, Inc.

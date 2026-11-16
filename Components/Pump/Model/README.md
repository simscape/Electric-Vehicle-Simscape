# Pump Models

This folder contains the coolant pump Simulink model and its parameter script.

---

## Pump

**File:** `Pump.slx`
**Parameter File:** `PumpParams.m`
**Thermal Coupling:** N/A (supporting thermal infrastructure component)

### Description

Volumetric displacement pump for the coolant loop. The controller supplies `cmdPump`; PumpDriver supplies low-voltage electrical power.

### Workflows

- Part of the **VehicleElectroThermal** template coolant loop.
- Receives low-voltage power from PumpDriverTh.
- Parameters are defined in `PumpParams.m`.

### Input Bus — `s`

| Signal | Description |
|--------|-------------|
| BatSt | Battery status signal |
| cmdPump | Pump speed command |

### Output Bus — `m`

| Signal | Description |
|--------|-------------|
| PumpCurr | Pump current draw |
| LowVolt | Low-voltage bus measurement |
| energy | Cumulative energy consumed |

### Physical Ports

| Port | Domain | Description |
|------|--------|-------------|
| LV | Electrical | Low-voltage bus connection |
| A | Thermal liquid | Coolant port |
| B | Thermal liquid | Coolant port |

### Key Parameters

| Parameter | Typical Value | Unit |
|-----------|--------------|------|
| Pump displacement | 0.02 | L/rev |
| Max pump speed | 1000 | rpm |
| Coolant pipe diameter | 0.019 | m |

---

## PumpDummy

**File:** `PumpDummy.slx`
**Parameter File:** `PumpDummyParams.m`
**Thermal Coupling:** No (no coolant ports)

### Description

Fixed electrical load on the LV bus, with no command input or coolant ports.

### Workflows

- Placeholder variant in the **VehicleElecAux** template for auxiliary configurations without a coolant loop.
- Parameters loaded by `PumpDummyParams.m`.

### Input Bus

No input bus (no inports).

### Output Bus — `m`

| Signal | Description |
|--------|-------------|
| PumpCurr | Pump current draw |
| LowVolt | Low-voltage bus measurement |
| energy | Cumulative energy consumed |

### Physical Ports

| Port | Domain | Description |
|------|--------|-------------|
| LV | Electrical | Low-voltage bus connection |

### Key Parameters

| Parameter | Typical Value | Unit |
|-----------|--------------|------|
| Max pump current | 10 | A |

---

## PumpDummyTh

**File:** `PumpDummyTh.slx`
**Parameter File:** `PumpDummyThParams.m`
**Thermal Coupling:** No (coolant pass-through, no active pumping)

### Description

Minimal pump stub that maintains the same port interface as the full Pump model. Draws a fixed electrical current from the LV bus proportional to the pump command signal. Coolant ports A and B are connected through a simple pipe so the coolant loop stays closed, but no active pumping occurs.

### Workflows

- Placeholder variant in the **VehicleElectroThermal** template for integration testing or fast simulations.
- Parameters loaded by `PumpDummyThParams.m`.

### Input Bus — `s`

| Signal | Description |
|--------|-------------|
| BatSt | Battery status (terminated internally) |
| cmdPump | Pump speed command |

### Output Bus — `m`

| Signal | Description |
|--------|-------------|
| PumpCurr | Pump current draw |
| LowVolt | Low-voltage bus measurement |
| energy | Cumulative energy consumed |

### Physical Ports

| Port | Domain | Description |
|------|--------|-------------|
| LV | Electrical | Low-voltage bus connection |
| A | Thermal liquid | Coolant port (pass-through) |
| B | Thermal liquid | Coolant port (pass-through) |

### Key Parameters

| Parameter | Typical Value | Unit |
|-----------|--------------|------|
| Max pump current | 10 | A |
| Coolant pipe diameter | 0.019 | m |

Copyright 2022 - 2026 The MathWorks, Inc.

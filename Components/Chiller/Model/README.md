# Chiller Models

This folder contains the chiller Simulink models at different fidelity levels and their corresponding parameter scripts.

---

## Chiller

**File:** `Chiller.slx`
**Parameter File:** `ChillerParams.m`
**Thermal Coupling:** Yes

### Description

Models the battery coolant chiller as a controlled current source drawing power from the HV bus. A thermal mass block captures heat absorption and storage, and a chiller volume is coupled to the coolant loop for active heat exchange. Energy drawn from the HV bus is tracked for efficiency and range studies.

### Workflows

- Part of the **VehicleElectroThermal** template for full-thermal vehicle simulations.
- Active during hot-ambient range estimation runs (e.g., 35 degC with AC on/off).
- Validated through `ChillerTestHarness.slx`.

### Input Bus — `s`

| Signal | Description |
|--------|-------------|
| cmdChillerByp | Chiller bypass command (0 = active, 1 = bypass) |
| BatSt | Battery status signal |

### Output Bus — `m`

| Signal | Description |
|--------|-------------|
| ChillerCurrent | Current drawn from the HV bus |
| energy | Cumulative energy consumed |

### Physical Ports

| Port | Domain | Description |
|------|--------|-------------|
| HV | Electrical | High-voltage bus connection |
| A | Thermal liquid | Coolant port |
| B | Thermal liquid | Coolant port |

---

## ChillerNoCoolant

**File:** `ChillerNoCoolant.slx`
**Parameter File:** `ChillerNoCoolantParams.m`
**Thermal Coupling:** No

### Description

Simplified chiller model without coolant loop coupling. The electrical load on the HV bus is represented but there are no thermal-liquid ports. This fidelity is used when the vehicle model does not include a coolant loop but the chiller power draw still needs to be accounted for.

### Workflows

- A simplified variant used as a standalone auxiliary load where the coolant loop is not modeled.
- Suitable for fast electrical-only simulations where auxiliary power consumption matters.

### Input Bus — `s`

| Signal | Description |
|--------|-------------|
| cmdChillerByp | Chiller bypass command |
| BatSt | Battery status signal |

### Output Bus — `m`

| Signal | Description |
|--------|-------------|
| ChillerCurrent | Current drawn from the HV bus |
| energy | Cumulative energy consumed |

### Physical Ports

| Port | Domain | Description |
|------|--------|-------------|
| HV | Electrical | High-voltage bus connection |

---

## ChillerDummy

**File:** `ChillerDummy.slx`
**Parameter File:** `ChillerDummyParams.m`
**Thermal Coupling:** No (coolant pass-through, no heat exchange)

### Description

Minimal chiller stub with the same port interface as the full Chiller model. Internally draws a fixed electrical current from the HV bus when the chiller is active (`cmdChillerByp = 0`). Coolant ports A and B are connected through a simple pipe so the coolant loop stays closed but no heat is exchanged. Used when the chiller subsystem is not the focus but the system model needs a connected chiller block to simulate.

### Workflows

- Placeholder variant for integration testing or fast electrical-only studies.
- Can replace `Chiller` in the VehicleElectroThermal template without breaking the coolant loop.

### Input Bus — `s`

| Signal | Description |
|--------|-------------|
| cmdChillerByp | Chiller bypass command (0 = active, 1 = bypass) |
| Batt.BatSt | Battery status signal |

### Output Bus — `m`

| Signal | Description |
|--------|-------------|
| ChillerCurrent | Fixed current when active, zero when bypassed |
| energy | Cumulative energy consumed |

### Physical Ports

| Port | Domain | Description |
|------|--------|-------------|
| HV | Electrical | High-voltage bus connection |
| A | Thermal liquid | Coolant port (pass-through) |
| B | Thermal liquid | Coolant port (pass-through) |

---

## Parameter Summary

| Parameter | Typical Value | Unit |
|-----------|--------------|------|
| Maximum chiller power | 6000 | W |
| Coolant pipe diameter | 0.019 | m |
| Initial coolant temperature | 298.15 | K |
| Initial coolant pressure | 0.101325 | MPa |

Copyright 2022 - 2026 The MathWorks, Inc.

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
- Parameters loaded by `BEVSystemModelParams.m` via `ChillerParams.m`.
- Validated through `ChillerTestHarness.slx`.

### Inputs

| Signal | Description |
|--------|-------------|
| Battery status | Pack temperature and thermal state from the BMS |
| Chiller bypass control | On/off or bypass command from the thermal controller |
| HV bus connection | Electrical connection for chiller power draw |
| Coolant port | Thermal-liquid interface for coolant loop heat exchange |

### Outputs

| Signal | Description |
|--------|-------------|
| Chiller Current | Current drawn from the HV bus |
| HV Power | Electrical power consumed |
| Thermal States | Chiller temperature and heat flow to coolant |

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

### Inputs

| Signal | Description |
|--------|-------------|
| Battery status | Pack state signals |
| Chiller bypass control | Enable command |
| HV bus connection | Electrical connection for power draw |

### Outputs

| Signal | Description |
|--------|-------------|
| Chiller Current | Current drawn from the HV bus |
| HV Power | Electrical power consumed |

---

## ChillerDummy

**File:** `ChillerDummy.slx`
**Parameter File:** `ChillerDummyParams.m`
**Thermal Coupling:** No (coolant pass-through, no heat exchange)

### Description

Minimal chiller stub with the same port interface as the full Chiller model. Internally draws a fixed electrical current from the HV bus when the chiller is active (`cmdChillerByp = 0`). Coolant ports A and B are connected through a simple pipe so the coolant loop stays closed but no heat is exchanged. Used when the chiller subsystem is not the focus but the system model needs a connected chiller block to simulate.

### Workflows

- Placeholder variant for integration testing or fast electrical-only studies.
- Can replace `Chiller` in any vehicle template without breaking the coolant loop.
- Build the model by running `createChillerDummy.m` from this folder.

### Inputs

| Signal | Description |
|--------|-------------|
| Battery status | Pack state signals (terminated internally) |
| Chiller bypass control | 0 = active (draws load), 1 = bypassed (no load) |
| HV bus connection | Electrical connection for fixed power draw |
| Coolant port | Thermal-liquid interface (pass-through, no heat exchange) |

### Outputs

| Signal | Description |
|--------|-------------|
| Chiller Current | Fixed current when active, zero when bypassed |
| HV Power | Nominal electrical power consumed |

---

## Parameter Summary

| Parameter | Typical Value | Unit |
|-----------|--------------|------|
| Maximum chiller power | 6000 | W |
| Coolant pipe diameter | 0.019 | m |
| Initial coolant temperature | 298.15 | K |
| Initial coolant pressure | 0.101325 | MPa |

Copyright 2022 - 2025 The MathWorks, Inc.

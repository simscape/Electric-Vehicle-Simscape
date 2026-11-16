# Charger Models

This folder contains the onboard charger Simulink models at different fidelity levels and their corresponding parameter scripts.

---

## Charger

**File:** `Charger.slx`
**Parameter File:** `ChargerParams.m`
**Thermal Coupling:** No

### Description

Constant-current / constant-voltage (CC-CV) charging controller without thermal dynamics. The model generates a charging current command and applies it to the HV bus based on relay commands, battery cell voltage, and charging state inputs.

### Workflows

- Listed in the **VehicleElectric** and **VehicleElecAux** templates in `VehicleTemplateConfig.json`.
- Suitable for electrical-only charging studies without thermal management.

### Input Bus — `s`

| Signal | Description |
|--------|-------------|
| Batt.Relay.RelayChg | Charge relay command |
| Batt.BattSensor.CellVoltMax | Maximum cell voltage for CC-CV transition |

### Output Bus

No output bus. Operates via physical HV port only.

### Physical Ports

| Port | Domain | Description |
|------|--------|-------------|
| HV | Electrical | High-voltage bus connection |

---

## ChargerDummy

**File:** `ChargerDummy.slx`
**Parameter File:** `ChargerDummyParams.m`
**Thermal Coupling:** No

### Description

Minimal stub charger providing the same port interface as the full Charger model. No internal parameter requirements -- used when the charger subsystem is not the focus but the system model needs a connected charger block to simulate.

### Workflows

- Placeholder variant for integration testing or when charger behavior is not under study.

### Input Bus — `s`

| Signal | Description |
|--------|-------------|
| (terminated) | Input bus `s` is terminated in this fidelity |

### Output Bus

No output bus.

### Physical Ports

| Port | Domain | Description |
|------|--------|-------------|
| HV | Electrical | High-voltage bus connection |

---

## ChargerThermal

**File:** `ChargerThermal.slx`
**Parameter File:** `ChargerThermalParams.m`
**Thermal Coupling:** Yes

### Description

CC-CV charger with a thermal representation of the power converter. The controlled current source charges the battery through the HV bus while heat generated in the converter is dissipated through a coolant jacket. This fidelity enables thermal management studies during charging events.

### Workflows

- Used in the **VehicleElectroThermal** template for full-thermal charging studies.
- Referenced by the charger test harness (`ChargerTestHarness.slx`).

### Input Bus — `s`

| Signal | Description |
|--------|-------------|
| Batt.Relay.RelayChg | Charge relay command |
| Batt.BattSensor.CellVoltMax | Maximum cell voltage for CC-CV transition |

### Output Bus

No output bus.

### Physical Ports

| Port | Domain | Description |
|------|--------|-------------|
| HV | Electrical | High-voltage bus connection |
| A | Thermal liquid | Coolant port |
| B | Thermal liquid | Coolant port |

---

## ChargerThermalDummy

**File:** `ChargerThermalDummy.slx`
**Parameter File:** `ChargerThermalDummyParams.m`
**Thermal Coupling:** Yes

### Description

Dummy variant of the thermal charger. Exposes the same thermal ports as ChargerThermal so the coolant loop remains closed, but requires no internal parameter data. Used when real charger thermal data is not yet available.

### Workflows

- Placeholder for thermal-loop integration testing.

### Input Bus — `s`

| Signal | Description |
|--------|-------------|
| Batt.Relay.RelayChg | Charge relay command |
| Batt.BattSensor.CellVoltMax | Maximum cell voltage |

### Output Bus

No output bus.

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
| Maximum voltage | 4.2 | V |
| Constant current (CC) | 50 | A |
| Controller Kp | 1 | - |
| Controller Ki | 1 | - |
| Coolant jacket channel diameter | 0.0092 | m |
| Initial coolant temperature | 298.15 | K |

Copyright 2022 - 2026 The MathWorks, Inc.

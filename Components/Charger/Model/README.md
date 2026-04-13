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

### Inputs

| Signal | Description |
|--------|-------------|
| Relay command | Enables charger connection to the HV bus |
| Battery cell voltage | Feedback for CC-CV transition |
| Charging state | Charge enable and mode signal from the BMS |

### Outputs

| Signal | Description |
|--------|-------------|
| Charging Current | Current delivered to the battery pack |
| HV Power | Electrical power drawn from the grid |

---

## ChargerDummy

**File:** `ChargerDummy.slx`
**Parameter File:** `ChargerDummyParams.m`
**Thermal Coupling:** No

### Description

Minimal stub charger providing the same port interface as the full Charger model. No internal parameter requirements -- used when the charger subsystem is not the focus but the system model needs a connected charger block to simulate.

### Workflows

- Placeholder variant for integration testing or when charger behavior is not under study.

### Inputs

| Signal | Description |
|--------|-------------|
| Relay command | Charger enable |
| Battery cell voltage | CC-CV feedback (passed through) |
| Charging state | Charge mode signal |

### Outputs

| Signal | Description |
|--------|-------------|
| Charging Current | Nominal or zero current |
| HV Power | Nominal or zero power |

---

## ChargerThermal

**File:** `ChargerThermal.slx`
**Parameter File:** `ChargerThermalParams.m`
**Thermal Coupling:** Yes

### Description

CC-CV charger with a thermal representation of the power converter. The controlled current source charges the battery through the HV bus while heat generated in the converter is dissipated through a coolant jacket. This fidelity enables thermal management studies during charging events.

### Workflows

- Used in the **VehicleElectroThermal** template for full-thermal charging studies.
- Parameters loaded by `BEVSystemModelParams.m` (via `ChargerThermalParams.m`).
- Referenced by the charger test harness (`ChargerTestHarness.slx`).

### Inputs

| Signal | Description |
|--------|-------------|
| Relay command | Charger enable |
| Battery cell voltage | CC-CV transition feedback |
| Charging status | Charge mode from BMS |
| Coolant port | Thermal-liquid interface for converter cooling |

### Outputs

| Signal | Description |
|--------|-------------|
| Charging Current | Current delivered to the battery |
| HV Power | Electrical power consumed |
| Converter Thermal States | Converter temperature, heat flow to coolant |

---

## ChargerThermalDummy

**File:** `ChargerThermalDummy.slx`
**Parameter File:** `ChargerThermalDummyParams.m`
**Thermal Coupling:** Yes

### Description

Dummy variant of the thermal charger. Exposes the same thermal ports as ChargerThermal so the coolant loop remains closed, but requires no internal parameter data. Used when real charger thermal data is not yet available.

### Workflows

- Placeholder for thermal-loop integration testing.

### Inputs

| Signal | Description |
|--------|-------------|
| Relay command | Charger enable |
| Battery cell voltage | CC-CV feedback |
| Charging status | Charge mode signal |
| Coolant port | Thermal-liquid interface (pass-through) |

### Outputs

| Signal | Description |
|--------|-------------|
| Charging Current | Nominal or zero current |
| HV Power | Nominal or zero power |
| Converter Thermal States | Minimal thermal output |

---

## ChargerWithThermal

**File:** `ChargerWithThermal.slx`
**Parameter File:** `ChargerWithThermalParams.m`
**Thermal Coupling:** Yes

### Description

Combined charger model that integrates electrical CC-CV control and thermal converter dynamics into a single subsystem reference block. This simplifies vehicle-level model assembly by providing one reference block instead of separate electrical and thermal charger subsystems.

### Workflows

- Used in electro-thermal vehicle configurations where a unified charger subsystem reference is preferred.
- Configured through the BEV Setup App for streamlined model creation.

### Inputs

| Signal | Description |
|--------|-------------|
| Relay command | Charger enable |
| Battery cell voltage | CC-CV transition feedback |
| Charging status | Charge mode from BMS |
| Coolant port | Thermal-liquid interface for converter cooling |

### Outputs

| Signal | Description |
|--------|-------------|
| Charging Current | Current delivered to the battery |
| HV Power | Electrical power consumed |
| Converter Thermal States | Converter temperature and heat flow |

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

Copyright 2022 - 2025 The MathWorks, Inc.

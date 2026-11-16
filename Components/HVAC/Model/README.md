# HVAC Models

This folder contains the HVAC Simulink models at different fidelity levels and their corresponding parameter scripts.

---

## HVACEmpiricalRef

**File:** `HVACEmpiricalRef.slx`
**Parameter File:** `HVACEmpiricalRefParams.m`
**Thermal Coupling:** No (empirical performance curves, no physical fluid dynamics)

### Description

Empirical-based HVAC model with cabin and refrigeration subsystems. Cabin blower, PTC heater, and compressor are driven by control commands, and their performance is captured through lookup tables rather than physical refrigerant dynamics. A controlled current source represents the HVAC electrical power draw from the HV bus. An energy monitoring block tracks total HVAC consumption.

### Workflows

- Listed in the **VehicleElecAux** and **VehicleElectroThermal** templates in `VehicleTemplateConfig.json`.
- Default fidelity in the HVAC test harness.
- Suitable for cabin comfort studies and HVAC energy-demand evaluation without modeling the refrigerant loop.

### Input Bus — `s`

| Signal | Description |
|--------|-------------|
| Env.Tenv | Environment temperature |
| Env | Environment bus (full struct: Tenv, Penv, RHenv, CO2env) |
| Batt.BatSt | Battery status |
| Batt | Battery bus (voltage) |
| Cntrl.CmdBlower | Blower speed command |
| Cntrl.CmdPTC | PTC heater command |
| Cntrl.acOnOff | AC on/off command |

### Output Bus — `m`

| Signal | Description |
|--------|-------------|
| energy | Cumulative HVAC energy consumption |
| Tcabin | Cabin air temperature |
| TacVent | AC vent temperature |
| Tptc | PTC heater temperature |

### Physical Ports

| Port | Domain | Description |
|------|--------|-------------|
| HV | Electrical | High-voltage bus connection |

---

## HVACsimpleTh

**File:** `HVACsimpleTh.slx`
**Parameter File:** `HVACsimpleThParams.m`
**Thermal Coupling:** Yes

### Description

HVAC model with a cabin thermal plant. The cabin air volume is linked with cabin heat transfer and the external environment. A blower, cooler, and PTC heater interact with the cabin air mass to regulate temperature. A controlled current source models the HVAC electrical load, and an HVAC demand block computes the required cooling or heating power. Energy monitoring tracks HVAC consumption from the HV bus.

### Workflows

- **Default HVAC fidelity** for the VehicleElectroThermal template.
- Used in range estimation workflows for hot and cold ambient scenarios.
- Validated through `HVACTestHarness.slx`.

### Input Bus — `s`

| Signal | Description |
|--------|-------------|
| Env.Tenv | Environment temperature |
| Batt.BatSt | Battery status |
| Batt | Battery bus (voltage) |
| Cntrl.CmdBlower | Blower speed command |
| Cntrl.CmdPTC | PTC heater command |
| Cntrl.CmdCool | Cooler/compressor command |

### Output Bus — `m`

| Signal | Description |
|--------|-------------|
| energy | Cumulative HVAC energy consumption |
| Tcabin | Cabin air temperature |
| TacVent | AC vent temperature |
| Tptc | PTC heater temperature |

### Physical Ports

| Port | Domain | Description |
|------|--------|-------------|
| HV | Electrical | High-voltage bus connection |

---

## Key Parameters

| Parameter | Typical Value | Unit |
|-----------|--------------|------|
| Cabin initial pressure | 0.101325 | MPa |
| Cabin initial temperature | 298.15 | K |
| Cabin initial relative humidity | 0.4 | - |
| Cabin setpoint temperature | 293.15 | K |
| Cabin duct area | 0.04 | m^2 |
| Number of passengers | 1 | - |
| Per-person heat transfer | 70 | W |

Copyright 2022 - 2026 The MathWorks, Inc.

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
- Suitable for cabin comfort studies and HVAC energy-demand evaluation without modeling the refrigerant loop.

### Inputs

| Signal | Description |
|--------|-------------|
| Environment temperature | Ambient air temperature |
| Blower command | Blower speed or enable signal |
| PTC command | Cabin heater power command |
| Compressor command | AC compressor enable |

### Outputs

| Signal | Description |
|--------|-------------|
| Cabin Temperature | Simulated cabin air temperature |
| HVAC Energy | Cumulative HVAC energy consumption |
| Blower/Cooler/PTC States | Operating states of HVAC actuators |

---

## HVACsimpleTh

**File:** `HVACsimpleTh.slx`
**Parameter File:** `HVACsimpleThParams.m`
**Thermal Coupling:** Yes

### Description

HVAC model with a cabin thermal plant. The cabin air volume is linked with cabin heat transfer and the external environment. A blower, cooler, and PTC heater interact with the cabin air mass to regulate temperature. A controlled current source models the HVAC electrical load, and an HVAC demand block computes the required cooling or heating power. Energy monitoring tracks HVAC consumption from the HV bus.

### Workflows

- **Default HVAC fidelity** loaded by `BEVSystemModelParams.m` (via `HVACsimpleThParams.m`).
- Used in range estimation workflows for hot and cold ambient scenarios.
- Validated through `HVACTestHarness.slx`.

### Inputs

| Signal | Description |
|--------|-------------|
| Environment temperature | Ambient air temperature |
| Blower command | Blower speed or enable signal |
| PTC command | Cabin heater power command |
| Compressor command | AC compressor enable |

### Outputs

| Signal | Description |
|--------|-------------|
| Cabin Temperature | Cabin air temperature from thermal dynamics |
| HVAC Energy | Cumulative HVAC energy consumption |
| Blower/Cooler/PTC Thermal States | Thermal operating states of HVAC actuators |

---

## HVACThermal

**File:** `HVACThermal.slx`
**Parameter File:** `HVACThermalParams.m`
**Thermal Coupling:** Yes

### Description

Full thermal HVAC model with detailed cabin and refrigerant loop dynamics. Provides the highest fidelity cabin comfort and thermal management representation. Includes physical modeling of the refrigerant cycle, evaporator, and condenser in addition to cabin air volume dynamics.

### Workflows

- Compatible with the **VehicleElecAux** and **VehicleElectroThermal** templates defined in `VehicleTemplateConfig.json`. Provides higher fidelity than the default HVAC options.
- Used for HVAC control strategy development and detailed thermal management analysis.
- Parameters loaded via `HVACThermalParams.m` and `BEVThermalManagementparam.m`.

### Inputs

| Signal | Description |
|--------|-------------|
| Environment temperature | Ambient air temperature |
| Blower command | Blower speed or enable signal |
| PTC command | Cabin heater power command |
| Compressor command | AC compressor enable |
| Coolant port | Thermal-liquid interface for HVAC-coolant interaction |

### Outputs

| Signal | Description |
|--------|-------------|
| Cabin Temperature | Cabin air temperature |
| HVAC Energy | Cumulative energy consumption |
| Refrigerant States | Evaporator and condenser thermal states |
| Blower/Cooler/PTC Thermal States | Actuator thermal operating states |

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

Copyright 2022 - 2025 The MathWorks, Inc.

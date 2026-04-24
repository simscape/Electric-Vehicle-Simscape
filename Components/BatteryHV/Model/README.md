# BatteryHV Models

This folder contains the high-voltage battery pack Simulink models at different fidelity levels and their corresponding parameter scripts.

---

## BatteryLumped

**File:** `BatteryLumped.slx`
**Parameter File:** `BatteryLumpedParams.m`
**Thermal Coupling:** No

### Description

Simplified lumped-parameter battery model without thermal dynamics. The model uses a constant or externally fixed temperature and represents the pack electrical behavior through a lumped equivalent circuit. Positive and negative relay commands control the HV bus connection.

### Workflows

- Used in the **VehicleElectric** template for fast drive-cycle simulations where thermal effects are not needed.
- Suitable for controller development and quick range sweeps.

### Inputs

| Signal | Description |
|--------|-------------|
| Positive relay command | Connects the battery positive terminal to the HV bus |
| Negative relay command | Connects the battery negative terminal to the HV bus |

### Outputs

| Signal | Description |
|--------|-------------|
| Voltage | Pack terminal voltage |
| Current | Pack current |
| SOC | State of charge |
| Temperature | Fixed or externally supplied temperature |
| Cell Voltage | Individual cell voltage estimate |

---

## BatteryLumpedThermal

**File:** `BatteryLumpedThermal.slx`
**Parameter File:** `BatteryLumpedThermalParams.m`
**Thermal Coupling:** Yes

### Description

Lumped battery model with a single thermal mass node. The electrical behavior is temperature-dependent, and the model includes a coolant port for heat exchange with the vehicle thermal management loop. This fidelity balances simulation speed with basic thermal response.

### Workflows

- Used in the **VehicleElectroThermal** template when a fast thermal approximation is sufficient.
- Referenced in the battery test harness (`TestBench/BatteryTestHarness.slx`) for component-level validation.
- Parameters are loaded by `BatteryTestHarnessParams.m` during test bench runs.

### Inputs

| Signal | Description |
|--------|-------------|
| Positive relay command | HV bus positive connection |
| Negative relay command | HV bus negative connection |
| Coolant port | Thermal-liquid interface for coolant loop heat exchange |

### Outputs

| Signal | Description |
|--------|-------------|
| Voltage | Pack terminal voltage |
| Current | Pack current |
| SOC | State of charge |
| Temperature | Lumped pack temperature |
| Cell Voltage | Individual cell voltage estimate |

---

## BatteryTableBased

**File:** `BatteryTableBased.slx`
**Parameter File:** `BatteryTableBasedParams.m`
**Thermal Coupling:** Yes

### Description

High-fidelity table-based battery model. Electrical characteristics come from lookup tables mapping SOC and temperature to open-circuit voltage and internal resistance. The model includes a thermal port for coupling with the coolant loop and battery heater. Positive and negative relays manage HV bus connectivity.

### Workflows

- **Default battery fidelity** in the assembled BEV system model (`BEVsystemModel.slx`).
- Used by `BEVSystemModelParams.m` when running range estimation (NEDC, WLTC, EPA) and battery sizing workflows.
- Cell characterization workflow (`Workflow/Battery/CellCharacterization/`) generates the lookup-table parameters consumed by this model.
- Virtual sensor neural network workflow uses simulation data from this model for training.

### Inputs

| Signal | Description |
|--------|-------------|
| Positive relay command | HV bus positive connection |
| Negative relay command | HV bus negative connection |
| Coolant port | Thermal-liquid interface for coolant and heater coupling |

### Outputs

| Signal | Description |
|--------|-------------|
| Voltage | Pack terminal voltage |
| Current | Pack current |
| SOC | State of charge |
| Cell Voltage | Individual cell voltage |
| Temperature | Pack temperature from thermal dynamics |

---

## Parameter Summary

All parameter scripts share a common structure:

| Parameter | Typical Value | Unit |
|-----------|--------------|------|
| Temperature vector | [278, 293, 313] | K |
| Cell capacity | 34 | Ah |
| SOC vector | [0, 0.1, 0.25, 0.5, 0.75, 0.9, 1] | - |
| Initial pack SOC | 0.75 | - |
| Coolant pipe diameter | 0.019 | m |
| Initial coolant temperature | 298.15 | K |

Copyright 2022 - 2025 The MathWorks, Inc.

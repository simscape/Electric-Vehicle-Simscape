# Pump Models

This folder contains the coolant pump Simulink model and its parameter script.

---

## Pump

**File:** `Pump.slx`
**Parameter File:** `PumpParams.m`
**Thermal Coupling:** N/A (supporting thermal infrastructure component)

### Description

Volumetric displacement pump that circulates coolant through the BEV thermal management loop. The pump speed is controlled by the thermal management controller (via the PumpDriver) and determines the coolant flow rate through the battery, motor drive, charger, chiller, heater, and radiator subsystems.

### Workflows

- Part of the **VehicleElectroThermal** template coolant loop.
- Works in conjunction with the PumpDriver component, which translates thermal controller commands into pump speed.
- Parameters loaded by `BEVThermalParams.m`.

### Inputs

| Signal | Description |
|--------|-------------|
| Pump speed command | Shaft speed from the PumpDriver |
| Coolant inlet port | Thermal-liquid inlet from the coolant loop |

### Outputs

| Signal | Description |
|--------|-------------|
| Coolant outlet port | Pressurized coolant flow to downstream components |
| Pump power | Mechanical power consumed |

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
**Thermal Coupling:** No (coolant pass-through, no active pumping)

### Description

Minimal pump stub that maintains the same port interface as the full Pump model. Draws a fixed electrical current from the LV bus proportional to the pump command signal. Coolant ports A and B are connected through a simple pipe so the coolant loop stays closed, but no active pumping occurs.

### Workflows

- Placeholder variant in the **VehicleElectroThermal** template for integration testing or fast simulations.
- Parameters loaded by `PumpDummyParams.m`.

### Inputs

| Signal | Description |
|--------|-------------|
| Battery status | Pack state signals (terminated internally) |
| Pump command | Normalized command (0 = off, 1 = full current draw) |
| LV bus | Low-voltage electrical connection |
| Coolant port A | Thermal-liquid inlet (pass-through) |

### Outputs

| Signal | Description |
|--------|-------------|
| Pump Current | Current drawn from LV bus (I_fixed x PumpCmd) |
| Low Voltage | Measured LV bus voltage |
| Coolant port B | Thermal-liquid outlet (pass-through) |

### Key Parameters

| Parameter | Typical Value | Unit |
|-----------|--------------|------|
| Max pump current | 10 | A |
| Coolant pipe diameter | 0.019 | m |

Copyright 2022 - 2025 The MathWorks, Inc.

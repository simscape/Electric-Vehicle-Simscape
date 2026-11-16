# Radiator Models

This folder contains the radiator Simulink model and its parameter script.

---

## Radiator

**File:** `Radiator.slx`
**Parameter File:** `RadiatorParams.m`
**Thermal Coupling:** Yes

### Description

Cross-flow heat exchanger that dissipates heat from the coolant loop to the ambient environment. The radiator is modeled with multiple coolant tubes, air fins, and fan-driven airflow. Heat transfer is computed from the primary surface area (tube walls) and the fin surface area. Two fans provide forced-air convection. The radiator connects to the coolant loop downstream of the thermal components (battery, motor, charger) and upstream of the coolant tank and pump.

### Workflows

- Part of the **VehicleElectroThermal** template coolant loop.
- Active during all electro-thermal drive-cycle simulations to reject heat and maintain coolant temperature.
- The fan command controls airflow; this model has no electrical interface and does not report fan power consumption.
- Parameters loaded by `BEVThermalParams.m` and `RadiatorParams.m`.

### Input Bus — `s`

| Signal | Description |
|--------|-------------|
| Env | Environment conditions sub-bus (Tenv, Penv, RHenv, CO2env) |
| VehSpd | Vehicle speed (ram air effect) |
| cmdFan | Fan speed command |

### Output Bus

No output bus. Operates via physical ports only.

### Physical Ports

| Port | Domain | Description |
|------|--------|-------------|
| A | Thermal liquid | Coolant port (inlet) |
| B | Thermal liquid | Coolant port (outlet) |

### Key Parameters

| Parameter | Typical Value | Unit |
|-----------|--------------|------|
| Radiator length | 0.6 | m |
| Radiator width | 0.015 | m |
| Radiator height | 0.2 | m |
| Number of coolant tubes | 25 | - |
| Coolant tube height | 0.0015 | m |
| Fin spacing | 0.002 | m |
| Wall thickness | 1e-4 | m |
| Wall thermal conductivity | 240 | W/m/K |
| Fan flow area | 0.5 (2 fans) | m^2 |

Copyright 2022 - 2026 The MathWorks, Inc.

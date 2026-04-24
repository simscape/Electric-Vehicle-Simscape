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
- Fan power is tracked as an auxiliary load on the HV bus.
- Parameters loaded by `BEVThermalParams.m` and `RadiatorParams.m`.

### Inputs

| Signal | Description |
|--------|-------------|
| Coolant inlet | Hot coolant from the thermal management loop |
| Ambient temperature | External air temperature |
| Fan airflow | Forced-air flow driven by radiator fans |
| Vehicle speed | Ram-air contribution to airflow at higher speeds |

### Outputs

| Signal | Description |
|--------|-------------|
| Coolant outlet | Cooled coolant returned to the loop |
| Heat dissipation rate | Thermal power rejected to ambient |

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

Copyright 2022 - 2025 The MathWorks, Inc.

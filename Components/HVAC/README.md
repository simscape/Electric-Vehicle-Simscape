# HVAC

Heating, ventilation, and air conditioning component for the BEV system model. The HVAC subsystem manages cabin comfort by controlling blower airflow, PTC heating, and compressor-based cooling. It draws power from the HV bus and has a significant impact on vehicle range, especially under extreme ambient conditions. Two fidelity levels are available.

## Model Fidelities

| Model | Description | Thermal | Use Case |
|-------|-------------|:-------:|----------|
| [HVACEmpiricalRef](Model/README.md#hvacempiricalref) | Empirical-based HVAC with cabin and refrigeration subsystems. Uses lookup-table-driven performance curves rather than physical fluid dynamics. | No | Fast cabin-comfort and HVAC energy-demand studies where refrigerant loop dynamics are not needed. |
| [HVACsimpleTh](Model/README.md#hvacsimpleth) | HVAC with a cabin thermal model including air volume, cabin heat transfer, and environment coupling. Blower, cooler, and PTC heater interact with the cabin air mass. | Yes | System-level range estimation studies where cabin temperature response and HVAC energy consumption matter. |
## Folder Structure

```
HVAC/
  Model/        - Simulink models and parameter scripts
  TestBench/    - Test harness (HVACTestHarness.slx)
  TestCase/     - Unit tests (HVACPassTests.m)
```

## Related Workflows

- **Range Estimation** (`Workflow/Vehicle/RangeEstimation/`) -- HVAC power consumption is a major factor in range under cold (heating) and hot (cooling) ambient conditions. The AC on/off flag directly toggles HVAC load in the simulation.
- **Electro-Thermal Vehicle Studies** -- HVACsimpleTh and HVACEmpiricalRef are used in the VehicleElectroThermal template.
- **BEV Setup App** (`APP/`) -- The app configuration lists HVACsimpleTh and HVACEmpiricalRef for the electro-thermal template. The AC button and cabin setpoint controls in the app map to HVAC parameters.

## Vehicle Configurations

- **VehicleElecAux** and **VehicleElectroThermal**: Uses HVACsimpleTh or HVACEmpiricalRef (configured via `VehicleTemplateConfig.json`).
- **BEVSystemModelParams.m**: Loads `HVACsimpleThParams.m` by default.
- **ControllerHVAC**: The HVAC-aware controller variant coordinates blower, compressor, and PTC commands with drivetrain torque control.

Copyright 2022 - 2025 The MathWorks, Inc.

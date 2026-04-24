# Model

System-level vehicle model for the BEV Simscape project. `BEVsystemModel.slx` assembles components from `Components/` via subsystem references.

---

## Folder Structure

```
Model/
  BEVsystemModel.slx    - Main system model (top-level wiring diagram)
  VehicleTemplate/       - Pre-configured vehicle templates
  Display/               - Energy flow display subsystems
```

Vehicle templates are documented in [VehicleTemplate/README.md](VehicleTemplate/README.md). Display models (`EnergyElectric`, `EnergyElectroThermal`) provide energy flow visualization during simulation.

Template-to-component fidelity mappings are defined in JSON config files under `APP/Config/Preset/`.

Copyright 2026 The MathWorks, Inc.

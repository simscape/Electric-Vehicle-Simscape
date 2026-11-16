# Model

System-level vehicle model for the BEV Simscape project. `BEVsystemModel.slx` assembles components from `Components/` via subsystem references.

---

## Folder Structure

```
Model/
  BEVsystemModel.slx    - Main system model (top-level wiring diagram)
  VehicleTemplate/       - Pre-configured vehicle templates
```

Vehicle templates are documented in [VehicleTemplate/README.md](VehicleTemplate/README.md). Energy logging is handled per-component via DataLogging on each component's `energy` output signal.

## Current Status: Display Folder Removed

The standalone `Model/Display/` subsystem models are intentionally not part of
the current project. The following files remain on the `BEVgitHub` branch but
their removal from the current branch is expected:

- `Model/Display/EnergyElectric.slx`
- `Model/Display/EnergyElectroThermal.slx`
- `Model/Display/README.md`

Do not treat these files as missing migration work unless the standalone
energy-flow display feature is explicitly reintroduced.

Template-to-component fidelity mappings are defined in JSON config files under `utils/APP/Config/Preset/`.

Copyright 2026 The MathWorks, Inc.

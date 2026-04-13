# Components

Self-contained, reusable subsystem modules for the Battery Electric Vehicle (BEV) Simscape system model. Each component is a standalone unit that encapsulates its Simulink models, parameters, test infrastructure, and documentation in one folder. Components are referenced by the system-level model (`Model/BEVsystemModel.slx`) via Simulink subsystem references, allowing any component to be swapped, upgraded, or extracted independently.

---

## Component Architecture

Every component follows a standardized folder structure:

```
Components/<ComponentName>/
  Model/           - Simulink models (.slx) and parameter scripts (*Params.m)
  TestBench/       - Standalone test harness for isolated validation
  TestCase/        - MATLAB unit tests (*PassTests.m)
  Documentation/   - Published HTML documentation and images
    html/          - Published HTML pages
    images/        - Screenshots and figures
  Utilities/       - Plot functions and helper scripts
  Library/         - Reusable Simulink library blocks (select components only)
  README.md        - Component overview, fidelity table, folder map
  Model/README.md  - Per-fidelity model descriptions, I/O, parameters
```

Not every component requires all folders. The Controller has no TestBench (it is tested at the system level). Only BatteryHV, HVAC, and MotorDrive have Library folders for shared Simulink blocks. But every component has at minimum: `Model/`, `TestCase/`, and `Documentation/`.

---

## Component Inventory

| Component | Description | Fidelities | Thermal | Test Harness |
|-----------|-------------|:----------:|:-------:|:------------:|
| [BatteryHV](BatteryHV/README.md) | High-voltage battery pack (lumped, lumped-thermal, table-based) | 3 | Yes | Yes |
| [BatteryHeater](BatteryHeater/README.md) | PTC heater for cold-climate battery warming | 1 | Yes | Yes |
| [BMS](BMS/README.md) | Battery management system with SOC estimation variants | 3 | Yes | Yes |
| [Charger](Charger/README.md) | On-board charger with CC-CV control and thermal variants | 5 | Yes | Yes |
| [Chiller](Chiller/README.md) | Refrigerant-to-coolant chiller for battery thermal management | 2 | Yes | Yes |
| [Controller](Controller/README.md) | Vehicle-level supervisory controller (standard, FRM, HVAC) | 3 | No | No |
| [Driveline](Driveline/README.md) | Mechanical driveline with optional braking | 2 | No | Yes |
| [HVAC](HVAC/README.md) | Cabin climate system (empirical, simple-thermal, full-thermal) | 3 | Yes | Yes |
| [MotorDrive](MotorDrive/README.md) | Electric motor drive unit with gear, thermal, and lubrication variants | 3 + library | Yes | Yes |
| [Pump](Pump/README.md) | Coolant circulation pump | 1 | Yes | Yes |
| [PumpDriver](PumpDriver/README.md) | DC-DC converter driving the coolant pump | 1 | Yes | Yes |
| [Radiator](Radiator/README.md) | Coolant-to-air radiator with fan | 1 | Yes | Yes |

---

## Modularity and Reuse

### Self-Contained Design

Each component folder contains everything needed to use, test, and understand that component in isolation:

- **Models and parameters together.** Every `.slx` model is paired with a `*Params.m` script in the same `Model/` folder. Loading the parameter script configures the workspace for that specific model. No external parameter files are required.

- **Independent test harness.** The `TestBench/` folder provides a standalone Simulink harness (with its own `*HarnessParams.m`) that exercises the component without the rest of the vehicle. Boundary conditions (voltage sources, coolant reservoirs, torque sources) are built into the harness so the component can be simulated on its own.

- **Unit tests ship with the component.** The `TestCase/` folder contains a MATLAB test class (`*PassTests.m`) that runs the test harness and validates outputs against pass/fail criteria. These tests can be executed with `runtests('<ComponentName>PassTests')` without any external dependencies beyond the MATLAB project.

- **Documentation is local.** Each component's `Documentation/` folder contains publishable MATLAB scripts (`*Description.m`) that produce HTML pages with model screenshots, parameter tables, I/O descriptions, and simulation plots. The documentation is self-contained: images live in `images/`, published HTML in `html/`.

### Extracting a Component

To reuse a component in another project:

1. Copy the entire `Components/<ComponentName>/` folder
2. Add the `Model/`, `Utilities/`, and `Documentation/` subfolders to the MATLAB path
3. Run the `*Params.m` script to load parameters into the workspace
4. Reference the `.slx` model as a subsystem reference in your system model

The component will function identically outside the BEV project because all its dependencies (parameters, test data, library blocks) are inside its own folder.

### Swapping Fidelities

Most components offer multiple fidelity levels for the same interface. For example, BatteryHV provides three models -- `BatteryLumped`, `BatteryLumpedThermal`, and `BatteryTableBased` -- all sharing the same port interface. The system model uses Simulink subsystem references, so switching fidelity is a single parameter change at the top level. This enables:

- Fast simulation runs with simplified models (e.g., `MotorDriveGear` without thermal)
- High-fidelity thermal studies by selecting thermal variants (e.g., `MotorDriveGearTh`)
- Algorithm development with specialized variants (e.g., `BMSSoCEKF` for Kalman filter SOC)

### Thermal Interface Convention

Components that participate in the thermal management system expose Simscape conserving ports (`LConn`/`RConn`) for coolant flow. This allows the thermal plant to be assembled by connecting components -- Battery, Heater, Chiller, Pump, Radiator, Motor, Charger -- into a coolant loop at the system level. Each thermal component's test harness provides its own coolant boundary conditions (reservoir, flow source) so it can be validated independently.

---

## Testing

### Test Harness Pattern

Each test harness (`*TestHarness.slx`) is a standalone Simulink model that:

1. **Provides stimulus** -- input signals (current profiles, torque commands, speed ramps) via constants, ramps, or signal builders in an `Inputs` subsystem
2. **Supplies boundary conditions** -- electrical sources (DC voltage), thermal sources (coolant reservoirs, ambient temperature), and mechanical loads as needed
3. **Captures outputs** -- scoped and logged signals for key component outputs (voltage, current, temperature, torque, flow rate)

Harnesses use Simulink signal logging. Logged signals are retrieved via `simout.logsout` and plotted by the component's utility function (`plot*HarnessResults.m` in `Utilities/`).

### Unit Test Pattern

Each `*PassTests.m` is a MATLAB test class that:

1. Loads the test harness and parameters
2. Runs the simulation
3. Checks that logged signals meet pass criteria (no NaN, within bounds, final values in expected range)

Run all component tests:

```matlab
openProject('ElectricVehicleSimscape.prj');
results = runtests('Components', 'IncludeSubfolders', true);
disp(results)
```

Run a single component's tests:

```matlab
results = runtests('BatteryHVPassTests');
```

---

## Documentation

Each component's documentation is generated from MATLAB publish scripts and produces standalone HTML pages.

### Documentation Files

| File | Purpose |
|------|---------|
| `*Description.m` | Model overview, screenshot, ports, parameters, workflows |
| `*TestHarnessDescription.m` | Harness overview, setup, simulation, result plots |
| `plot*HarnessResults.m` | Utility that plots all logged signals from the harness |


Published HTML and images are stored locally within each component's `Documentation/` folder, keeping the documentation portable with the component.

---

## System Integration

The system-level model (`Model/BEVsystemModel.slx`) assembles these components using Simulink subsystem references. Each component block in the system model points to one of the `.slx` fidelities in the component's `Model/` folder. The vehicle configuration script selects which fidelity each component uses.

```
BEVsystemModel.slx
  ├── BatteryHV         → Components/BatteryHV/Model/BatteryLumpedThermal.slx
  ├── BMS               → Components/BMS/Model/BMS.slx
  ├── MotorDrive        → Components/MotorDrive/Model/MotorDriveGearTh.slx
  ├── Controller        → Components/Controller/Model/ControllerHVAC.slx
  ├── Driveline         → Components/Driveline/Model/DrivelineWithBraking.slx
  ├── Charger           → Components/Charger/Model/ChargerWithThermal.slx
  ├── HVAC              → Components/HVAC/Model/HVACThermal.slx
  ├── Pump              → Components/Pump/Model/Pump.slx
  ├── PumpDriver        → Components/PumpDriver/Model/PumpDriver.slx
  ├── Radiator          → Components/Radiator/Model/Radiator.slx
  ├── BatteryHeater     → Components/BatteryHeater/Model/Heater.slx
  └── Chiller           → Components/Chiller/Model/Chiller.slx
```

This reference-based architecture means the system model contains no component logic itself -- it is purely a wiring diagram. All physics, control, and parameter definitions live inside the component folders.

Copyright  2026 The MathWorks, Inc.

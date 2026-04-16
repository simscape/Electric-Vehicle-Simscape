# Components

Self-contained, reusable subsystem modules for the Battery Electric Vehicle (BEV) Simscape system model. Each component encapsulates its Simulink models, parameters, tests, and documentation in one folder. Components are referenced by the system-level model (`Model/BEVsystemModel.slx`) via subsystem references, so any component can be swapped, upgraded, or extracted independently.

---

## Component Inventory

| Component | Description | Fidelities | Thermal | Test Harness |
|-----------|-------------|:----------:|:-------:|:------------:|
| [BatteryHV](BatteryHV/README.md) | High-voltage battery pack (lumped, lumped-thermal, table-based) | 3 | Yes | Yes |
| [BatteryHeater](BatteryHeater/README.md) | PTC heater for cold-climate battery warming (full, dummy) | 2 | Yes | Yes |
| [BMS](BMS/README.md) | Battery management system with SOC estimation variants | 3 | Yes | Yes |
| [Charger](Charger/README.md) | On-board charger with CC-CV control and thermal variants | 4 | Yes | Yes |
| [Chiller](Chiller/README.md) | Refrigerant-to-coolant chiller for battery thermal management (full, no-coolant, dummy) | 3 | Yes | Yes |
| [Controller](Controller/README.md) | Vehicle-level supervisory controller (standard, FRM, HVAC) | 3 | No | No |
| [Driveline](Driveline/README.md) | Mechanical driveline with optional braking | 2 | No | Yes |
| [HVAC](HVAC/README.md) | Cabin climate system (empirical, simple-thermal) | 2 | Yes | Yes |
| [MotorDrive](MotorDrive/README.md) | Electric motor drive unit with gear, thermal, and lubrication variants | 3 + library | Yes | Yes |
| [Pump](Pump/README.md) | Coolant circulation pump (full, dummy) | 2 | Yes | Yes |
| [PumpDriver](PumpDriver/README.md) | DC-DC converter driving the coolant pump | 1 | Yes | Yes |
| [Radiator](Radiator/README.md) | Coolant-to-air radiator with fan | 1 | Yes | Yes |

---

## Folder Structure

Every component follows a standardized layout:

```
Components/<ComponentName>/
  Model/           - Simulink models (.slx) and parameter scripts (*Params.m)
  TestBench/       - Standalone test harness with boundary conditions
  TestCase/        - MATLAB unit tests (*PassTests.m)
  Documentation/   - Published HTML documentation
    html/          - HTML pages
    images/        - Screenshots and figures
  Utilities/       - Plot functions and helpers
  Library/         - Reusable Simulink library blocks (BatteryHV, HVAC, MotorDrive only)
  README.md        - Component overview and fidelity table
```

---

## Modularity

Each component is fully self-contained. Models, parameters, test harnesses, unit tests, and documentation all live inside the component folder. To reuse a component in another project, copy the entire folder -- no external dependencies need to be resolved.

Most components offer multiple fidelity levels sharing the same port interface. Switching fidelity is a single subsystem reference change at the system level. Thermal components expose Simscape conserving ports for coolant flow, allowing them to be connected into a thermal loop at the system level while remaining independently testable with their own coolant boundary conditions.

---

## System Integration

```
BEVsystemModel.slx
  ├── BatteryHV         → Components/BatteryHV/Model/BatteryLumpedThermal.slx
  ├── BMS               → Components/BMS/Model/BMS.slx
  ├── MotorDrive        → Components/MotorDrive/Model/MotorDriveGearTh.slx
  ├── Controller        → Components/Controller/Model/ControllerHVAC.slx
  ├── Driveline         → Components/Driveline/Model/DrivelineWithBraking.slx
  ├── Charger           → Components/Charger/Model/ChargerThermal.slx
  ├── HVAC              → Components/HVAC/Model/HVACsimpleTh.slx
  ├── Battery Pump      → Components/Pump/Model/Pump.slx
  ├── Motor Pump        → Components/Pump/Model/Pump.slx
  ├── PumpDriver        → Components/PumpDriver/Model/PumpDriver.slx
  ├── Radiator          → Components/Radiator/Model/Radiator.slx
  ├── BatteryHeater     → Components/BatteryHeater/Model/Heater.slx
  └── Chiller           → Components/Chiller/Model/Chiller.slx
```

The system model is purely a wiring diagram. All physics, control, and parameter definitions live inside the component folders.

Copyright 2026 The MathWorks, Inc.

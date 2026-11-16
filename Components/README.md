# Components

Reusable subsystem packages for the battery electric vehicle (BEV) model. Component folders group models, parameters, tests, and documentation. Vehicle templates connect them through subsystem references.

## Component Inventory

| Component | Description | Model files | Thermal behavior | Test Harness |
|-----------|-------------|:-----------:|------------------|:------------:|
| [BatteryHV](BatteryHV/README.md) | Battery pack variants | 4 | Thermal variants | Yes |
| [BatteryHeater](BatteryHeater/README.md) | Battery heater and dummy | 2 | Coolant heat exchange | Yes |
| [BMS](BMS/README.md) | Battery protection and two internal SOC algorithms | 3 | Temperature monitoring | Yes |
| [Charger](Charger/README.md) | Electrical and thermal chargers | 4 | Thermal variants | Yes |
| [Chiller](Chiller/README.md) | Full, no-coolant, and dummy chillers | 3 | Coolant heat exchange | Yes |
| [Controller](Controller/README.md) | Vehicle supervisory controllers | 4 | Control commands | No |
| [Driveline](Driveline/README.md) | Vehicle variants and flexible NVH model | 4 | None | Yes |
| [HVAC](HVAC/README.md) | Cabin climate models | 2 | Cabin temperature dynamics | Yes |
| [MotorDrive](MotorDrive/README.md) | Electrical, thermal, and lubrication variants | 3 | Thermal variants | Yes |
| [Pump](Pump/README.md) | Coolant pump and dummy variants | 3 | Coolant circulation | Yes |
| [DCDC](PumpDriver/README.md) | DC-DC converter variants | 2 | Thermal variant | Yes |
| [Radiator](Radiator/README.md) | Coolant-to-air heat exchanger | 1 | Coolant heat rejection | Yes |

The 35 model files include two internal BMS SOC algorithms. Available vehicle-template combinations come from [the preset configuration](../utils/APP/Config/Preset/README.md).

## Folder Structure

```
Components/<ComponentName>/
  Model/                  - Models and parameter scripts
  TestBench/              - Standalone harnesses, when provided
  TestCase/               - Component unit tests, when provided
  Documentation/          - Publish sources
    html/                 - Published pages
      images/             - Screenshots and result figures
  Library/                - Shared blocks or data, when provided
  Utilities/              - Plotting helpers, when provided
  README.md               - Component reference
```

Controller has no standalone harness or test class. BMS has no Utilities folder.

## Reuse and Integration

Preserve the selected model's signal and physical interfaces. Thermal variants add coolant connections; FlexibleDriveline has a separate analysis interface.

Resolve dependencies when reusing a package. Controller uses BMS; thermal parameter scripts require environment values from the system or harness setup.

## Saved System Configuration

```
BEVsystemModel.slx
  Controller.slx
    BMS.slx
      BMSSoCDirect.slx
  VehicleElectroThermal.slx
    BatteryTableBased.slx
    MotorDriveGearTh.slx      (front and rear)
    Driveline.slx
    ChargerThermal.slx
    HVACsimpleTh.slx
    Chiller.slx
    Heater.slx
    Pump.slx                 (battery and motor loops)
    PumpDriverTh.slx
    Radiator.slx
```

The setup app changes these references in memory. See [vehicle templates](../Model/VehicleTemplate/README.md) and [setup presets](../Script_Data/Setup/Preset/README.md).

Copyright 2026 The MathWorks, Inc.

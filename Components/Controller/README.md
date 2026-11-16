# Vehicle Controller

Distribute motor torque, control battery relays, and coordinate regenerative braking. Thermal variants also command coolant and cabin systems.

## Model Fidelities

| Model | Description | Thermal | Use Case |
|-------|-------------|:-------:|----------|
| [Controller](Model/README.md#controller) | Drivetrain and thermal-management commands | No | VehicleElectroThermal |
| [ControllerFRM](Model/README.md#controllerfrm) | Core drivetrain commands | No | VehicleElectric |
| [ControllerHVAC](Model/README.md#controllerhvac) | Drivetrain, thermal, and cabin-control commands | No | VehicleElecAux |
| [Controller3w](Model/README.md#controller3w) | Single-motor drivetrain commands | No | Three-wheel studies |

Controllers contain [BMS](../BMS/README.md) for battery protection.

## Component Interface

### Inputs

| Port or element | Description | Required | Used by |
|-----------------|-------------|----------|---------|
| `Spd` | Reference speed | Yes | All fidelities |
| `Env` | Environment bus | Yes | All fidelities |
| `Cabin` | Cabin bus | Yes | All fidelities |
| `m` | Vehicle measurements | Yes | All fidelities |
| `HMI.BMS` | Battery operating-mode command | Yes | All fidelities |
| `HMI.AWD` | All-wheel-drive mode | Optional | Controller, ControllerFRM, ControllerHVAC |

### Output Bus Groups — `s`

| Element | Description | Required | Used by |
|---------|-------------|----------|---------|
| `DV` | Brake command | Yes | All fidelities |
| `BA` | Battery relay commands | Yes | All fidelities |
| `CG` | Charger commands | Yes | All fidelities |
| `M1`, `M2` | Front/rear motor commands | Optional | Controller, ControllerFRM, ControllerHVAC |
| `M` | Single-motor command | Optional | Controller3w |
| `RA` | Radiator fan command | Optional | Controller, ControllerHVAC |
| `MP`, `BP` | Coolant pump commands | Optional | Controller, ControllerHVAC |
| `CV`, `MV`, `RV` | Coolant valve commands | Optional | Controller, ControllerHVAC |
| `HE`, `CH` | Heater and chiller commands | Optional | Controller, ControllerHVAC |
| `VA` | Cabin-control commands | Optional | Controller, ControllerHVAC |

### Interface Notes

- ControllerFRM omits thermal command groups.
- Controller3w uses `M` and omits `HMI.AWD`; its input blocks are named EnvBus, CabinBus, Meas, and BMSSensor.
- Check the selected controller and component interfaces together when changing a template.

## Files

| Location | Contents |
|----------|----------|
| `Model/` | Controller models and shared ControllerParams.m |
| `Documentation/` | Description sources and published pages |

## Related Workflows

- [Range estimation](../../Workflow/Vehicle/RangeEstimation/README.md)
- [Vehicle templates](../../Model/VehicleTemplate/README.md)

Copyright 2022 - 2026 The MathWorks, Inc.

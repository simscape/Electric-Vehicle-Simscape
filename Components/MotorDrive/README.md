# MotorDrive

Electric motor drive unit component for the BEV system model. The motor drive converts electrical energy from the HV battery into mechanical torque delivered to the driveline through a fixed gear. Multiple fidelity levels are available, progressing from a fast electrical-only model through thermal-coupled and lubrication-aware variants.

## Model Fidelities

### Drive Unit Models (`Model/`)

| Model | Description | Thermal | Use Case |
|-------|-------------|:-------:|----------|
| [MotorDriveGear](Model/README.md#motordrivegear) | Electric motor with lumped electrical and mechanical dynamics plus a fixed gear. No thermal coupling -- temperature is a fixed input. | No | Fast vehicle-level range estimation and controller tuning where motor thermal behavior is not needed. |
| [MotorDriveGearTh](Model/README.md#motordrivegearth) | Motor drive with fixed gear including thermal coupling. Motor plant has electrical, mechanical, and thermal ports. Coolant jacket for motor and inverter thermal dynamics. | Yes | Electro-thermal vehicle simulations where motor and inverter temperatures affect performance and range. Default motor fidelity for VehicleElectroThermal. |
| [MotorDriveLube](Model/README.md#motordrivelube) | Motor drive with fixed gear, thermal coupling, and gearbox lubrication losses. Adds gear thermal interface and oil-related losses to the thermal model. | Yes | High-fidelity powertrain studies including gear lubrication effects on efficiency and thermal behavior. |

### Library (`Library/`)

| File | Description |
|------|-------------|
| EmotorLib.slx | Reusable motor library blocks |
| InverterMotorDriveParam.m | Inverter Cauer thermal, heatsink, and loss map parameters |
| MotorLossMap.mat | Pre-computed motor loss map data |
| InverterLossMap.mat | Pre-computed inverter loss map data |

## Folder Structure

```
MotorDrive/
  Model/              - Drive unit models and parameter scripts
  Library/            - Reusable library blocks and loss map data
  TestBench/          - Test harness (MotorTestHarness.slx)
  TestCase/           - Unit tests (MotorDrivePassTests.m)
```

## Related Workflows

- **Range Estimation** (`Workflow/Vehicle/RangeEstimation/`) -- Motor drive losses directly affect vehicle range. MotorDriveGearTh is the default for electro-thermal runs.
- **Gear Ratio Selection** (`Workflow/MotorDrive/GearRatioSelect/`) -- Batch simulations sweep gear ratios to find the most efficient fixed ratio for the drive cycle.
- **Loss Map Generation** (`Workflow/MotorDrive/GenerateMotInvLoss/`) -- Detailed PMSM test bench and loss map generation for motor and inverter (`MotorLossMap.mat`) consumed by the system-level models.
- **Inverter Life** (`Workflow/MotorDrive/InverterLife/`) -- Junction temperature cycling from the thermal motor model is used to predict inverter power module lifetime.
- **Thermal Durability** (`Workflow/MotorDrive/ThermalDurability/`) -- Drive-unit thermal behavior over extended duty cycles.

Copyright 2022 - 2025 The MathWorks, Inc.

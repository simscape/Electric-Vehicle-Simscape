# Driveline NVH

Analyze torsional vibration, motor torque control, and gear ratio optimization for the BEV driveline.

| Item | Detail |
|------|--------|
| **Entry points** | `optimizeVehicleLaunch.mlx`, `generateOrderMap.mlx` |
| **Models** | `mechanicalDLTorsionOrderMap.slx`, `motorDrivelineElectricalTRQControl.slx` |
| **Key outputs** | Optimized gear ratios, extended motor torque profiles, frequency order maps, bearing forces |

## Files

### Live Scripts

| File | Purpose |
|------|---------|
| `optimizeVehicleLaunch.mlx` | Main workflow — optimize gear ratios for vehicle launch jerk minimization |
| `generateOrderMap.mlx` | Generate frequency order map from driveline torsional vibration simulation |

### Models

| File | Purpose |
|------|---------|
| `mechanicalDLTorsionOrderMap.slx` | Mechanical driveline torsional vibration model |
| `motorDrivelineElectricalTRQControl.slx` | Motor with electrical torque control for launch simulation |

### Script Data — Functions

| File | Purpose |
|------|---------|
| `calculateAndExtendMotorTRQ.m` | Simulate motor torque for multiple setpoints and extend profiles |
| `calculateBearingForce.m` | Compute net radial load on the bearing |
| `calculateTractionForceMatrix.m` | Compute traction force matrix for flat road |
| `expVelocityProfile.m` | Exponential velocity and acceleration for a single time constant |
| `extendMotorTorque.m` | Extend a torque signal by repeating its tail portion |
| `generateVelocityProfile.m` | Generate velocity and acceleration profiles for multiple time constants |
| `plotExtendedTorque.m` | Plot simulated and extended motor torque profiles |
| `runMultiLevelSurrogateOptimisation.m` | Surrogate optimization of gear ratios across torque levels |
| `simulateElectricModel.m` | Simulate electric motor model and return torque output |
| `simulateModel.m` | Simulate driveline torsion model and extract torque and speed |
| `simulateOptlaunch.m` | Compare optimized and baseline launch simulations |

### Script Data — Parameter Files

| File | Purpose |
|------|---------|
| `mechanicalDLTorsionOrderMapParams.m` | All parameters for `mechanicalDLTorsionOrderMap` model (`mechDLParams` struct) |
| `motorDrivelineElectricalTRQControlParams.m` | All parameters for `motorDrivelineElectricalTRQControl` model (`elecTRQParams` struct) |

### Component Parameter Files

| File | Purpose |
|------|---------|
| `../../../Components/Driveline/Model/FlexibleDrivelineParams.m` | Parameters for `FlexibleDriveline` referenced model (`flexDLParams` struct) |
| `../../../Components/Driveline/TestBench/FlexibleDriveLineTestHarnessParams.m` | Parameters for `FlexibleDriveLineTestHarness` model (`thParams` struct) |

### Script Data — MAT Files

| File | Purpose |
|------|---------|
| `AVGConverterParams.mat` | Converter averaging parameters |
| `extendedMotorTorque.mat` | Extended motor torque results |
| `extendedVehicleLaunchTorque.mat` | Extended vehicle launch torque profiles |
| `motorStartTorque.mat` | Motor starting torque data |

Copyright 2025-2026 The MathWorks, Inc.

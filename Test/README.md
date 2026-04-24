# Test

System-level and workflow tests for the BEV Simscape project. All test classes inherit from `BaseTest` which handles working folder setup, figure/model cleanup, and warning suppression.

Component-level tests are inside each component folder (`Components/<Name>/TestCase/`).

### Test Locations

| Location | Scope |
|----------|-------|
| `Test/` | System-level simulation and workflow tests |
| `Components/<Name>/TestCase/` | Per-component unit tests |
| `APP/Test/` | BEV Setup App configuration and UI tests |

## Folder Structure

```
Test/
  BaseTest.m                          -- Base test class (shared fixtures)
  BEVSystemMainModel.m                -- System model simulation tests
  BatteryWorkflowTests.m              -- Battery workflow tests
  MotorDriveWorkflowTests.m           -- Motor drive workflow tests
  VehicleWorkflowTests.m              -- Vehicle workflow tests
  CheckProject/
    BEVProjectCheckProject.m          -- Project integrity checks
    BEVProjectRuntestsCheckProject.m  -- CI runner with JUnit XML + coverage
```

## Test Classes

| Class | Inherits | What It Tests |
|-------|----------|---------------|
| `BaseTest` | `matlab.unittest.TestCase` | Shared setup: working folder fixture, open figure/model tracking, teardown cleanup |
| `BEVSystemMainModel` | `BaseTest` | Simulates `BEVsystemModel` under Default, PlantAbstract, and PlantElectroThermal configurations |
| `BatteryWorkflowTests` | `BaseTest` | Battery sizing, `.mlx` workflows, virtual sensor neural net |
| `MotorDriveWorkflowTests` | `BaseTest` | Gear ratio selection, motor inverter loss generation, thermal bench run and plot |
| `VehicleWorkflowTests` | `BaseTest` | Range estimation scripts (NEDC, WLTC) and `.mlx` workflow |

## CI / Check Project

| File | Purpose |
|------|---------|
| `BEVProjectCheckProject.m` | Runs `runChecks(prj)` on the MATLAB project and asserts all checks pass |
| `BEVProjectRuntestsCheckProject.m` | Creates test suite, runs with JUnit XML output and code coverage report |

## APP Tests

Tests under `APP/Test/` verify the BEV Setup App configuration layer:

| File | Purpose |
|------|---------|
| `BuildComponentEntriesTest.m` | Validates component entry struct generation for all components |
| `BEVFidelityTest.m` | Compile-checks every template × fidelity combination from JSON config |
| `BEVFidelityAppCheck.m` | Drives the app UI to validate setup output for all fidelity variants |
| `BEVHyperlinkTest.m` | Validates all hyperlinks and image references across project HTML files |
| `BEVPresetTest.m` | Clears workspace, applies each discovered preset, and compile-checks the model |
| `runBEVFidelityReport.m` | Generates a summary report of fidelity coverage across presets |
| `runBEVHyperlinkReport.m` | Generates HTML + JUnit report for hyperlink validation |

## Running Tests

```matlab
% System-level and workflow tests
results = runtests('Test');
disp(results);

% APP configuration tests
appResults = runtests('APP/Test');
disp(appResults);
```

Copyright 2022 - 2026 The MathWorks, Inc.

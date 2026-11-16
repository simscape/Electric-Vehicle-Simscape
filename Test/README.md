# Project Tests

System and workflow test classes use `BaseTest` for shared fixtures and cleanup. The parameterized smoke-test framework uses `ProjectSmokeTests`, which inherits `matlab.unittest.TestCase` directly.

## Test Locations

| Location | Scope |
|----------|-------|
| `Test/` | System and workflow test classes |
| `Components/<Name>/TestCase/` | Component tests |
| [utils/APP/Test](../utils/APP/Test/README.md) | Setup-app unit tests and standalone UI check |
| `Test/CheckProject/` | MATLAB Project checks |
| `Test/Framework/` | Discovery, execution, and report utilities |

## Test Classes and Runners

| File | Purpose |
|------|---------|
| `BaseTest.m` | Shared working-folder, figure, model, and warning fixtures |
| `BEVSystemMainModel.m` | Simulate system configurations |
| `BatteryWorkflowTests.m` | Battery sizing and virtual-sensor workflows |
| `MotorDriveWorkflowTests.m` | Gear-ratio, loss-map, and thermal workflows |
| `VehicleWorkflowTests.m` | Range-estimation workflows |
| `BEVProjectTests.m` | Run system/workflow and component suites with reports |
| `CheckProject/BEVProjectCheckProject.m` | Verify MATLAB Project checks |
| `CheckProject/BEVProjectRuntestsCheckProject.m` | Project-check runner with reports |
| `Framework/ProjectSmokeTests.m` | Parameterized model and workflow smoke tests |
| `Framework/TestFileDiscovery.m` | Discover included targets and apply exclusions |
| `Framework/TestExecutor.m` | Build suites, run tests, and generate reports |
| `Framework/TestReportBuilder.m` | Build the framework report |

See [the test-framework guide](Documentation/TestFrameworkHome.html) for configuration and discovery.

## Running Tests

Open `ElectricVehicleSimscape.prj` before running tests.

```matlab
root = currentProject().RootFolder;

% Run one system test class
results = runtests(fullfile(root, 'Test', 'BEVSystemMainModel.m'));

% Run app unit tests
appResults = runtests(fullfile(root, 'utils', 'APP', 'Test'));
```

For the maintained system/workflow/component runner, run `BEVProjectTests`. It excludes the virtual-sensor Live Script test from that suite. Component and app suites have different scopes; inspect results before claiming whole-project coverage.

Copyright 2022 - 2026 The MathWorks, Inc.

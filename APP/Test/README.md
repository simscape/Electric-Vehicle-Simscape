# APP Tests

Validation tests for the BEV Setup App. All tests use the MATLAB Unit Testing Framework.

## Test Files

| File | What It Tests |
|------|---------------|
| `BEVFidelityTest.m` | Parameterized test — generates setup output and compile-checks every template × fidelity combination from `VehicleTemplateConfig.json` |
| `BEVFidelityAppCheck.m` | Standalone script — drives the app UI to generate setup folders for all preset fidelity variants |
| `BEVHyperlinkTest.m` | Validates all hyperlinks and image references across project HTML files |
| `BEVPresetTest.m` | Parameterized test — clears workspace, applies each discovered preset, and compile-checks the model |
| `BuildComponentEntriesTest.m` | Unit test for `buildComponentEntries` — verifies struct array output from parsed JSON config |

## Report Runners

| File | Report Output |
|------|---------------|
| `runBEVFidelityReport.m` | `Reports/FidelityReport_<release>.html` + JUnit XML |
| `runBEVHyperlinkReport.m` | `Reports/HyperlinkReport_<release>.html` + JUnit XML |

## Quick Start

```matlab
% Run all fidelity tests
results = runtests('BEVFidelityTest');

% Run one template
results = runtests('BEVFidelityTest', ...
    'ParameterProperty','Setup','ParameterName','VehicleElecAux*');

% Run with HTML report
runBEVFidelityReport
runBEVFidelityReport('VehicleElecAux')

% Run hyperlink validation
results = runtests('BEVHyperlinkTest');
runBEVHyperlinkReport
```

## Reports Folder

Generated HTML and XML reports are saved to `Reports/`. This folder is not tracked in git.

Copyright 2026 The MathWorks, Inc.

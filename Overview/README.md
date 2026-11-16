# Repository Architecture

Find the owning models, parameters, configuration, documentation, and tests.

## Folder Responsibilities

| Folder | Responsibility |
|--------|----------------|
| [APP](../utils/APP/README.md) | Setup app, configuration authoring, and exports |
| [utils/APP/API](../utils/APP/API/README.md) | 84 functions in eight responsibility groups |
| [utils/APP/Config](../utils/APP/Config/README.md) | Preset configuration and saved user setups |
| [Components](../Components/README.md) | 12 component packages; 35 model files and 12 harnesses |
| [Model](../Model/README.md) | System model and three vehicle templates |
| [Script_Data/Setup/Preset](../Script_Data/Setup/Preset/README.md) | Shipped setup runners |
| [Workflow](../Workflow/README.md) | Battery, MotorDrive, Vehicle, and Driveline studies |
| [Test](../Test/README.md) | System/workflow tests and the test framework |
| `utils/` | Signal Designer and preset-picker utilities |

The model total includes two internal BMS SOC algorithms. Controller and BMS variants share parameter scripts.

## Source of Truth

| Concern | Owner |
|---------|-------|
| Selectable templates and fidelities | [VehicleTemplateConfig.json](../utils/APP/Config/Preset/VehicleTemplateConfig.json) |
| Component behavior and interfaces | Component SLX files and their parameter scripts |
| System assembly | [BEVsystemModel.slx](../Model/BEVsystemModel.slx) and [vehicle templates](../Model/VehicleTemplate/README.md) |
| Environment initialization | [BEVSystemModelParams.m](../Script_Data/BEVSystemModelParams.m) or the selected harness/setup script |
| Current setup selections | `buildSetupState` |
| Saved setups | `saveSetupToFile` |
| Documentation | Maintained HTML or its matching publish source |

API groups contain Author 8, AuthorUI 21, Catalog 3, Detect 6, State 4, Export 8, UI 25, and Util 9 functions.

## Setup and Export

1. Open the project.
2. Select a template and component fidelities in `BEVapp`, or use the [preset picker](../Script_Data/OpenPresetPicker.m).
3. Apply subsystem references and load parameters.
4. Run the configured model.

`setupModelReferences.m` applies references and operating modes in memory. `setupModelParameters.m` initializes environment, component, and controller variables. `applyPreset.m` runs those setup scripts; simulation is a separate action.

Generated user setups go under `Script_Data/Setup/User/`; saved JSON goes under `utils/APP/Config/User/`. Both are Git-ignored. Shipped presets remain under `Script_Data/Setup/Preset/`.

## Component Dependencies

Use each model's documented interface. Thermal variants add physical ports, and FlexibleDriveline uses a distinct NVH interface. Controller depends on BMS. Reuse requires the referenced libraries, parameter scripts, and environment inputs.

## Documentation Ownership

| Set | Source and maintenance |
|-----|------------------------|
| Project help | [ElectricVehicleDesignOverview.html](html/ElectricVehicleDesignOverview.html) and themed component/workflow pages are maintained directly |
| Published overview references | Existing Overview M sources own their matching HTML outputs |
| Component descriptions | Documentation M sources own matching published HTML and result images |
| App help | utils/APP/Documents/html pages |

Preserve [BatteryElectricVehicleModelOverview.html](html/BatteryElectricVehicleModelOverview.html), [ElectricVehicleComponentOverview.html](html/ElectricVehicleComponentOverview.html), and shared images. Publishing one overview source must preserve the rest of the mixed HTML folder.

To publish a component description, open the project and publish the actual source to its existing HTML folder, for example:

```matlab
root = currentProject().RootFolder;
source = fullfile(root, 'Components', 'Charger', 'Documentation', 'ChargerDescription.m');
publish(source, 'outputDir', fullfile(fileparts(source), 'html'));
```

Harness documentation executes simulations when published with evaluation enabled. Use its documented setup and plotting utilities.

Move new publish images into the matching `html/images/` folder and update their HTML paths before review.

## Extend the Project

| Change | Update |
|--------|--------|
| Component fidelity | Model, parameters, configuration, both READMEs, documentation, and focused tests |
| Vehicle template | Template SLX, configuration, setup, and help |
| Workflow | Entry point, README, prerequisites, results, navigation, and tests |
| Component package | Component files, dependencies, configuration, catalog, and help |

Verify actual file paths, interface compatibility, and source/output ownership after changes.

Copyright 2022 - 2026 The MathWorks, Inc.

# Repository Architecture

Single-page reference for how the BEV Simscape repository is organized, where truth lives for each concern, and how to extend it.

## Folder Responsibilities

| Folder | Responsibility |
|--------|---------------|
| [`APP/`](../APP/README.md) | BEV Setup App — GUI, API back-end, config presets, user-saved setups |
| [`APP/API/`](../APP/API/README.md) | 53 functions in 6 domain subfolders (Catalog, Detect, State, Export, UI, Util) |
| [`APP/Config/`](../APP/Config/README.md) | Shipped JSON configs (Preset) and user-saved configs (User, gitignored) |
| [`Components/`](../Components/README.md) | 12 self-contained component packages with models, params, tests, docs |
| [`Model/`](../Model/README.md) | System-level Simulink model (`BEVsystemModel.slx`) — authored assets only |
| [`Model/VehicleTemplate/`](../Model/VehicleTemplate/README.md) | 4 vehicle template `.slx` files assembled from component references |
| [`Model/Display/`](../Model/Display/README.md) | Energy-flow visualisation subsystems used during simulation |
| `Script_Data/` | System-level param scripts, legacy setup scripts |
| `Script_Data/Setup/User/` | Generated setup/param scripts from app export (gitignored) |
| [`Workflow/`](../Workflow/README.md) | Engineering workflows — Battery, MotorDrive, Vehicle (range estimation) |
| `Overview/` | Published MATLAB overview pages (`.m` source → `html/` output) |
| `Overview/Image/` | Images referenced by overview documentation |
| [`Test/`](../Test/README.md) | Project-level test suite — system model, workflow, and project checks |
| `utils/` | Shared utilities — signal designer, cell characterisation methods |

## Source of Truth

Each concern has one canonical source. Everything else derives from it.

| Concern | Source of Truth | Consumers |
|---------|----------------|-----------|
| Template → component → fidelity mapping | `APP/Config/Preset/*.json` | App dropdowns, export scripts, validation |
| Component fidelity availability | `Components/*/Model/*.slx` (files on disk) | `scanComponentAvailability()` at runtime |
| Parameter values | `Components/*/Model/*Params.m` | Export scripts, test harnesses, system setup |
| System-level model wiring | `BEVsystemModel.slx` (subsystem references) | `detectSSRFromBEVModel()` at runtime |
| Vehicle template structure | `Model/VehicleTemplate/*.slx` | App template dropdown, export SSR targets |
| Component documentation | `Components/*/Documentation/*.m` (source) | Published to `html/` via MATLAB `publish()` |
| Overview documentation | `Overview/*.m` (source) | Published to `Overview/html/` via MATLAB `publish()` |
| App help pages | `APP/Documents/html/*.html` | App help button, doc links |
| App internal state | `setupState` struct (built by `buildSetupState()`) | All API functions that read/write app state |
| User-saved configurations | `APP/Config/User/*.json` | Config dropdown, load/replay |
| Generated setup scripts | `Script_Data/Setup/User/` (timestamped folders) | User runs outside app to replay a configuration |

## Config / Manifest Contract

Two shipped JSON configs define which templates exist and what fidelities each template supports.

| Config File | Templates Covered | Purpose |
|-------------|-------------------|---------|
| `VehicleTemplateConfig.json` | VehicleElectric, VehicleElecAux, VehicleElectroThermal | Main template manifest — all 3 core templates |
| `ThermalDesignSolutionConfig.json` | VehicleElectroThermal | Thermal-specific subset with tighter fidelity options |

### JSON structure

Each template entry contains:

| Key | Type | Purpose |
|-----|------|---------|
| `Description` | string | Human-readable template description |
| `Components` | object | Component type → `{Instances, Models}` mapping |
| `Components.*.Instances` | array | Display names (e.g. "Rear Motor (EM2)") |
| `Components.*.Models` | array | Available fidelity `.slx` base names |
| `Controls` | object | Controller → `{Instances, Models}` mapping |
| `SystemParameter` | array | System-level param scripts to call (or `"NA"`) |

### Template → Component Matrix

| Template | Battery | Motor | Charger | HVAC | Chiller | Heater | Driveline | Pump | DCDC | Radiator | Controller |
|----------|---------|-------|---------|------|---------|--------|-----------|------|------|----------|------------|
| VehicleElectric | BatteryLumped | MotorDriveGear | Charger, ChargerDummy | — | — | — | Driveline, DrivelineWithBraking | — | — | — | ControllerFRM |
| VehicleElecAux | BatteryLumped | MotorDriveGear | Charger, ChargerDummy | HVACsimpleTh, HVACEmpiricalRef | — | — | Driveline, DrivelineWithBraking | PumpDummy | PumpDriver | — | ControllerHVAC |
| VehicleElectroThermal | BatteryTableBased, BatteryLumpedThermal | MotorDriveGearTh, MotorDriveLube | ChargerThermal, ChargerThermalDummy | HVACsimpleTh, HVACEmpiricalRef | Chiller, ChillerDummy | Heater, HeaterDummy | Driveline, DrivelineWithBraking | Pump, PumpDummyTh | PumpDriverTh | Radiator | Controller |

`VehicleElectroThermalLowTemp` is a `.slx` template on disk but not in the JSON configs — it is a pre-wired cold-climate variant of VehicleElectroThermal, not a separately configurable template.

## Component Architecture

### Standard folder layout

Every component under `Components/` follows this structure:

| Subfolder | Required | Contents |
|-----------|----------|----------|
| `Model/` | Yes | Fidelity `.slx` models + matching `*Params.m` scripts |
| `TestBench/` | Most | Standalone test harness with boundary conditions |
| `TestCase/` | Yes | MATLAB unit tests (`*PassTests.m`) |
| `Documentation/` | Yes | Source `.m` description files |
| `Documentation/html/` | Yes | Published HTML from source |
| `Documentation/images/` | Yes | Screenshots and figures |
| `Utilities/` | Some | Plot functions and helper scripts |
| `Library/` | Few | Shared Simulink library blocks (BatteryHV, HVAC, MotorDrive) |
| `README.md` | Yes | Component-level summary |

### Component inventory

| Component | Fidelities | Thermal | Test Harness |
|-----------|-----------|---------|-------------|
| [BatteryHV](../Components/BatteryHV/README.md) | BatteryLumped, BatteryLumpedThermal, BatteryTableBased | Yes | Yes |
| [BatteryHeater](../Components/BatteryHeater/README.md) | Heater, HeaterDummy | Yes | Yes |
| [BMS](../Components/BMS/README.md) | BMS, BMSSoCDirect, BMSSoCEKF | Yes | Yes |
| [Charger](../Components/Charger/README.md) | Charger, ChargerDummy, ChargerThermal, ChargerThermalDummy | Yes | Yes |
| [Chiller](../Components/Chiller/README.md) | Chiller, ChillerNoCoolant, ChillerDummy | Yes | Yes |
| [Controller](../Components/Controller/README.md) | Controller, ControllerFRM, ControllerHVAC | No | No |
| [Driveline](../Components/Driveline/README.md) | Driveline, DrivelineWithBraking | No | Yes |
| [HVAC](../Components/HVAC/README.md) | HVACEmpiricalRef, HVACSimpleTh | Yes | Yes |
| [MotorDrive](../Components/MotorDrive/README.md) | MotorDriveGear, MotorDriveGearTh, MotorDriveLube, EmotorLib | Yes | Yes |
| [Pump](../Components/Pump/README.md) | Pump, PumpDummy, PumpDummyTh | Yes | Yes |
| [DCDC](../Components/PumpDriver/README.md) | PumpDriver, PumpDriverTh | Yes | Yes |
| [Radiator](../Components/Radiator/README.md) | Radiator | Yes | Yes |

**Totals:** 12 components, 32 fidelity variants, 11 test harnesses.

### Parameter convention

Every fidelity model has a matching parameter script in the same `Model/` folder. The naming rule is `<FidelityName>Params.m`.

| Example Model | Matching Param Script |
|--------------|----------------------|
| `BatteryLumpedThermal.slx` | `BatteryLumpedThermalParams.m` |
| `MotorDriveGear.slx` | `MotorDriveGearParams.m` |
| `ChargerDummy.slx` | `ChargerDummyParams.m` |

Param scripts are plain MATLAB scripts (not functions) that populate workspace variables. Harness param scripts in `TestBench/` call the component param script and layer boundary-condition variables on top.

### Port interface contract

All fidelities within the same component type share a common Simulink port interface. Switching fidelity is a single subsystem reference change — no rewiring needed. Thermal components expose Simscape conserving ports for coolant flow.

## App Architecture

### Layers

| Layer | Location | Responsibility |
|-------|----------|---------------|
| GUI | `APP/BEVapp.mlapp` | App Designer UI — thin callbacks only |
| Catalog | `APP/API/Catalog/` (3) | Config parsing, template resolution, validation |
| Detect | `APP/API/Detect/` (5) | Runtime model scanning — SSR detection, platform/controls ID |
| State | `APP/API/State/` (4) | `setupState` struct build, save, cache |
| Export | `APP/API/Export/` (4) | Script generation, param export, link validation |
| UI | `APP/API/UI/` (23) | Dropdown population, descriptions, panels, preview |
| Util | `APP/API/Util/` (14) | Path helpers, project root, file listing, SSR masking |

### Key data flow

1. **Startup** — `initAppDropdowns()` → `getBEVAppPaths()` → `populateConfigDropDown()` → `createComponentDropdowns()`
2. **Template selection** — `buildComponentEntries()` reads JSON config → `scanComponentAvailability()` checks disk → UI dropdowns populated
3. **Export** — `buildSetupState()` captures current selections → `exportSetupScript()` writes SSR setup → `exportParamScript()` writes param setup
4. **Save/Load** — `saveSetupToFile()` writes JSON to `APP/Config/User/` → `populateConfigDropDown()` refreshes dropdown

### setupState contract

`buildSetupState()` produces a flat struct capturing the full current configuration: chosen template, all component fidelity selections, controller, environment settings, drive cycle, and param file links. Every export and save function reads from this struct.

## Export / Script Flow

### Output ownership

| What | Where | Tracked |
|------|-------|---------|
| SSR setup scripts | `Script_Data/Setup/User/<model>_<timestamp>/` | No (gitignored) |
| Param setup scripts | Same timestamped folder | No (gitignored) |
| User-saved JSON configs | `APP/Config/User/` | No (gitignored) |
| Preset JSON configs | `APP/Config/Preset/` | Yes |
| Component models | `Components/*/Model/` | Yes |
| Vehicle templates | `Model/VehicleTemplate/` | Yes |

### Generated script content

**SSR setup script** (`*_ssr_setup.m`): Opens the system model, issues `set_param()` calls to change each subsystem reference to the selected fidelity, configures drive cycle, saves model.

**Param setup script** (`*_params_setup.m`): Sets environment variables, adds component `Model/` folders to path, calls each component's `*Params.m` in sequence, calls system-level param scripts.

Both scripts are designed to be replayable from a fresh checkout — they resolve paths relative to the project root.

## Documentation Chain

### Two publishing pipelines

| Pipeline | Source | Output | Publish Method |
|----------|--------|--------|---------------|
| Overview pages | `Overview/*.m` | `Overview/html/*.html` | MATLAB `publish()` |
| Component descriptions | `Components/*/Documentation/*.m` | `Components/*/Documentation/html/*.html` | MATLAB `publish()` via `publishHarnessDocs.m` |

### Rules

- Source `.m` files are the canonical copy. Never patch generated HTML directly.
- Images generated during publish go to `Documentation/images/`. HTML `src=` attributes reference `../images/`.
- Cross-links between published pages use relative paths (same-folder links use just the filename).
- The app loads component HTML via `ComponentDescription()`, which searches `Components/**/Documentation/html/` by fidelity name.

## Workflow Organization

| Domain | Workflow | Entry Point | Template Needed |
|--------|----------|-------------|-----------------|
| Battery | [Battery Sizing](../Workflow/Battery/BatterySizing/README.md) | `BEVBatterySizingMain.mlx` | Any |
| Battery | [Cell Characterisation](../Workflow/Battery/CellCharacterization/README.md) | `CellCharacterizationForBEV.mlx` | Any |
| Battery | [Neural Net Virtual Sensor](../Workflow/Battery/VirtualSensorNeuralNetModel/README.md) | `VirtualSensorNeuralNetModel.mlx` | Electro-thermal |
| MotorDrive | [Gear Ratio Selection](../Workflow/MotorDrive/GearRatioSelect/README.md) | `minimumRequiredGearRatio.mlx` | Electro-thermal |
| MotorDrive | [PMSM Loss Map Generation](../Workflow/MotorDrive/GenerateMotInvLoss/README.md) | `generateDULossMap.mlx` | Any |
| MotorDrive | [Inverter Life](../Workflow/MotorDrive/InverterLife/README.md) | `inverterPowerModuleLife.mlx` | Electro-thermal |
| MotorDrive | [Thermal Durability](../Workflow/MotorDrive/ThermalDurability/README.md) | `DUThermalDurability.mlx` | Electro-thermal |
| Vehicle | [Range Estimation](../Workflow/Vehicle/RangeEstimation/README.md) | `BEVRangeEstimationMain.mlx` | Any |

Workflows live under `Workflow/<Domain>/<WorkflowName>/`. Each expects the system model to be configured and parameterised before running. See the [Workflow README](../Workflow/README.md) for the full catalog.

## Testing Structure

| Location | Scope | Tests |
|----------|-------|-------|
| `Test/BEVSystemMainModel.m` | System model loads and compiles | 1 |
| `Test/BatteryWorkflowTests.m` | Battery workflow smoke tests | 1 |
| `Test/MotorDriveWorkflowTests.m` | MotorDrive workflow smoke tests | 1 |
| `Test/VehicleWorkflowTests.m` | Vehicle workflow smoke tests | 1 |
| `Test/CheckProject/` | MATLAB Project integrity checks | Varies |
| `Components/*/TestCase/*PassTests.m` | Component-level unit tests (all 12) | 12 |
| `APP/Test/BuildComponentEntriesTest.m` | App catalog logic unit test | 8 methods |

## Known Drift Points

These are areas where sources can fall out of sync. Check after any structural change.

| Drift Risk | What Can Go Wrong | How to Check |
|-----------|-------------------|-------------|
| JSON config vs disk | Config declares a fidelity that doesn't exist as `.slx` | `scanComponentAvailability()` reports missing models |
| Template `.slx` vs JSON | A template exists on disk but isn't in any config | Compare `Model/VehicleTemplate/*.slx` against JSON keys |
| Param script vs model | Model renamed but param script not updated | Check `<Fidelity>Params.m` exists for every `<Fidelity>.slx` |
| Doc source vs published HTML | Source `.m` edited but HTML not republished | Compare timestamps: `Documentation/*.m` vs `Documentation/html/*.html` |
| App function count vs README | Functions added/removed but README counts stale | Count files in `APP/API/*/` vs documented counts |
| Component inventory vs overview | Component added/removed but overview page not updated | Compare `Components/*/` folders against overview table |

## Extension Guides

### Add a new fidelity to an existing component

1. Create `<FidelityName>.slx` and `<FidelityName>Params.m` in `Components/<Type>/Model/`
2. Match the port interface of existing fidelities in that component
3. Add the fidelity name to relevant template entries in `APP/Config/Preset/*.json`
4. Create `<FidelityName>Description.m` in `Documentation/`, publish to `html/`
5. Update test coverage in `TestCase/` if needed

### Add a new vehicle template

1. Create `<TemplateName>.slx` in `Model/VehicleTemplate/` with subsystem references
2. Add a new top-level key in `APP/Config/Preset/VehicleTemplateConfig.json` with component/fidelity mapping
3. Update `Overview/ElectricVehicleComponentOverview.m` template table
4. Republish overview HTML

### Add a new component type

1. Create `Components/<ComponentName>/` with standard subfolder layout (see Component Architecture)
2. Add `Model/`, `Documentation/`, `TestCase/` at minimum
3. Add component entries to relevant templates in `APP/Config/Preset/*.json`
4. Update `Components/README.md` and `Overview/ElectricVehicleComponentOverview.m`
5. The app picks up new component types automatically from the JSON config

### Add a new workflow

1. Create `Workflow/<Domain>/<WorkflowName>/` with entry script and README
2. Document required template/fidelity prerequisites
3. Link from `Overview/ElectricVehicleDesignOverview.m` Design Workflows section
4. Add test coverage in `Test/` if practical

### Republish documentation

1. Open MATLAB in the project
2. For overview pages: `publish('Overview/<FileName>.m')`
3. For component docs: run `publishHarnessDocs` or `publishOneHarness('<component>')`
4. Verify generated HTML in `html/` subfolder

---

Copyright 2022 - 2026 The MathWorks, Inc.

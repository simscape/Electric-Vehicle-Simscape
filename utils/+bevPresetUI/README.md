# BEV Preset Picker

Lightweight UI for browsing and applying shipped preset configurations.

## Functions

| Function | Purpose |
|----------|---------|
| `openPresetPicker` | Open the preset picker UI |
| `discoverPresets` | Scan `Script_Data/Setup/Preset/` and return a struct array of available presets |

## Usage

```matlab
bevPresetUI.openPresetPicker
```

## Preset Folder Structure

Each preset folder in `Script_Data/Setup/Preset/` contains:

| File | Role |
|------|------|
| `applyPreset.m` | Self-contained script to configure model and load parameters |
| `BEVsystemModel_ssr_setup.m` | Subsystem reference setup |
| `BEVsystemModel_params_setup.m` | Parameter initialization |
| `README.md` | Build snapshot with template, components, parameters, environment |

## Shortcut

`Script_Data/OpenPresetPicker.m` is the project shortcut entry point.

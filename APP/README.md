# BEV Setup App

Configure and export a battery electric vehicle Simulink model through a single GUI. Select a vehicle template, pick component fidelities, set environment and HVAC conditions, choose a drive cycle, and export a ready-to-simulate model with parameter scripts.

![BEV App](Documents/images/BEVappWindow.png)

## Folder Structure

```
APP/
  BEVapp.mlapp        -- App Designer GUI
  API/                -- 58 supporting functions
    Author/    (7)    -- Template registration, fidelity management, config sync, cleanup
    Catalog/   (3)    -- Config validation, template resolution
    Detect/    (6)    -- Model scanning, subsystem reference detection, platform/controls
    State/     (4)    -- Setup state build, save, cache
    Export/    (5)    -- Script generation, param export, build snapshot
    UI/       (23)    -- Dropdowns, descriptions, panels, preview
    Util/     (10)    -- Project root, path helpers, file listing, param namespace
  Config/             -- JSON configuration files
    Preset/           -- Shipped template configs (read-only)
    User/             -- User-saved setup configs (gitignored)
  Documents/          -- Help pages and screenshots
    html/             -- HTML help files
    images/           -- UI screenshots
```

## Contents

| Item | Description |
|------|-------------|
| `BEVapp.mlapp` | Main App Designer application |
| `API/` | Back-end functions organized by responsibility (see `API/README.md`) |
| `Config/` | JSON configuration files — `Preset/` for shipped configs, `User/` for saved setups |
| `Documents/` | Help pages (`html/helpAppDetail.html`), template authoring guides, and UI screenshots (`images/`) |

Copyright 2022 - 2026 The MathWorks, Inc.

# BEV Setup App

Configure and export a battery electric vehicle Simulink model through a single GUI. Select a vehicle template, pick component fidelities, set environment and HVAC conditions, choose a drive cycle, and export a ready-to-simulate model with parameter scripts.

![BEV App](Documents/images/BEVappWindow.png)

## Folder Structure

```
APP/
  BEVapp.mlapp        -- App Designer GUI
  API/                -- 24 supporting functions
  Documents/          -- Help pages and screenshots
    html/             -- HTML help files
    images/           -- UI screenshots
```

## Contents

| Item | Description |
|------|-------------|
| `BEVapp.mlapp` | Main App Designer application |
| `API/` | All back-end functions called by the app |
| `Documents/` | Help pages (`html/helpAppDetail.html`) and UI screenshots (`images/`) |

Copyright 2022 - 2025 The MathWorks, Inc.

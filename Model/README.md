# Model

System-level vehicle models and configuration for the BEV Simscape project. The main system model (`BEVsystemModel.slx`) assembles components from `Components/` via subsystem references. Vehicle templates define pre-configured component combinations for different simulation scopes. Display models provide energy visualization dashboards.

---

## Folder Structure

```
Model/
  BEVsystemModel.slx              - Main system model (top-level wiring diagram)
  VehicleTemplateConfig.json       - Template-to-component mapping
  ThermalDesignSolutionConfig.json - Thermal design solution mapping
  VehicleTemplate/                 - Pre-configured vehicle templates
  Display/                         - Energy flow display subsystems
```

---

## Vehicle Templates

| Template | Description | Components |
|----------|-------------|------------|
| VehicleElectric | Electrical-only, no thermal or auxiliary | Battery, Motor, Charger, Driveline |
| VehicleElecAux | Electrical with auxiliary loads (HVAC, pumps) | Battery, Motor, Charger, HVAC, Driveline |
| VehicleElectroThermal | Full electro-thermal plant | Battery, Motor, Charger, HVAC, Chiller, Heater, Driveline |
| VehicleElectroThermalLowTemp | Electro-thermal for cold-climate scenarios | Same as ElectroThermal with cold-start focus |

Each template is a standalone `.slx` in `VehicleTemplate/` that references the appropriate component fidelities defined in `VehicleTemplateConfig.json`.

---

## Display Models

| Model | Description |
|-------|-------------|
| EnergyElectric | Energy flow visualization for electrical-only templates |
| EnergyElectroThermal | Energy flow visualization for electro-thermal templates |

---

## Configuration

`VehicleTemplateConfig.json` maps each template to its component fidelities. For example, `VehicleElectric` uses `BatteryLumped` and `MotorDriveGear` (no thermal), while `VehicleElectroThermal` uses `BatteryTableBased` and `MotorDriveGearTh` (thermal-coupled). This configuration drives fidelity selection without modifying the system model itself.

Copyright 2026 The MathWorks, Inc.

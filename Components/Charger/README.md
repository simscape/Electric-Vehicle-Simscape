# Charger

Onboard charger component for the BEV system model. The charger implements constant-current / constant-voltage (CC-CV) charging control and connects to the HV bus to replenish the battery pack. Multiple fidelity levels cover purely electrical through fully thermal representations, plus lightweight dummy variants for rapid integration testing.

## Model Fidelities

| Model | Description | Thermal | Use Case |
|-------|-------------|:-------:|----------|
| [Charger](Model/README.md#charger) | CC-CV charging control without thermal dynamics. Simplified model focused on electrical charging behavior with relay and cell-voltage inputs. | No | Fast charging simulations where thermal effects are not needed, controller algorithm development. |
| [ChargerDummy](Model/README.md#chargerdummy) | Minimal CC-CV stub with no parameter requirements. Provides the same port interface as the full charger so the system model can run without real charger data. | No | Placeholder for integration testing or when the charger subsystem is not the focus of the study. |
| [ChargerThermal](Model/README.md#chargerthermal) | CC-CV charger with a thermal representation of the power converter. Heat generation and coolant jacket coupling allow thermal management studies. | Yes | Charging scenarios where converter temperature and heat rejection to the coolant loop are important. |
| [ChargerThermalDummy](Model/README.md#chargerthermaldummy) | Thermal-capable dummy charger with the same thermal ports as ChargerThermal but no internal parameter requirements. | Yes | Placeholder when the thermal loop must remain closed but real charger thermal data is unavailable. |
## Folder Structure

```
Charger/
  Model/        - Simulink models and parameter scripts
  TestBench/    - Test harness (ChargerTestHarness.slx)
  TestCase/     - Unit tests (ChargerPassTests.m)
```

## Related Workflows

- **Range Estimation** (`Workflow/Vehicle/RangeEstimation/`) -- The charger is included in the BEV system model for charge-discharge scenario studies.
- **Electro-Thermal Vehicle Studies** -- ChargerThermal is used in the VehicleElectroThermal template where coolant loop interactions matter.
- **BEV Setup App** (`APP/`) -- The app configuration lists available charger fidelities for the VehicleElectric template.

Copyright 2022 - 2025 The MathWorks, Inc.

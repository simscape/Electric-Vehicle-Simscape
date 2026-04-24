# Electric Vehicle Design with Simscape

[![View Electric Vehicle Design with Simscape on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/124795-electric-vehicle-design-with-simscape)

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=simscape/Electric-Vehicle-Simscape)

<table>
  <tr>
    <td class="text-column" width=300> 
The key components of an electrified platform include HV battery pack, an 
e-drive system, HVAC, and other electromechanical components. Design of an 
electric drivetrain is often a collaborative effort between diverse groups 
and model sharing and reuse becomes important. In this project, a battery 
electric vehicle is modelled with components available in different fidelity, 
for you to select and run based on application need. The vehicle model is a 
coupled electrical, mechanical, and thermal model built using Simscape&trade;, 
Battery&trade;, Simscape Driveline&trade;, Simscape Electrical&trade;, and 
Simscape Fluids&trade; Libraries. </td>
    <td class="image-column" width=600><img src="Overview/Image/BEVplantModelVehicle.png" alt="Main text"></td>
  </tr>
</table>

## Getting Started

<p align="center">
  <img src="Overview/Image/BEVWorkflow.png" alt="BEV Design Workflow" width="700">
</p>

The project supports two ways to configure and load the vehicle model.
Choose the one that fits your workflow.

<table>
  <tr>
    <td class="text-column" width=400>
      <strong>Preferred way (Preset)</strong> — Use the
      <strong>Preset Picker</strong> to browse and
      apply a shipped vehicle configuration. Three defaults are available:
      <em>VehicleElectric</em>, <em>VehicleElecAux</em>, and
      <em>VehicleElectroThermal</em>. Each preset configures the model
      references, loads the correct parameters, and opens the model ready to
      simulate. No manual configuration needed.<br><br>
      <strong>Custom configuration</strong> — Launch the
      <a href="APP/README.md">BEV Setup App</a> (<code>BEVapp</code>) to select
      a template, choose component fidelities, link parameter files, and
      configure environment, HVAC, and driver settings.
    </td>
    <td class="image-column" width=500><img src="APP/Documents/images/BEVappWindow.png" alt="BEV Setup App"></td>
  </tr>
</table>

## Engineering Workflows

In this project, you will learn about the following **seven engineering 
workflows**:

## 1. Estimate Driving Range of Electric Vehicle
<table>
  <tr>
    <td class="image-column" width=600><img src="Overview/Image/BatteryElectricVehicleModelOverview_01.png" alt="BEV system model canvas"></td>
    <td class="text-column" width=300>Estimate the on-road range of the vehicle. Run drive cycles with different ambient conditions to determine the range of the vehicle with a given capacity. See <strong><a href="Workflow/Vehicle/RangeEstimation/README.md">Workflow/Vehicle/RangeEstimation</a></strong>.</td>
  </tr>
</table>

## 2. Size Battery for Electric Vehicle
<table>
  <tr>
    <td class="image-column" width=300><img src="Overview/Image/BEVplantModelbatterysSubs.png" alt="Battery Sizing"></td>
    <td class="text-column" width=600>Size your high-voltage (HV) battery pack to achieve your desired range. You will learn how to simulate battery packs with different capacities and weights, and compare them based on how these factors affect the range of the vehicle. See <strong><a href="Workflow/Battery/BatterySizing/README.md">Workflow/Battery/BatterySizing</a></strong>.</td>
  </tr>
</table>

## 3. Create Battery Virtual Sensors (Neural Networks)
<table>
  <tr>
    <td class="image-column" width=600><img src="Overview/Image/BatteryNeuralNetResults.png" alt="Battery NN"></td>
    <td class="text-column" width=300>Build a neural network model to predict battery temperature. This Neural network model takes in battery voltage and current measurements to predict battery temperature. This, when deployed, can help in eliminating some thermal sensors in the battery pack and reduce cost of development. See <strong><a href="Workflow/Battery/VirtualSensorNeuralNetModel/README.md">Workflow/Battery/VirtualSensorNeuralNetModel</a></strong>.</td>
  </tr>
</table>

## 4. Estimate Efficient Gear Ratio for Electric Drive
<table>
  <tr>
    <td class="image-column" width=600><img src="Overview/Image/PMSMThermalTestGearResult.png" alt="Gear Ratio"></td>
    <td class="text-column" width=300>Drive units with fixed gear ratio are usually the most cost effective option for battery electric vehicle. To determine an appropriate fixed gear ratio, run a design of experiment (DoE) which covers a range of gear ratios and test cycle parameters. See <strong><a href="Workflow/MotorDrive/GearRatioSelect/README.md">Workflow/MotorDrive/GearRatioSelect</a></strong>.</td>
  </tr>
</table>

## 5. Setup Electric Motor Test Bench for System Integration
<table>
  <tr>
    <td class="text-column" width=300>Learn how to generate a permanent magnet synchronous motor (PMSM) for a system level (electro-thermal) simulation by creating a motor loss map and integrating it into the system level blocks. See <strong><a href="Workflow/MotorDrive/GenerateMotInvLoss/README.md">Workflow/MotorDrive/GenerateMotInvLoss</a></strong>.</td>
    <td class="image-column" width=600><img src="Overview/Image/PMSMlossMapGen.PNG" alt="Motor Loss Map"></td>
  </tr>
</table>

## 6. Verify Electric Drive Durability and Life
<table>
  <tr>
    <td class="image-column" width=600><img src="Overview/Image/PMSMThermalTestInverterResult.png" alt="Durability"></td>
    <td class="text-column" width=300>Estimate the inverter power module semiconductor device junction temperature variation due to switching and predict the lifetime of the inverter. See <strong><a href="Workflow/MotorDrive/InverterLife/README.md">Workflow/MotorDrive/InverterLife</a></strong> and <strong><a href="Workflow/MotorDrive/ThermalDurability/README.md">Workflow/MotorDrive/ThermalDurability</a></strong>.</td>
  </tr>
</table>


## Repository Architecture

For the full project architecture — folder responsibilities, source-of-truth, config schema, app layers, export flow, component inventory, workflow catalog, drift risks, and extension guides — see **[Overview/README.md](Overview/README.md)**.

## Release Notes

**R2022b** (Feb 2023)
- Initial release — BEV system model with range estimation and battery sizing workflows

**R2023a** (Oct 2023)
- GitHub Actions CI introduced
- Battery component update

**R2023b** (Jul 2024)
- Fast running model variant
- Document updates

**R2024b** (Dec 2025)
- Componentization — models restructured into self-contained packages with shared port interfaces
- Range estimation workflow updated
- PMSM model block and motor drive workflow updates

**R2024b Update 2** (Apr 2026) — Latest release
- BEV Setup App — GUI-based vehicle configuration and script export
- JSON config-driven template/fidelity system with presets
- 3 new dummy fidelities for simplified simulations
- Standardized documentation across all 12 components and 7 workflows
- Architecture reference doc with extension guides

## Related Solutions

- [Simscape Battery Electric Vehicle Model](https://www.mathworks.com/matlabcentral/fileexchange/82250) — BEV reference model with battery, motor, and vehicle dynamics
- [Simscape HEV Series-Parallel](https://www.mathworks.com/matlabcentral/fileexchange/92820) — Hybrid electric vehicle model with series-parallel powertrain architecture

## Setup 
* Clone the project repository.
* Open ElectricVehicleSimscape.prj to get started with the project. 
* Requires MATLAB&reg; release R2024b or newer.

Copyright 2022 - 2026 The MathWorks, Inc.

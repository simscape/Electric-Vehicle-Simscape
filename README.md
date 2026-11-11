# Electric Vehicle Design with Simscape

[![View Electric Vehicle Design with Simscape on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/124795-electric-vehicle-design-with-simscape)

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=simscape/Electric-Vehicle-Simscape)

<table>
  <tr>
    <td class="text-column" width="1200">
      In this project, you will find Simscape workflows for designing battery electric vehicles.
      Modeling and simulation help you meet range targets under different environmental conditions
      and evaluate components and complete vehicle platforms.
    </td>
  </tr>
</table>

<table>
  <tr>
    <td class="image-column" width="1200"><img src="Overview/html/Image/BatteryElectricVehicleModelOverview_01.png" alt="BEV vehicle-level system model"></td>
  </tr>
</table>

## Electrical Analysis

<table>
  <tr>
    <td class="text-column" width="1200">
      On the electrical side, you size battery packs to meet range targets, build virtual
      sensors for battery temperature estimation, generate motor and inverter loss maps,
      and compare vehicle range across drive cycles and ambient conditions.
    </td>
  </tr>
</table>

<table>
  <tr>
    <td class="image-column" width="600" align="center" valign="middle"><img src="Overview/html/Image/PMSMlossMapGen.PNG" alt="PMSM motor and inverter loss-map generation test bench"></td>
    <td class="image-column" width="600" align="center" valign="middle"><img src="Overview/html/Image/BatteryNeuralNetResults.png" alt="Predicted and actual battery temperatures using a neural-network virtual sensor"></td>
  </tr>
</table>

## Mechanical Analysis

<table>
  <tr>
    <td class="text-column" width="1200">
      On the mechanical side, you select a fixed gear ratio for the electric drivetrain.
      Sweep candidate gear ratios over EUDC and US06 drive cycles, compare motor winding
      and magnet temperatures, and identify a suitable ratio based on motor thermal performance.
    </td>
  </tr>
</table>

<table>
  <tr>
    <td class="image-column" width="1200" align="center" valign="middle"><img src="Overview/html/Image/PMSMThermalTestGearResult.png" alt="Motor winding and magnet temperatures for different gear ratios over the EUDC drive cycle"></td>
  </tr>
</table>

## Thermal Analysis

<table>
  <tr>
    <td class="text-column" width="1200">
      On the thermal side, you explore vehicle thermal management and assess motor thermal
      durability over extended duty cycles at different coolant temperatures. Compare winding
      and magnet temperatures against limits, and estimate inverter power-module life from
      junction-temperature cycles.
    </td>
  </tr>
</table>

<table>
  <tr>
    <td class="image-column" width="600" align="center" valign="middle"><img src="Overview/html/Image/BatteryElectricVehicleModelOverviewThermalDiagram.png" alt="Vehicle thermal-management circuit for the battery and electric drivetrain"></td>
    <td class="image-column" width="600" align="center" valign="middle"><img src="Overview/html/Image/PMSMThermalTestInverterResult.png" alt="Inverter IGBT junction temperatures during duty and test cycles"></td>
  </tr>
</table>

<hr color="gray" size="10">

## To Get Started

* Clone this repository and open `ElectricVehicleSimscape.prj`.
* Launch the BEV Setup App (`BEVapp`) or select presets using `OpenPresetPicker`.

## Requirements

* MATLAB&reg; release R2024b or newer.
* Simulink&reg;, Simscape&trade;, Simscape Battery&trade;, Simscape Driveline&trade;, Simscape Fluids&trade;, and Simscape Electrical&trade;.

Copyright 2022 - 2026 The MathWorks, Inc.

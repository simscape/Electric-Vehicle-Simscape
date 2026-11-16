# Electric Vehicle Design with Simscape

[![View Electric Vehicle Design with Simscape on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/124795-electric-vehicle-design-with-simscape)

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=simscape/Electric-Vehicle-Simscape)

<table>
  <tr>
    <td class="text-column" width=1200>
      In this project, you will find Simscape workflows for designing battery electric vehicles.
      Modeling and simulation help you meet range targets under different environmental conditions
      and evaluate components and complete vehicle platforms.
    </td>
  </tr>
</table>

<table>
  <tr>
    <td class="image-column" width=1200 align="center">
      <p align="center"><img src="Overview/html/Image/BatteryElectricVehicleModelOverview_01.png" width="78%" alt="BEV vehicle-level system model"></p>
    </td>
  </tr>
</table>

## Electrical Analysis

<table>
  <tr>
    <td class="text-column" width=1200>
      On the electrical side, you size battery packs to meet range targets, build virtual
      sensors for battery temperature estimation, generate motor and inverter loss maps, and
      compare vehicle range across drive cycles, ambient temperatures, and HVAC loads.
    </td>
  </tr>
</table>

<table>
  <tr>
    <td class="image-column" width="600" align="center" valign="middle"><img src="Overview/html/Image/PMSMlossMapGen.PNG" alt="PMSM motor and inverter loss-map generation test bench"></td>
    <td class="image-column" width="600" align="center" valign="middle"><img src="Overview/html/Image/BatteryNeuralNetResults.png" alt="Predicted and actual battery temperatures using a neural-network virtual sensor"></td>
  </tr>
</table>

## Thermal Analysis

<table>
  <tr>
    <td class="text-column" width=1200>
      On the thermal side, you assess motor thermal durability over extended duty cycles at
      different coolant temperatures, compare winding and magnet temperatures against limits,
      and estimate inverter power-module life from junction-temperature cycles.
    </td>
  </tr>
</table>

<table>
  <tr>
    <td class="image-column" width="600" align="center" valign="middle"><img src="Overview/html/Image/BatteryElectricVehicleModelOverviewThermalDiagram.png" alt="Vehicle thermal-management circuit for the battery and electric drivetrain"></td>
    <td class="image-column" width="600" align="center" valign="middle"><img src="Overview/html/Image/PMSMThermalTestInverterResult.png" alt="Inverter IGBT junction temperatures during duty and test cycles"></td>
  </tr>
</table>

## Mechanical Analysis

<table>
  <tr>
    <td class="text-column" width=1200>
      On the mechanical side, you select gear ratios within motor thermal limits, evaluate
      torque ripple and driveline vibration using frequency order maps, and optimize launch
      ratios to reduce vehicle jerk while maintaining acceleration.
    </td>
  </tr>
</table>

<table>
  <tr>
    <td class="image-column" width="600" align="center" valign="middle"><img src="Overview/html/Image/DrivelineOrderMap.png" alt="Frequency order map of motor-bearing excitation versus motor speed and order"></td>
    <td class="image-column" width="600" align="center" valign="middle"><img src="Overview/html/Image/VehicleLaunchJerkComparison.png" alt="Optimized and baseline vehicle jerk during launch"></td>
  </tr>
</table>

<hr color="gray" size="10">

## To Get Started

* Clone this repository and open `ElectricVehicleSimscape.prj`.
* Select a preset using `OpenPresetPicker` to get started.
* Use the BEV Setup App (`BEVapp`) when you want a custom vehicle configuration.

## Requirement(s)

* MATLAB&reg; release R2025b or newer
* Simulink&reg;, Simscape&trade;, Simscape Battery&trade;, Simscape Driveline&trade;, Simscape Fluids&trade;, Simscape Electrical&trade;, Stateflow&reg;, Powertrain Blockset&trade;, Deep Learning Toolbox&trade;, MATLAB Coder&trade;, Predictive Maintenance Toolbox&trade;, Signal Processing Toolbox&trade;, System Identification Toolbox&trade;, Statistics and Machine Learning Toolbox&trade;, Optimization Toolbox&trade;, Global Optimization Toolbox&trade;

Copyright 2022 - 2026 The MathWorks, Inc.

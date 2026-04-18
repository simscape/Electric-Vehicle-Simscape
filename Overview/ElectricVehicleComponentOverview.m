%% BEV Component Overview
%
% This page summarises the reusable component packages that make up the
% BEV Simscape system model. It covers the standard folder structure,
% available component variants and fidelities, vehicle templates, parameter
% conventions, and how these connect to the BEV Setup App.
%
% Copyright 2022 - 2026 The MathWorks, Inc.

%% Components Folder Structure
%
% Every component follows a standardised layout:
%
% <html>
% <table border="1" cellpadding="6" cellspacing="0" style="border-collapse:collapse;">
% <tr><th>Folder</th><th>Purpose</th></tr>
% <tr><td><code>Model/</code></td><td>Component model variants (<code>.slx</code>) and parameter scripts (<code>*Params.m</code>)</td></tr>
% <tr><td><code>TestBench/</code></td><td>Standalone test harness with boundary conditions</td></tr>
% <tr><td><code>TestCase/</code></td><td>MATLAB unit tests (<code>*PassTests.m</code>)</td></tr>
% <tr><td><code>Documentation/html/</code></td><td>Published HTML documentation pages</td></tr>
% <tr><td><code>Documentation/images/</code></td><td>Screenshots and figures</td></tr>
% <tr><td><code>Utilities/</code></td><td>Plot functions and helper scripts</td></tr>
% <tr><td><code>Library/</code></td><td>Shared Simulink library blocks (select components only)</td></tr>
% <tr><td><code>README.md</code></td><td>Component-level summary and usage notes</td></tr>
% </table>
% </html>

%% Component Inventory
%
% All 12 components with their available fidelity variants. Fidelity names
% link to published HTML documentation where available.
%
% <html>
% <table border="1" cellpadding="6" cellspacing="0" style="border-collapse:collapse; width:100%;">
% <tr>
%   <th>Component</th>
%   <th>Description</th>
%   <th>Fidelities</th>
%   <th>Thermal</th>
%   <th>Test Harness</th>
% </tr>
% <tr>
%   <td><strong>BatteryHV</strong></td>
%   <td>High-voltage battery pack</td>
%   <td>
%     <a target="_blank" href="../../Components/BatteryHV/Documentation/html/BatteryLumpedDescription.html">BatteryLumped</a>,
%     <a target="_blank" href="../../Components/BatteryHV/Documentation/html/BatteryLumpedThermalDescription.html">BatteryLumpedThermal</a>,
%     <a target="_blank" href="../../Components/BatteryHV/Documentation/html/BatteryTableBasedDescription.html">BatteryTableBased</a>
%   </td>
%   <td style="text-align:center;">Yes</td>
%   <td style="text-align:center;"><a target="_blank" href="../../Components/BatteryHV/Documentation/html/BatteryTestHarnessDescription.html">Yes</a></td>
% </tr>
% <tr>
%   <td><strong>BatteryHeater</strong></td>
%   <td>PTC heater for cold-climate battery warming</td>
%   <td>
%     <a target="_blank" href="../../Components/BatteryHeater/Documentation/html/HeaterDescription.html">Heater</a>,
%     <a target="_blank" href="../../Components/BatteryHeater/Documentation/html/HeaterDummyDescription.html">HeaterDummy</a>
%   </td>
%   <td style="text-align:center;">Yes</td>
%   <td style="text-align:center;"><a target="_blank" href="../../Components/BatteryHeater/Documentation/html/HeaterTestHarnessDescription.html">Yes</a></td>
% </tr>
% <tr>
%   <td><strong>BMS</strong></td>
%   <td>Battery management system with SOC estimation variants</td>
%   <td>
%     <a target="_blank" href="../../Components/BMS/Documentation/html/BMSDescription.html">BMS</a>,
%     <a target="_blank" href="../../Components/BMS/Documentation/html/BMSSoCDirectDescription.html">BMSSoCDirect</a>,
%     <a target="_blank" href="../../Components/BMS/Documentation/html/BMSSoCEKFDescription.html">BMSSoCEKF</a>
%   </td>
%   <td style="text-align:center;">Yes</td>
%   <td style="text-align:center;">Yes</td>
% </tr>
% <tr>
%   <td><strong>Charger</strong></td>
%   <td>On-board charger with CC-CV control and thermal variants</td>
%   <td>
%     <a target="_blank" href="../../Components/Charger/Documentation/html/ChargerDescription.html">Charger</a>,
%     <a target="_blank" href="../../Components/Charger/Documentation/html/ChargerDummyDescription.html">ChargerDummy</a>,
%     <a target="_blank" href="../../Components/Charger/Documentation/html/ChargerThermalDescription.html">ChargerThermal</a>,
%     <a target="_blank" href="../../Components/Charger/Documentation/html/ChargerThermalDummyDescription.html">ChargerThermalDummy</a>
%   </td>
%   <td style="text-align:center;">Yes</td>
%   <td style="text-align:center;"><a target="_blank" href="../../Components/Charger/Documentation/html/ChargerTestHarnessDescription.html">Yes</a></td>
% </tr>
% <tr>
%   <td><strong>Chiller</strong></td>
%   <td>Refrigerant-to-coolant chiller for battery thermal management</td>
%   <td>
%     <a target="_blank" href="../../Components/Chiller/Documentation/html/ChillerDescription.html">Chiller</a>,
%     <a target="_blank" href="../../Components/Chiller/Documentation/html/ChillerNoCoolantDescription.html">ChillerNoCoolant</a>,
%     <a target="_blank" href="../../Components/Chiller/Documentation/html/ChillerDummyDescription.html">ChillerDummy</a>
%   </td>
%   <td style="text-align:center;">Yes</td>
%   <td style="text-align:center;"><a target="_blank" href="../../Components/Chiller/Documentation/html/ChillerTestHarnessDescription.html">Yes</a></td>
% </tr>
% <tr>
%   <td><strong>Controller</strong></td>
%   <td>Vehicle-level supervisory controller</td>
%   <td>
%     <a target="_blank" href="../../Components/Controller/Documentation/html/ControllerDescription.html">Controller</a>,
%     <a target="_blank" href="../../Components/Controller/Documentation/html/ControllerFRMDescription.html">ControllerFRM</a>,
%     <a target="_blank" href="../../Components/Controller/Documentation/html/ControllerHVACDescription.html">ControllerHVAC</a>
%   </td>
%   <td style="text-align:center;">No</td>
%   <td style="text-align:center;">No</td>
% </tr>
% <tr>
%   <td><strong>Driveline</strong></td>
%   <td>Mechanical driveline with optional braking</td>
%   <td>
%     <a target="_blank" href="../../Components/Driveline/Documentation/html/DrivelineDescription.html">Driveline</a>,
%     <a target="_blank" href="../../Components/Driveline/Documentation/html/DrivelineWithBrakingDescription.html">DrivelineWithBraking</a>
%   </td>
%   <td style="text-align:center;">No</td>
%   <td style="text-align:center;"><a target="_blank" href="../../Components/Driveline/Documentation/html/DrivelineTestHarnessDescription.html">Yes</a></td>
% </tr>
% <tr>
%   <td><strong>HVAC</strong></td>
%   <td>Cabin climate system</td>
%   <td>
%     <a target="_blank" href="../../Components/HVAC/Documentation/html/HVACEmpiricalRefDescription.html">HVACEmpiricalRef</a>,
%     <a target="_blank" href="../../Components/HVAC/Documentation/html/HVACSimpleThDescription.html">HVACSimpleTh</a>
%   </td>
%   <td style="text-align:center;">Yes</td>
%   <td style="text-align:center;"><a target="_blank" href="../../Components/HVAC/Documentation/html/HVACTestHarnessDescription.html">Yes</a></td>
% </tr>
% <tr>
%   <td><strong>MotorDrive</strong></td>
%   <td>Electric motor drive unit with gear, thermal, and lubrication variants</td>
%   <td>
%     <a target="_blank" href="../../Components/MotorDrive/Documentation/html/MotorDriveGearDescription.html">MotorDriveGear</a>,
%     <a target="_blank" href="../../Components/MotorDrive/Documentation/html/MotorDriveGearThDescription.html">MotorDriveGearTh</a>,
%     <a target="_blank" href="../../Components/MotorDrive/Documentation/html/MotorDriveLubeDescription.html">MotorDriveLube</a>,
%     <a target="_blank" href="../../Components/MotorDrive/Documentation/html/EmotorLibDescription.html">EmotorLib</a>
%   </td>
%   <td style="text-align:center;">Yes</td>
%   <td style="text-align:center;"><a target="_blank" href="../../Components/MotorDrive/Documentation/html/MotorTestHarnessDescription.html">Yes</a></td>
% </tr>
% <tr>
%   <td><strong>Pump</strong></td>
%   <td>Coolant circulation pump</td>
%   <td>
%     <a target="_blank" href="../../Components/Pump/Documentation/html/PumpDescription.html">Pump</a>,
%     <a target="_blank" href="../../Components/Pump/Documentation/html/PumpDummyDescription.html">PumpDummy</a>,
%     <a target="_blank" href="../../Components/Pump/Documentation/html/PumpDummyThDescription.html">PumpDummyTh</a>
%   </td>
%   <td style="text-align:center;">Yes</td>
%   <td style="text-align:center;"><a target="_blank" href="../../Components/Pump/Documentation/html/PumpTestHarnessDescription.html">Yes</a></td>
% </tr>
% <tr>
%   <td><strong>DCDC</strong></td>
%   <td>DC-DC converter driving the coolant pump</td>
%   <td>
%     <a target="_blank" href="../../Components/PumpDriver/Documentation/html/PumpDriverDescription.html">PumpDriver</a>,
%     <a target="_blank" href="../../Components/PumpDriver/Documentation/html/PumpDriverThDescription.html">PumpDriverTh</a>
%   </td>
%   <td style="text-align:center;">Yes</td>
%   <td style="text-align:center;"><a target="_blank" href="../../Components/PumpDriver/Documentation/html/PumpDriverTestHarnessDescription.html">Yes</a></td>
% </tr>
% <tr>
%   <td><strong>Radiator</strong></td>
%   <td>Coolant-to-air radiator with fan</td>
%   <td>
%     <a target="_blank" href="../../Components/Radiator/Documentation/html/RadiatorDescription.html">Radiator</a>
%   </td>
%   <td style="text-align:center;">Yes</td>
%   <td style="text-align:center;"><a target="_blank" href="../../Components/Radiator/Documentation/html/RadiatorTestHarnessDescription.html">Yes</a></td>
% </tr>
% </table>
% </html>
%
% *Totals:* 12 components, 32 fidelity variants, 11 test harnesses.

%% Templates and Model Structure
%
% The system model *BEVsystemModel.slx* assembles components via subsystem
% references. Pre-configured vehicle templates in *Model/VehicleTemplate/*
% provide ready-made assemblies at different fidelity scopes. The
% *Model/Display/* folder contains energy-flow visualisation subsystems
% (*EnergyElectric*, *EnergyElectroThermal*) used during simulation.
%
% <html>
% <p align="center">
%   <img src="../Image/BEVplantModelVehicle.png" alt="BEV Vehicle Template Structure" width="700">
% </p>
% </html>
%
% <html>
% <table border="1" cellpadding="6" cellspacing="0" style="border-collapse:collapse; width:100%;">
% <tr><th>Template</th><th>Description</th><th>Thermal</th><th>Auxiliary</th></tr>
% <tr><td><strong>VehicleElectric</strong></td><td>Minimal electrical powertrain &mdash; battery, motor, charger, driveline</td><td style="text-align:center;">No</td><td style="text-align:center;">No</td></tr>
% <tr><td><strong>VehicleElecAux</strong></td><td>Electrical powertrain with HVAC, pump, DCDC, and auxiliary loads</td><td style="text-align:center;">No</td><td style="text-align:center;">Yes</td></tr>
% <tr><td><strong>VehicleElectroThermal</strong></td><td>Full electro-thermal vehicle with coolant loop, chiller, heater, radiator</td><td style="text-align:center;">Yes</td><td style="text-align:center;">Yes</td></tr>
% <tr><td><strong>VehicleElectroThermalLowTemp</strong></td><td>Electro-thermal configured for cold-climate studies</td><td style="text-align:center;">Yes</td><td style="text-align:center;">Yes</td></tr>
% </table>
% </html>
%
% Fidelity-to-template mapping is defined in JSON config files under
% *APP/Config/Preset/*.

%% Parameters and Default Model Setup
%
% Each fidelity variant has a matching parameter script in the component
% *Model/* folder. The naming convention is *FidelityNameParams.m* — for
% example, *BatteryLumpedThermal.slx* is parameterised by
% *BatteryLumpedThermalParams.m*.
%
% Harness parameter scripts (*TestHarnessParams.m*) in *TestBench/* call
% the component param file and layer boundary-condition variables on top,
% so each harness is self-contained for standalone testing.
%
% <html>
% <p align="center">
%   <img src="../../Components/BatteryHV/Documentation/images/BatteryTestHarnessDescription_01.png" alt="BatteryLumpedThermal model" width="650">
% </p>
% </html>
%
% At the system level, the BEV Setup App generates a param setup script
% that calls all linked component param files in sequence. This populates
% the full vehicle workspace in one run for the selected model
% configuration.

%% Modularity and Reuse
%
% Each component folder is a self-contained digital asset package. Models,
% parameters, test harnesses, unit tests, documentation, and utilities all
% live inside the component folder. To reuse a component in another
% project, copy the entire folder — no external dependencies need to be
% resolved.
%
% Components within the same type share a common port interface, so
% switching fidelity is a single subsystem reference change at the system
% level. Thermal components expose Simscape conserving ports for coolant
% flow, allowing them to connect into a thermal loop at the system level
% while remaining independently testable with their own boundary
% conditions.

%% How This Connects to the BEV Setup App
%
% The BEV Setup App reads JSON config files from *APP/Config/Preset/* to
% populate its component dropdowns. Each config maps a vehicle template to
% the available fidelities per component. The app scans the component
% *Model/* folders to verify that the listed *.slx* files exist on disk
% before presenting them as options.
%
% <html>
% <p align="center">
%   <img src="../../APP/Documents/images/BEVappWindow.png" alt="BEV Setup App" width="650">
% </p>
% </html>
%
% Once a configuration is selected, the app generates setup and parameter
% scripts that wire the chosen component fidelities into the system model.
% The configured model is then ready for the engineering workflows
% elsewhere in the repository.

%% Adding a New Fidelity
%
% To add a new fidelity variant to an existing component:
%
% # Create the model *.slx* and its *Params.m* in the component *Model/*
% folder. Use an existing fidelity in that component as a reference for
% the port interface.
% # Add the new fidelity name to the relevant template entries in the JSON
% config under *APP/Config/Preset/*.
% # Add a documentation description file and publish HTML to
% *Documentation/html/*.
% # Update or create harness and test coverage in *TestBench/* and
% *TestCase/* as needed.
% # Follow the existing naming conventions — the app picks up new
% fidelities on its next config load with no app code changes required.

%% See Also
%
% * <matlab:web('ElectricVehicleDesignOverview.html') Electric Vehicle Design Overview>
% * <matlab:web('../../APP/Documents/html/helpAppDetail.html') BEV Setup App Reference>
% * <matlab:open_system('BEVsystemModel') BEV System Model>

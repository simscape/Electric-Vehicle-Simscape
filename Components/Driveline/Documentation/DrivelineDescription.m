%% Driveline
% Four-wheel driveline with front and rear axle connections, tire models,
% and vehicle body dynamics.

%% Overview
% The Driveline block models a four-wheel drivetrain with front and rear
% axle connections. It includes tire models for all four wheels (FR, FL,
% RR, RL) with slip dynamics and a vehicle body subsystem capturing
% longitudinal and lateral dynamics. Torque inputs from front and rear
% motor drive units are transmitted through the axles to the wheels.
%
% *Model:* <matlab:open_system('Driveline') Driveline.slx>
%
% *Parameters:* <matlab:edit('DrivelineParams.m') DrivelineParams.m>
%
% *Thermal Coupling:* None

%% Open Model

open_system('Driveline')

%% Ports
%
% <html>
% <h3>Input Bus &mdash; <code>s</code></h3>
% <p>Input bus <code>s</code> is terminated in this fidelity.</p>
% <h3>Output Bus &mdash; <code>m</code></h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Signal</th><th>Description</th></tr>
% <tr><td>VehSpd</td><td>Vehicle speed</td></tr>
% </table>
% <h3>Physical Ports</h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Port</th><th>Domain</th><th>Description</th></tr>
% <tr><td>FA</td><td>Mechanical rotational</td><td>Front axle connection</td></tr>
% <tr><td>RA</td><td>Mechanical rotational</td><td>Rear axle connection</td></tr>
% </table>
% </html>

%% Workflows
% The Driveline block is the *default driveline* in the assembled BEV
% system model (|BEVsystemModel.slx|). It is used in all range estimation
% workflows (NEDC, WLTC, EPA) and battery sizing workflows. The model is
% validated through |DriveLineTestHarness.slx|.

%% Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Tire rolling radius</td><td>0.30 m</td><td>Effective rolling radius of the tires</td></tr>
% <tr><td>Vehicle mass</td><td>1600 kg</td><td>Total vehicle mass including payload</td></tr>
% <tr><td>Max vehicle speed</td><td>140 km/h</td><td>Maximum allowable vehicle speed</td></tr>
% <tr><td>Brake factor</td><td>0.4</td><td>Braking force distribution factor</td></tr>
% </table>
% </html>
%
% See |DrivelineParams.m| for a complete list of parameters.

%% See Also
% * <DrivelineWithBrakingDescription.html DrivelineWithBraking>
% * <DrivelineTestHarnessDescription.html Driveline Test Harness>

% Copyright 2022 - 2026 The MathWorks, Inc.

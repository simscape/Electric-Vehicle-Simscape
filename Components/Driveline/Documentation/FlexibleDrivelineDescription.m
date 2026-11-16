%% FlexibleDriveline
% Flexible driveline with gear backlash, torsional shaft compliance, and
% motor bearing dynamics for NVH analysis.

%% Overview
% The FlexibleDriveline block extends the standard Driveline with flexible
% shafts, gear backlash, bearing friction, and motor torsional vibration
% subsystems. It captures high-frequency torsional dynamics relevant to
% Noise, Vibration, and Harshness (NVH) studies such as launch jerk
% minimization and frequency order map generation.
%
% The model includes a two-stage gear transmission with counter shaft,
% a front wheel differential, left and right tire models, and a motor
% mechanical subsystem with torsional vibration modes.
%
% *Model:* <matlab:open_system('FlexibleDriveline') FlexibleDriveline.slx>
%
% *Parameters:* <matlab:edit('FlexibleDriveLineTestHarnessParams.m') FlexibleDriveLineTestHarnessParams.m>
%
% *Thermal Coupling:* None

%% Open Model
%   open_system('FlexibleDriveline')
%
% <html>
% <img src="images/FlexibleDrivelineDescription_01.png" alt="FlexibleDriveline block diagram">
% </html>

%% Ports
%
% <html>
% <h3>Physical Ports &mdash; Input</h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Port</th><th>Domain</th><th>Description</th></tr>
% <tr><td>I</td><td>Mechanical rotational</td><td>Motor shaft input</td></tr>
% </table>
% <h3>Physical Ports &mdash; Output</h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Port</th><th>Domain</th><th>Description</th></tr>
% <tr><td>D1</td><td>Mechanical rotational</td><td>Left drive shaft output</td></tr>
% <tr><td>D2</td><td>Mechanical rotational</td><td>Right drive shaft output</td></tr>
% </table>
% <h3>Output Bus &mdash; <code>meas</code></h3>
% <p>Measurement bus containing sensor signals from the driveline.</p>
% </html>

%% Subsystems
%
% * *Motor Mechanical* &mdash; Motor shaft with bearings and torsional vibration modes
% * *Gear Transmission* &mdash; Two-stage gear ratio with flexible counter shafts, gear backlash, and radial load sensors
% * *Front wheel differential* &mdash; Final drive with configurable gear ratio
% * *Left tire / Right tire* &mdash; Tire models with slip dynamics
% * *Mechanical sensor* &mdash; Speed and torque measurement

%% Parameters
%
% <html>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Name</th><th>Default</th><th>Description</th></tr>
% <tr><td>Motor-to-CS gear ratio</td><td>2.5</td><td>Motor pinion to counter shaft gear ratio</td></tr>
% <tr><td>CS-to-MS gear ratio</td><td>1.0</td><td>Counter shaft to main shaft gear ratio</td></tr>
% <tr><td>Overall gear ratio</td><td>7.5</td><td>Total gear reduction (motor to wheel)</td></tr>
% <tr><td>Gear backlash</td><td>1e&minus;3 rad</td><td>Backlash at each gear mesh</td></tr>
% <tr><td>Gear mesh stiffness</td><td>1e6 N&middot;m/rad</td><td>Contact stiffness at gear mesh</td></tr>
% <tr><td>Counter shaft torsional stiffness</td><td>2e5 N&middot;m/rad</td><td>Torsional stiffness of flexible shaft segments</td></tr>
% <tr><td>Tire rolling radius</td><td>0.33 m</td><td>Effective rolling radius of the tires</td></tr>
% <tr><td>Vehicle mass</td><td>1000 kg</td><td>Total vehicle mass</td></tr>
% </table>
% </html>
%
% See |FlexibleDriveLineTestHarnessParams.m| for a complete list of parameters.

%% Workflows
% The FlexibleDriveline block is used in driveline NVH analysis workflows:
%
% * <matlab:open('optimizeVehicleLaunch.mlx') Optimize Gear Ratios for Vehicle Launch>
% * <matlab:open('generateOrderMap.mlx') Generate Frequency Order Map>

%% See Also
% * <DrivelineDescription.html Driveline>
% * <DrivelineWithBrakingDescription.html DrivelineWithBraking>

% Copyright 2026 The MathWorks, Inc.

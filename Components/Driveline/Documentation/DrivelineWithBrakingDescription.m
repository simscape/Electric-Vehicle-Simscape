%% DrivelineWithBraking
% Extended driveline model with an integrated braking system on the rear
% axle.

%% Overview
% The DrivelineWithBraking block extends the standard Driveline with an
% integrated braking system on the rear axle. In addition to all features
% of the base Driveline, this variant captures traction and braking forces
% for deceleration studies and blended regenerative/friction braking
% analysis.
%
% *Model:* |DrivelineWithBraking.slx|
%
% *Parameters:* |DrivelineWithBrakingParams.m|
%
% *Thermal Coupling:* None

%% Open Model

open_system('DrivelineWithBraking')

%% Ports
% *Inputs*
%
% * *Front axle torque (FA)* - Torque from the front motor.
% * *Rear axle torque (RA)* - Torque from the rear motor.
% * *Brake command* - Mechanical braking torque request.
%
% *Outputs*
%
% * *Vehicle Speed* - Longitudinal vehicle speed.
% * *Wheel Dynamics* - Wheel speeds, slip, and traction forces.
% * *Braking Response* - Braking force and deceleration.

%% Workflows
% The DrivelineWithBraking block is used in vehicle configurations that
% require explicit mechanical braking behavior. It is tested through
% |DriveLineTestHarness.slx| and |DrivelinePassTests.m|.

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
% See |DrivelineWithBrakingParams.m| for a complete list of parameters.

%% See Also
% * <DrivelineDescription.html Driveline>
% * <DrivelineTestHarnessDescription.html Driveline Test Harness>

% Copyright 2022 - 2025 The MathWorks, Inc.

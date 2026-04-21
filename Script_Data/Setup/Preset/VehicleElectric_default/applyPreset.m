%% Apply Preset: VehicleElectric_default
% Basic electric powertrain — battery, dual motors, charger, driveline.
% No thermal management or auxiliary systems.
%
% Usage:
%   run('Script_Data/Setup/Preset/VehicleElectric_default/applyPreset.m')
% Copyright 2026 The MathWorks, Inc.

thisDir = fileparts(mfilename('fullpath'));

fprintf('Applying preset: VehicleElectric_default\n');

% Configure model subsystem references
run(fullfile(thisDir, 'BEVsystemModel_ssr_setup.m'));

% Wait for model and referenced subsystems to fully load
pause(5);

% Load preset parameters (overwrites any defaults from callbacks)
run(fullfile(thisDir, 'BEVsystemModel_params_setup.m'));

fprintf('Preset applied: VehicleElectric_default\n');

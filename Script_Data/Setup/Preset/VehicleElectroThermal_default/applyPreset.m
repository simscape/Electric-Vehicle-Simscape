%% Apply Preset: VehicleElectroThermal_default
% Full electro-thermal vehicle model with thermal-aware battery, motor-drives,
% charger, and complete coolant loop (radiator, chiller, heater, pumps).
%
% Usage:
%   run('Script_Data/Setup/Preset/VehicleElectroThermal_default/applyPreset.m')
% Copyright 2026 The MathWorks, Inc.

thisDir = fileparts(mfilename('fullpath'));

fprintf('Applying preset: VehicleElectroThermal_default\n');

% Configure model subsystem references
run(fullfile(thisDir, 'BEVsystemModel_ssr_setup.m'));

% Wait for model and referenced subsystems to fully load
pause(5);

% Load preset parameters (overwrites any defaults from callbacks)
run(fullfile(thisDir, 'BEVsystemModel_params_setup.m'));

fprintf('Preset applied: VehicleElectroThermal_default\n');

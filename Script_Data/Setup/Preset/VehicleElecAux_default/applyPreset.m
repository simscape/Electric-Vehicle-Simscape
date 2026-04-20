%% Apply Preset: VehicleElecAux_default
% Electric powertrain with auxiliary systems — HVAC, coolant pumps, pump driver.
% Thermal fluid loops are not modeled.
%
% Usage:
%   run('Script_Data/Setup/Preset/VehicleElecAux_default/applyPreset.m')

thisDir = fileparts(mfilename('fullpath'));

fprintf('Applying preset: VehicleElecAux_default\n');

% Configure model subsystem references
run(fullfile(thisDir, 'BEVsystemModel_ssr_setup.m'));

% Load parameters into base workspace
run(fullfile(thisDir, 'BEVsystemModel_params_setup.m'));

fprintf('Preset applied: VehicleElecAux_default\n');

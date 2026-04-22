classdef BEVPresetTest < matlab.unittest.TestCase
% BEVPRESETTEST Apply each discovered preset and compile-check the model.
%   For every preset in Script_Data/Setup/Preset/:
%     1. Clear the base workspace
%     2. Run the SSR script  (setupModelReferences — sets subsystem refs)
%     3. Run the param script (setupModelParameters — loads params)
%     4. Diagram-update the model (compile check)
%
%   Run all:
%     results = runtests('BEVPresetTest');
%
%   Run one preset:
%     results = runtests('BEVPresetTest', ...
%         'ParameterProperty','Preset','ParameterName','VehicleElectric*');
%
% Copyright 2026 The MathWorks, Inc.

    properties (TestParameter)
        Preset = localBuildPresetParams()
    end

    properties (Access = private)
        Root
    end

    % ---- Class-level setup / teardown ----

    methods (TestClassSetup)
        function setupProject(testCase)
        % SETUPPROJECT Capture project root once for the whole suite.
            testCase.Root = char(matlab.project.rootProject().RootFolder);
        end
    end

    methods (TestClassTeardown)
        function closeAllModels(~)
        % CLOSEALLMODELS Clean up any Simulink models left open.
            localCloseAllModels();
        end
    end

    % ---- Test method ----

    methods (Test)
        function presetApplyAndCompile(testCase, Preset)
        % PRESETAPPLYANDCOMPILE Clear workspace, apply preset, compile-check.

            fprintf('\n>> Preset: %s\n', Preset.Name);

            % ---- Guard: preset must be complete ----
            testCase.assumeEqual(Preset.Status, 'Complete', ...
                sprintf('Preset %s is incomplete: %s', Preset.Name, Preset.Status));

            % ---- Close any open models from previous test ----
            localCloseAllModels();

            % ---- Clear base workspace ----
            evalin('base', 'clear');

            % ---- Run SSR script (opens model, sets subsystem references) ----
            run(Preset.SSRScript);
            pause(5);

            % ---- Run param script (loads parameters into base workspace) ----
            evalin('base', sprintf('run(''%s'')', ...
                strrep(Preset.ParamScript, '''', '''''')));

            % ---- Compile check (diagram update) ----
            modelName = 'BEVsystemModel';
            testCase.assertTrue(bdIsLoaded(modelName), ...
                sprintf('Model %s not loaded after SSR script.', modelName));

            set_param(modelName, 'SimulationCommand', 'update');
            fprintf('   Compile check passed: %s\n', Preset.Name);
        end
    end
end


%% ========================= Local functions =========================

function params = localBuildPresetParams()
% LOCALBUILDPRESETPARAMS Discover presets and return one test parameter each.
    presets = bevPresetUI.discoverPresets();

    params = struct();

    for k = 1:numel(presets)
        preset = presets(k);

        key = matlab.lang.makeValidName(preset.Name);
        params.(key) = struct( ...
            'Name',        preset.Name, ...
            'Folder',      preset.Folder, ...
            'SSRScript',   preset.SSRScript, ...
            'ParamScript', preset.ParamScript, ...
            'Status',      preset.Status);
    end
end


function localCloseAllModels()
% LOCALCLOSEALLMODELS Close any open Simulink models.
    try
        openModels = get_param(Simulink.allBlockDiagrams('model'), 'Name');
        if ~iscell(openModels), openModels = {openModels}; end
        for k = 1:numel(openModels)
            try, close_system(openModels{k}, 0); catch, end
        end
    catch
    end
end

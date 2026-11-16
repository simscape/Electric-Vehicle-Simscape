classdef BEVPresetTest < matlab.unittest.TestCase
% BEVPRESETTEST Apply each discovered preset and compile-check the model.
%   For every preset in Script_Data/Setup/Preset/:
%     1. Clear the base workspace
%     2. Run the SSR script  (setupModelReferences — sets subsystem refs)
%     3. Run the param script (setupModelParameters — loads params)
%     4. Diagram-update the model (compile check)
%     5. Simulate for 100 seconds (runtime check)
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
        InitialDiagrams
    end

    % ---- Class-level setup / teardown ----

    methods (TestClassSetup)
        function setupProject(testCase)
        % SETUPPROJECT Capture project root once for the whole suite.
            testCase.Root = char(matlab.project.rootProject().RootFolder);
            testCase.InitialDiagrams = Simulink.allBlockDiagrams();
        end
    end

    methods (TestClassTeardown)
        function closeTestDiagrams(testCase)
        % CLOSETESTDIAGRAMS Close block diagrams opened by this test class.
            localCloseNewBlockDiagrams(testCase.InitialDiagrams);
        end
    end

    % ---- Test method ----

    methods (Test)
        function presetApplicationDoesNotSaveShippedModels(testCase, Preset)
        % PRESETAPPLICATIONDOESNOTSAVESHIPPEDMODELS Apply references in memory.
            testCase.assumeEqual(Preset.Status, 'Complete');
            initialDiagrams = Simulink.allBlockDiagrams();
            initialDiagramNames = localDiagramNames(initialDiagrams);
            presetDiagramNames = [ ...
                "BEVsystemModel", "VehicleElectric", ...
                "VehicleElecAux", "VehicleElectroThermal"];
            testCase.assumeFalse(any(ismember( ...
                presetDiagramNames, initialDiagramNames)), ...
                "A shipped preset model is already loaded.");

            modelFiles = [ ...
                fullfile(testCase.Root, "Model", "BEVsystemModel.slx"), ...
                fullfile(testCase.Root, "Model", "VehicleTemplate", ...
                    "VehicleElectric.slx"), ...
                fullfile(testCase.Root, "Model", "VehicleTemplate", ...
                    "VehicleElecAux.slx"), ...
                fullfile(testCase.Root, "Model", "VehicleTemplate", ...
                    "VehicleElectroThermal.slx")];
            fileCleanup = localProtectModelFiles( ...
                modelFiles, initialDiagrams); %#ok<NASGU>
            before = arrayfun( ...
                @localReadBytes, modelFiles, UniformOutput=false);

            run(Preset.SSRScript);

            for k = 1:numel(modelFiles)
                testCase.verifyEqual( ...
                    localReadBytes(modelFiles(k)), before{k});
            end
            testCase.verifyTrue(bdIsLoaded("BEVsystemModel"));
            expectedTemplate = extractBefore( ...
                string(Preset.Name), "_default");
            actualTemplate = string(get_param( ...
                "BEVsystemModel/Vehicle", "ReferencedSubsystem"));
            testCase.verifyEqual(actualTemplate, expectedTemplate);

            clear fileCleanup
            testCase.verifyEqual( ...
                sort(localDiagramNames(Simulink.allBlockDiagrams())), ...
                sort(initialDiagramNames));
        end

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

            % ---- Verify model loaded, then simulate (also validates compilation) ----
            modelName = 'BEVsystemModel';
            testCase.assertTrue(bdIsLoaded(modelName), ...
                sprintf('Model %s not loaded after SSR script.', modelName));

            % ---- Hide model window so sim() compile doesn't shrink the canvas ----
            set_param(modelName, 'Open', 'off');

            origStop = get_param(modelName, 'StopTime');
            set_param(modelName, 'StopTime', '100');
            simout = sim(modelName, 'SrcWorkspace', 'base');
            set_param(modelName, 'StopTime', origStop);

            testCase.verifyNotEmpty(simout, ...
                sprintf('Simulation returned empty for preset %s.', Preset.Name));
            fprintf('   Simulation passed: %s\n', Preset.Name);
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
    openModels = get_param(Simulink.allBlockDiagrams('model'), 'Name');
    if ~iscell(openModels), openModels = {openModels}; end
    for k = 1:numel(openModels)
        try
            close_system(openModels{k}, 0);
        catch ME
            warning('BEVPresetTest:closeFailed', ...
                'Could not close %s: %s', openModels{k}, ME.message);
        end
    end
end

function cleanup = localProtectModelFiles(paths, initialDiagrams)
% LOCALPROTECTMODELFILES Restore shipped model files after the test.
    backupFolder = string(tempname);
    mkdir(backupFolder);
    for k = 1:numel(paths)
        copyfile(paths(k), fullfile(backupFolder, string(k) + ".slx"));
    end
    cleanup = onCleanup( ...
        @() localRestoreModelFiles(paths, backupFolder, initialDiagrams));
end

function localRestoreModelFiles(paths, backupFolder, initialDiagrams)
% LOCALRESTOREMODELFILES Close models and restore their original bytes.
    localCloseNewBlockDiagrams(initialDiagrams);
    for k = 1:numel(paths)
        backupFile = fullfile(backupFolder, string(k) + ".slx");
        if ~isequal(localReadBytes(paths(k)), localReadBytes(backupFile))
            copyfile(backupFile, paths(k), "f");
        end
    end
    rmdir(backupFolder, "s");
end

function bytes = localReadBytes(path)
% LOCALREADBYTES Read a model file as raw bytes.
    fid = fopen(path, "rb");
    assert(fid >= 0, ...
        "BEVPresetTest:fileOpenFailed", "Could not open %s.", path);
    cleanup = onCleanup(@() fclose(fid));
    bytes = fread(fid, Inf, "*uint8");
end

function localCloseNewBlockDiagrams(initialDiagrams)
% LOCALCLOSENEWBLOCKDIAGRAMS Close block diagrams opened by the test.
    modelDiagrams = Simulink.allBlockDiagrams("model");
    newModels = setdiff(modelDiagrams, initialDiagrams, "stable");
    for k = 1:numel(newModels)
        close_system(newModels(k), 0);
    end

    currentDiagrams = Simulink.allBlockDiagrams();
    newDiagrams = setdiff(currentDiagrams, initialDiagrams, "stable");
    for k = 1:numel(newDiagrams)
        close_system(newDiagrams(k), 0);
    end
end

function names = localDiagramNames(diagrams)
% LOCALDIAGRAMNAMES Return block diagram names as a string column.
    names = strings(0, 1);
    if ~isempty(diagrams)
        names = string(get_param(diagrams, "Name"));
        names = names(:);
    end
end

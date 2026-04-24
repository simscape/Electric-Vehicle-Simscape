classdef BEVFidelityTest < matlab.unittest.TestCase
%BEVFIDELITYTEST Parameterized test for all JSON preset fidelity variants.
%   Generates setup output, compile-checks, and simulates (100 s) every
%   template x fidelity combination defined in VehicleTemplateConfig.json.
%
%   Run all:
%     results = runtests('BEVFidelityTest');
%
%   Run one template:
%     results = runtests('BEVFidelityTest', ...
%         'ParameterProperty','Setup','ParameterName','VehicleElectric*');
%
%   Run with report:
%     runBEVFidelityReport
%     runBEVFidelityReport('VehicleElecAux')
%
%   Copyright 2026 The MathWorks, Inc.

    properties (TestParameter)
        Setup = localBuildParams()
    end

    properties (Access = private)
        App
        CurrentTemplate = ''
        Root
        SetupRoot
        RawCfg
    end

    % ---- Class-level setup / teardown ----

    methods (TestClassSetup)
        function setupProject(testCase)
            testCase.Root = char(matlab.project.rootProject().RootFolder);
            configFile = fullfile(testCase.Root, ...
                'APP', 'Config', 'Preset', 'VehicleTemplateConfig.json');
            testCase.RawCfg   = jsondecode(fileread(configFile));
            testCase.SetupRoot = fullfile(testCase.Root, 'Script_Data', 'Setup', 'User');

            % Clear saved user configs so no stale setups leak in
            userConfigDir = fullfile(testCase.Root, 'APP', 'Config', 'User');
            if isfolder(userConfigDir)
                stale = dir(fullfile(userConfigDir, '*.json'));
                for j = 1:numel(stale)
                    delete(fullfile(stale(j).folder, stale(j).name));
                end
            end
        end
    end

    methods (TestClassTeardown)
        function closeAll(testCase)
            if ~isempty(testCase.App)
                try, delete(testCase.App); catch, end
            end
            localCloseAllModels();
        end
    end

    % ---- Test method ----

    methods (Test)
        function fidelityCombination(testCase, Setup)
        %FIDELITYCOMBINATION Generate scripts, verify output, compile-check.

            fprintf('\n>> [%s] %s\n', Setup.Template, Setup.FolderName);

            % ---- Reopen app for each new template (clean state) ----
            if ~strcmp(Setup.Template, testCase.CurrentTemplate)
                if ~isempty(testCase.App)
                    try, delete(testCase.App); catch, end
                end
                localCloseAllModels();

                testCase.App = BEVapp;
                drawnow; pause(3);

                localSetTemplateDropdown(testCase.App, Setup.Template);
                createComponentDropdowns(testCase.App, true);
                controlSelectionDropdown(testCase.App);
                drawnow;
                testCase.CurrentTemplate = Setup.Template;
            end

            % ---- Apply fidelity selections ----
            fidelities = containers.Map(Setup.CompTypes, Setup.Models);
            applyStruct = localBuildApplyStruct( ...
                testCase.RawCfg.(Setup.Template), fidelities, Setup.Controller);
            applySelections(testCase.App, applyStruct);
            drawnow;

            % ---- Generate scripts (same path as Model Setup button) ----
            state = buildSetupState(testCase.App);

            outFileModel = exportSetupScript(testCase.App, state);
            testCase.assertNotEmpty(outFileModel, ...
                'exportSetupScript returned empty — model or vehicle block not found');

            [outputFolder, ssrBaseName, ssrExt] = fileparts(outFileModel);
            modelName    = state.BEVModel;
            outFileParam = fullfile(outputFolder, [modelName '_params_setup.m']);
            exportParamScript(testCase.App, outFileParam, state);
            exportBuildReadme(state, outputFolder, {outFileModel, outFileParam});

            % ---- Rename timestamped folder to named folder ----
            namedFolder = fullfile(testCase.SetupRoot, Setup.FolderName);
            if isfolder(namedFolder), rmdir(namedFolder, 's'); end
            movefile(outputFolder, namedFolder);

            % ---- Verify output files ----
            ssrScript   = fullfile(namedFolder, strcat(ssrBaseName, ssrExt));
            paramScript = fullfile(namedFolder, [modelName '_params_setup.m']);
            readmePath  = fullfile(namedFolder, 'README.md');

            testCase.verifyTrue(isfile(ssrScript),   'SSR setup script missing');
            testCase.verifyTrue(isfile(paramScript),  'Param setup script missing');
            testCase.verifyTrue(isfile(readmePath),   'README missing');

            % ---- Clear workspace — only this combo's params should be loaded ----
            evalin('base', 'clear');

            % ---- Apply configuration to model ----
            run(ssrScript);
            evalin('base', sprintf('run(''%s'')', ...
                strrep(paramScript, '''', '''''')));

            % ---- Compile check (diagram update) ----
            set_param(modelName, 'SimulationCommand', 'update');

            % ---- Simulate for 100 seconds ----
            origStop = get_param(modelName, 'StopTime');
            set_param(modelName, 'StopTime', '100');
            simout = sim(modelName, 'SrcWorkspace', 'base');
            set_param(modelName, 'StopTime', origStop);

            testCase.verifyNotEmpty(simout, ...
                sprintf('Simulation returned empty for %s.', Setup.FolderName));
            fprintf('   Simulation passed: %s\n', Setup.FolderName);
        end
    end
end

%% ========================= Local functions =========================

function params = localBuildParams()
%LOCALBUILDPARAMS Generate one test parameter per unique template x fidelity combo.
%   Scans ALL JSON files in APP/Config/Preset/ and deduplicates so
%   overlapping configs (e.g. same template in two JSONs) are tested once.
    root = char(matlab.project.rootProject().RootFolder);

    presetDir = fullfile(root, 'APP', 'Config', 'Preset');
    jsonFiles = dir(fullfile(presetDir, '*.json'));

    params = struct();
    seen   = containers.Map();  % fingerprint → true

    for f = 1:numel(jsonFiles)
        rawCfg    = jsondecode(fileread(fullfile(jsonFiles(f).folder, jsonFiles(f).name)));
        templates = fieldnames(rawCfg);

        for t = 1:numel(templates)
            tmpl   = templates{t};
            config = rawCfg.(tmpl);
            comps  = fieldnames(config.Components);

            % Collect default fidelities (first model per component)
            defaultTypes  = cell(1, numel(comps));
            defaultModels = cell(1, numel(comps));
            for c = 1:numel(comps)
                defaultTypes{c}  = comps{c};
                defaultModels{c} = config.Components.(comps{c}).Models{1};
            end

            controller = config.Controls.Models{1};

            % Entry: all defaults
            addCombo(tmpl, [tmpl '_default'], defaultTypes, defaultModels, controller);

            % Entries: vary one component at a time
            counter = 0;
            for c = 1:numel(comps)
                models = config.Components.(comps{c}).Models;
                for m = 1:numel(models)
                    if strcmp(models{m}, defaultModels{c}), continue; end
                    counter = counter + 1;

                    variedModels    = defaultModels;
                    variedModels{c} = models{m};

                    folderName = sprintf('%s_%02d_%s_%s', ...
                        tmpl, counter, comps{c}, models{m});
                    addCombo(tmpl, folderName, defaultTypes, variedModels, controller);
                end
            end
        end
    end

    function addCombo(tmpl, folderName, compTypes, models, ctrl)
    %ADDCOMBO Add combo to params if not already seen (deduplicate).
        fingerprint = strjoin([{tmpl, ctrl}, sort(models)], '|');
        if isKey(seen, fingerprint), return; end
        seen(fingerprint) = true;

        key = matlab.lang.makeValidName(folderName);
        params.(key) = struct( ...
            'Template',   tmpl, ...
            'FolderName', folderName, ...
            'CompTypes',  {compTypes}, ...
            'Models',     {models}, ...
            'Controller', ctrl);
    end
end

function localSetTemplateDropdown(app, templateKey)
%LOCALSETTEMPLATEDROPDOWN Set the vehicle template dropdown value.
    dropdown = app.VehicleTemplateDropDown;
    items    = string(dropdown.Items);
    bases    = erase(items, '.slx');
    idx      = find(strcmpi(bases, templateKey), 1);
    if ~isempty(idx)
        dropdown.Value = dropdown.Items{idx};
    else
        dropdown.Items = [dropdown.Items, {templateKey}];
        dropdown.Value = templateKey;
    end
end

function applyStruct = localBuildApplyStruct(config, fidelities, controller)
%LOCALBUILDAPPLYSTRUCT Build the struct that applySelections expects.
    applyStruct = struct();
    applyStruct.Controls.Model = controller;

    comps = fieldnames(config.Components);
    applyStruct.Components = struct();

    for c = 1:numel(comps)
        comp      = comps{c};
        instances = config.Components.(comp).Instances;
        if ~iscell(instances), instances = {instances}; end
        model = fidelities(comp);

        selections = struct();
        for i = 1:numel(instances)
            instKey = matlab.lang.makeValidName(instances{i});
            selections.(instKey) = struct('Model', model);
        end
        applyStruct.Components.(comp).Selections = selections;
    end
end

function localCloseAllModels()
%LOCALCLOSEALLMODELS Close any open Simulink models.
    try
        openModels = get_param(Simulink.allBlockDiagrams('model'), 'Name');
        if ~iscell(openModels), openModels = {openModels}; end
        for m = 1:numel(openModels)
            try, close_system(openModels{m}, 0); catch, end
        end
    catch
    end
end

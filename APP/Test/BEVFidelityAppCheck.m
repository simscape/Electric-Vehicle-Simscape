%BEVFIDELITYAPPCHECK Validate all JSON preset fidelity variants.
%   Opens the BEV app and programmatically drives its UI to generate
%   setup output for each template x fidelity combination.
%
%   For each template, creates a default setup (first fidelity everywhere)
%   plus one variation per alternate fidelity. Each gets a named folder
%   under Script_Data/Setup/User/ with SSR setup script + param script +
%   README — identical to pressing Model Setup in the app.
%
%   Folder naming:
%     <Template>_default/
%     <Template>_01_<Component>_<Fidelity>/
%
%   Usage:
%     BEVFidelityAppCheck            % all templates
%     BEVFidelityAppCheck('VehicleElecAux')  % one template
%
%   Copyright 2026 The MathWorks, Inc.

function results = BEVFidelityAppCheck(templateFilter)

    if nargin < 1, templateFilter = ''; end

    % ---- Resolve paths ----
    root = char(matlab.project.rootProject().RootFolder);

    configFile = fullfile(root, 'APP', 'Config', 'Preset', 'VehicleTemplateConfig.json');
    rawCfg     = jsondecode(fileread(configFile));
    templates  = fieldnames(rawCfg);
    setupRoot  = fullfile(root, 'Script_Data', 'Setup', 'User');

    if ~isfolder(setupRoot), mkdir(setupRoot); end

    % ---- Filter to one template if requested ----
    if ~isempty(templateFilter)
        idx = strcmpi(templates, templateFilter);
        if ~any(idx)
            error('Template "%s" not found in config. Available: %s', ...
                templateFilter, strjoin(templates, ', '));
        end
        templates = templates(idx);
    end

    % ---- Build the plan ----
    plan = buildPlan(rawCfg, templates);
    fprintf('\n=== BEV Preset Fidelity Check — Script Generation ===\n');
    fprintf('Templates: %d | Combinations: %d\n\n', numel(templates), numel(plan));

    % ---- Clear saved user configs so no stale setups leak in ----
    userConfigDir = fullfile(root, 'APP', 'Config', 'User');
    if isfolder(userConfigDir)
        staleConfigs = dir(fullfile(userConfigDir, '*.json'));
        for j = 1:numel(staleConfigs)
            delete(fullfile(staleConfigs(j).folder, staleConfigs(j).name));
        end
        if ~isempty(staleConfigs)
            fprintf('Cleared %d saved user config(s) from APP/Config/User/\n', numel(staleConfigs));
        end
    end

    % ---- Generate scripts for each combo ----
    results = repmat(struct('Template','','Name','','Status','','Error',''), numel(plan), 1);
    lastTemplate = '';
    app = [];

    for k = 1:numel(plan)
        currentCombo = plan(k);
        results(k).Template = currentCombo.Template;
        results(k).Name     = currentCombo.FolderName;

        fprintf('[%2d/%2d] %s ... ', k, numel(plan), currentCombo.FolderName);

        try
            % Reopen app for each new template (clean state per template)
            if ~strcmp(currentCombo.Template, lastTemplate)
                if ~isempty(app), delete(app); end
                fprintf('opening app ... ');
                app = BEVapp;
                drawnow; pause(3);

                setTemplateDropdown(app, currentCombo.Template);
                createComponentDropdowns(app, true);
                controlSelectionDropdown(app);
                drawnow;
                lastTemplate = currentCombo.Template;
            end

            % Apply fidelity selections to component and controller dropdowns
            applyStruct = buildApplyStruct(rawCfg.(currentCombo.Template), ...
                currentCombo.Fidelities, currentCombo.Controller);
            applySelections(app, applyStruct);
            drawnow;

            % Build state and export (same path as CreateModelButton)
            state = buildSetupState(app);

            outFileModel = exportSetupScript(app, state);
            if isempty(outFileModel)
                error('exportSetupScript returned empty — model or vehicle block not found');
            end

            [outputFolder, ~, ~] = fileparts(outFileModel);
            modelName = state.BEVModel;
            outFileParam = fullfile(outputFolder, [modelName '_params_setup.m']);
            exportParamScript(app, outFileParam, state);
            exportBuildReadme(state, outputFolder, {outFileModel, outFileParam});

            % Rename timestamped folder to named folder
            namedFolder = fullfile(setupRoot, currentCombo.FolderName);
            if isfolder(namedFolder), rmdir(namedFolder, 's'); end
            movefile(outputFolder, namedFolder);

            fprintf('generated ... ');

            % Clear base workspace so only this combo's params are tested
            evalin('base', 'clear');

            % Run scripts to apply configuration to the model
            ssrScript   = fullfile(namedFolder, [modelName '_ssr_setup.m']);
            paramScript = fullfile(namedFolder, [modelName '_params_setup.m']);

            run(ssrScript);
            evalin('base', sprintf('run(''%s'')', strrep(paramScript, '''', '''''')));

            % Update diagram (compile check)
            set_param(modelName, 'SimulationCommand', 'update');

            results(k).Status = 'PASS';
            fprintf('COMPILE OK\n');
        catch setupError
            % Mark as COMPILE_FAIL if scripts were generated but compile failed
            if isfolder(fullfile(setupRoot, currentCombo.FolderName))
                results(k).Status = 'COMPILE_FAIL';
            else
                results(k).Status = 'ERROR';
            end
            results(k).Error  = ME.message;
            fprintf('FAIL — %s\n', ME.message);
        end
    end

    % ---- Print summary ----
    printSummary(results);
    saveSummary(results, setupRoot);

    % ---- Close app ----
    try, delete(app); catch, end

    fprintf('\nDone.\n');
end

%% ========================= Plan Builder =========================

function plan = buildPlan(rawCfg, templates)
%BUILDPLAN Generate the one-at-a-time variation plan across all templates.
    plan = struct('Template',{},'FolderName',{},'Fidelities',{},'Controller',{});

    for t = 1:numel(templates)
        tmpl   = templates{t};
        config = rawCfg.(tmpl);
        comps  = fieldnames(config.Components);

        defaults = containers.Map();
        for c = 1:numel(comps)
            models = config.Components.(comps{c}).Models;
            defaults(comps{c}) = models{1};
        end

        controller = config.Controls.Models{1};

        % Entry 1: all defaults
        entry.Template   = tmpl;
        entry.FolderName = [tmpl '_default'];
        entry.Fidelities = containers.Map(defaults.keys, defaults.values);
        entry.Controller = controller;
        plan(end+1) = entry; %#ok<AGROW>

        % Entries 2..N: vary one component at a time
        counter = 0;
        for c = 1:numel(comps)
            models = config.Components.(comps{c}).Models;
            for m = 1:numel(models)
                if strcmp(models{m}, defaults(comps{c}))
                    continue;
                end
                counter = counter + 1;

                varied = containers.Map(defaults.keys, defaults.values);
                varied(comps{c}) = models{m};

                entry.Template   = tmpl;
                entry.FolderName = sprintf('%s_%02d_%s_%s', tmpl, counter, comps{c}, models{m});
                entry.Fidelities = varied;
                entry.Controller = controller;
                plan(end+1) = entry; %#ok<AGROW>
            end
        end
    end
end

%% ========================= UI Helpers =========================

function setTemplateDropdown(app, templateKey)
%SETTEMPLATEDROPDOWN Set the vehicle template dropdown to the given template key.
    dropdown = app.VehicleTemplateDropDown;
    items    = string(dropdown.Items);
    bases    = erase(items, '.slx');

    idx = find(strcmpi(bases, templateKey), 1);
    if ~isempty(idx)
        dropdown.Value = dropdown.Items{idx};
    else
        % Template not in dropdown yet — add it
        dropdown.Items = [dropdown.Items, {templateKey}];
        dropdown.Value = templateKey;
    end
end

function tmpl = buildApplyStruct(config, fidelities, controller)
%BUILDAPPLYSTRUCT Build the struct that applySelections expects.
%   Maps the plan's component-type→model fidelity to the per-instance
%   Selections format used by applySelections.
    tmpl = struct();
    tmpl.Controls.Model = controller;

    comps = fieldnames(config.Components);
    tmpl.Components = struct();

    for c = 1:numel(comps)
        comp      = comps{c};
        instances = config.Components.(comp).Instances;
        if ~iscell(instances), instances = {instances}; end

        model = fidelities(comp);  % from containers.Map

        selections = struct();
        for i = 1:numel(instances)
            instKey = matlab.lang.makeValidName(instances{i});
            selections.(instKey) = struct('Model', model);
        end

        tmpl.Components.(comp).Selections = selections;
    end
end

%% ========================= Summary =========================

function printSummary(results)
    fprintf('\n=== Summary ===\n');
    fprintf('%-55s  %s\n', 'Setup', 'Status');
    fprintf('%-55s  %s\n', repmat('-',1,55), '---------');

    for k = 1:numel(results)
        fprintf('%-55s  %s\n', results(k).Name, results(k).Status);
    end

    passCount    = sum(strcmp({results.Status}, 'PASS'));
    compFailCount = sum(strcmp({results.Status}, 'COMPILE_FAIL'));
    errCount     = sum(strcmp({results.Status}, 'ERROR'));
    fprintf('\nTotal: %d | Pass: %d | Compile Fail: %d | Error: %d\n', ...
        numel(results), passCount, compFailCount, errCount);

    failIdx = ~strcmp({results.Status}, 'PASS');
    if any(failIdx)
        fprintf('\n--- Failures ---\n');
        for k = 1:numel(results)
            if failIdx(k)
                fprintf('  [%s] %s\n    %s\n', results(k).Status, results(k).Name, results(k).Error);
            end
        end
    end
end

function saveSummary(results, setupRoot)
    summaryFile = fullfile(setupRoot, 'fidelity_check_summary.txt');
    fid = fopen(summaryFile, 'w');
    if fid < 0, return; end
    cleanup = onCleanup(@() fclose(fid));

    fprintf(fid, 'BEV Preset Fidelity Check — %s\n\n', datestr(now));

    passCount    = sum(strcmp({results.Status}, 'PASS'));
    compFailCount = sum(strcmp({results.Status}, 'COMPILE_FAIL'));
    errCount     = sum(strcmp({results.Status}, 'ERROR'));
    fprintf(fid, 'Total: %d | Pass: %d | Compile Fail: %d | Error: %d\n\n', ...
        numel(results), passCount, compFailCount, errCount);

    fprintf(fid, '%-55s  %-10s  %s\n', 'Setup', 'Status', 'Error');
    fprintf(fid, '%-55s  %-10s  %s\n', repmat('-',1,55), '----------', repmat('-',1,40));
    for k = 1:numel(results)
        fprintf(fid, '%-55s  %-10s  %s\n', results(k).Name, results(k).Status, results(k).Error);
    end
end

function bevCleanConfig(configFile, options)
% BEVCLEANCONFIG Remove stale fidelities from a config file.
%   bevCleanConfig(configFile)
%   bevCleanConfig(configFile, Name=Value)
%
%   Scans a config JSON and checks each model in every Models list against
%   the Components/*/Model/ folders on disk. Models that no longer exist
%   are removed. Selections referencing removed models are cleaned up.
%
%   Inputs:
%     configFile — JSON filename (bare name resolves to APP/Config/Preset/)
%
%   Name-Value Arguments:
%     DryRun      — if true, print what would be removed but do not write (default: true)
%     ProjectRoot — project root (default: auto-detect via MATLAB project)
%
%   Examples:
%     % Preview stale entries
%     bevCleanConfig("VehicleTemplateConfig.json")
%
%     % Remove stale entries and write
%     bevCleanConfig("VehicleTemplateConfig.json", DryRun = false)
%
% Copyright 2026 The MathWorks, Inc.

    arguments
        configFile              (1,1) string
        options.DryRun          (1,1) logical = true
        options.ProjectRoot     (1,1) string  = ""
    end

    % ---- Resolve project root ----
    if options.ProjectRoot ~= ""
        projectRoot = options.ProjectRoot;
    else
        projectRoot = string(getBEVProjectRoot());
    end

    % ---- Read config ----
    [cfg, configFilePath] = bevConfigRead(configFile, projectRoot);

    if isempty(fieldnames(cfg))
        fprintf('\n  Config file not found or empty: %s\n\n', configFile);
        return;
    end

    % ---- Build lookup of models on disk ----
    componentLookup = buildComponentModelLookup(projectRoot);

    % ---- Scan each template ----
    templateNames = fieldnames(cfg);
    totalRemoved = 0;

    for tIdx = 1:numel(templateNames)
        tmplName = templateNames{tIdx};
        tmplData = cfg.(tmplName);

        if ~isstruct(tmplData) || ~isfield(tmplData, 'Components')
            continue;
        end

        fprintf('\n  Template: %s\n', tmplName);
        [cleanedComponents, removedCount] = cleanComponents( ...
            tmplData.Components, componentLookup);

        % ---- Clean Controls section ----
        controlsRemoved = 0;
        if isfield(tmplData, 'Controls')
            [cleanedControls, controlsRemoved] = cleanControlsSection( ...
                tmplData.Controls, componentLookup);
            if isempty(fieldnames(cleanedControls))
                tmplData = rmfield(tmplData, 'Controls');
            else
                tmplData.Controls = cleanedControls;
            end
        end

        templateRemovedCount = removedCount + controlsRemoved;
        totalRemoved = totalRemoved + templateRemovedCount;

        if templateRemovedCount == 0
            fprintf('    (no stale entries)\n');
        end

        tmplData.Components = cleanedComponents;
        cfg.(tmplName) = tmplData;
    end

    % ---- Summary ----
    if totalRemoved == 0
        fprintf('\n  Config is clean. No stale models found.\n\n');
        return;
    end

    fprintf('\n  ============================================\n');
    fprintf('  Cleanup Summary\n');
    fprintf('  ============================================\n');
    fprintf('  Config:  %s\n', configFilePath);
    fprintf('  Removed: %d stale model(s)\n', totalRemoved);
    printCleanedState(cfg);

    % ---- Write or skip ----
    if ~options.DryRun
        validateVehicleConfig(cfg);
        bevConfigWrite(cfg, configFilePath);
        fprintf('\n  Written: %s\n\n', configFilePath);
    else
        fprintf('\n  DryRun = true. No file written.\n\n');
    end
end


%% ========================================================================
%  Local helpers
%  ========================================================================

function [cleanedComponents, removedCount] = cleanComponents(components, componentLookup)
% CLEANCOMPONENTS Remove stale models from each component in the Components section.

    cleanedComponents = components;
    removedCount = 0;
    compNames = fieldnames(components);

    for cIdx = 1:numel(compNames)
        compName = compNames{cIdx};
        comp = components.(compName);

        if ~isfield(comp, 'Models')
            continue;
        end

        modelList = ensureCell(comp.Models);
        staleModels = {};

        % ---- Check each model against disk ----
        for mIdx = 1:numel(modelList)
            modelKey = lower(modelList{mIdx});
            if ~isKey(componentLookup, modelKey)
                staleModels{end+1} = modelList{mIdx}; %#ok<AGROW>
            end
        end

        if isempty(staleModels)
            continue;
        end

        % ---- Remove stale models ----
        survivingModels = setdiff(modelList, staleModels, 'stable');

        for sIdx = 1:numel(staleModels)
            fprintf('    - %s.%s  (not found on disk)\n', compName, staleModels{sIdx});
        end

        removedCount = removedCount + numel(staleModels);

        if isempty(survivingModels)
            fprintf('    * %s removed entirely (no models left)\n', compName);
            cleanedComponents = rmfield(cleanedComponents, compName);
        else
            comp.Models = survivingModels;

            % ---- Clean Selections referencing removed models ----
            if isfield(comp, 'Selections')
                comp.Selections = cleanSelectionsForModels( ...
                    comp.Selections, staleModels, compName);
            end

            cleanedComponents.(compName) = comp;
        end
    end
end


function [cleanedControls, removedCount] = cleanControlsSection(controls, componentLookup)
% CLEANCONTROLSSECTION Remove stale models from the Controls section.

    cleanedControls = controls;
    removedCount = 0;

    if ~isfield(controls, 'Models')
        return;
    end

    modelList = ensureCell(controls.Models);
    staleModels = {};

    for mIdx = 1:numel(modelList)
        modelKey = lower(modelList{mIdx});
        if ~isKey(componentLookup, modelKey)
            staleModels{end+1} = modelList{mIdx}; %#ok<AGROW>
        end
    end

    if isempty(staleModels)
        return;
    end

    survivingModels = setdiff(modelList, staleModels, 'stable');

    for sIdx = 1:numel(staleModels)
        fprintf('    - Controls.%s  (not found on disk)\n', staleModels{sIdx});
    end

    removedCount = numel(staleModels);

    if isempty(survivingModels)
        fprintf('    * Controls removed entirely (no models left)\n');
        cleanedControls = struct();
    else
        cleanedControls.Models = survivingModels;
    end
end


function selections = cleanSelectionsForModels(selections, removedModels, compName)
% CLEANSELECTIONSFORMODELS Remove Selection entries whose Model was removed.

    selKeys = fieldnames(selections);
    for sIdx = 1:numel(selKeys)
        sel = selections.(selKeys{sIdx});
        if isfield(sel, 'Model') && ismember(sel.Model, removedModels)
            fprintf('      Selections.%s cleaned (model %s removed)\n', ...
                selKeys{sIdx}, sel.Model);
            selections = rmfield(selections, selKeys{sIdx});
        end
    end
end


function printCleanedState(cfg)
% PRINTCLEANEDSTATE Print the remaining models per component after cleanup.

    templateNames = fieldnames(cfg);

    for tIdx = 1:numel(templateNames)
        tmplName = templateNames{tIdx};
        tmplData = cfg.(tmplName);

        if ~isstruct(tmplData) || ~isfield(tmplData, 'Components')
            continue;
        end

        fprintf('\n  %s:\n', tmplName);
        compNames = fieldnames(tmplData.Components);

        for cIdx = 1:numel(compNames)
            comp = tmplData.Components.(compNames{cIdx});
            modelList = ensureCell(comp.Models);
            fprintf('    %-20s [%s]\n', compNames{cIdx}, strjoin(modelList, ', '));
        end

        if isfield(tmplData, 'Controls')
            controlModels = ensureCell(tmplData.Controls.Models);
            fprintf('    %-20s [%s]\n', 'Controls', strjoin(controlModels, ', '));
        end
    end
end


function cellArr = ensureCell(value)
% ENSURECELL Convert char or string to cell array if needed.

    if ischar(value)
        cellArr = {value};
    elseif isstring(value)
        cellArr = cellstr(value);
    else
        cellArr = value;
    end
end

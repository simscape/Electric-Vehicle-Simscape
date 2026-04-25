function bevUpdateTemplate(templatePath, options)
% BEVUPDATETEMPLATE Rescan a template and sync all configs that reference it.
%   bevUpdateTemplate(templatePath)
%   bevUpdateTemplate(templatePath, Name=Value)
%
%   Rescans the template .slx for subsystem reference blocks, finds all
%   config files in APP/Config/Preset/ that contain this template, and
%   updates each to match the current template structure.
%
%   Components, instances, and SSR-linked models are synced:
%     - Unchanged components: preserved (fidelities, Selections kept)
%     - Modified instances: updated from template
%     - New components: added with SSR model only
%     - Removed components: deleted from config
%
%   User-added fidelities and Selections are never removed.
%
%   Inputs:
%     templatePath — path to the vehicle template .slx file
%
%   Name-Value Arguments:
%     DryRun      — if true, print diff but do not write (default: true)
%     ProjectRoot — project root (default: auto-detect via MATLAB project)
%
%   Examples:
%     % Preview changes after adding a HeatPump to the template
%     bevUpdateTemplate("Model/VehicleTemplate/VehicleElectric.slx")
%
%     % Apply changes to all configs
%     bevUpdateTemplate("Model/VehicleTemplate/VehicleElectric.slx", ...
%         DryRun = false)
%
% Copyright 2026 The MathWorks, Inc.

    arguments
        templatePath              (1,1) string
        options.DryRun            (1,1) logical = true
        options.ProjectRoot       (1,1) string  = ""
        options.ScanOverride      (1,1) struct  = struct()
    end

    % ---- Resolve project root ----
    if options.ProjectRoot ~= ""
        projectRoot = options.ProjectRoot;
    else
        projectRoot = string(getBEVProjectRoot());
    end

    % ---- Derive template name ----
    [~, modelBasename] = fileparts(templatePath);
    templateName = string(modelBasename);
    templateKey = char(templateName);

    % ---- Get fresh scan ----
    if ~isempty(fieldnames(options.ScanOverride))
        freshEntry = options.ScanOverride;
    else
        scanFcn = @() bevRegisterTemplate(templatePath, ProjectRoot=projectRoot);
        [~, freshEntry] = evalc('scanFcn()');
    end

    if isempty(fieldnames(freshEntry))
        fprintf('\n  No components found in template. Nothing to update.\n\n');
        return;
    end

    % ---- Find config files containing this template ----
    presetDir = fullfile(projectRoot, 'APP', 'Config', 'Preset');
    configFiles = findConfigsWithTemplate(templateKey, presetDir);

    if isempty(configFiles)
        fprintf('\n  Template "%s" not found in any config file.\n', templateKey);
        fprintf('  Use bevRegisterTemplate to register it first.\n\n');
        return;
    end

    fprintf('\n  Template "%s" found in %d config(s):\n', ...
        templateKey, numel(configFiles));
    for idx = 1:numel(configFiles)
        fprintf('    - %s\n', configFiles{idx});
    end

    % ---- Process each config ----
    for idx = 1:numel(configFiles)
        configPath = fullfile(presetDir, configFiles{idx});
        [cfg, ~] = bevConfigRead(configPath, projectRoot);

        fprintf('\n  ============================================\n');
        fprintf('  %s\n', configFiles{idx});
        fprintf('  ============================================\n');

        oldEntry = cfg.(templateKey);
        updatedEntry = syncEntry(oldEntry, freshEntry);
        hasChanges = ~isequal(updatedEntry, oldEntry);

        if ~hasChanges
            fprintf('    (no changes)\n');
            continue;
        end

        % ---- Validate before writing ----
        cfg.(templateKey) = updatedEntry;
        validateVehicleConfig(cfg, templateKey);

        if ~options.DryRun
            bevConfigWrite(cfg, configPath);
            fprintf('\n  Written: %s\n', configPath);
        else
            fprintf('\n  DryRun = true. No file written.\n');
        end
    end

    fprintf('\n');
end


%% ========================================================================
%  Local helpers
%  ========================================================================

function updatedEntry = syncEntry(oldEntry, freshEntry)
% SYNCENTRY Diff and merge an existing config entry with a fresh scan.
%   Preserves user-added fidelities and Selections.

    updatedEntry = oldEntry;

    % ---- Sync Components ----
    if isfield(freshEntry, 'Components')
        updatedEntry.Components = syncSection( ...
            getFieldOrEmpty(oldEntry, 'Components'), ...
            freshEntry.Components);
    elseif isfield(updatedEntry, 'Components')
        fprintf('    - Components section removed (no components in template)\n');
        updatedEntry = rmfield(updatedEntry, 'Components');
    end

    % ---- Sync Controls ----
    if isfield(freshEntry, 'Controls')
        updatedEntry.Controls = syncControls( ...
            getFieldOrEmpty(oldEntry, 'Controls'), ...
            freshEntry.Controls);
    elseif isfield(updatedEntry, 'Controls')
        fprintf('    - Controls section removed (no controllers in template)\n');
        updatedEntry = rmfield(updatedEntry, 'Controls');
    end
end


function mergedSection = syncSection(oldSection, freshSection)
% SYNCSECTION Sync a Components section: add, remove, update component types.

    if isempty(fieldnames(oldSection))
        mergedSection = freshSection;
        freshNames = fieldnames(freshSection);
        for idx = 1:numel(freshNames)
            comp = freshSection.(freshNames{idx});
            fprintf('    + %s  [%s]\n', freshNames{idx}, ...
                strjoin(ensureCell(comp.Instances), ', '));
        end
        return;
    end

    mergedSection = oldSection;

    oldNames   = fieldnames(oldSection);
    freshNames = fieldnames(freshSection);
    added      = setdiff(freshNames, oldNames);
    removed    = setdiff(oldNames, freshNames);
    common     = intersect(oldNames, freshNames);

    % ---- Removed components ----
    for idx = 1:numel(removed)
        fprintf('    - %s  (removed from template)\n', removed{idx});
        mergedSection = rmfield(mergedSection, removed{idx});
    end

    % ---- Added components ----
    for idx = 1:numel(added)
        compName = added{idx};
        freshComp = freshSection.(compName);
        mergedSection.(compName) = freshComp;
        fprintf('    + %s  [%s]  (%s)\n', compName, ...
            strjoin(ensureCell(freshComp.Instances), ', '), ...
            strjoin(ensureCell(freshComp.Models), ', '));
    end

    % ---- Common components — sync instances and ensure SSR models ----
    for idx = 1:numel(common)
        compName = common{idx};
        mergedSection.(compName) = syncComponent( ...
            oldSection.(compName), freshSection.(compName), compName);
    end
end


function mergedComp = syncComponent(oldComp, freshComp, compName)
% SYNCCOMPONENT Sync instances and models for a single component type.
%   Instances: take from template (source of truth).
%   Models: ensure SSR models present, preserve user-added fidelities.
%   Selections: remove entries for deleted instances, preserve the rest.

    mergedComp = oldComp;

    oldInstances   = ensureCell(oldComp.Instances);
    freshInstances = ensureCell(freshComp.Instances);

    % ---- Update instances if changed ----
    if ~isequal(sort(oldInstances), sort(freshInstances))
        fprintf('    ~ %s  instances: [%s] -> [%s]\n', compName, ...
            strjoin(oldInstances, ', '), strjoin(freshInstances, ', '));
        mergedComp.Instances = freshInstances;

        % ---- Clean Selections for removed instances ----
        if isfield(mergedComp, 'Selections')
            mergedComp.Selections = cleanSelections( ...
                mergedComp.Selections, freshInstances);
        end
    end

    % ---- Ensure SSR models are in the list ----
    oldModels  = ensureCell(oldComp.Models);
    ssrModels  = ensureCell(freshComp.Models);
    modelsAdded = {};

    for mIdx = 1:numel(ssrModels)
        if ~ismember(ssrModels{mIdx}, oldModels)
            oldModels{end+1} = ssrModels{mIdx}; %#ok<AGROW>
            modelsAdded{end+1} = ssrModels{mIdx}; %#ok<AGROW>
        end
    end

    if ~isempty(modelsAdded)
        fprintf('    ~ %s  models added: [%s]\n', compName, ...
            strjoin(modelsAdded, ', '));
    end

    mergedComp.Models = oldModels;
end


function mergedControls = syncControls(oldControls, freshControls)
% SYNCCONTROLS Sync the Controls section (flat Instances + Models).

    if isempty(fieldnames(oldControls))
        mergedControls = freshControls;
        fprintf('    + Controls  [%s]\n', ...
            strjoin(ensureCell(freshControls.Instances), ', '));
        return;
    end

    mergedControls = oldControls;

    % ---- Update instances from template ----
    oldInstances   = ensureCell(oldControls.Instances);
    freshInstances = ensureCell(freshControls.Instances);

    if ~isequal(sort(oldInstances), sort(freshInstances))
        fprintf('    ~ Controls  instances: [%s] -> [%s]\n', ...
            strjoin(oldInstances, ', '), strjoin(freshInstances, ', '));
        mergedControls.Instances = freshInstances;
    end

    % ---- Ensure SSR models present ----
    oldModels   = ensureCell(oldControls.Models);
    ssrModels   = ensureCell(freshControls.Models);
    modelsAdded = {};

    for mIdx = 1:numel(ssrModels)
        if ~ismember(ssrModels{mIdx}, oldModels)
            oldModels{end+1} = ssrModels{mIdx}; %#ok<AGROW>
            modelsAdded{end+1} = ssrModels{mIdx}; %#ok<AGROW>
        end
    end

    if ~isempty(modelsAdded)
        fprintf('    ~ Controls  models added: [%s]\n', ...
            strjoin(modelsAdded, ', '));
    end

    mergedControls.Models = oldModels;
end


function selections = cleanSelections(selections, validInstances)
% CLEANSELECTIONS Remove Selection entries whose instance is no longer in the template.

    selKeys = fieldnames(selections);
    for idx = 1:numel(selKeys)
        sel = selections.(selKeys{idx});
        if isfield(sel, 'Label') && ~ismember(sel.Label, validInstances)
            fprintf('      Selections: removed "%s" (instance no longer in template)\n', ...
                sel.Label);
            selections = rmfield(selections, selKeys{idx});
        end
    end
end


function configFiles = findConfigsWithTemplate(templateKey, presetDir)
% FINDCONFIGSWITHTEMPLATE Find all JSON config files containing a template key.

    configFiles = {};

    if ~isfolder(presetDir)
        return;
    end

    jsonFiles = dir(fullfile(presetDir, '*.json'));
    for idx = 1:numel(jsonFiles)
        jsonPath = fullfile(presetDir, jsonFiles(idx).name);
        try
            rawCfg = jsondecode(fileread(jsonPath));
            if isfield(rawCfg, templateKey)
                configFiles{end+1} = jsonFiles(idx).name; %#ok<AGROW>
            end
        catch
            % ---- Skip malformed JSON ----
        end
    end
end


function fieldValue = getFieldOrEmpty(parent, fieldName)
% GETFIELDOREMPTY Return field value or empty struct if field does not exist.

    if isfield(parent, fieldName)
        fieldValue = parent.(fieldName);
    else
        fieldValue = struct();
    end
end


function cellArr = ensureCell(value)
% ENSURECELL Convert char to cell array if needed.

    if ischar(value)
        cellArr = {value};
    else
        cellArr = value;
    end
end

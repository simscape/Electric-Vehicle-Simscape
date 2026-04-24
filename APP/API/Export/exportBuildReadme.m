function readmePath = exportBuildReadme(state, outFolder, generatedFiles)
% EXPORTBUILDREADME Write a README.md build snapshot summarizing the export.
%   readmePath = exportBuildReadme(state, outFolder, generatedFiles)
%
%   Inputs:
%     state          - flat setupState struct from buildSetupState()
%     outFolder      - char, absolute path to the timestamped output folder
%     generatedFiles - cell array of char, absolute paths to files already
%                      written to outFolder (SSR script, param script)
%
%   Output:
%     readmePath     - char, full path to the written README.md
%
% Copyright 2026 The MathWorks, Inc.

    readmePath = fullfile(outFolder, 'README.md');

    try
        lines = {};
        lines{end+1} = '# Build Snapshot';
        lines{end+1} = '';

        lines = [lines, buildOverviewSection(state, outFolder)];
        lines = [lines, buildTemplateSection(state)];
        lines = [lines, buildModelConfigSection(state)];
        lines = [lines, buildParamFilesSection(state)];
        lines = [lines, buildEnvironmentSection(state)];
        lines = [lines, buildGeneratedFilesSection(state.Root, outFolder, generatedFiles, readmePath)];

        % Write file
        fid = fopen(readmePath, 'w', 'n', 'UTF-8');
        if fid < 0
            warning('BEVapp:exportBuildReadme', ...
                'Cannot create README.md in %s', outFolder);
            readmePath = '';
            return;
        end
        cleanup = onCleanup(@() fclose(fid));
        for k = 1:numel(lines)
            fprintf(fid, '%s\n', char(lines{k}));
        end

    catch ME
        warning('BEVapp:exportBuildReadme', ...
            'README.md write failed: %s', ME.message);
        readmePath = '';
    end
end

%% ========================= Section builders =========================

function lines = buildOverviewSection(state, outFolder)
% BUILDOVERVIEWSECTION Build the Overview markdown table.
    lines = {};
    lines{end+1} = '## Build Overview';
    lines{end+1} = '';
    lines{end+1} = '| Field | Value |';
    lines{end+1} = '|-------|-------|';
    lines{end+1} = sprintf('| Timestamp | %s |', state.Timestamp);
    lines{end+1} = sprintf('| Model | %s |', state.BEVModel);
    lines{end+1} = sprintf('| Model Path | %s |', ...
        fwdSlash(fullfile('Model', [state.BEVModel '.slx'])));
    lines{end+1} = '';
end

function lines = buildTemplateSection(state)
% BUILDTEMPLATESECTION Build the Selected Template markdown table.
    lines = {};
    lines{end+1} = '## Selected Template';
    lines{end+1} = '';
    lines{end+1} = '| Field | Value |';
    lines{end+1} = '|-------|-------|';
    lines{end+1} = sprintf('| Template | %s |', state.TemplateName);
    lines{end+1} = sprintf('| Config Source | %s |', relPath(state.ConfigFile, state.Root));

    desc = readTemplateDescription(state);
    if ~isempty(desc)
        lines{end+1} = sprintf('| Description | %s |', desc);
    end
    lines{end+1} = '';
end

function lines = buildModelConfigSection(state)
% BUILDMODELCONFIGSECTION Build the Instance-to-Selection markdown table.
    lines = {};
    rows = {};

    % Component selections
    if isfield(state, 'Components')
        compTypes = fieldnames(state.Components);
        for c = 1:numel(compTypes)
            comp = state.Components.(compTypes{c});
            if ~isfield(comp, 'Selections') || ~isstruct(comp.Selections)
                continue;
            end
            instKeys = fieldnames(comp.Selections);
            for i = 1:numel(instKeys)
                inst = comp.Selections.(instKeys{i});
                label = instKeys{i};
                if isfield(inst, 'Label') && ~isempty(inst.Label)
                    label = char(inst.Label);
                end
                model = '';
                if isfield(inst, 'Model')
                    model = char(inst.Model);
                end
                if isempty(model) || startsWith(model, '__MISSING__')
                    continue;
                end
                rows{end+1} = sprintf('| %s | %s |', label, model); %#ok<AGROW>
            end
        end
    end

    % Controller
    if isfield(state, 'Controls') && state.Controls.Enabled && ~isempty(state.Controls.Model)
        rows{end+1} = sprintf('| Controller | %s |', state.Controls.Model);
    end

    % Drive Cycle
    if isfield(state, 'DriveCycle') && state.DriveCycle.Enabled && ~isempty(state.DriveCycle.Value)
        rows{end+1} = sprintf('| Drive Cycle | %s |', state.DriveCycle.Value);
    end

    if isempty(rows), return; end

    lines{end+1} = '## Model Configuration';
    lines{end+1} = '';
    lines{end+1} = '| Instance | Selection |';
    lines{end+1} = '|----------|-----------|';
    lines = [lines, rows];
    lines{end+1} = '';
end

function lines = buildParamFilesSection(state)
% BUILDPARAMFILESSECTION Build the Parameter Files markdown table with namespace and type.
    lines = {};
    rows = {};

    if isfield(state, 'Components')
        compTypes = fieldnames(state.Components);
        for c = 1:numel(compTypes)
            comp = state.Components.(compTypes{c});
            if ~isfield(comp, 'Selections') || ~isstruct(comp.Selections)
                continue;
            end
            instKeys = fieldnames(comp.Selections);
            for i = 1:numel(instKeys)
                inst = comp.Selections.(instKeys{i});

                paramFile = '';
                if isfield(inst, 'ParamFile')
                    paramFile = char(inst.ParamFile);
                end
                if isempty(paramFile) || exist(paramFile, 'file') ~= 2
                    continue;
                end

                label = instKeys{i};
                if isfield(inst, 'Label') && ~isempty(inst.Label)
                    label = char(inst.Label);
                end

                model = '';
                if isfield(inst, 'Model')
                    model = char(inst.Model);
                end

                [~, paramBase, ~] = fileparts(paramFile);
                ns = discoverNamespaceSafe(paramFile);
                selType = inferSelectionType(paramFile, model);

                rows{end+1} = sprintf('| %s | %s | %s | %s | %s |', ...
                    label, paramBase, ns, ...
                    relPath(paramFile, state.Root), selType); %#ok<AGROW>
            end
        end
    end

    if isempty(rows), return; end

    lines{end+1} = '## Loaded Parameter Files';
    lines{end+1} = '';
    lines{end+1} = '| Instance | Parameter File | Namespace | Path | Type |';
    lines{end+1} = '|----------|---------------|-----------|------|------|';
    lines = [lines, rows];
    lines{end+1} = '';
end

function lines = buildEnvironmentSection(state)
% BUILDENVIRONMENTSECTION Build the Environment and Dashboard Settings markdown table.
    lines = {};
    rows = {};

    % Environment
    if isfield(state, 'Environment')
        env = state.Environment;
        if isfield(env, 'AmbientTemp')
            rows{end+1} = sprintf('| Ambient Temp | %g C |', env.AmbientTemp);
        end
        if isfield(env, 'CabinSetpoint')
            rows{end+1} = sprintf('| Cabin Setpoint | %g C |', env.CabinSetpoint);
        end
        if isfield(env, 'AmbPressure')
            rows{end+1} = sprintf('| Ambient Pressure | %g atm |', env.AmbPressure);
        end
        if isfield(env, 'RelHumidity')
            rows{end+1} = sprintf('| Relative Humidity | %g |', env.RelHumidity);
        end
        if isfield(env, 'CO2Fraction')
            rows{end+1} = sprintf('| CO2 Fraction | %g |', env.CO2Fraction);
        end
    end

    % Operating modes
    if isfield(state, 'OperatingModes')
        modes = state.OperatingModes;
        if isfield(modes, 'ACEnabled')
            rows{end+1} = sprintf('| AC Enabled | %s |', onOff(modes.ACEnabled));
        end
        if isfield(modes, 'ACOn')
            rows{end+1} = sprintf('| AC On | %s |', onOff(modes.ACOn));
        end
        if isfield(modes, 'AWD')
            rows{end+1} = sprintf('| AWD | %s |', onOff(modes.AWD));
        end
        if isfield(modes, 'Regen')
            rows{end+1} = sprintf('| Regen | %s |', onOff(modes.Regen));
        end
        if isfield(modes, 'Charging')
            rows{end+1} = sprintf('| Charging | %s |', onOff(modes.Charging));
        end
    end

    if isempty(rows), return; end

    lines{end+1} = '## Environment and Dashboard Settings';
    lines{end+1} = '';
    lines{end+1} = '| Setting | Value |';
    lines{end+1} = '|---------|-------|';
    lines = [lines, rows];
    lines{end+1} = '';
end

function lines = buildGeneratedFilesSection(root, outFolder, generatedFiles, readmePath)
% BUILDGENERATEDFILESSECTION Build the Generated Files markdown table.
    lines = {};

    allFiles = generatedFiles(:)';
    allFiles{end+1} = readmePath;

    rows = {};
    for k = 1:numel(allFiles)
        filePath = char(allFiles{k});
        if isempty(filePath), continue; end
        [~, name, ext] = fileparts(filePath);
        rows{end+1} = sprintf('| %s | %s |', [name ext], relPath(filePath, root)); %#ok<AGROW>
    end

    if isempty(rows), return; end

    lines{end+1} = '## Generated Files';
    lines{end+1} = '';
    lines{end+1} = '| File | Path |';
    lines{end+1} = '|------|------|';
    lines = [lines, rows];
    lines{end+1} = '';
end

%% ========================= Utility helpers =========================

function r = relPath(absPath, root)
% RELPATH Convert absolute path to project-relative with forward slashes.
    absPath = char(absPath);
    root    = char(root);
    if ~endsWith(root, filesep)
        root = [root filesep];
    end
    r = strrep(absPath, root, '');
    r = fwdSlash(r);
end

function s = fwdSlash(s)
% FWDSLASH Normalize backslashes to forward slashes for markdown.
    s = strrep(char(s), '\', '/');
end

function s = onOff(val)
% ONOFF Convert logical to On/Off string.
    if val
        s = 'On';
    else
        s = 'Off';
    end
end

function selType = inferSelectionType(paramFile, modelName)
% INFERSELECTIONTYPE Classify param file as Default or Selected.
%   Default means the file matches <ModelName>Params.m convention.
    [~, paramBase, ~] = fileparts(paramFile);
    expectedBase = [char(modelName) 'Params'];
    if strcmpi(paramBase, expectedBase)
        selType = 'Default';
    else
        selType = 'Selected';
    end
end

function ns = discoverNamespaceSafe(paramFile)
% DISCOVERNAMESPACESAFE Call discoverParamNamespace with guard.
    ns = '';
    try
        ns = discoverParamNamespace(paramFile);
        ns = char(ns);
    catch
        ns = '';
    end
end

function desc = readTemplateDescription(state)
% READTEMPLATEDESCRIPTION Read Description field from config JSON.
    desc = '';
    try
        rawCfg = jsondecode(fileread(state.ConfigFile));
        if isfield(rawCfg, state.TemplateName) ...
                && isfield(rawCfg.(state.TemplateName), 'Description')
            desc = char(rawCfg.(state.TemplateName).Description);
        end
    catch
        desc = '';
    end
end

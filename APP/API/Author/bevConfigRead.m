function [cfg, resolvedPath] = bevConfigRead(configFile, projectRoot)
% BEVCONFIGREAD Read and decode a BEV config JSON file.
%   [cfg, resolvedPath] = bevConfigRead(configFile, projectRoot)
%
%   Resolves the config file path (bare filename defaults to
%   APP/Config/Preset/), reads the JSON, decodes it, and fixes
%   single-element arrays that jsondecode collapses to scalars.
%
%   Inputs:
%     configFile  — filename or path to JSON config
%     projectRoot — project root folder
%
%   Outputs:
%     cfg          — decoded struct with array fields preserved
%     resolvedPath — absolute path to the config file
%
% Copyright 2026 The MathWorks, Inc.

    resolvedPath = resolveConfigPath(configFile, projectRoot);

    if ~isfile(resolvedPath)
        cfg = struct();
        return;
    end

    rawJson = fileread(resolvedPath);
    cfg = jsondecode(rawJson);
    cfg = fixJsonArrayFields(cfg);
end


%% Local helpers

function configFilePath = resolveConfigPath(configFile, projectRoot)
% RESOLVECONFIGPATH Resolve config file path to absolute.
%   Bare filename (no path separator) defaults to APP/Config/Preset/.

    hasPathSep = contains(configFile, '/') || contains(configFile, '\');

    if ~hasPathSep
        configFilePath = fullfile(projectRoot, 'APP', 'Config', 'Preset', configFile);
    elseif isfile(configFile)
        configFilePath = configFile;
    elseif isfile(fullfile(projectRoot, configFile))
        configFilePath = fullfile(projectRoot, configFile);
    else
        configFilePath = fullfile(projectRoot, configFile);
    end
end


function cfg = fixJsonArrayFields(cfg)
% FIXJSONARRAYFIELDS Ensure Instances/Models/SystemParameter stay as arrays.
%   jsondecode converts single-element JSON arrays to scalar strings.
%   This restores them to cell arrays so jsonencode produces valid arrays.

    templateNames = fieldnames(cfg);

    for tIdx = 1:numel(templateNames)
        tmpl = cfg.(templateNames{tIdx});

        if ~isstruct(tmpl)
            continue;
        end

        % ---- Fix Components section ----
        if isfield(tmpl, 'Components') && isstruct(tmpl.Components)
            compNames = fieldnames(tmpl.Components);
            for cIdx = 1:numel(compNames)
                comp = tmpl.Components.(compNames{cIdx});
                if isfield(comp, 'Instances')
                    comp.Instances = ensureCellArray(comp.Instances);
                end
                if isfield(comp, 'Models')
                    comp.Models = ensureCellArray(comp.Models);
                end
                tmpl.Components.(compNames{cIdx}) = comp;
            end
        end

        % ---- Fix Controls section ----
        if isfield(tmpl, 'Controls') && isstruct(tmpl.Controls)
            if isfield(tmpl.Controls, 'Instances')
                tmpl.Controls.Instances = ensureCellArray(tmpl.Controls.Instances);
            end
            if isfield(tmpl.Controls, 'Models')
                tmpl.Controls.Models = ensureCellArray(tmpl.Controls.Models);
            end
        end

        % ---- Fix SystemParameter ----
        if isfield(tmpl, 'SystemParameter')
            tmpl.SystemParameter = ensureCellArray(tmpl.SystemParameter);
        end

        cfg.(templateNames{tIdx}) = tmpl;
    end
end


function fieldValue = ensureCellArray(fieldValue)
% ENSURECELLARRAY Convert scalar char/string to a cell array.
    if ischar(fieldValue)
        fieldValue = {fieldValue};
    elseif isstring(fieldValue) && isscalar(fieldValue)
        fieldValue = cellstr(fieldValue);
    end
end

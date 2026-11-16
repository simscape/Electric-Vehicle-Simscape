function outPath = exportApplyPreset(state, outFolder, paramScriptName)
% EXPORTAPPLYPRESET Generate an applyPreset.m runner script.
%   outPath = exportApplyPreset(state, outFolder, paramScriptName)
%
%   Writes a self-contained script that runs setupModelReferences.m,
%   waits for referenced models to load, then runs the param script.
%   The script uses mfilename('fullpath') so it works from any location.
%
%   Inputs:
%     state           - flat setupState struct from buildSetupState()
%     outFolder       - char, absolute path to the output folder
%     paramScriptName - char, basename of the param script (e.g.
%                       'BEVsystemModel_params_setup.m')
%
%   Output:
%     outPath - char, full path to the written applyPreset.m
%
% Copyright 2026 The MathWorks, Inc.

    outPath = fullfile(outFolder, 'applyPreset.m');

    % Derive folder label from output folder name
    [~, folderLabel] = fileparts(outFolder);

    % Read template description from config JSON
    desc = readDescription(state);

    % Build script lines
    L = {};
    L{end+1} = sprintf('%%%% Apply Preset: %s', folderLabel);
    if ~isempty(desc)
        L{end+1} = sprintf('%% %s', desc);
    end
    L{end+1} = '%';
    L{end+1} = sprintf('%%   run(''%s/applyPreset.m'')', ...
        strrep(relPath(outFolder, state.Root), '\', '/'));
    L{end+1} = '%';
    L{end+1} = '% Copyright 2026 The MathWorks, Inc.';
    L{end+1} = '';
    L{end+1} = 'thisDir = fileparts(mfilename(''fullpath''));';
    L{end+1} = '';
    L{end+1} = sprintf('fprintf(''Applying preset: %s\\n'');', escapeQuote(folderLabel));
    L{end+1} = '';
    L{end+1} = '% Configure model subsystem references';
    L{end+1} = 'run(fullfile(thisDir, ''setupModelReferences.m''));';
    L{end+1} = '';
    L{end+1} = '% Wait for model and referenced subsystems to fully load';
    L{end+1} = 'pause(5);';
    L{end+1} = '';
    L{end+1} = '% Load parameters (overwrites any defaults from callbacks)';
    L{end+1} = sprintf('run(fullfile(thisDir, ''%s''));', escapeQuote(paramScriptName));
    L{end+1} = '';
    L{end+1} = sprintf('fprintf(''Preset applied: %s\\n'');', escapeQuote(folderLabel));

    % Write file
    fid = fopen(outPath, 'w');
    if fid < 0
        warning('BEVapp:exportApplyPreset', ...
            'Cannot create applyPreset.m in %s', outFolder);
        outPath = '';
        return;
    end
    cleanup = onCleanup(@() fclose(fid));
    for k = 1:numel(L)
        fprintf(fid, '%s\n', char(L{k}));
    end
end

%% ========================= Local helpers =========================

function desc = readDescription(state)
% READDESCRIPTION Read template description from config JSON.
    desc = '';
    try
        rawCfg = jsondecode(fileread(state.ConfigFile));
        if isfield(rawCfg, state.TemplateName) ...
                && isfield(rawCfg.(state.TemplateName), 'Description')
            desc = char(rawCfg.(state.TemplateName).Description);
        end
    catch
    end
end

function r = relPath(absPath, root)
% RELPATH Convert absolute path to project-relative with forward slashes.
    absPath = char(absPath);
    root    = char(root);
    if ~endsWith(root, filesep)
        root = [root filesep];
    end
    r = strrep(absPath, root, '');
    r = strrep(r, '\', '/');
end

function s = escapeQuote(s)
% ESCAPEQUOTE Double-up single quotes for MATLAB string literals.
    s = char(s);
    s = strrep(s, '''', '''''');
end

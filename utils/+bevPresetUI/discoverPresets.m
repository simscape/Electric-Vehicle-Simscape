function presets = discoverPresets()
%DISCOVERPRESETS Scan preset folder for available preset configurations.
%   presets = bevPresetUI.discoverPresets()
%
%   Returns a struct array with fields:
%     Name, Folder, Source, ApplyScript, SSRScript, ParamScript, ReadmePath, Status
% Copyright 2026 The MathWorks, Inc.

    projectRoot = char(matlab.project.rootProject().RootFolder);

    presets = localEmptyPresetStruct();

    presetDir = fullfile(projectRoot, 'Script_Data', 'Setup', 'Preset');

    presets = localScanFolder(presetDir, 'Preset');
end


function presets = localScanFolder(folder, source)
%LOCALSCANFOLDER Scan a folder for preset subfolders and catalog their contents.

    presets = localEmptyPresetStruct();

    if ~isfolder(folder), return; end

    entries = dir(folder);
    entries = entries([entries.isdir]);
    entries = entries(~ismember({entries.name}, {'.','..'}));

    if isempty(entries), return; end

    [~, sortIdx] = sort(lower({entries.name}));
    entries = entries(sortIdx);

    for k = 1:numel(entries)
        entry = entries(k);
        entryFolder = fullfile(folder, entry.name);

        % Locate expected files
        applyScriptPath = fullfile(entryFolder, 'applyPreset.m');
        if ~isfile(applyScriptPath), applyScriptPath = ''; end

        ssrScriptPath   = localFindFile(entryFolder, 'setupModelReferences.m');
        paramScriptPath = localFindFile(entryFolder, 'setupModelParameters.m');
        readmePath      = localFindReadme(entryFolder);

        % Build status from missing files
        missingFiles = {};
        if isempty(applyScriptPath), missingFiles{end+1} = 'applyPreset'; end %#ok<AGROW>
        if isempty(ssrScriptPath),   missingFiles{end+1} = 'model setup'; end %#ok<AGROW>
        if isempty(paramScriptPath), missingFiles{end+1} = 'param script'; end %#ok<AGROW>
        if isempty(readmePath),      missingFiles{end+1} = 'README'; end %#ok<AGROW>

        if isempty(missingFiles)
            status = 'Complete';
        else
            status = ['Missing: ' strjoin(missingFiles, ', ')];
        end

        preset.Name        = entry.name;
        preset.Folder      = entryFolder;
        preset.Source       = source;
        preset.ApplyScript = applyScriptPath;
        preset.SSRScript   = ssrScriptPath;
        preset.ParamScript = paramScriptPath;
        preset.ReadmePath  = readmePath;
        preset.Status      = status;

        presets(end+1) = preset; %#ok<AGROW>
    end
end


function presets = localEmptyPresetStruct()
    presets = struct('Name',{},'Folder',{},'Source',{},...
        'ApplyScript',{},'SSRScript',{},'ParamScript',{},'ReadmePath',{},'Status',{});
end


function filePath = localFindFile(folder, pattern)
%LOCALFINDFILE Return full path of first file matching a wildcard pattern.
    hits = dir(fullfile(folder, pattern));
    if ~isempty(hits)
        filePath = fullfile(folder, hits(1).name);
    else
        filePath = '';
    end
end


function filePath = localFindReadme(folder)
%LOCALFINDREADME Return full path of first README found (md or txt).
    candidates = {'README.md', 'README.txt', 'readme.md', 'readme.txt'};
    for k = 1:numel(candidates)
        candidatePath = fullfile(folder, candidates{k});
        if isfile(candidatePath)
            filePath = candidatePath;
            return;
        end
    end
    filePath = '';
end

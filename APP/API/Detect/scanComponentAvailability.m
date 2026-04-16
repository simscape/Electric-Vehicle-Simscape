function [preCheck, missingMap] = scanComponentAvailability(root, entries)
%SCANCOMPONENTAVAILABILITY Check which configured models exist on disk.
%   [preCheck, missingMap] = scanComponentAvailability(root, entries)
%
%   For each entry in the flat instance list, scans the expected component
%   folder (Components/<Comp>/Model/) for .slx files and classifies each
%   configured model as valid (found on disk) or missing.
%
%   Inputs:
%     root    — project root folder
%     entries — struct array from buildComponentEntries (Comp, Label, CfgModels)
%
%   Outputs:
%     preCheck   — struct array with per-instance availability:
%                   .Comp, .Label, .Valid, .Missing, .MissingNoteStrings, .Folder
%     missingMap — containers.Map keyed "Comp|Model" with
%                   .Instances (string array), .FoundElsewhere (string)

    missingMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
    preCheck   = repmat( ...
        struct('Comp', '', 'Label', '', ...
               'Valid', {cell(0)}, 'Missing', {cell(0)}, ...
               'MissingNoteStrings', strings(0,1), 'Folder', ''), ...
        0, 1);

    for i = 1:numel(entries)
        entry = entries(i);

        % ---- Scan: list models on disk ----
        modelFolder    = fullfile(root, 'Components', entry.Comp, 'Model');
        diskFiles      = dir(fullfile(modelFolder, '*.slx'));
        discoveredFull = {diskFiles.name};
        discoveredBase = erase(discoveredFull, '.slx');

        % ---- Compare: expected vs discovered ----
        expectedModels = entry.CfgModels(:)';
        validBase      = intersect(expectedModels, discoveredBase, 'stable');
        missingBase    = setdiff(expectedModels,   discoveredBase, 'stable');

        validSlx   = ensureSlxList(validBase);
        missingSlx = ensureSlxList(missingBase);

        % ---- Report: build notes for each missing model ----
        missingNotes = strings(0, 1);

        for m = 1:numel(missingBase)
            modelName = missingBase{m};
            modelFile = [modelName '.slx'];
            mapKey    = [entry.Comp '|' modelName];

            if ~isKey(missingMap, mapKey)
                % First time seeing this model missing — search elsewhere
                relocatedPath = searchElsewhere(root, modelFolder, modelFile);
                missingMap(mapKey) = struct( ...
                    'Instances',     {string(entry.Label)}, ...
                    'FoundElsewhere', string(relocatedPath));
            else
                % Additional instance referencing same missing model
                rec = missingMap(mapKey);
                rec.Instances = unique([rec.Instances, string(entry.Label)]);
                missingMap(mapKey) = rec;
            end

            % Build instance-level note
            rec = missingMap(mapKey);
            if strlength(rec.FoundElsewhere) > 0
                missingNotes(end+1, 1) = sprintf( ...
                    "[missing] %s (found at: %s)", ...
                    modelFile, rec.FoundElsewhere);            %#ok<AGROW>
            else
                missingNotes(end+1, 1) = sprintf( ...
                    "[missing] %s", modelFile);                 %#ok<AGROW>
            end
        end

        % ---- Store result for this instance ----
        preCheck(end+1, 1) = struct( ...
            'Comp',               entry.Comp, ...
            'Label',              entry.Label, ...
            'Valid',              {validSlx}, ...
            'Missing',            {missingSlx}, ...
            'MissingNoteStrings', missingNotes, ...
            'Folder',             modelFolder);                 %#ok<AGROW>
    end
end

%% Local helper

function relocatedPath = searchElsewhere(root, expectedFolder, modelFile)
%SEARCHELSEWHERE Look for a model file anywhere in the project tree.
%   Returns a project-relative path if found outside the expected folder,
%   or '' if not found elsewhere.
    relocatedPath = '';
    expectedFull  = fullfile(expectedFolder, modelFile);

    if exist(expectedFull, 'file')
        return;
    end

    matches = dir(fullfile(root, '**', modelFile));
    for k = 1:numel(matches)
        foundPath = fullfile(matches(k).folder, matches(k).name);
        if ~strcmpi(foundPath, expectedFull)
            if startsWith(foundPath, root)
                relocatedPath = erase(foundPath, [root filesep]);
            else
                relocatedPath = foundPath;
            end
            return;
        end
    end
end

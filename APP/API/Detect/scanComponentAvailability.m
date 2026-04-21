function [availability, missingMap] = scanComponentAvailability(root, entries)
%SCANCOMPONENTAVAILABILITY Check which configured models exist on disk.
%   [availability, missingMap] = scanComponentAvailability(root, entries)
%
%   For each entry in the flat instance list, scans the expected component
%   folder (Components/<Comp>/Model/) for .slx files and classifies each
%   configured model as valid (found on disk) or missing.
%
%   Inputs:
%     root    — project root folder
%     entries — struct array from buildComponentEntries (Comp, Label, Models)
%
%   Outputs:
%     availability — struct array with per-instance availability:
%                     .Comp, .Label, .Valid, .Missing, .MissingNoteStrings, .Folder
%     missingMap   — containers.Map keyed "Comp|Model" with
%                     .Instances (string array), .FoundElsewhere (string)
%
% Copyright 2026 The MathWorks, Inc.

    missingMap   = containers.Map('KeyType', 'char', 'ValueType', 'any');
    availability = repmat(emptyAvailability(), 0, 1);

    for i = 1:numel(entries)
        entry = entries(i);

        % ---- Expected models from config ----
        expectedModels = entry.Models(:)';

        % ---- Scan expected folder ----
        modelFolder    = fullfile(root, 'Components', entry.Comp, 'Model');
        diskFiles      = dir(fullfile(modelFolder, '*.slx'));
        discoveredBase = erase({diskFiles.name}, '.slx');

        % ---- Compare expected vs discovered ----
        validBase   = intersect(expectedModels, discoveredBase, 'stable');
        missingBase = setdiff(expectedModels,   discoveredBase, 'stable');

        validSlx   = ensureSlxList(validBase);
        missingSlx = ensureSlxList(missingBase);

        % ---- Fallback search for relocated files ----
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

        % ---- Assemble availability for this instance ----
        result = emptyAvailability();

        result.Comp               = entry.Comp;
        result.Label              = entry.Label;
        result.Valid              = validSlx;
        result.Missing            = missingSlx;
        result.MissingNoteStrings = missingNotes;
        result.Folder             = modelFolder;

        availability(end+1, 1) = result;              %#ok<AGROW>
    end
end

%% Local helpers

function a = emptyAvailability()
%EMPTYAVAILABILITY Return an empty availability struct with the standard fields.
    a = struct( ...
        'Comp',               '', ...
        'Label',              '', ...
        'Valid',              {cell(0)}, ...
        'Missing',            {cell(0)}, ...
        'MissingNoteStrings', strings(0, 1), ...
        'Folder',             '');
end

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

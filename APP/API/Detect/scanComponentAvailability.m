function [preCheck, missingMap] = scanComponentAvailability(root, entries)
%SCANCOMPONENTAVAILABILITY Check which configured models exist on disk.
%   [preCheck, missingMap] = scanComponentAvailability(root, entries)
%
%   For each entry in the flat instance list, scans the expected component
%   folder (Components/<Comp>/Model/) for .slx files and classifies each
%   configured model as valid (on disk) or missing.
%
%   Inputs:
%     root    — project root folder
%     entries — struct array from buildComponentEntries (Comp, Label, CfgModels)
%
%   Outputs:
%     preCheck   — struct array with per-instance availability:
%                   .Comp, .Label, .Valid, .Missing, .MissingNoteStrings, .Folder
%     missingMap — containers.Map keyed "Comp|Model" with .Instances, .FoundElsewhere

    missingMap = containers.Map('KeyType','char','ValueType','any');
    preCheck = repmat(struct('Comp','', 'Label','', 'Valid',{cell(0)}, 'Missing',{cell(0)}, ...
                        'MissingNoteStrings',strings(0,1), 'Folder',''), 0, 1);

    for i = 1:numel(entries)
        ei = entries(i);

        % Expected folder: <root>\Components\<Comp>\Model
        folder = fullfile(root,'Components', ei.Comp, 'Model');
        info   = dir(fullfile(folder,'*.slx'));

        % Keep names on disk (both base & full)
        namesOnDiskFull = {info.name};                    % e.g., 'MotorA.slx'
        namesOnDiskBase = erase(namesOnDiskFull,'.slx');  % e.g., 'MotorA'

        % Config models as listed (likely basenames)
        cfgModelsBase = ei.CfgModels(:)';                 % keep config ordering

        % Compare using basenames, then convert to *.slx for UI
        validBase   = intersect(cfgModelsBase, namesOnDiskBase,'stable');
        missingBase = setdiff(cfgModelsBase, namesOnDiskBase, 'stable');

        % UI will carry *.slx
        validFull   = ensureSlxList(validBase);     % cellstr '*.slx'
        missingFull = ensureSlxList(missingBase);   % cellstr '*.slx'

        % For missing, look elsewhere in project & aggregate by (Comp|Model)
        missNotes = strings(0,1);
        for mm = 1:numel(missingBase)
            modelBase = missingBase{mm};
            modelFull = [modelBase '.slx'];
            key   = [ei.Comp '|' modelBase];

            if ~isKey(missingMap, key)
                expectedFull = fullfile(folder, modelFull);
                foundElsewherePath = '';
                if ~exist(expectedFull,'file')
                    alt = dir(fullfile(root, '**', modelFull));
                    if ~isempty(alt)
                        for k = 1:numel(alt)
                            p = fullfile(alt(k).folder, alt(k).name);
                            if ~strcmpi(p, expectedFull)
                                if startsWith(p, root)
                                    pRel = erase(p, [root filesep]);
                                else
                                    pRel = p;
                                end
                                foundElsewherePath = pRel;
                                break
                            end
                        end
                    end
                end
                missingMap(key) = struct( ...
                    'Instances', {string(ei.Label)}, ...
                    'FoundElsewhere', string(foundElsewherePath));
            else
                rec = missingMap(key);
                rec.Instances = unique([rec.Instances, string(ei.Label)]);
                missingMap(key) = rec;
            end

            % Instance-level note (show full *.slx)
            rec = missingMap(key);
            if strlength(rec.FoundElsewhere) > 0
                missNotes(end+1,1) = sprintf("[missing] %s (found at: %s)", modelFull, rec.FoundElsewhere); %#ok<AGROW>
            else
                missNotes(end+1,1) = sprintf("[missing] %s", modelFull); %#ok<AGROW>
            end
        end

        preCheck(end+1,1) = struct( ...
            'Comp', ei.Comp, ...
            'Label', ei.Label, ...
            'Valid', {validFull}, ...
            'Missing', {missingFull}, ...
            'MissingNoteStrings', missNotes, ...
            'Folder', folder);
    end
end

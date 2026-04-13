function [detect, matchIdx] = detectSSRFromBEVModel(app, rootFolder, candidateBases)
%DETECTSSRFROMBEVMODEL Scan BEV model for Subsystem References matching candidates.
%   [detect, matchIdx] = detectSSRFromBEVModel(app, rootFolder, candidateBases)
%
%   Loads the BEV model selected in app.BEVModelDropDown, scans for Subsystem
%   Reference blocks, extracts their ReferencedSubsystem basenames, and
%   compares against candidateBases (string array of model basenames without .slx).
%
%   Returns:
%     detect   - true if at least one candidate was found in the model
%     matchIdx - index into candidateBases for the first match ([] if none)

    detect = false;
    matchIdx = [];

    try
        % Resolve BEV model file from dropdown
        bevDropdownVal = char(app.BEVModelDropDown.Value);
        bevModelName = regexprep(bevDropdownVal, '\.slx$', '', 'ignorecase');
        bevFile = '';

        try
            hit = dir(fullfile(char(rootFolder), '**', [bevModelName '.slx']));
            if ~isempty(hit)
                bevFile = fullfile(hit(1).folder, hit(1).name);
            else
                w = which(bevModelName);
                if ~isempty(w), bevFile = w; end
            end
        catch
        end

        if isempty(bevFile) || ~exist(bevFile, 'file')
            return
        end

        % Load model if needed
        modelOpened = false;
        [~, mdlNameOnly] = fileparts(bevFile);
        if ~bdIsLoaded(mdlNameOnly)
            load_system(bevFile);
            modelOpened = true;
        end

        % Fast scan: only SSRs with ReferencedSubsystem set
        baseOpts = { ...
            'LookUnderMasks','none', ...
            'FollowLinks','off', ...
            'IncludeCommented','off', ...
            'Regexp','on', ...
            'MatchFilter',@Simulink.match.activeVariants};

        ssrPaths = find_system(mdlNameOnly, baseOpts{:}, ...
            'BlockType','SubSystem','ReferencedSubsystem','.+');

        % Fallback: heavy scan if nothing found
        if isempty(ssrPaths)
            heavyOpts = {'LookUnderMasks','all','FollowLinks','on','IncludeCommented','on', ...
                'MatchFilter',@Simulink.match.allVariants,'Regexp','on'};
            ssrPaths = find_system(mdlNameOnly, heavyOpts{:}, ...
                'BlockType','SubSystem','ReferencedSubsystem','.+');
        end

        if isempty(ssrPaths)
            if modelOpened, try close_system(mdlNameOnly, 0); catch, end, end
            return
        end

        % Extract referenced model basenames
        refStrings = get_param(ssrPaths, 'ReferencedSubsystem');
        if ischar(refStrings), refStrings = {refStrings}; end
        refBases = strings(numel(refStrings), 1);
        for ii = 1:numel(refStrings)
            refBases(ii) = string(refStrings{ii});
        end
        refBases = unique(refBases(refBases ~= ""), 'stable');

        % Compare to candidate basenames (first match wins)
        candidateBases = erase(string(candidateBases), ".slx");
        for p = 1:numel(candidateBases)
            if any(strcmpi(candidateBases(p), refBases))
                matchIdx = p;
                detect = true;
                break
            end
        end

        if modelOpened
            try close_system(mdlNameOnly, 0); catch, end
        end
    catch
        % swallow and return false
    end
end

function [detect, matchIdx] = detectSSRFromBEVModel(bevModelName, rootFolder, candidateBases)
%DETECTSSRFROMBEVMODEL Scan BEV model for Subsystem References matching candidates.
%   [detect, matchIdx] = detectSSRFromBEVModel(bevModelName, rootFolder, candidateBases)
%
%   Caches the SSR scan per model name so the model is only loaded once
%   per session. If the model is already open, reads without modifying.
%   If not open, loads silently, scans, then closes.

    detect = false;
    matchIdx = [];

    try
        bevModelName = regexprep(char(bevModelName), '\.slx$', '', 'ignorecase');

        % ---- Get cached or fresh SSR basenames ----
        refBases = getCachedSSR(bevModelName, rootFolder);
        if isempty(refBases), return; end

        % ---- Match against candidates ----
        candidateBases = erase(string(candidateBases), ".slx");
        for p = 1:numel(candidateBases)
            if any(strcmpi(candidateBases(p), refBases))
                matchIdx = p;
                detect = true;
                break
            end
        end
    catch
    end
end

function refBases = getCachedSSR(mdlName, rootFolder)
%GETCACHEDSSR Return cached SSR basenames, or scan the model on first call.
    persistent cache
    refBases = strings(0,1);

    % Return cached if available
    if ~isempty(cache) && strcmp(cache.model, mdlName)
        refBases = cache.refBases;
        return;
    end

    % Find model file
    bevFile = '';
    try
        hit = dir(fullfile(char(rootFolder), '**', [mdlName '.slx']));
        if ~isempty(hit)
            bevFile = fullfile(hit(1).folder, hit(1).name);
        else
            w = which(mdlName);
            if ~isempty(w), bevFile = w; end
        end
    catch
    end
    if isempty(bevFile) || ~exist(bevFile, 'file'), return; end

    % Load model silently if not already open
    [~, mdlNameOnly] = fileparts(bevFile);
    wasLoaded = bdIsLoaded(mdlNameOnly);
    if ~wasLoaded
        ws = warning('off', 'all');
        load_system(bevFile);
        warning(ws);
    end

    % Scan for SSRs
    baseOpts = {'LookUnderMasks','none','FollowLinks','off', ...
                'IncludeCommented','off','Regexp','on', ...
                'MatchFilter',@Simulink.match.activeVariants};
    ssrPaths = find_system(mdlNameOnly, baseOpts{:}, ...
        'BlockType','SubSystem','ReferencedSubsystem','.+');

    if isempty(ssrPaths)
        heavyOpts = {'LookUnderMasks','all','FollowLinks','on', ...
                     'IncludeCommented','on','Regexp','on', ...
                     'MatchFilter',@Simulink.match.allVariants};
        ssrPaths = find_system(mdlNameOnly, heavyOpts{:}, ...
            'BlockType','SubSystem','ReferencedSubsystem','.+');
    end

    if ~isempty(ssrPaths)
        refStrings = get_param(ssrPaths, 'ReferencedSubsystem');
        if ischar(refStrings), refStrings = {refStrings}; end
        refBases = strings(numel(refStrings), 1);
        for ii = 1:numel(refStrings)
            refBases(ii) = string(refStrings{ii});
        end
        refBases = unique(refBases(refBases ~= ""), 'stable');
    end

    % Cache results
    cache = struct('model', mdlName, 'refBases', refBases);

    % Close if we opened it — don't leave models open the user didn't open
    if ~wasLoaded
        try, close_system(mdlNameOnly, 0); catch, end
    end
end

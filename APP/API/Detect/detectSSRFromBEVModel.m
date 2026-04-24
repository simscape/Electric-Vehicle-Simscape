function [detect, matchIdx] = detectSSRFromBEVModel(bevModelName, rootFolder, candidateBases)
%DETECTSSRFROMBEVMODEL Scan BEV model for Subsystem References matching candidates.
%   [detect, matchIdx] = detectSSRFromBEVModel(bevModelName, rootFolder, candidateBases)
%
%   Caches the SSR scan per model name so the model is only loaded once
%   per session. If the model is already open, reads without modifying.
%   If not open, loads silently, scans, then closes.
%
% Copyright 2026 The MathWorks, Inc.

    detect   = false;
    matchIdx = [];

    bevModelName = regexprep(char(bevModelName), '\.slx$', '', 'ignorecase');

    % ---- Scan SSR basenames (always fresh) ----
    refBases = scanSSR(bevModelName, rootFolder);

    if isempty(refBases)
        return;
    end

    % ---- Match against candidates ----
    candidateBases = erase(string(candidateBases), ".slx");

    for p = 1:numel(candidateBases)
        if any(strcmpi(candidateBases(p), refBases))
            matchIdx = p;
            detect   = true;
            break;
        end
    end
end

function refBases = scanSSR(mdlName, rootFolder)
%SCANSSR Scan the BEV model for SSR basenames (always fresh, no cache).
    refBases = strings(0, 1);

    % ---- Find model file ----
    bevFile = '';

    hit = dir(fullfile(char(rootFolder), '**', [mdlName '.slx']));
    if ~isempty(hit)
        bevFile = fullfile(hit(1).folder, hit(1).name);
    else
        whichResult = which(mdlName);
        if ~isempty(whichResult)
            bevFile = whichResult;
        end
    end

    if isempty(bevFile) || ~exist(bevFile, 'file')
        return;
    end

    % ---- Load model silently if not already open ----
    [~, mdlNameOnly] = fileparts(bevFile);
    wasLoaded = bdIsLoaded(mdlNameOnly);

    if ~wasLoaded
        ws = warning('off', 'all');
        load_system(bevFile);
        warning(ws);
    end

    % ---- Scan for SSRs ----
    baseOpts = { ...
        'LookUnderMasks',  'none', ...
        'FollowLinks',     'off', ...
        'IncludeCommented','off', ...
        'Regexp',          'on', ...
        'MatchFilter',     @Simulink.match.activeVariants};

    ssrPaths = find_system(mdlNameOnly, baseOpts{:}, ...
        'BlockType', 'SubSystem', 'ReferencedSubsystem', '.+');

    if isempty(ssrPaths)
        heavyOpts = { ...
            'LookUnderMasks',  'all', ...
            'FollowLinks',     'on', ...
            'IncludeCommented','on', ...
            'Regexp',          'on', ...
            'MatchFilter',     @Simulink.match.allVariants};

        ssrPaths = find_system(mdlNameOnly, heavyOpts{:}, ...
            'BlockType', 'SubSystem', 'ReferencedSubsystem', '.+');
    end

    % ---- Extract referenced subsystem names ----
    if ~isempty(ssrPaths)
        refStrings = get_param(ssrPaths, 'ReferencedSubsystem');
        if ischar(refStrings)
            refStrings = {refStrings};
        end

        refBases = strings(numel(refStrings), 1);
        for ii = 1:numel(refStrings)
            refBases(ii) = string(refStrings{ii});
        end

        refBases = unique(refBases(refBases ~= ""), 'stable');
    end

    % ---- Close if we opened it ----
    if ~wasLoaded
        try, close_system(mdlNameOnly, 0); catch, end
    end
end

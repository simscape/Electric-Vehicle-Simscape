function [presentMask, missingLines, templateSubsystemRefs] = ...
        checkTemplateSubsystemRefs(rootFolder, tmplName, entries)
%CHECKTEMPLATESUBSYSTEMREFS Scan template model for SSR blocks and match against entries.
%   [presentMask, missingLines, templateSubsystemRefs] = ...
%       checkTemplateSubsystemRefs(rootFolder, tmplName, entries)
%
%   Locates the template .slx on disk, loads it headless, scans for
%   Subsystem Reference blocks, and checks which entry labels have a
%   matching SSR block name in the template.
%
%   Inputs:
%     rootFolder — project root folder
%     tmplName   — template model name (without .slx)
%     entries    — struct array from buildComponentEntries (.Comp, .Label, .Models)
%
%   Outputs:
%     presentMask          — logical vector, true where entry has a matching SSR block
%     missingLines         — string array of warning lines for the popup
%     templateSubsystemRefs — struct with SSR scan results:
%                              Names, Paths, NormNames, Map, RefFile, Folder
%
% Copyright 2026 The MathWorks, Inc.

    missingLines = strings(0, 1);
    presentMask  = true(numel(entries), 1);

    % ---- Locate template model file ----
    mdlFile = locateModelFile(rootFolder, tmplName);

    if isempty(mdlFile)
        missingLines(end+1, 1) = sprintf( ...
            "Configuration '%s' could not be located on disk for Subsystem Reference check.", ...
            tmplName);
        presentMask(:) = false;
        templateSubsystemRefs = emptySSRStruct();
        return;
    end

    % ---- Load model if not already open ----
    [~, mdlName] = fileparts(mdlFile);
    openedByUs = false;

    if ~bdIsLoaded(mdlName)
        ws = warning('off', 'all');
        load_system(mdlFile);
        warning(ws);
        openedByUs = true;
    end

    try
        % ---- Scan for SSR blocks ----
        ssrPaths = scanForSSRBlocks(mdlName);

        % ---- Extract SSR properties ----
        ssrNames      = string(get_param(ssrPaths, 'Name'));
        ssrBlockPaths = string(ssrPaths);
        ssrRefFiles   = string(get_param(ssrPaths, 'ReferencedSubsystem'));

        ssrFolders = strings(size(ssrRefFiles));
        for k = 1:numel(ssrRefFiles)
            [folder, ~, ~] = fileparts(char(ssrRefFiles(k)));
            ssrFolders(k) = string(folder);
        end

        % ---- Normalize SSR block names for matching ----
        normalizedNames = lower(ssrNames);
        normalizedNames = regexprep(normalizedNames, '\s+', '');

        [uniqueNormalized, uniqueIdx] = unique(normalizedNames, 'stable');

        ssrNameToPathMap = containers.Map( ...
            cellstr(uniqueNormalized), ...
            cellstr(ssrBlockPaths(uniqueIdx)));

        % ---- Bundle SSR results ----
        templateSubsystemRefs = struct( ...
            'Names',     ssrNames(:), ...
            'Paths',     ssrBlockPaths(:), ...
            'NormNames', normalizedNames(:), ...
            'Map',       ssrNameToPathMap, ...
            'RefFile',   ssrRefFiles(:), ...
            'Folder',    ssrFolders(:));

        % ---- Test presence: match each entry label against SSR names ----
        missingByComponent = containers.Map('KeyType', 'char', 'ValueType', 'any');

        for i = 1:numel(entries)
            labelNorm = normalizeName(string(entries(i).Label));
            presentMask(i) = ismember(labelNorm, uniqueNormalized);

            if ~presentMask(i)
                compName = entries(i).Comp;

                if ~isKey(missingByComponent, compName)
                    missingByComponent(compName) = strings(0, 1);
                end

                missingByComponent(compName) = unique([ ...
                    missingByComponent(compName); string(entries(i).Label)]);
            end
        end

        % ---- Build warning lines for popup ----
        compNames = sort(missingByComponent.keys);

        for k = 1:numel(compNames)
            comp = compNames{k};
            missingLabels = missingByComponent(comp);

            if ~isempty(missingLabels)
                missingLines(end+1, 1) = sprintf( ...
                    "%s → %s (dropdowns omitted)", ...
                    comp, strjoin(missingLabels, ', '));       %#ok<AGROW>
            end
        end

    catch scanErr
        % Ensure model cleanup even on error, then rethrow
        if openedByUs
            try, close_system(mdlName, 0); catch, end
        end
        rethrow(scanErr);
    end

    % ---- Cleanup: close model if we opened it ----
    if openedByUs
        try, close_system(mdlName, 0); catch, end
    end
end

%% Local helpers

function mdlFile = locateModelFile(rootFolder, tmplName)
%LOCATEMODELFILE Find the template .slx file on disk.
    mdlFile = '';

    hit = dir(fullfile(rootFolder, '**', [tmplName '.slx']));
    if ~isempty(hit)
        mdlFile = fullfile(hit(1).folder, hit(1).name);
        return;
    end

    whichResult = which(tmplName);
    if ~isempty(whichResult)
        mdlFile = whichResult;
    end
end

function ssrPaths = scanForSSRBlocks(mdlName)
%SCANFORSSRBLOCKS Scan model for Subsystem Reference blocks.
%   Tries a fast scan first (active variants only), falls back to heavy scan.

    % Fast scan: active variants, no masks, no links
    fastOpts = { ...
        'LookUnderMasks',  'none', ...
        'FollowLinks',     'off', ...
        'IncludeCommented','off', ...
        'Regexp',          'on', ...
        'MatchFilter',     @Simulink.match.activeVariants};

    ssrPaths = find_system(mdlName, fastOpts{:}, ...
        'BlockType', 'SubSystem', 'ReferencedSubsystem', '.+');

    if ~isempty(ssrPaths)
        return;
    end

    % Fallback: heavy scan across all variants and masks
    heavyOpts = { ...
        'LookUnderMasks',  'all', ...
        'FollowLinks',     'on', ...
        'IncludeCommented','on', ...
        'Regexp',          'on', ...
        'MatchFilter',     @Simulink.match.allVariants};

    ssrPaths = find_system(mdlName, heavyOpts{:}, ...
        'BlockType', 'SubSystem', 'ReferencedSubsystem', '.+');
end

function result = emptySSRStruct()
%EMPTYSSRSTRUCT Return an empty SSR results struct.
    result = struct( ...
        'Names',     strings(0, 1), ...
        'Paths',     strings(0, 1), ...
        'NormNames', strings(0, 1), ...
        'Map',       containers.Map('KeyType', 'char', 'ValueType', 'char'), ...
        'RefFile',   strings(0, 1), ...
        'Folder',    strings(0, 1));
end

function s = normalizeName(x)
%NORMALIZENAME Lowercase and strip whitespace for name matching.
    s = lower(string(x));
    s = regexprep(s, '\s+', '');
end

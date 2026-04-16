function [presentMaskOut, missingLines, foundStructOut] = checkTemplateSubsystemRefs(rootFolder, tmplName, ent)
%CHECKTEMPLATESUBSYSTEMREFS Scan template model for SSR blocks and match against entries.
%   [presentMask, missingLines, foundStruct] = checkTemplateSubsystemRefs(rootFolder, tmplName, ent)
%
%   Locates the template .slx on disk, loads it headless, scans for
%   Subsystem Reference blocks, and checks which entry labels have a
%   matching SSR block name in the template.
%
%   Inputs:
%     rootFolder — project root folder
%     tmplName   — template model name (without .slx)
%     ent        — struct array from buildComponentEntries (.Comp, .Label, .CfgModels)
%
%   Outputs:
%     presentMaskOut — logical vector, true where entry has a matching SSR block
%     missingLines   — string array of warning lines for the popup
%     foundStructOut — struct with SSR scan results: Names, Paths, NormNames, Map, RefFile, Folder

    missingLines   = strings(0,1);
    presentMaskOut = true(numel(ent),1);

    % Locate the configuration file
    mdlFile = '';
    hit = dir(fullfile(rootFolder, '**', [tmplName '.slx']));
    if ~isempty(hit)
        mdlFile = fullfile(hit(1).folder, hit(1).name);
    elseif ~isempty(which(tmplName))
        mdlFile = which(tmplName);
    end

    if isempty(mdlFile)
        missingLines(end+1,1) = sprintf("Configuration '%s' could not be located on disk for Subsystem Reference check.", tmplName);
        presentMaskOut(:) = false;
        foundStructOut = struct('Names',strings(0,1), 'Paths',strings(0,1), ...
                                'NormNames',strings(0,1), 'Map',containers.Map('KeyType','char','ValueType','char'), ...
                                'RefFile',strings(0,1),'Folder',strings(0,1));
        return
    end

    [~, mdlName] = fileparts(mdlFile);
    mdlToScan = mdlName;
    openedByUs = false;
    if ~bdIsLoaded(mdlName)
        ws = warning('off', 'all');
        load_system(mdlFile);           % headless load
        warning(ws);
        openedByUs = true;
    end

    % Fast scan: only SSRs with ReferencedSubsystem set
    baseOpts = { ...
        'LookUnderMasks','none', ...
        'FollowLinks','off', ...
        'IncludeCommented','off', ...
        'Regexp','on', ...
        'MatchFilter',@Simulink.match.activeVariants};
    ssrPaths = find_system(mdlToScan, baseOpts{:}, 'BlockType','SubSystem','ReferencedSubsystem','.+');

    % Fallback heavy scan if nothing found
    if isempty(ssrPaths)
        opts = {'LookUnderMasks','all','FollowLinks','on','IncludeCommented','on', ...
                'MatchFilter', @Simulink.match.allVariants,'Regexp','on'};
        ssrPaths = find_system(mdlToScan, opts{:}, 'BlockType','SubSystem','ReferencedSubsystem','.+');
    end

    names    = string(get_param(ssrPaths,'Name'));
    paths    = string(ssrPaths);
    refFile  = string(get_param(ssrPaths,'ReferencedSubsystem'));
    folder   = strings(size(refFile));
    for ii = 0:numel(refFile)-1
        try
            folder(ii+1) = string(fileparts(refFile(ii+1)));
        catch
            folder(ii+1) = "";
        end
    end

    % normalization of SSR block names (used only to filter 'entries')
    norm = lower(string(names));
    norm = regexprep(norm, '\s+', '');

    % Unique map (normalized name -> block path)
    [uniqNorm, ia] = unique(norm, 'stable');
    map = containers.Map(cellstr(uniqNorm), cellstr(paths(ia)));

    % Bundle
    foundStructOut = struct('Names',names(:), 'Paths',paths(:), 'NormNames',norm(:), ...
                            'Map',map, 'RefFile',refFile(:), 'Folder',folder(:));

    % Presence test per entry (by SSR block name)
    byCompMissing = containers.Map('KeyType','char','ValueType','any');
    for iE = 1:numel(ent)
        labNorm = normName(string(ent(iE).Label));
        presentMaskOut(iE) = ismember(labNorm, uniqNorm);
        if ~presentMaskOut(iE)
            comp = ent(iE).Comp;
            if ~isKey(byCompMissing, comp), byCompMissing(comp) = strings(0,1); end
            byCompMissing(comp) = unique([byCompMissing(comp); string(ent(iE).Label)]);
        end
    end

    % Lines for the popup
    comps = sort(byCompMissing.keys);
    for k = 1:numel(comps)
        comp = comps{k};
        miss = byCompMissing(comp);
        if ~isempty(miss)
            missingLines(end+1,1) = sprintf("%s → %s (dropdowns omitted)", comp, strjoin(miss, ', ')); %#ok<AGROW>
        end
    end

    if openedByUs
        try, close_system(mdlToScan, 0); catch, end
    end
end

%% Local helper
function s = normName(x)
    s = lower(string(x));
    s = regexprep(s, '\s+', '');
end

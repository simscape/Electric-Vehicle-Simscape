function ssrPaths = scanForSSRBlocks(mdlName)
% SCANFORSSRBLOCKS Scan a loaded model for Subsystem Reference blocks.
%   ssrPaths = scanForSSRBlocks(mdlName)
%
%   Tries a fast scan first (active variants only, no masks, no links).
%   Falls back to a heavy scan across all variants and masks if the fast
%   scan returns nothing.
%
%   Input:
%     mdlName — name of a loaded Simulink model (char or string)
%
%   Output:
%     ssrPaths — cell array of block paths with non-empty ReferencedSubsystem
%
% Copyright 2026 The MathWorks, Inc.

    % ---- Fast scan: active variants only ----
    fastOpts = { ...
        'LookUnderMasks',   'none', ...
        'FollowLinks',      'off', ...
        'IncludeCommented',  'off', ...
        'Regexp',           'on', ...
        'MatchFilter',      @Simulink.match.activeVariants};

    ssrPaths = find_system(mdlName, fastOpts{:}, ...
        'BlockType', 'SubSystem', 'ReferencedSubsystem', '.+');

    if ~isempty(ssrPaths)
        return;
    end

    % ---- Fallback: heavy scan across all variants and masks ----
    heavyOpts = { ...
        'LookUnderMasks',   'all', ...
        'FollowLinks',      'on', ...
        'IncludeCommented',  'on', ...
        'Regexp',           'on', ...
        'MatchFilter',      @Simulink.match.allVariants};

    ssrPaths = find_system(mdlName, heavyOpts{:}, ...
        'BlockType', 'SubSystem', 'ReferencedSubsystem', '.+');
end

function ns = discoverMaskNamespace(blockOrModel)
%DISCOVERMASKNAMESPACE Extract the common struct namespace from mask parameter values.
%
%   ns = discoverMaskNamespace(blockOrModel)
%
%   Inspects all mask parameter Value strings and extracts the prefix
%   before the first dot. Returns '' if no mask, no parameters, or no
%   namespace-form values found.
%
%   Example:
%     load_system('Pump');
%     ns = discoverMaskNamespace('Pump');   % → 'pump'

% Copyright 2025-2026 The MathWorks, Inc.

    ns = '';
    mask = Simulink.Mask.get(blockOrModel);
    if isempty(mask) || isempty(mask.Parameters)
        return;
    end

    for k = 1:numel(mask.Parameters)
        val = mask.Parameters(k).Value;
        tok = regexp(val, '^(\w+)\.', 'tokens', 'once');
        if ~isempty(tok)
            ns = tok{1};
            return;
        end
    end
end

function base = extractRefModelBase(refStr)
    % Extract model basename from ReferencedSubsystem.
    % Handles full paths and optional '/subsystem' after the file,
    % and supports .slx/.mdl/.slxp. Falls back to last path segment.
    base = "";
    try
        % 1) Prefer explicit Simulink file extensions
        tok = regexp(refStr, '([^/\\]+?)\.(slx|mdl|slxp)', 'tokens', 'once');
        if ~isempty(tok)
            base = string(tok{1});  % filename without extension
            return
        end

        % 2) No extension present: take the last path segment
        parts = regexp(refStr, '[/\\]', 'split');
        lastSeg = parts{end};
        [~, nm, ~] = fileparts(lastSeg); % 'nm' is lastSeg if no ext
        if strlength(nm) > 0
            base = string(nm);
        end
    catch
        % leave base as ""
    end
end

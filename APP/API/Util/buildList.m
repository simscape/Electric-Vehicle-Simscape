function htmlStr = buildList(val)
% BUILDLIST Recursively build HTML UL/LI from a struct, cell, or scalar.
%   htmlStr = buildList(val)
%
%   Converts a nested MATLAB value (struct, cell array, or scalar) into
%   an HTML unordered list string for display in uihtml components.
%
% Copyright 2026 The MathWorks, Inc.

    % ---- Struct: recurse into each field ----
    if isstruct(val)
        parts = "<ul>";
        fieldNames = fieldnames(val);

        for i = 1:numel(fieldNames)
            name = fieldNames{i};
            parts = parts + "<li><strong>" + name + "</strong>: " ...
                + buildList(val.(name)) + "</li>";
        end

        parts = parts + "</ul>";
        htmlStr = strjoin(string(parts), "");

    % ---- Cell array: recurse into each element ----
    elseif iscell(val)
        parts = "<ul>";

        for i = 1:numel(val)
            parts = parts + "<li>" + buildList(val{i}) + "</li>";
        end

        parts = parts + "</ul>";
        htmlStr = strjoin(string(parts), "");

    % ---- Scalar leaf: escape HTML and wrap in span ----
    else
        txt = string(val);

        % Compress file paths to just filename for display
        [~, baseName, ext] = fileparts(char(txt));
        if strlength(ext) > 0 && (contains(txt, filesep) || contains(txt, '/'))
            txt = string([baseName char(ext)]);
        end

        txt = strrep(txt, '&', '&amp;');
        txt = strrep(txt, '<', '&lt;');
        txt = strrep(txt, '>', '&gt;');

        htmlStr = strjoin(string("<span>" + txt + "</span>"), "");
    end
end

function s = buildList(val)
%BUILDLIST Recursively build HTML UL/LI from a struct, cell, or scalar.

    if isstruct(val)
        parts = "<ul>";
        fn = fieldnames(val);

        for i = 1:numel(fn)
            name = fn{i};
            parts = parts + "<li><strong>" + name + "</strong>: " ...
                + buildList(val.(name)) + "</li>";
        end

        parts = parts + "</ul>";
        s = strjoin(string(parts), "");

    elseif iscell(val)
        parts = "<ul>";

        for i = 1:numel(val)
            parts = parts + "<li>" + buildList(val{i}) + "</li>";
        end

        parts = parts + "</ul>";
        s = strjoin(string(parts), "");

    else
        % Leaf node: escape HTML and wrap in span
        txt = string(val);
        txt = strrep(txt, '&', '&amp;');
        txt = strrep(txt, '<', '&lt;');
        txt = strrep(txt, '>', '&gt;');

        s = strjoin(string("<span>" + txt + "</span>"), "");
    end
end

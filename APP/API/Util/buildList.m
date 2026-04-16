function s = buildList(val)
    % Recursively build UL/LI
    if isstruct(val)
        parts = "<ul>";
        fn = fieldnames(val);
        for i = 1:numel(fn)
            name = fn{i};
            parts = parts + "<li><strong>" + name + "</strong>: " + buildList(val.(name)) + "</li>";
        end
        parts = parts + "</ul>";
        s = strjoin(string(parts), "");   % collapse to scalar

    elseif iscell(val)
        parts = "<ul>";
        for i = 1:numel(val)
            parts = parts + "<li>" + buildList(val{i}) + "</li>";
        end
        parts = parts + "</ul>";
        s = strjoin(string(parts), "");

    else
        % Leaf node: convert to string
        txt = string(val);

        % Escape HTML-sensitive chars
        txt = strrep(txt, '&', '&amp;');
        txt = strrep(txt, '<', '&lt;');
        txt = strrep(txt, '>', '&gt;');

        s = "<span>" + txt + "</span>";
        s = strjoin(string(s), "");
    end
end

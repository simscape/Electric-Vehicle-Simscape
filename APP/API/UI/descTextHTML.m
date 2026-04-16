function descHTML = descTextHTML(desc)
%DESCTEXTHTML Convert plain-text model description to styled HTML.

    % Replace line breaks with <br>
    descHTML = strrep(desc, newline, '<br>');

    % Convert markdown-style bold to HTML bold
    descHTML = regexprep(descHTML, '\*\*(.*?)\*\*', '<b>$1</b>');

    % Wrap in styled HTML
    descHTML = [ ...
        '<html><body style="font-size:14px; font-family:Helvetica;">' ...
        descHTML ...
        '</body></html>'];
end

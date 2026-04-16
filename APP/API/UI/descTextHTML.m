  function descHTML = descTextHTML(desc)
            % Replace line breaks with <br>
            descHTML = strrep(desc, newline, '<br>');

            % Optional: replace markdown-style bold with <b>...</b>
            descHTML = regexprep(descHTML, '\*\*(.*?)\*\*', '<b>$1</b>');

            % Wrap in HTML
            descHTML = ['<html><body style="font-size:14px; font-family:Helvetica;">' descHTML '</body></html>'];

        end
function showResult(app, text, lamp, success)
% SHOWRESULT Display text in results area and set lamp color.

    app.ResultsArea.Value = strsplit(char(text), newline)';

    if success
        lamp.Color = app.GREEN;
        lamp.Tooltip = 'Applied successfully';
    else
        lamp.Color = app.RED;
        lamp.Tooltip = 'Error — check results';
    end
end

function appendLog(app, msg)
% APPENDLOG Append a timestamped message to the results text area.

    ts = string(datetime('now', 'Format', 'HH:mm:ss'));
    line = ts + "  " + string(msg);
    existing = app.ResultsArea.Value;

    if isempty(existing) || (isscalar(existing) && existing{1} == "")
        app.ResultsArea.Value = {char(line)};
    else
        app.ResultsArea.Value = [existing; {char(line)}];
    end
end

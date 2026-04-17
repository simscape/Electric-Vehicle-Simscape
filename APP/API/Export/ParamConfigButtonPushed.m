function ParamConfigButtonPushed(app)
%PARAMCONFIGBUTTONPUSHED Validate param links, then export param script.
%   Thin orchestrator: delegates link validation to ensureParamLinks,
%   then exports via exportParamScript (which shows a save dialog).

    if ~ensureParamLinks(app), return; end

    try
        outFile = exportParamScript(app);
        if ~isempty(outFile), open(outFile); end
    catch ME
        uialert(app.UIFigure, ...
            sprintf('Export failed:\n\n%s', ME.message), ...
            'Error', 'Icon', 'error');
    end
end

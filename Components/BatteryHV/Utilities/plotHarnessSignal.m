function plotHarnessSignal(logsout, idx, titleStr, ylabelStr)
%plotHarnessSignal Plot a logged signal from simulation output.
%   plotHarnessSignal(LOGSOUT, IDX, TITLESTR, YLABELSTR) extracts element
%   IDX from LOGSOUT and plots its timeseries data.

    el = logsout.getElement(idx);
    figure
    plot(el.Values, 'LineWidth', 1.2)
    title(titleStr)
    ylabel(ylabelStr)
    grid on
end

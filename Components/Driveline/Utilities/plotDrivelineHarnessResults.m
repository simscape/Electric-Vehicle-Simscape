function plotDrivelineHarnessResults(logsout)
%plotDrivelineHarnessResults Plot all logged signals from DriveLineTestHarness.
%   plotDrivelineHarnessResults(LOGSOUT) creates one figure per logged
%   signal. Bus signals are expanded into individual sub-signal plots.
% Copyright 2026 The MathWorks, Inc.

    for k = 1:logsout.numElements
        el = logsout.getElement(k);
        vals = el.Values;

        if isa(vals, 'timeseries')
            figure
            plot(vals, 'LineWidth', 1.2)
            title(el.Name)
            xlabel('Time (s)')
            grid on

        elseif isstruct(vals)
            % Bus signal -- plot each field
            fn = fieldnames(vals);
            for m = 1:numel(fn)
                if isa(vals.(fn{m}), 'timeseries')
                    figure
                    plot(vals.(fn{m}), 'LineWidth', 1.2)
                    title([el.Name ' - ' fn{m}])
                    xlabel('Time (s)')
                    grid on
                end
            end
        end
    end
end

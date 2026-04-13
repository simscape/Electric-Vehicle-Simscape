function plotHeaterHarnessResults(logsout)
%plotHeaterHarnessResults Plot all logged signals from HeaterTestHarness.
%   plotHeaterHarnessResults(LOGSOUT) creates one figure per logged signal.

    signals = {
        'DC Input Voltage',          'Voltage (V)'
        'Heater Current',            'Current (A)'
        'Coolant Inlet Temperature', 'Temperature (K)'
        'Coolant Outlet Temperature','Temperature (K)'
    };

    for k = 1:size(signals, 1)
        el = logsout.getElement(signals{k, 1});
        figure
        plot(el.Values, 'LineWidth', 1.2)
        title(signals{k, 1})
        ylabel(signals{k, 2})
        xlabel('Time (s)')
        grid on
    end
end

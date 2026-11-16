function plotExtendedTorque(startingMotorTorqueVect,inputTRQDataStruct)
%plotExtendedTorque Plot simulated and extended motor torque profiles.
%   plotExtendedTorque(startingMotorTorqueVect, inputTRQDataStruct)
%   displays the electrical torque control simulation results and the
%   extended torque profiles for each torque setpoint.

% Copyright 2026 The MathWorks, Inc.

electricalTRQFig = figure(1); clf(electricalTRQFig);
tiledlayout(electricalTRQFig, 1, 1);
nexttile;
hold on; grid on;
title('Electrical Torque Control - Simulated Torque vs Time');
xlabel('Time (s)');
ylabel('Torque (N·m)');
extendedTRQFig = figure(2); clf(extendedTRQFig);
tiledlayout(extendedTRQFig, 1, 1);
nexttile;
hold on; grid on;
title('Extended Motor Torque Profile');
xlabel('Time (s)');
ylabel('Torque (N·m)');
nLevels = length(startingMotorTorqueVect);
legEntriesRaw = cell(1, nLevels);
legEntriesExt = cell(1, nLevels);

for i = 1:nLevels
    solutionTime = inputTRQDataStruct.timeCellMotor{i};
    motorTRQ = inputTRQDataStruct.motorTorqueCell{i};
    % Plot simulated torque vs time
    figure(electricalTRQFig);
    plot(solutionTime, motorTRQ, 'LineWidth', 1.6);
    legEntriesRaw{i} = sprintf('Setpoint = %.0f N·m', value(startingMotorTorqueVect(i)));

    % Plot extended profile in Figure 2
    timeVector_i = inputTRQDataStruct.timeCell{i};
    torqueVector_i = inputTRQDataStruct.EXTtorqueCell{i};
    figure(extendedTRQFig);
    plot(timeVector_i, torqueVector_i, 'LineWidth', 1.6);
    legEntriesExt{i} = sprintf('Setpoint = %.0f N·m', value(startingMotorTorqueVect(i)));
end

figure(electricalTRQFig);
legend(legEntriesRaw, 'Location', 'best');

figure(extendedTRQFig);
legend(legEntriesExt, 'Location', 'best');

end
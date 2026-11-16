function simulateOptlaunch(modelName, outputSignalName, options)
%simulateOptlaunch Compare optimized and baseline launch simulations.
%   simulateOptlaunch(modelName, outputSignalName) runs the model with
%   optimized and baseline gear ratios across scenario levels and plots
%   jerk and vehicle speed comparisons.

% Copyright 2026 The MathWorks, Inc.

arguments
    modelName {mustBeText}              % Simulink model name
    outputSignalName {mustBeText}       % Logged signal name for force output
    options.BaseXYZ (1,3) double = [3.75, 1.01, 3.0]  % Baseline [x, y, z] gear ratios
    options.BestXYZ (1,3) double = [3.75, 1.01, 3.0]  % Optimized [x, y, z] gear ratios
    options.StopTime {simscape.mustBeCommensurateUnit(options.StopTime,"s")} = simscape.Value(10,"s") % Simulation stop time
    options.ScenarioLevels struct = struct( ...   % Input scenarios (struct array with Name/Value)
        'Name', {"Low", "Mid", "High"}, ...
        'Value', {simscape.Value(50,"N*m"), simscape.Value(100,"N*m"), simscape.Value(150,"N*m")})
    options.InputLevelVarName {mustBeText} = "TRQTime"  % Workspace variable overridden per scenario
end

baseXYZ = options.BaseXYZ;
bestXYZ = options.BestXYZ;
stopTimeStr = string(value(options.StopTime,"s"));
scenarioLevels = options.ScenarioLevels;
inputLevelVarName = options.InputLevelVarName;

xOPT = bestXYZ(1);
yOPT = bestXYZ(2);
zOPT = bestXYZ(3);
xBase = baseXYZ(1);
yBase = baseXYZ(2);
zBase = baseXYZ(3);


K = numel(scenarioLevels);
rmsJerkOPT = zeros(1, K);
rmsJerkBase = zeros(1, K);
jerkOPTCell = cell(1, K);
jerkBaseCell = cell(1, K);
jerkTimeCell = cell(1, K);

forceFig = figure(1); clf(forceFig);
forceFig.Position = [10, 10, 800, 600];
velFig = figure(2); clf(velFig);
velFig.Position = [10, 10, 800, 400];
for k = 1:K
    levelVal = scenarioLevels(k).Value;
    simIn1 = Simulink.SimulationInput(modelName);
    simIn1 = simIn1.setBlockParameter(modelName+"/Flexible Driveline/Gear Transmission/Motor Pinion Ratio","ratio",string(xOPT));
    simIn1 = simIn1.setBlockParameter(modelName+"/Flexible Driveline/Gear Transmission/Counter Shaft Ratio","ratio",string(yOPT));
    simIn1 = simIn1.setBlockParameter(modelName+"/Flexible Driveline/Front wheel differential/Differential","cd_ratio",string(zOPT));
    simIn1 = simIn1.setVariable(inputLevelVarName, levelVal);

    simIn1 = simIn1.setModelParameter("StopTime", stopTimeStr);
    outOPT  = sim(simIn1);
    dsOPT   = outOPT.logsout;
    sig1OPT = dsOPT.get(outputSignalName);
    sig2OPT = dsOPT.get("V");
    forceOPT = sig1OPT.Values;
    velocity = sig2OPT.Values;

    simIn2 = Simulink.SimulationInput(modelName);
    simIn2 = simIn2.setVariable(inputLevelVarName, levelVal);
    simIn2 = simIn2.setBlockParameter(modelName+"/Flexible Driveline/Gear Transmission/Motor Pinion Ratio","ratio",string(xBase));
    simIn2 = simIn2.setBlockParameter(modelName+"/Flexible Driveline/Gear Transmission/Counter Shaft Ratio","ratio",string(yBase));
    simIn2 = simIn2.setBlockParameter(modelName+"/Flexible Driveline/Front wheel differential/Differential","cd_ratio",string(zBase));
    simIn2 = simIn2.setModelParameter("StopTime", stopTimeStr);
    outBase = sim(simIn2);
    dsBase  = outBase.logsout;
    sig1Base = dsBase.get(outputSignalName);
    sig2Base = dsBase.get("V");
    forceBase = sig1Base.Values;
    velocityBase = sig2Base.Values;

    jerkOPT  = gradient(forceOPT.Data, forceOPT.Time);
    jerkBase = gradient(forceBase.Data, forceBase.Time);
    jerkOPTCell{k}  = jerkOPT;
    jerkBaseCell{k}  = jerkBase;
    jerkTimeCell{k}  = forceOPT.Time;
    rmsJerkOPT(k)  = rms(jerkOPT);
    rmsJerkBase(k) = rms(jerkBase);

    tPad = 1;
    jerkTimeOPT  = [0; forceOPT.Time + tPad];
    jerkTimeBas  = [0; forceBase.Time + tPad];
    jerkOPTPad   = [0; jerkOPT];
    jerkBasePad  = [0; jerkBase];
    velTimeOPT   = [0; velocity.Time + tPad];
    velTimeBas   = [0; velocityBase.Time + tPad];
    velOPTPad    = [0; velocity.Data];
    velBasePad   = [0; velocityBase.Data];

    figure(forceFig)
    plot(jerkTimeOPT, jerkOPTPad);
    hold on; grid on;
    plot(jerkTimeBas, jerkBasePad);

    figure(velFig)
    plot(velTimeOPT, velOPTPad);
    hold on; grid on;
    plot(velTimeBas, velBasePad, '--');
end

figure(forceFig)
xlim([0 6]);
xlabel("Time [s]"); ylabel("Jerk [N/s]");
title("Jerk on Vehicle");
legend({"Optimized","Baseline"}, "Location", "best");
yLimits = ylim;
xregion(0, 1, 'FaceColor', [0.8 0.9 1.0], 'FaceAlpha', 0.4, 'HandleVisibility', 'off');
xregion(1, 2, 'FaceColor', [1.0 0.85 0.85], 'FaceAlpha', 0.4, 'HandleVisibility', 'off');
xregion(2, 6, 'FaceColor', [0.85 1.0 0.85], 'FaceAlpha', 0.4, 'HandleVisibility', 'off');
text(0.5, yLimits(2)*0.9, 'Vehicle Stationary', 'HorizontalAlignment', 'center', 'FontSize', 8, 'FontWeight', 'bold');
text(1.5, yLimits(2)*0.9, 'Launch Jerk', 'HorizontalAlignment', 'center', 'FontSize', 8, 'FontWeight', 'bold');
text(4.0, yLimits(2)*0.9, 'Steady Acceleration', 'HorizontalAlignment', 'center', 'FontSize', 8, 'FontWeight', 'bold');

levelNames = cellstr({scenarioLevels.Name});
rmsFig = figure(3); clf(rmsFig);
rmsFig.Position = [10, 10, 800, 400];
barData = [rmsJerkOPT; rmsJerkBase]';
bar(categorical(levelNames, levelNames), barData);
ylabel("RMS Jerk [N/s]");
title("RMS Jerk Comparison");
legend({"Optimized","Baseline"}, "Location", "best");
grid on;

figure(velFig)
xlabel("Time [s]"); ylabel("Speed [mph]");
title("Vehicle Speed Comparison");
legend({"Optimized","Baseline"}, "Location", "best");

end
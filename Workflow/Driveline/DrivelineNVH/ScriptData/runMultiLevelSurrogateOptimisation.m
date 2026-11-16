function bestXY = runMultiLevelSurrogateOptimisation(modelName,outputBlockPath,outputSignalName,options)
%runMultiLevelSurrogateOptimisation Optimize gear ratios to minimize jerk and maximize acceleration.
%   bestXY = runMultiLevelSurrogateOptimisation(modelName, outputBlockPath,
%   outputSignalName) uses surrogate optimization to find three gear ratio
%   parameters (motorToCS, CSToMS, finalDrive) that minimize a composite
%   objective of jerk RMS and inverse mean acceleration across multiple
%   input scenarios.

% Copyright 2026 The MathWorks, Inc.

arguments
    modelName {mustBeText}                  % Simulink model name
    outputBlockPath {mustBeText}            % Block path whose outport is logged
    outputSignalName {mustBeText}           % Logging name for the output signal
    options.SimulationTime {simscape.mustBeCommensurateUnit(options.SimulationTime,"s")} = simscape.Value(10,"s") % Stop time per simulation
    options.InputLevelVarName {mustBeText} = "TRQTime"  % Workspace variable overridden per scenario
    options.LowerBound (1,3) double = [2.5, 0.9, 2.0]   % Lower bounds for [x, y, z] gear ratios
    options.UpperBound (1,3) double = [5.0, 1.1, 4.0]  % Upper bounds for [x, y, z] gear ratios
    options.ScenarioLevels struct = struct( ...          % Input scenarios (struct array with Name/Value)
        'Name', {"Low", "Mid", "High"}, ...
        'Value', {simscape.Value(50,"N*m"), simscape.Value(100,"N*m"), simscape.Value(150,"N*m")})
    options.InitialPoints (1,3) double = [3.75, 1.01, 3.0] % Starting point for surrogate optimizer
    options.ObjectiveWeights (1,2) double {mustBeNonnegative} = [0.7, 0.3] % [jerk, acceleration] weights in composite objective
    options.JerkReferenceValue (1,1) double {mustBePositive} = 1e3   % Normalization reference for jerk metric
    options.AccelReferenceValue (1,1) double {mustBePositive} = 10   % Normalization reference for mean acceleration (m/s^2)
    options.VehicleMass (1,1) double {mustBePositive} = 1000         % Vehicle mass (kg) for acceleration computation
    options.MaximumSimulations (1,1) double {mustBePositive, mustBeInteger} = 100 % Max function evaluations for surrogateopt
    options.AggregationWeights (1,:) double {mustBePositive} = [1, 1, 1] % Weighted-mean weights across scenario levels
    options.FixedTimeStep (1,1) double {mustBePositive} = 1e-4 % Fixed solver time step (s)
end

    simulationTime = string(value(options.SimulationTime,"s"));
    inputLevelVarName = options.InputLevelVarName;
    lowerBound = options.LowerBound;
    upperBound = options.UpperBound;
    scenarioLevels = options.ScenarioLevels;
    
    %% ---- PREPARE MODEL & LOGGING ----
    load_system(modelName);
    
    % Enable signal logging to logsout (Dataset format)
    set_param(modelName, 'SignalLogging', 'on');
    set_param(modelName, 'SignalLoggingName', 'logsout');
    set_param(modelName, 'SignalLoggingSaveFormat', 'Dataset');
    
    % Ensure the desired output is marked for logging and named consistently
    ensureSignalLogged(outputBlockPath, outputSignalName);
    
    % Fixed-step solver for faster simulation
    set_param(modelName, 'SolverType', 'Fixed-step');
    set_param(modelName, 'Solver', 'ode3');
    set_param(modelName, 'FixedStep', string(options.FixedTimeStep));

    % Set Simscape local solver to the same time step
    solverBlks = find_system(modelName, 'MatchFilter', @Simulink.match.allVariants, ...
        'ReferenceBlock', 'nesl_utility/Solver Configuration');
    stepStr = string(options.FixedTimeStep);
    for i = 1:numel(solverBlks)
        set_param(solverBlks{i}, 'LocalSolverSampleTime', stepStr);
    end

    % Accelerator mode and Fast Restart speed up repeated simulations
    set_param(modelName, 'SimulationMode', 'accelerator');
    set_param(modelName, 'FastRestart', 'on');
    cleanupObj = onCleanup(@() cleanupModel(modelName));

%% ---- SURROGATE OPTIMIZATION ----
    opts = optimoptions('surrogateopt', ...
        'UseParallel', false, ...
        'PlotFcn', 'surrogateoptplot', ...
        'MaxFunctionEvaluations', options.MaximumSimulations, ...
        'InitialPoints', options.InitialPoints, ...
        'Display', 'off');
    
    obj = @(vars) computeCompositeObjective(vars, modelName, outputSignalName, simulationTime, ...
        scenarioLevels, inputLevelVarName, ...
        options.AggregationWeights, options.ObjectiveWeights, ...
        options.JerkReferenceValue, options.AccelReferenceValue, options.VehicleMass);
    
    [bestXY, fval, exitflag, output] = surrogateopt(obj, lowerBound, upperBound, opts);

%% ---- REPORT ----
    displayOptimizedGearRatios(bestXY);
    fprintf('Composite objective (jerk w=%.2f, accel w=%.2f) = %.6g\n', ...
        options.ObjectiveWeights(1), options.ObjectiveWeights(2), fval);
    fprintf('Exit flag: %d\n', exitflag);
    disp(output);
end

%% ================== HELPER FUNCTIONS ==================

function ensureSignalLogged(blockPath, signalName)
    % Ensure the outport of the given block is marked for Signal Logging
    % and set its logging name to `signalName`.
    
    try
        get_param(blockPath, 'Handle');
    catch ME
        error('runMultiLevelSurrogateOptimisation:BlockNotFound', ...
            'Block path "%s" not found. Verify outputBlockPath.\n  Cause: %s', ...
            blockPath, ME.message);
    end
    
    ph = get_param(blockPath, 'PortHandles');
    if isempty(ph) || ~isfield(ph, 'Outport') || isempty(ph.Outport)
        error('Block "%s" has no Outport to log. Specify a block with an Outport.', blockPath);
    end
    
    outp = ph.Outport(1); % first outport
    set_param(outp, 'DataLogging', 'on');
    set_param(outp, 'DataLoggingName', signalName);
    
    % Optional quality-of-life settings
    % set_param(outp, 'DataLoggingDecimation', '1');   % log every sample
    % set_param(outp, 'DataLoggingLimitDataPoints', 'off');
    
    fprintf('Signal logging enabled on "%s" with name "%s".\n', blockPath, signalName);
end


function valueOfObjFunc = computeCompositeObjective(vars, modelName, outputSignalName, stopTimeStr, ...
    scenarioLevels, inputLevelVarName, weights, ...
    objectiveWeights, jerkRefValue, accelRefValue, vehicleMass)
% Evaluate model at multiple input levels and compute a weighted composite
% of normalized jerk metric and mean vehicle acceleration.

    PENALTY = 1e6;
    
    x = vars(1);
    y = vars(2);
    z = vars(3);
    
    K = numel(scenarioLevels);
    
    % Run scenarios sequentially
    jerkPerLevel = nan(1, K);
    meanAccelPerLevel = nan(1, K);
    % load

    for k = 1:K
        simIn = Simulink.SimulationInput(modelName);
        simIn = simIn.setVariable('motorToCSGearRatio', x);
        simIn = simIn.setVariable('CSToMSGearRatio', y);
        simIn = simIn.setVariable('finalDriveGearRatio', z);
        simIn = simIn.setVariable(inputLevelVarName, scenarioLevels(k).Value);
        simIn = simIn.setModelParameter('StopTime', stopTimeStr);
        
        try
            out = sim(simIn);
            ds  = out.logsout;
            sig = ds.get(outputSignalName);
    
            if isempty(sig)
                warning('logsout does not contain signal "%s" (level "%s"). Applying penalty.', ...
                    outputSignalName, scenarioLevels(k).Name);
                jerkPerLevel(k) = PENALTY;
                meanAccelPerLevel(k) = 0;
                continue;
            end
    
            ts    = sig.Values;
            ydata = double(ts.Data(:));
            t     = double(ts.Time(:));
    
            if numel(ydata) < 3 || numel(t) ~= numel(ydata)
                jerkPerLevel(k) = PENALTY;
                meanAccelPerLevel(k) = 0;
                continue;
            end
    
            jerkPerLevel(k) = computePSDJerkMetric(ydata, t);
            meanAccelPerLevel(k) = mean(abs(ydata)) / vehicleMass;
    
            if ~isfinite(jerkPerLevel(k))
                jerkPerLevel(k) = PENALTY;
            end
            if ~isfinite(meanAccelPerLevel(k))
                meanAccelPerLevel(k) = 0;
            end
    
        catch ME
            warning('Simulation failed at level "%s": %s', scenarioLevels(k).Name, ME.message);
            jerkPerLevel(k) = PENALTY;
            meanAccelPerLevel(k) = 0;
        end
    end
    
    % Aggregate each metric across levels (weighted mean)
    jerkAgg = aggregateAcrossLevels(jerkPerLevel, weights);
    accelAgg = aggregateAcrossLevels(meanAccelPerLevel, weights);
    
    % Normalize and combine: minimize jerk, maximize acceleration
    wJerk  = objectiveWeights(1);
    wAccel = objectiveWeights(2);
    valueOfObjFunc = wJerk * (jerkAgg / jerkRefValue) + wAccel * (accelRefValue / accelAgg);
    
    if ~isfinite(valueOfObjFunc)
        valueOfObjFunc = PENALTY;
    end
end


function aggValue = aggregateAcrossLevels(metricPerLevel, weights)
% Weighted mean of per-level metric vector.

    if numel(weights) ~= numel(metricPerLevel)
        error('AggregationWeights length (%d) must match number of levels (%d).', ...
            numel(weights), numel(metricPerLevel));
    end
    aggValue = sum(weights(:) .* metricPerLevel(:)) / sum(weights);
end


function jerkMetric = computePSDJerkMetric(ydata, t)
% Compute jerk metric as the square root of integrated PSD of the signal
% derivative. This captures oscillatory content relevant to NVH.

    % Resample to uniform time grid for FFT
    dt_median = median(diff(t));
    tUniform  = (t(1):dt_median:t(end))';
    yUniform  = interp1(t, ydata, tUniform, 'linear');
    
    N  = numel(yUniform);
    fs = 1 / dt_median;
    
    % Compute derivative in frequency domain (jerk = d/dt of force signal)
    Y    = fft(yUniform);
    freq = (0:N-1)' * (fs / N);
    jw   = 1i * 2 * pi * freq;
    Ydot = Y .* jw;
    
    % One-sided PSD of the derivative
    psdTwoSided = (abs(Ydot).^2) / (fs * N);
    psdOneSided = 2 * psdTwoSided(1:floor(N/2)+1);
    freqOneSided = freq(1:floor(N/2)+1);
    
    % Integrate full-spectrum PSD
    jerkMetric = sqrt(trapz(freqOneSided, psdOneSided));
end


function displayOptimizedGearRatios(bestXY)
% Display optimized gear ratios in a formatted table.

    resultTable = table(bestXY(:), ...
        'VariableNames', "Optimized Gear Ratio", ...
        'RowNames', ["Motor Shaft to Counter Shaft", "Counter Shaft to Main Shaft", "Final Drive Ratio"]);
    fprintf('\n=== Surrogate optimization complete ===\n');
    disp(resultTable);
    end
    
    
    function cleanupModel(modelName)
    % Restore simulation settings and close the model on normal or error exit.
    try
        set_param(modelName, 'FastRestart', 'off');
    catch
    end
    try
        set_param(modelName, 'SimulationMode', 'normal');
    catch
    end
    try
        bdclose(modelName);
    catch
    end
end
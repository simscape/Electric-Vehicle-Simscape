function[EXTNTime,EXTNTRQ] = extendMotorTorque(varVector,timeVector,extensionDuration,portionDuration)
%extendMotorTorque Extend a torque signal by repeating its tail portion.
%   [ext_time, ext_signal] = extendMotorTorque(varVector, timeVector,
%   extensionDuration, portionDuration) extends the input signal to the
%   desired total duration by cyclically repeating the last portionDuration
%   seconds of data.

% Copyright 2026 The MathWorks, Inc.

signal = varVector;
time   = timeVector;
         
% --- User inputs ---
desiredDuration  = extensionDuration + portionDuration;% seconds (final target duration)                    

% Preserve original orientation (row vs column)
sigIsRow  = isrow(signal);
timeIsRow = isrow(time);

signal = signal(:);   % work as columns internally
time   = time(:);

% --- Basic validations ---
if length(signal) ~= length(time)
    error('Signal and time must be the same length.');
end
if any(~isfinite(time)) || any(~isfinite(signal))
    error('Signal and time must contain finite values.');
end
if any(diff(time) <= 0)
    error('Time vector must be strictly increasing.');
end

% --- Durations and targets ---
t0               = time(1);
t_end            = time(end);
% originalDuration = t_end - t0;
target_end_time   = t0+desiredDuration;

% --- If the target is within the original duration, just trim ---
if target_end_time <= t_end
    % Keep samples up to the last time <= target_end_time
    idx_keep = time <= target_end_time;
    EXTNTime   = time(idx_keep);
    EXTNTRQ = signal(idx_keep);
else
    % --- Keep original as-is ---
    EXTNTime   = time;
    EXTNTRQ = signal;

    % --- Pick the portion from the END based on time ---
    portion_start_time = t_end - portionDuration;
    portion_idx        = find(time >= portion_start_time);
    if numel(portion_idx) < 2
        error(['portionDuration (%.3f s) yields fewer than 2 samples in the ' ...
               'selected portion. Increase portionDuration or verify data density.'], ...
              portionDuration);
    end

    portion_time   = time(portion_idx);
    portion_signal = signal(portion_idx);

    % --- Build the repeat pattern using the portion's internal spacings ---
    % We avoid duplicating t_end by starting from the SECOND sample of the portion
    pattern_dt      = diff(portion_time);    % time steps within the portion
    pattern_values  = portion_signal(2:end); % corresponding values

    % --- Append repeats until we reach the desired end time ---
    t_curr = EXTNTime(end);
    while t_curr < target_end_time
        appended_any = false;
        for j = 1:numel(pattern_dt)
            t_next = t_curr + pattern_dt(j);
            if t_next > target_end_time
                break;  % stop before exceeding the target time
            end
            EXTNTime(end+1,1)   = t_next;
            EXTNTRQ(end+1,1) = pattern_values(j);
            t_curr = t_next;
            appended_any = true;
        end
        if ~appended_any
            % Remaining gap is smaller than the first dt; cannot append more without exceeding target
            break;
        end
    end
end

% --- Resample to 1 ms uniform grid to reduce file size ---
dtResample = 1e-3;
tUniform = (EXTNTime(1):dtResample:EXTNTime(end))';
trqUniform = interp1(EXTNTime, EXTNTRQ, tUniform, 'linear');
EXTNTime = tUniform;
EXTNTRQ = trqUniform;
if sigIsRow,  EXTNTRQ = EXTNTRQ.'; end
if timeIsRow, EXTNTime = EXTNTime.'; end

% --- (Optional) Plot ---
figure;
plot(EXTNTime - t0, EXTNTRQ);
grid on;
xlabel('Time (s)');
ylabel('Torque (N*m)');
title('Original + Repeating Torque Appended');

% --- Save result ---
save(fullfile(fileparts(mfilename('fullpath')), 'extendedMotorTorque.mat'), 'EXTNTime', 'EXTNTRQ');
end

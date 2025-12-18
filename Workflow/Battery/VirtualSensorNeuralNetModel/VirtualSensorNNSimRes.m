%% Battery measurement data processing for neural network
% This function converts input data into a timeseries defined by constant
% time step of 'ts' seconds. 

% Copyright 2023 The MathWorks, Inc.

function training = VirtualSensorNNSimRes(ts,battSensorData)
    current       = sum(battSensorData.Current,2)/size(battSensorData.Current,2);
    voltage       = sum(battSensorData.Cellvolt,2);
    temperature   = sum(battSensorData.temp,2)/size(battSensorData.temp,2);
    stateOfCharge = sum(battSensorData.SoC,2)/size(battSensorData.SoC,2);
    time          = battSensorData.Time;
    %
    training.time          = 1:ts:round(time2num(time(end)),0);
    training.current       = interp1(time2num(time)',current',training.time);
    training.voltage       = interp1(time2num(time)',voltage',training.time);
    training.stateOfCharge = interp1(time2num(time)',stateOfCharge',training.time);
    training.temperature   = interp1(time2num(time)',temperature',training.time);
    training.tsNeuralNet   = ts;
end
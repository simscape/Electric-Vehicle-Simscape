%% Battery neural network calculation and function calls

% Copyright 2023 The MathWorks, Inc.

function result = BatteryNeuralNetVerify(network,cellArrayNARX_X,cellArrayNARX_Y)
    [pv,Piv,Aiv,~] = preparets(network,cellArrayNARX_X,{},cellArrayNARX_Y);
    result         = network(pv,Piv,Aiv);
end
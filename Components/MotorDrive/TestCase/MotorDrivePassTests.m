classdef MotorDrivePassTests < matlab.unittest.TestCase
    %% Class implementation of unit test

    % Copyright 2025 The MathWorks, Inc.

    %% Simple tests ... just run runnables


    %% Harness folder
    methods (Test)
        function TestModel(~)
            model = 'MotorTestHarness';
            load_system(model)
            MotorTestHarnessParams;
            sim(model, 'SrcWorkspace', 'current');
        end
    end
end  % classdef

classdef ChargerPassTests < matlab.unittest.TestCase
    %% Class implementation of unit test
    %
    % These are tests to achieve the Minimum Quality Criteria (MQC).
    % MQC is achieved when all runnables (models, scripts, functions) run
    % without any errors.
    %
    % You can run this test by opening in MATLAB Editor and clicking
    % Run Tests button or Run Current Test button.
    % You can also run this test using test runner (*_runtests.m)
    % which can not only run tests but also generates summary and
    % measures code coverage report.

    % Copyright 2021-2023 The MathWorks, Inc.

    %% Test combinations of battery models and simulation cases

    methods (Test)
        function TestModel(~)
            model = 'ChargerTestHarness';
            load_system(model)
            ChargerTestHarnessParams;
            sim(model, 'SrcWorkspace', 'current');
        end


    end

end  % classdef

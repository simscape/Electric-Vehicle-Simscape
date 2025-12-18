classdef BatteryHeaterPassTests < matlab.unittest.TestCase
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

    % Copyright 2024 The MathWorks, Inc.

    %% Test combinations of battery models and simulation cases

    %% Simple tests ... just run runnables
    % properties (TestParameter)
    %   SimCases = {
    %     TestBench_Driveline_With_Braking
    %     TestBench_Driveline_Without_Braking
    %     }
    %   Model = {
    %       Driveline
    %       DrivelineWithBraking
    %       }
    % end

    methods (Test)
        function TestModel(~)
            model = 'HeaterTestHarness';
            load_system(model)
            HeaterTestHarnessParams;
            sim(model, 'SrcWorkspace', 'current');
        end 
        % function TestMLX(~,SimCases)
        %       SimCases;
        % end% function
    end  % methods



    % methods

end  % classdef

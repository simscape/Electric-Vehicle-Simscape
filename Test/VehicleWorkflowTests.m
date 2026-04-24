classdef VehicleWorkflowTests < BaseTest
    % The test class runs the live scripts and models of Vehicle Workflows
    % to make sure that they run without any error or warning.

    % Copyright 2023-2026 The MathWorks, Inc.
    methods (Test)

        function test_BEVrangeNEDCscript(test)
            % The test runs the function under test and makes sure that
            % there are no errors or warning thrown
            test.verifyWarningFree(@()run_BEVrangeEstimationNEDC, "'NEDC range script'  should execute wihtout any warning or error.");
        end

        function test_BEVrangeWLTCscript(test)
            % The test runs the function under test and makes sure that
            % there are no errors or warning thrown
            test.verifyWarningFree(@()run_BEVrangeEstimationWLTC, "'WLTC range script'  should execute wihtout any warning or error.");
        end

        function MLXBEVRangeEstimation(test)
            %The test runs the |.mlx| file and makes sure that there are
            %no errors or warning thrown.
            test.verifyWarningFree(@()runRangeEstimation, "'BEVRangeEstimationMain mlx'  should execute wihtout any warning or error.");
            test.addTeardown(@()close_system('BEVsystemModel', 0));
        end
    end
end

function run_BEVrangeEstimationNEDC()
% Function runs the |.m| script.
BEVrangeEstimationNEDC;
end

function run_BEVrangeEstimationWLTC()
% Function runs the |.m| script.
BEVrangeEstimationWLTC;
end

function runRangeEstimation()
% Function runs the |.mlx| script.
BEVRangeEstimationMain;
end

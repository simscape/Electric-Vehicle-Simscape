classdef BatteryWorkflowTests < BaseTest
    % The test class runs the live scripts and models of Vehicle Workflows
    % to make sure that they run without any error or warning.

    % Copyright 2024-2026 The MathWorks, Inc.
    methods (Test)
        function MLXVirtualSensorNeuralNetModel(test)
            %The test runs the |.mlx| file and makes sure that there are
            %no errors or warning thrown.
            test.verifyWarningFree(@()runVirtualSensorNeuralNetModel, "'VirtualSensorNeuralNetModel mlx'  should execute wihtout any warning or error.");
            test.addTeardown(@()close_system('BatteryTestHarness', 0));

        end

        function MLXBatterySizing(test)
            %The test runs the |.mlx| file and makes sure that there are
            %no errors or warning thrown.
            test.verifyWarningFree(@()runBatterySizing, "'BEVRangeEstimationMain mlx'  should execute wihtout any warning or error.");
            test.addTeardown(@()close_system('BEVsystemModel', 0));

        end

        function test_BEVbatterySizingscript(test)
            % The test runs the function under test and makes sure that
            % there are no errors or warning thrown
            test.verifyWarningFree(@()run_BEVbatterySizing, "'Battery Sizing script'  should execute wihtout any warning or error.");
        end

    end

end  % classdef

function runVirtualSensorNeuralNetModel()
% Function runs the |.mlx| script.
VirtualSensorNeuralNetModel;
end

function runBatterySizing()
% Function runs the |.mlx| script.
BEVBatterySizingMain;
end

function run_BEVbatterySizing()
% Function runs the |.m| script.
BEVbatterySizing;
end

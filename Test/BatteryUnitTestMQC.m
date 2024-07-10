classdef BatteryUnitTestMQC < matlab.unittest.TestCase
    %% Class implementation of unit test

    % Copyright 2024 The MathWorks, Inc.

    properties
        openfigureListBefore;
    end

    methods(TestMethodSetup)
        function listOpenFigures(test)
            % List all open figures
            test.openfigureListBefore = findall(0,'Type','Figure');
        end

        function setupWorkingFolder(test)
            % Set up working folder
            import matlab.unittest.fixtures.WorkingFolderFixture;
            test.applyFixture(WorkingFolderFixture);
        end
    end

    methods (Test)
        function CellCharacterizationHPPCModel(testCase)
            mdl = "CellCharacterizationHPPC";
            load_system(mdl)
            testCase.addTeardown(@()close_system(mdl,0));
            sim(mdl);
        end

        function CellCharacterizationVerifyModel(testCase)
            mdl = "CellCharacterizationVerify";
            load_system(mdl)
            testCase.addTeardown(@()close_system(mdl,0));
            sim(mdl);
        end

        function MLXCellCharacterizationForBEV(test)
            %The test runs the |.mlx| file and makes sure that there are
            %no errors or warning thrown.
            test.verifyWarningFree(@()runCellCharacterizationForBEV, "'CellCharacterizationForBEV mlx'  should execute wihtout any warning or error.");
        end

        function MLXBatteryNeuralNetModel(test)
            %The test runs the |.mlx| file and makes sure that there are
            %no errors or warning thrown.
            test.verifyWarningFree(@()runBatteryNeuralNetModel, "'BatteryNeuralNetModel mlx'  should execute wihtout any warning or error.");
        end
    end

end  % classdef

function runCellCharacterizationForBEV()
    % Function runs the |.mlx| script.
    CellCharacterizationForBEV;
end

function runBatteryNeuralNetModel()
    % Function runs the |.mlx| script.
    BatteryNeuralNetModel;
end

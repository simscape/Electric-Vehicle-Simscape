classdef PMSMtestbenchRunScriptsTest < matlab.unittest.TestCase
    % The test class runs the scripts and functions to make sure that they
    % run without any error or warning.

    % Copyright 2023 The MathWorks, Inc.

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

        function test_PMSMcountEqTestFunction(test)
            % The test runs the function under test and makes sure that
            % there are no errors or warning thrown
            test.verifyWarningFree(@()countEqTest(67.5), "'PMSMcountEqTest'  should execute wihtout any warning or error.");
        end

        function test_PMSMgetDutyLifeFunction(test)
            % The test runs the function under test and makes sure that
            % there are no errors or warning thrown
            test.verifyWarningFree(@()getDutyLife(67.5, 0.2, 108.3), "'PMSMgetDutyLife'  should execute wihtout any warning or error.");
        end

        function test_PMSMgetLossFunction(test)
            % The test runs the function under test and makes sure that
            % there are no errors or warning thrown
            test.verifyWarningFree(@()getLossTable(10,500,298.15,60000), "'PMSMgetLoss'  should execute wihtout any warning or error.");
        end

        function test_PMSMrunInverterLifeFunction(test)
            % The test runs the function under test and makes sure that
            % there are no errors or warning thrown
            test.verifyWarningFree(@()runInverterLife("FTP75"), "'PMSMrunInverterLife'  should execute wihtout any warning or error.");
        end

        function test_PMSMtestBenchDuraRunFunction(test)
            % The test runs the function under test and makes sure that
            % there are no errors or warning thrown
            LSHT = [0 0;1 5; 2 10; 3 15; 4 20; 5 20];
            HSLT = [0 0;1 30; 2 60; 3 90; 4 120; 5 120];
            assignin('base', "LSHT", LSHT);
            assignin('base', "HSLT", HSLT);
            driveTest= ["LSHT" "HSLT"];
            test.verifyWarningFree(@()testBenchDuraRun(50,driveTest), "'PMSMrunInverterLife'  should execute wihtout any warning or error.");
        end

        function test_PMSMtestBenchRunAndPlotFunction(test)
            % The test runs the function under test and makes sure that
            % there are no errors or warning thrown.
            test.verifyWarningFree(@()testThermalBenchRun(3.4,"FTP75",400), "'PMSMtestBenchRun'  should execute wihtout any warning or error.");
            test.verifyWarningFree(@()plotMotTemperature("FTP75",3.4), "'PMSMplotMotTemperature'  should execute wihtout any warning or error.");
        end
    end

    methods(TestMethodTeardown)
        function closeOpenedFigures(test)
            % Close all figure opened during test
            figureListAfter = findall(0,'Type','Figure');
            figuresOpenedByTest = setdiff(figureListAfter, test.openfigureListBefore);
            arrayfun(@close, figuresOpenedByTest);
        end
    end
end
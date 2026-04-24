classdef MotorDriveWorkflowTests < BaseTest
    % The test class runs the scripts, models and functions of MotorDrive 
    % Workflows to make sure that they run without any error or warning.

    % Copyright 2023-2026 The MathWorks, Inc.
    methods (Test)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%MOTOR DRIVE : GEAR RATIO SELECT
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function test_PMSMtestBenchRunAndPlotFunction(test)
            % The test runs the function under test and makes sure that
            % there are no errors or warning thrown.
            test.verifyWarningFree(@()testThermalBenchRun(3.4,"FTP75",400), "'PMSMtestBenchRun'  should execute wihtout any warning or error.");
            test.verifyWarningFree(@()plotMotTemperature("FTP75",3.4), "'PMSMplotMotTemperature'  should execute wihtout any warning or error.");
        end

        function runMinimumRequiredGearRatioMLX(test)
            %The test runs the |.mlx| file and makes sure that there are
            %no errors or warning thrown.
            test.verifyWarningFree(@()runMinimumRequiredGearRatio, "'minimumRequiredGearRatio mlx'  should execute wihtout any warning or error.");
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%MOTOR DRIVE : GENEREATE MOTOR INVERTER LOSS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function test_PMSMgetLossFunction(test)
            % The test runs the function under test and makes sure that
            % there are no errors or warning thrown
            test.verifyWarningFree(@()getLossTable(10,500,298.15,60000), "'getLossTable'  should execute wihtout any warning or error.");
        end

        function PMSMfocControlLossMapGenModel(testCase)
            mdl = "PMSMfocControlLossMapGen";
            load_system(mdl)
            testCase.addTeardown(@()close_system(mdl,0));
            sim(mdl);
        end

        function runGenerateDULossMapMLX(test)
            %The test runs the |.mlx| file and makes sure that there are
            %no errors or warning thrown.
            test.verifyWarningFree(@()runGenerateDULossMap, "'GenerateDULossMap mlx'  should execute wihtout any warning or error.");
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%MOTOR DRIVE : INVERTER LIFE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function test_PMSMcountEqTestFunction(test)
            % The test runs the function under test and makes sure that
            % there are no errors or warning thrown
            test.verifyWarningFree(@()countEqTest(67.5), "'countEqTest'  should execute wihtout any warning or error.");
        end

        function test_PMSMgetDutyLifeFunction(test)
            % The test runs the function under test and makes sure that
            % there are no errors or warning thrown
            test.verifyWarningFree(@()getDutyLife(67.5, 0.2, 108.3), "'getDutyLife'  should execute wihtout any warning or error.");
        end

        function test_PMSMrunInverterLifeFunction(test)
            % The test runs the function under test and makes sure that
            % there are no errors or warning thrown
            test.verifyWarningFree(@()runInverterLife("FTP75"), "'inverterPowerModuleLife'  should execute wihtout any warning or error.");
        end

        function InverterTestCycleModel(testCase)
            mdl = "InverterTestCycle";
            load_system(mdl)
            testCase.addTeardown(@()close_system(mdl,0));
            sim(mdl);
        end

        function runInverterPowerModuleLifeMLX(test)
            %The test runs the |.mlx| file and makes sure that there are
            %no errors or warning thrown.
            test.verifyWarningFree(@()runInverterPowerModuleLife, "'inverterPowerModuleLife mlx'  should execute wihtout any warning or error.");
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%MOTOR DRIVE : THERMAL DURABILITY
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function test_PMSMtestBenchDuraRunFunction(test)
            % The test runs the function under test and makes sure that
            % there are no errors or warning thrown
            LSHT = [0 0;1 5; 2 10; 3 15; 4 20; 5 20];
            HSLT = [0 0;1 30; 2 60; 3 90; 4 120; 5 120];
            assignin('base', "LSHT", LSHT);
            assignin('base', "HSLT", HSLT);
            driveTest= ["LSHT" "HSLT"];
            test.verifyWarningFree(@()testBenchDuraRun(50,driveTest), "'DUThermalDurability'  should execute wihtout any warning or error.");
        end


        function runDUThermalDurabilityMLX(test)
            %The test runs the |.mlx| file and makes sure that there are
            %no errors or warning thrown.
            test.verifyWarningFree(@()runDUThermalDurability, "'DUThermalDurability mlx'  should execute wihtout any warning or error.");
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%TEST MODEL FOR THERMAL DURABILITY\GEAR SELECT RATIO
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function MotorDriveThermalTestbenchModel(testCase)
            mdl = "MotorDriveThermalTestbench";
            load_system(mdl)
            testCase.addTeardown(@()close_system(mdl,0));
            sim(mdl);
        end
    end
end

function runMinimumRequiredGearRatio()
% Function runs the |.mlx| script.
minimumRequiredGearRatio;
end

function runGenerateDULossMap()
% Function runs the |.mlx| script.
generateDULossMap;
end

function runInverterPowerModuleLife()
% Function runs the |.mlx| script.
inverterPowerModuleLife;
end

function runDUThermalDurability()
% Function runs the |.mlx| script.
DUThermalDurability;
end

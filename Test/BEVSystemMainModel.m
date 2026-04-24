classdef BEVSystemMainModel < BaseTest
    % The test class runs the different vehicle configs of BEV System Main 
    % model to make sure that they run without any error or warning.

    % Copyright 2023-2026 The MathWorks, Inc.
    properties
        Model = "BEVsystemModel";
    end

    methods(TestMethodSetup)
        % These functions will be executed before each test point runs
        function setupModel(testCase)
            load_system(testCase.Model)
            testCase.addTeardown(@()close_system(testCase.Model, 0));
        end
    end

    methods (Test)
        function Default(testCase)
            sim(testCase.Model);
        end

        function PlantAbstract(testCase)
            SetupPlantAbstract
            sim(testCase.Model);
        end

        function PlantElectroThermal(testCase)
            SetupPlantElectroThermal
            sim(testCase.Model);
        end

        function PlantBatteryTable(testCase)
            SetupPlantElectroThermal
            set_param('BEVsystemModel/Vehicle/Battery', 'ReferencedSubsystem', 'BatteryTableBased')
            sim(testCase.Model);
        end
    end
end

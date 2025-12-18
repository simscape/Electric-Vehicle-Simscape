classdef BEVSystemMainModel < matlab.unittest.TestCase
    %% Class implementation of unit test

    % Copyright 2023-2025 The MathWorks, Inc.

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

    methods(TestMethodTeardown)
        function closeOpenedFigures(testCase)
            % Close all figure opened during test
            figureListAfter = findall(0,'Type','Figure');
            figuresOpenedByTest = setdiff(figureListAfter, testCase.openfigureListBefore);
            arrayfun(@close, figuresOpenedByTest);
            bdclose all
        end
    end

    methods (Test)


        %% Harness folder

        function Default(testCase)
            mdl = "BEVsystemModel";
            load_system(mdl)
            testCase.addTeardown(@()close_system(mdl, 0));
            sim(mdl);

        end

        function PlantAbstract(testCase)
            mdl = "BEVsystemModel";
            load_system(mdl)
            SetupPlantAbstract
            testCase.addTeardown(@()close_system(mdl, 0));
            sim(mdl);

        end


        function PlantElectroThermal(testCase)
            mdl = "BEVsystemModel";
            load_system(mdl)
            SetupPlantElectroThermal
            testCase.addTeardown(@()close_system(mdl, 0));
            sim(mdl);

        end        

        function PlantBatteryTable(testCase)
            mdl = "BEVsystemModel";
            load_system(mdl)
            SetupPlantElectroThermal
            set_param('BEVsystemModel/Vehicle/Battery', 'ReferencedSubsystem', 'BatteryTableBased')
            testCase.addTeardown(@()close_system(mdl, 0));
            sim(mdl);

        end

    end

end  % classdef





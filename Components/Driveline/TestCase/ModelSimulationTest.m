classdef ModelSimulationTest < matlab.unittest.TestCase
    % Test to check model simulation.

    % Copyright 2026 The MathWorks, Inc.

    properties
        workingFolderFixture;
        openfigureListBefore;
        openModelsBefore;
    end

    methods (TestClassSetup)

        function setupWorkingFolder(testCase)
            % Set up working folder
            import matlab.unittest.fixtures.WorkingFolderFixture;
            testCase.workingFolderFixture = testCase.applyFixture(WorkingFolderFixture);
        end

        function suppressWarning_AutoSoftwareOpenGL(testCase)
            % Suppress known warnings
            import matlab.unittest.fixtures.SuppressedWarningsFixture
            testCase.applyFixture(SuppressedWarningsFixture("MATLAB:hg:AutoSoftwareOpenGL"))
        end

        function addProjectToMatlabPath(testCase)
            % Add project on the matlab path
            import matlab.unittest.fixtures.PathFixture
            testCase.applyFixture(PathFixture(currentProject().RootFolder, "IncludeSubfolders",true));
        end

    end

    methods(TestMethodSetup)

        function listOpenFigures(testCase)
            % List all open figures
            testCase.openfigureListBefore = findall(0,'Type','Figure');
        end

        function listOpenModels(testCase)
            % List all open simulink models
            testCase.openModelsBefore = get_param(Simulink.allBlockDiagrams('model'),'Name');
        end

    end

    methods(TestMethodTeardown)

        function closeOpenedFigures(testCase)
            % Close all figure opened during test
            figureListAfter = findall(0,'Type','Figure');
            figuresOpenedByTest = setdiff(figureListAfter, testCase.openfigureListBefore);
            arrayfun(@close, figuresOpenedByTest);
        end

        function closeOpenedModels(testCase)
            % Close all models opened during test
            openModelsAfter = get_param(Simulink.allBlockDiagrams('model'),'Name');
            modelsOpenedByTest = setdiff(openModelsAfter, testCase.openModelsBefore);
            close_system(modelsOpenedByTest, 0);
        end

    end

    methods (Test)

        function TestMechanicalDLTorsionOrderMap(testCase)
            % The check the "BuildingTestHarness" model for warnings and/or
            % errors.

            mdl = "mechanicalDLTorsionOrderMap";
            load_system(mdl)
            testCase.addTeardown(@()close_system(mdl,0));

            testCase.verifyWarningFree(@()sim(mdl), 'Model should run without warnings or errors.');
        end

         function TestMotorDrivelineElectricalTRQControl(testCase)
            % The check the "BuildingTestHarness" model for warnings and/or
            % errors.

            mdl = "motorDrivelineElectricalTRQControl";
            load_system(mdl)
            set_param(mdl, "StopTime", "0.2"); % Reducing time for faster testing
            testCase.addTeardown(@()close_system(mdl,0));

            testCase.verifyWarningFree(@()sim(mdl), 'Model should run without warnings or errors.');
         end

         function TestFlexibleDriveLineTestHarness(testCase)
            % The check the "FlexibleDriveLineTestHarness" model for
            % warnings and/or errors.

            mdl = "FlexibleDriveLineTestHarness";
            load_system(mdl)
            testCase.addTeardown(@()close_system(mdl,0));

            testCase.verifyWarningFree(@()sim(mdl), 'Model should run without warnings or errors.');
        end
        
    end
    
end

classdef WorkflowTest < matlab.unittest.TestCase
    % Test to check workflow scripts.

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

        function TestGenerateOrderMap(testCase)
            %The test runs the |.mlx| file and makes sure that there are
            %no errors or warning thrown.
            testCase.verifyWarningFree(@()runGenerateOrderMap(),...
                "'generateOrderMap Live Script' should execute without any warning or error.");
        end

        function TestOptimizeVehicleLaunch(testCase)
            %The test runs the |.mlx| file and makes sure that there are
            %no errors or warning thrown.
            testCase.verifyWarningFree(@()runOptimizeVehicleLaunch(),...
                "'optimizeVehicleLaunch Live Script' should execute without any warning or error.");
        end
        
    end
end

function runGenerateOrderMap()
% Function runs the |.mlx| script.
generateOrderMap();
end

function runOptimizeVehicleLaunch()
% Function runs the |.mlx| script.
optimizeVehicleLaunch();
end


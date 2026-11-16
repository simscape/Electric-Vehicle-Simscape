classdef ProjectSmokeTests < matlab.unittest.TestCase
% ProjectSmokeTests - Parameterized smoke tests for Simulink models and scripts
%
% This TestCase class provides two parameterized test methods that validate
% basic project health:
%
%   TestModelSimulation - Loads each discovered Simulink model and runs a
%       simulation. Passes if sim() completes without error. Models and
%       figures opened during the test are automatically closed in teardown.
%
%   TestScriptExecution - Runs each discovered workflow script inside
%       verifyWarningFree(). Passes if the script completes without warnings
%       or errors. Tests run in a temporary working folder for isolation.
%
% Test parameters (modelName, scriptName) are populated externally by
% TestExecutor using Parameter.fromData, so this class does not need to
% know where files are located.
%
% Test Parameters:
%   modelName  - Cell array of model file names to simulate
%   scriptName - Cell array of script file names to run

% Copyright 2026 The MathWorks, Inc.

    properties
        openFiguresBefore;
        openModelsBefore;
    end

    properties (TestParameter)
        modelName = {"__skip__"};
        scriptName = {"__skip__"};
    end

    methods (TestClassSetup)
        function setupWorkingFolder(testCase)
            import matlab.unittest.fixtures.WorkingFolderFixture;
            testCase.applyFixture(WorkingFolderFixture);
        end

        function suppressConfiguredWarnings(testCase)
        % suppressConfiguredWarnings - Apply SuppressedWarningsFixture for all
        %   warning IDs specified in config.SuppressedWarnings.
        %   Reads from appdata set by TestExecutor before test execution.
        %   When run standalone (without TestExecutor), no warnings are suppressed.

            import matlab.unittest.fixtures.SuppressedWarningsFixture;

            if isappdata(0, 'TestFramework_SuppressedWarnings')
                warningIDs = getappdata(0, 'TestFramework_SuppressedWarnings');
                if ~isempty(warningIDs)
                    testCase.applyFixture(SuppressedWarningsFixture(warningIDs));
                end
            end
        end
    end

    methods (TestMethodSetup)
        function captureOpenFigures(testCase)
            testCase.openFiguresBefore = findall(0, "Type", "Figure");
        end

        function captureOpenModels(testCase)
            testCase.openModelsBefore = get_param(Simulink.allBlockDiagrams(), "Name");
        end
    end

    methods (TestMethodTeardown)
        function closeTestFigures(testCase)
            figuresAfter = findall(0, "Type", "Figure");
            newFigures = setdiff(figuresAfter, testCase.openFiguresBefore);
            arrayfun(@close, newFigures);
        end

        function closeTestModels(testCase)
            modelsAfter = get_param(Simulink.allBlockDiagrams(), "Name");
            newModels = setdiff(modelsAfter, testCase.openModelsBefore);
            close_system(newModels, 0);
        end
    end

    methods (Test)
        function TestModelSimulation(testCase, modelName)
        % TestModelSimulation - Verify model loads and simulates without error.
        %   Models not simulatable standalone (Subsystem references,
        %   Libraries) are discovered but skipped via assumeFalse, so they
        %   appear in the test report as Incomplete with a documented reason
        %   instead of erroring in sim().
            testCase.assumeNotEqual(modelName, "__skip__", ...
                "Skipped: no models parameterized for this test.");

            diagramType = string(Simulink.MDLInfo(char(modelName)).BlockDiagramType);
            testCase.assumeFalse(any(diagramType == ["Subsystem" "Library"]), ...
                sprintf("Skipped: '%s' is a %s and cannot be simulated standalone.", ...
                    modelName, diagramType));

            load_system(modelName);
            sim(modelName);
        end

        function TestScriptExecution(testCase, scriptName)
        % TestScriptExecution - Verify script runs without warnings or errors
            testCase.assumeNotEqual(scriptName, "__skip__", ...
                "Skipped: no scripts parameterized for this test.");
            testCase.verifyWarningFree(@()evalin('base', "run('" + scriptName + "')"), ...
                scriptName + " should execute without any warning or error.");
        end
    end
end

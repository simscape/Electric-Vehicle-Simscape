classdef BEVCarRunScriptsTest < matlab.unittest.TestCase
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

         function test_BEVbatterySizingscript(test)
            % The test runs the function under test and makes sure that
            % there are no errors or warning thrown
            test.verifyWarningFree(@()run_BEVbatterySizing, "'Battery Sizing script'  should execute wihtout any warning or error.");
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

function run_BEVrangeEstimationNEDC()
% Function runs the |.m| script.
BEVrangeEstimationNEDC;
end

function run_BEVrangeEstimationWLTC()
% Function runs the |.m| script.
BEVrangeEstimationWLTC;
end

function run_BEVbatterySizing()
% Function runs the |.m| script.
BEVbatterySizing;
end

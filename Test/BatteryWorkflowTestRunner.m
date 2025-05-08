%% Script to run unit tests
% This script runs all the unit tests that are the child classes of
% matlab.unittest.TestCase in the project.
% Unit test classes are automatically detected by
% the matlab.unittest.TestSuite.fromFolder function.

% Copyright 2024 The MathWorks, Inc.

relstr = matlabRelease().Release;
disp("This is MATLAB " + relstr + ".")

%% Create test suite
prjRoot = currentProject().RootFolder;
suite   = matlab.unittest.TestSuite.fromFile(fullfile(prjRoot, "Test", "BatteryWorkflowTests.m"));

%% Create test runner
runner = matlab.unittest.TestRunner.withTextOutput( ...
          "OutputDetail", matlab.unittest.Verbosity.Detailed);

%% JUnit style test result
plugin = matlab.unittest.plugins.XMLPlugin.producingJUnitFormat( ...
          fullfile(prjRoot,"Test", "TestResults_"+relstr+".xml"));
addPlugin(runner, plugin);

%% Run tests
results = run(runner, suite);
assertSuccess(results);

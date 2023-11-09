%% Run unit tests
% This script runs unit tests and generates a test result summary in XML
% and a MATLAB code coverage report in HTML.

% Copyright 2022 The MathWorks, Inc.

relstr = matlabRelease().Release;
disp("This is MATLAB " + relstr + ".")

prjroot = currentProject().RootFolder;

%% Create test suite

suite = matlab.unittest.TestSuite.fromFile( ...
  fullfile(prjroot, "Test", "CheckProject", "BEVProject_CheckProject.m"));

%% Create test runner

runner = matlab.unittest.TestRunner.withTextOutput( ...
            OutputDetail = matlab.unittest.Verbosity.Detailed );

%% JUnit Style Test Result

plugin = matlab.unittest.plugins.XMLPlugin.producingJUnitFormat( ...
            fullfile(prjroot, "Test", "CheckProject", "TestResults_"+relstr+".xml"));

addPlugin(runner, plugin)

%% Run tests

results = run(runner, suite);

assertSuccess(results)

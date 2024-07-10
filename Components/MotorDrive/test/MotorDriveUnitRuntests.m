%% Run unit tests
% This script runs unit tests for drive unit test bench

% Copyright 2023 The MathWorks, Inc.

RelStr = matlabRelease().Release;
disp("This is MATLAB " + RelStr + ".")

TopFolder = fullfile(currentProject().RootFolder, "Components", "MotorDrive");

%% Test suite and runner

suite = matlab.unittest.TestSuite.fromFile( ...
  fullfile(TopFolder, "Test", "MotorDriveUnitUnitTestMQC.m"));

runner = matlab.unittest.TestRunner.withTextOutput( ...
  OutputDetail = matlab.unittest.Verbosity.Detailed );

%% JUnit Style Test Result

TestResultFile = "MotorDriveUnitTestResults_" + RelStr + ".xml";

plugin = matlab.unittest.plugins.XMLPlugin.producingJUnitFormat( ...
  fullfile(TopFolder, "Test", TestResultFile));

addPlugin(runner, plugin)


%% Run tests
results = run(runner, suite);
assertSuccess(results)

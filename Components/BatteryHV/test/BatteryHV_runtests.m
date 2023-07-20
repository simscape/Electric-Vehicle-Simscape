%% Run unit tests
% This script runs unit test for battery testbench

% Copyright 2023 The MathWorks, Inc.

RelStr = matlabRelease().Release;
disp("This is MATLAB " + RelStr + ".")

TopFolder = fullfile(currentProject().RootFolder, "Components", "BatteryHV");

%% Test Suite & Runner

% suite_1 = matlab.unittest.TestSuite.fromFile( ...
%   fullfile(TopFolder, "Test", "BatteryHV_UnitTest.m"));

suite1 = matlab.unittest.TestSuite.fromFile( ...
  fullfile(TopFolder, "Test", "BatteryHV_UnitTest_MQC.m"));

suite= [suite1];

runner = matlab.unittest.TestRunner.withTextOutput( ...
  OutputDetail = matlab.unittest.Verbosity.Detailed );

%% JUnit Style Test Result

TestResultFile = "BatteryHV_TestResults_" + RelStr + ".xml";

plugin = matlab.unittest.plugins.XMLPlugin.producingJUnitFormat( ...
  fullfile(TopFolder, "Test", TestResultFile));

addPlugin(runner, plugin)

%% Run tests
results = run(runner, suite);
assertSuccess(results)

%% Script to run unit tests
% This script runs all the unit tests that are the child classes of
% matlab.unittest.TestCase in the project.
% Unit test classes are automatically detected by
% the matlab.unittest.TestSuite.fromFolder function.

% Copyright 2021-2022 The MathWorks, Inc.

relstr = matlabRelease().Release;
disp("This is MATLAB " + relstr + ".")

%% Create test suite

prjRoot = currentProject().RootFolder;

suite_1 = matlab.unittest.TestSuite.fromFolder( ...
  fullfile(prjRoot, "Components\BatteryHV"), IncludingSubfolders = true);

suite_2 = matlab.unittest.TestSuite.fromFile( ...
    fullfile(prjRoot, "Test", "BEV_System_UnitTest_MQC.m"));

suite_3 = matlab.unittest.TestSuite.fromFolder( ...
  fullfile(prjRoot, "Components\MotorDrive"), IncludingSubfolders = true);



suite = [suite_1 suite_2 suite_3];

%% Create test runner

runner = matlab.unittest.TestRunner.withTextOutput( ...
          "OutputDetail", matlab.unittest.Verbosity.Detailed);

%% JUnit style test result

plugin = matlab.unittest.plugins.XMLPlugin.producingJUnitFormat( ...
          fullfile(prjRoot,"Test", "TestResults_"+relstr+".xml"));

addPlugin(runner, plugin)


%% Code Coverage Report Plugin
coverageReportFolder = fullfile(currentProject().RootFolder,"", "coverage" + relstr);
if ~isfolder(coverageReportFolder)
  mkdir(coverageReportFolder)
end
coverageReport = matlab.unittest.plugins.codecoverage.CoverageReport(coverageReportFolder, MainFile = "BEV_MQC_Coverage_" + relstr + ".html" );

%% Code Coverage Plugin
list = dir(fullfile(prjRoot, 'Script_Data'));
list = list(~[list.isdir] & startsWith({list.name}, 'BEV') & endsWith({list.name}, {'.m', '.mlx'}));
fileList = arrayfun(@(x)[x.folder, filesep, x.name], list, 'UniformOutput', false);
codeCoveragePlugin = matlab.unittest.plugins.CodeCoveragePlugin.forFile(fileList, Producing = coverageReport );
addPlugin(runner, codeCoveragePlugin);


%% Run tests

results = run(runner, suite);

assertSuccess(results)

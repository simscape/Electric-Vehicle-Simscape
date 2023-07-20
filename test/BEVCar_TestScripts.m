% Unit Test Driver Script for BEV system model 

% Copyright 2023 The MathWorks, Inc.

ComponentName = "BEVCar";

relstr = matlabRelease().Release;
disp("This MATLAB Release: " + relstr)

prjRoot = currentProject().RootFolder;

%% Suite and Runner

BEVsuite = matlab.unittest.TestSuite.fromFile(fullfile(prjRoot, "test", "BEVCar_RunScriptsTest.m"));

suite = BEVsuite;

runner = matlab.unittest.TestRunner.withTextOutput( ...
  OutputDetail = matlab.unittest.Verbosity.Detailed);

%% JUnit Style Test Result

plugin = matlab.unittest.plugins.XMLPlugin.producingJUnitFormat( ...
  "TestResults_ModelScripts_" + relstr + ".xml");

addPlugin(runner, plugin)

%% Code Coverage Report Plugin
coverageReportFolder = fullfile(currentProject().RootFolder,"", "coverage" + relstr);
if ~isfolder(coverageReportFolder)
  mkdir(coverageReportFolder)
end
coverageReport = matlab.unittest.plugins.codecoverage.CoverageReport(coverageReportFolder, MainFile = "BEV_Coverage_" + relstr + ".html" );

%% Code Coverage Plugin
list = dir(fullfile(prjRoot, 'Script_Data'));
list = list(~[list.isdir] & startsWith({list.name}, 'BEV') & endsWith({list.name}, {'.m', '.mlx'}));
fileList = arrayfun(@(x)[x.folder, filesep, x.name], list, 'UniformOutput', false);
codeCoveragePlugin = matlab.unittest.plugins.CodeCoveragePlugin.forFile(fileList, Producing = coverageReport );
addPlugin(runner, codeCoveragePlugin);

%% Run tests
results = run(runner, suite);
disp(results)

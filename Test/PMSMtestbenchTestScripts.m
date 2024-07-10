% Unit Test Driver Script for BEV Drive Unit Thermal Solution- Code coverage Test

% Copyright 2023 The MathWorks, Inc.

ComponentName = "PMSMtestbench";

%% Get project root
prjRoot = currentProject().RootFolder;

relstr = matlabRelease().Release;
disp("This MATLAB Release: " + relstr)
PMSMsuiteScripts = matlab.unittest.TestSuite.fromFile(fullfile(prjRoot, "Test", "PMSMtestbenchRunScriptsTest.m"));

suite = [PMSMsuiteScripts];
runner = matlab.unittest.TestRunner.withTextOutput(OutputDetail = matlab.unittest.Verbosity.Detailed);

%% Code Coverage Report Plugin
coverageReportFolder = fullfile(currentProject().RootFolder,"", "coverage" + relstr);
if ~isfolder(coverageReportFolder)
  mkdir(coverageReportFolder)
end
coverageReport = matlab.unittest.plugins.codecoverage.CoverageReport(coverageReportFolder, MainFile = "PMSMCoverage_" + relstr + ".html" );

%% Code Coverage Plugin
list = dir(fullfile(prjRoot, 'Script_Data'));
list = list(~[list.isdir] & startsWith({list.name}, 'PMSM') & endsWith({list.name}, {'.m', '.mlx'}));
fileList = arrayfun(@(x)[x.folder, filesep, x.name], list, 'UniformOutput', false);
codeCoveragePlugin = matlab.unittest.plugins.CodeCoveragePlugin.forFile(fileList, Producing = coverageReport );
addPlugin(runner, codeCoveragePlugin);
%% Run tests
results = run(runner, suite);
out = assertSuccess(results);
disp(out);
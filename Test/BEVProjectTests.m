%% Script to run unit tests
% This script runs the unit tests and generates the code coverage report.

% Copyright 2021-2026 The MathWorks, Inc.

relStr = matlabRelease().Release;
disp("This is MATLAB " + relStr + ".")

topFolder = currentProject().RootFolder;

%% Create test suite

suite_1 = matlab.unittest.TestSuite.fromFile( ...
    fullfile(topFolder, "Test", "BEVSystemMainModel.m"));

suite_2 = matlab.unittest.TestSuite.fromFile( ...
    fullfile(topFolder, "Test", "BatteryWorkflowTests.m"));

suite_3 = matlab.unittest.TestSuite.fromFile( ...
    fullfile(topFolder, "Test", "MotorDriveWorkflowTests.m"));

suite_4 = matlab.unittest.TestSuite.fromFile( ...
    fullfile(topFolder, "Test", "VehicleWorkflowTests.m"));

suite_5 = matlab.unittest.TestSuite.fromFolder( ...
    fullfile(topFolder, "Components"), IncludingSubfolders = true);

suite = [suite_1 suite_2 suite_3 suite_4 suite_5];

%% Create test runner

runner = matlab.unittest.TestRunner.withTextOutput( ...
    OutputDetail = matlab.unittest.Verbosity.Detailed);

%% JUnit style test result

junitPlugin = matlab.unittest.plugins.XMLPlugin.producingJUnitFormat( ...
    fullfile(topFolder, "Test", "TestResults_" + relStr + ".xml"));

addPlugin(runner, junitPlugin)

%% MATLAB Code Coverage Report

coverageReportFolder = fullfile(topFolder, "coverage" + relStr);
if not(isfolder(coverageReportFolder))
    mkdir(coverageReportFolder)
end

coverageReport = matlab.unittest.plugins.codecoverage.CoverageReport( ...
    coverageReportFolder, ...
    MainFile = "BEVCoverage_" + relStr + ".html");

coverageFiles = { ...
    fullfile(topFolder, "Workflow", "Vehicle", "RangeEstimation", "BEVrangeEstimationNEDC.m"); ...
    fullfile(topFolder, "Workflow", "Vehicle", "RangeEstimation", "BEVrangeEstimationWLTC.m"); ...
    fullfile(topFolder, "Workflow", "Battery", "BatterySizing", "BEVbatterySizing.m"); ...
    fullfile(topFolder, "Workflow", "MotorDrive", "GearRatioSelect", "testThermalBenchRun.m"); ...
    fullfile(topFolder, "Workflow", "MotorDrive", "GearRatioSelect", "plotMotTemperature.m"); ...
    fullfile(topFolder, "Workflow", "MotorDrive", "GenerateMotInvLoss", "getLossTable.m"); ...
    fullfile(topFolder, "Workflow", "MotorDrive", "InverterLife", "countEqTest.m"); ...
    fullfile(topFolder, "Workflow", "MotorDrive", "InverterLife", "getDutyLife.m"); ...
    fullfile(topFolder, "Workflow", "MotorDrive", "InverterLife", "runInverterLife.m"); ...
    fullfile(topFolder, "Workflow", "MotorDrive", "ThermalDurability", "testBenchDuraRun.m") ...
    };

codeCoveragePlugin = matlab.unittest.plugins.CodeCoveragePlugin.forFile( ...
    cellstr(coverageFiles), Producing = coverageReport);

addPlugin(runner, codeCoveragePlugin)

%% Run tests

results = run(runner, suite);
assertSuccess(results)

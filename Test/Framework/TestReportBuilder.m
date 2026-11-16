classdef TestReportBuilder
% TestReportBuilder - Generates test report artifacts (JUnit XML, HTML, Coverage)
%
% This class provides factory methods that create and configure test runner
% plugins for report generation. It is called by TestExecutor to attach
% reporting capabilities to the test runner before execution.
%
% Reports are written to subfolders under Test/ProjectTestReport/, with
% filenames incorporating the MATLAB release string for traceability.
%
% Static Methods:
%   addJUnitPlugin        - Creates JUnit XML plugin for CI pipeline consumption
%   addHTMLReportPlugin   - Creates HTML test results report plugin
%   addCoveragePlugin     - Creates HTML code coverage plugin for source files
%   getCodeIssuesPath     - Returns output paths for Code Analyzer results
%   ensureFolder          - Creates output folder if it does not exist

% Copyright 2026 The MathWorks, Inc.

    methods (Static)
        function plugin = addJUnitPlugin(outputFolder, releaseStr)
        % addJUnitPlugin - Creates a JUnit XML plugin for the test runner
        %
        % Inputs:
        %   outputFolder - String path to report output directory
        %   releaseStr   - MATLAB release string (e.g., "R2025b")
        %
        % Output:
        %   plugin - XMLPlugin configured for JUnit format

            TestReportBuilder.ensureFolder(outputFolder);
            xmlPath = fullfile(outputFolder, "TestResults_" + releaseStr + ".xml");
            plugin = matlab.unittest.plugins.XMLPlugin.producingJUnitFormat(xmlPath);
        end

        function [plugin, reportPath] = addCoveragePlugin(fileList, outputFolder, releaseStr)
        % addCoveragePlugin - Creates a code coverage plugin
        %
        % Inputs:
        %   fileList     - String array of source files to measure coverage
        %   outputFolder - String path to report output directory
        %   releaseStr   - MATLAB release string
        %
        % Outputs:
        %   plugin     - CodeCoveragePlugin configured for the file list
        %   reportPath - String path to the generated coverage HTML file

            coverageFolder = fullfile(outputFolder, "CodeCoverage_" + releaseStr);
            TestReportBuilder.ensureFolder(coverageFolder);

            coverageFileName = "CoverageReport_" + releaseStr + ".html";
            reportPath = fullfile(coverageFolder, coverageFileName);

            coverageReport = matlab.unittest.plugins.codecoverage.CoverageReport(...
                coverageFolder, MainFile=coverageFileName);

            plugin = matlab.unittest.plugins.CodeCoveragePlugin.forFile(...
                cellstr(fileList), Producing=coverageReport);
        end

        function [plugin, reportPath] = addHTMLReportPlugin(outputFolder, releaseStr)
        % addHTMLReportPlugin - Creates an HTML test report plugin
        %
        % Produces an interactive HTML report of test results including
        % pass/fail status, diagnostics, and duration for each test point.
        %
        % Inputs:
        %   outputFolder - String path to report output directory
        %   releaseStr   - MATLAB release string
        %
        % Outputs:
        %   plugin     - TestReportPlugin configured for HTML output
        %   reportPath - String path to the generated HTML report file

            TestReportBuilder.ensureFolder(outputFolder);
            reportPath = fullfile(outputFolder, "TestReport_" + releaseStr + ".html");
            plugin = matlab.unittest.plugins.TestReportPlugin.producingHTML(reportPath);
        end

        function path = getCodeIssuesPath(outputFolder, releaseStr)
        % getCodeIssuesPath - Returns output paths for code issues results
        %
        % Inputs:
        %   outputFolder - String path to report output directory
        %   releaseStr   - MATLAB release string
        %
        % Output:
        %   path - String array of [.mat, .sarif] output paths

            TestReportBuilder.ensureFolder(outputFolder);
            baseName = "CodeIssues_" + releaseStr;
            path = [fullfile(outputFolder, baseName + ".mat"), ...
                    fullfile(outputFolder, baseName + ".sarif")];
        end

        function ensureFolder(folderPath)
        % ensureFolder - Creates folder if it does not already exist
            if ~isfolder(folderPath)
                mkdir(folderPath);
            end
        end
    end
end

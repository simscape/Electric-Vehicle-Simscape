classdef TestExecutor
% TestExecutor - Orchestrates test discovery, execution, and reporting
%
% This class is the central coordinator of the test framework. It reads a
% configuration struct (from any testConfig.m file), discovers test
% targets using TestFileDiscovery, builds parameterized test suites, configures
% the test runner with appropriate plugins (JUnit XML, code coverage), executes
% the tests, and displays results.
%
% File discovery delegates to TestFileDiscovery.find(), which uses a two-phase
% inclusion/exclusion approach:
%   Phase 1: IncludeDirectories (always recursive) and IncludeFiles are merged
%            into a unified candidate list and deduplicated.
%   Phase 2: ExcludeDirectories and ExcludeFiles are applied. Exclusion always
%            wins — a file in both IncludeFiles and ExcludeFiles is excluded.
%
% It also provides a dry-run mode for previewing discovered files without
% running any tests, and a utility method for Code Analyzer report paths.
%
% Static Methods:
%   runAll              - Run all smoke tests (models + workflows + custom) with coverage
%   runModelsOnly       - Run only model simulation tests
%   runWorkflowsOnly    - Run only workflow script tests
%   runCustomOnly       - Run only custom test files/directories
%   getCodeAnalyzerPaths - Return code issues output paths for buildfile integration
%   dryRun              - Preview which files will be tested without running

% Copyright 2026 The MathWorks, Inc.

    methods (Static)
        function results = runAll(config)
        % runAll - Discover all test targets, run full suite, generate reports
        %
        % Performs complete test execution for the given configuration:
        %   1. Resolves paths from config.ProjectRoot and validates report folder name.
        %   2. Discovers models, workflows, and coverage source files using
        %      the two-phase inclusion/exclusion approach in TestFileDiscovery.
        %   3. Checks if any custom tests (files or directories) are configured.
        %   4. Returns early if no test targets exist.
        %   5. Builds parameterized test suites for models (TestModelSimulation)
        %      and workflows (TestScriptExecution) via ProjectSmokeTests.
        %   6. Appends custom test suites from files and/or directories.
        %   7. Configures the test runner with reporting plugins (JUnit XML,
        %      HTML report, code coverage).
        %   8. Executes all suites and displays a pass/fail/incomplete summary.
        %   9. Optionally opens the coverage report in a browser.
        %
        % Input:
        %   config - Configuration struct from testConfig()
        %
        % Output:
        %   results - matlab.unittest.TestResult array

            [prjRoot, releaseStr, testRoot] = TestExecutor.resolvePaths(config);
            TestExecutor.validateFolderName(config.Reports.FolderName);
            reportFolder = fullfile(testRoot, "ProjectTestReport", config.Reports.FolderName);

            % Discover files using two-phase inclusion/exclusion
            models = TestExecutor.discoverFiles(config.Models, prjRoot, false);
            workflows = TestExecutor.discoverFiles(config.Workflows, prjRoot, true);
            coverageFiles = TestExecutor.discoverFiles(config.CodeCoverage, prjRoot, false);

            % Early return if nothing to test
            hasCustom = TestExecutor.hasCustomTests(config.CustomTests);
            if isempty(models) && isempty(workflows) && ~hasCustom
                fprintf("No models, workflows, or custom tests found. Nothing to run.\n");
                results = matlab.unittest.TestResult.empty;
                return;
            end

            % Build test suite
            suite = matlab.unittest.Test.empty;

            if ~isempty(models)
                suite = [suite, TestExecutor.buildSmokeTestSuite( ...
                    testRoot, "modelName", models, "TestModelSimulation")];
            else
                fprintf("No models found. Skipping model tests.\n");
            end

            if ~isempty(workflows)
                suite = [suite, TestExecutor.buildSmokeTestSuite( ...
                    testRoot, "scriptName", workflows, "TestScriptExecution")];
            else
                fprintf("No workflows found. Skipping workflow tests.\n");
            end

            if hasCustom
                suite = [suite, TestExecutor.buildCustomSuite(prjRoot, config.CustomTests)];
            end

            % Configure runner with coverage
            [runner, covReportPath] = TestExecutor.configureRunner( ...
                config, reportFolder, releaseStr, coverageFiles);

            % Bridge suppressed warnings to ProjectSmokeTests and run tests
            TestExecutor.setWarningAppData(config);
            try
                results = run(runner, suite);
            catch runErr
                TestExecutor.clearWarningAppData();
                rethrow(runErr);
            end
            TestExecutor.clearWarningAppData();

            % Display summary
            disp(results);
            resultTable = table(results);
            fprintf("\nTotals: %d Passed, %d Failed, %d Incomplete.\n", ...
                sum(resultTable.Passed), sum(resultTable.Failed), sum(resultTable.Incomplete));

            % Open reports if configured
            if config.Reports.OpenInBrowser && covReportPath ~= ""
                web(covReportPath, "-new");
            end
        end

        function results = runModelsOnly(config)
        % runModelsOnly - Run only model simulation tests
        %
        % Discovers Simulink models using the two-phase inclusion/exclusion
        % approach (IncludeDirectories + IncludeFiles merged, then filtered
        % by ExcludeDirectories and ExcludeFiles), builds a parameterized test
        % suite targeting TestModelSimulation, and executes it.
        %
        % Input:
        %   config - Configuration struct from testConfig()

            [prjRoot, releaseStr, testRoot] = TestExecutor.resolvePaths(config);
            TestExecutor.validateFolderName(config.Reports.FolderName);
            reportFolder = fullfile(testRoot, "ProjectTestReport", config.Reports.FolderName);

            models = TestExecutor.discoverFiles(config.Models, prjRoot, false);

            if isempty(models)
                fprintf("No models found. Nothing to run.\n");
                results = matlab.unittest.TestResult.empty;
                return;
            end

            suite = TestExecutor.buildSmokeTestSuite( ...
                testRoot, "modelName", models, "TestModelSimulation");

            runner = TestExecutor.configureRunner(config, reportFolder, releaseStr);
            TestExecutor.setWarningAppData(config);
            try
                results = run(runner, suite);
            catch runErr
                TestExecutor.clearWarningAppData();
                rethrow(runErr);
            end
            TestExecutor.clearWarningAppData();
            disp(results);
        end

        function results = runWorkflowsOnly(config)
        % runWorkflowsOnly - Run only workflow script tests
        %
        % Discovers workflow scripts using the two-phase inclusion/exclusion
        % approach (IncludeDirectories + IncludeFiles merged, then filtered
        % by ExcludeDirectories and ExcludeFiles). Function files are always
        % excluded automatically (only scripts can be executed as workflows).
        % Builds a parameterized test suite targeting TestScriptExecution.
        %
        % Input:
        %   config - Configuration struct from testConfig()

            [prjRoot, releaseStr, testRoot] = TestExecutor.resolvePaths(config);
            TestExecutor.validateFolderName(config.Reports.FolderName);
            reportFolder = fullfile(testRoot, "ProjectTestReport", config.Reports.FolderName);

            workflows = TestExecutor.discoverFiles(config.Workflows, prjRoot, true);

            if isempty(workflows)
                fprintf("No workflows found. Nothing to run.\n");
                results = matlab.unittest.TestResult.empty;
                return;
            end

            suite = TestExecutor.buildSmokeTestSuite( ...
                testRoot, "scriptName", workflows, "TestScriptExecution");

            runner = TestExecutor.configureRunner(config, reportFolder, releaseStr);
            TestExecutor.setWarningAppData(config);
            try
                results = run(runner, suite);
            catch runErr
                TestExecutor.clearWarningAppData();
                rethrow(runErr);
            end
            TestExecutor.clearWarningAppData();
            disp(results);
        end

        function results = runCustomOnly(config)
        % runCustomOnly - Run only custom test files and/or directories
        %
        % Loads test suites from the custom test configuration:
        %   - config.CustomTests.Files: Individual TestCase files resolved relative
        %     to the project root and loaded via TestSuite.fromFile().
        %   - config.CustomTests.Directories: Folders resolved relative to the
        %     project root, with all TestCase classes discovered via
        %     TestSuite.fromFolder().
        %
        % Input:
        %   config - Configuration struct from testConfig()

            [prjRoot, releaseStr, testRoot] = TestExecutor.resolvePaths(config);
            TestExecutor.validateFolderName(config.Reports.FolderName);
            reportFolder = fullfile(testRoot, "ProjectTestReport", config.Reports.FolderName);

            if ~TestExecutor.hasCustomTests(config.CustomTests)
                fprintf("No custom test files or directories configured. Nothing to run.\n");
                results = matlab.unittest.TestResult.empty;
                return;
            end

            suite = TestExecutor.buildCustomSuite(prjRoot, config.CustomTests);

            if isempty(suite)
                fprintf("No valid custom tests found. Nothing to run.\n");
                results = matlab.unittest.TestResult.empty;
                return;
            end

            runner = TestExecutor.configureRunner(config, reportFolder, releaseStr);
            results = run(runner, suite);
            disp(results);
        end

        function paths = getCodeAnalyzerPaths(config)
        % getCodeAnalyzerPaths - Returns code issues output file paths for buildfile
        %
        % Provides the output paths (.mat and .sarif) where Code Analyzer
        % results will be written. Used by the buildfile to configure the
        % codeIssues task output location.
        %
        % Input:
        %   config - Configuration struct from testConfig() (uses ProjectRoot)
        %
        % Output:
        %   paths - String array of output paths [.mat, .sarif]

            [~, releaseStr, testRoot] = TestExecutor.resolvePaths(config);
            reportFolder = fullfile(testRoot, "ProjectTestReport", "CodeAnalyzer");
            paths = TestReportBuilder.getCodeIssuesPath(reportFolder, releaseStr);
        end

        function dryRun(config)
        % dryRun - Preview which files will be tested without running any tests
        %
        % Executes the full file discovery pipeline (two-phase inclusion/exclusion)
        % for models, workflows, custom tests, and coverage sources, then prints
        % a summary of what would be tested. Useful for validating configuration
        % changes before committing to a full test run.
        %
        % For custom tests, lists individual files (with existence check) and
        % directories (with existence check) separately.
        %
        % Usage:
        %   TestExecutor.dryRun(testConfig())

            [prjRoot, ~, ~] = TestExecutor.resolvePaths(config);

            fprintf("\n===== DRY RUN: Test File Discovery =====\n\n");

            fprintf("--- Models (TestModelSimulation) ---\n");
            models = TestExecutor.discoverFiles(config.Models, prjRoot, false);
            if isempty(models)
                fprintf("  (none found)\n");
            end

            fprintf("\n--- Workflows (TestScriptExecution) ---\n");
            workflows = TestExecutor.discoverFiles(config.Workflows, prjRoot, true);
            if isempty(workflows)
                fprintf("  (none found)\n");
            end

            fprintf("\n--- Custom Tests ---\n");
            hasCustomFiles = ~isempty(config.CustomTests.Files);
            hasCustomDirs = ~isempty(config.CustomTests.Directories);
            if hasCustomFiles || hasCustomDirs
                for i = 1:numel(config.CustomTests.Files)
                    testFile = fullfile(prjRoot, config.CustomTests.Files(i));
                    if isfile(testFile)
                        fprintf("  [File] %s\n", testFile);
                    else
                        fprintf("  [File] %s [NOT FOUND]\n", config.CustomTests.Files(i));
                    end
                end
                for i = 1:numel(config.CustomTests.Directories)
                    testDir = fullfile(prjRoot, config.CustomTests.Directories(i));
                    if isfolder(testDir)
                        fprintf("  [Dir]  %s\n", testDir);
                    else
                        fprintf("  [Dir]  %s [NOT FOUND]\n", config.CustomTests.Directories(i));
                    end
                end
            else
                fprintf("  (none configured)\n");
            end

            fprintf("\n--- Code Coverage Source Files ---\n");
            coverage = TestExecutor.discoverFiles(config.CodeCoverage, prjRoot, false);
            if isempty(coverage)
                fprintf("  (none found)\n");
            end

            numCustom = numel(config.CustomTests.Files) + numel(config.CustomTests.Directories);

            fprintf("\n--- Suppressed Warnings (Models & Workflows only) ---\n");
            warnings = TestExecutor.getValidatedWarnings(config);
            if isempty(warnings)
                fprintf("  (none configured)\n");
            else
                for i = 1:numel(warnings)
                    fprintf("  %s\n", warnings(i));
                end
            end

            fprintf("\n===== Summary =====\n");
            fprintf("  Models:              %d\n", numel(models));
            fprintf("  Workflows:           %d\n", numel(workflows));
            fprintf("  Custom Tests:        %d\n", numCustom);
            fprintf("  Coverage:            %d source files\n", numel(coverage));
            fprintf("  Total test points:   %d\n", ...
                numel(models) + numel(workflows) + numCustom);
            fprintf("==================================\n\n");
        end
    end

    methods (Static, Access=private)
        function setWarningAppData(config)
        % setWarningAppData - Stores suppressed warnings on root object for TestCase access
        %
        % Writes the validated warning ID list to MATLAB's root graphics object
        % (handle 0) using setappdata. This data is read by ProjectSmokeTests
        % during TestClassSetup to apply SuppressedWarningsFixture.
        %
        % If the warning list is empty, no appdata is set (ProjectSmokeTests
        % checks with isappdata and skips fixture application).
        %
        % Input:
        %   config - Configuration struct with config.SuppressedWarnings field

            warnings = TestExecutor.getValidatedWarnings(config);
            if ~isempty(warnings)
                setappdata(0, 'TestFramework_SuppressedWarnings', warnings);
            end
        end

        function clearWarningAppData()
        % clearWarningAppData - Removes the appdata key after test run completes
        %
        % Called in both the success and error paths to ensure no stale data
        % remains on the root object after test execution.

            if isappdata(0, 'TestFramework_SuppressedWarnings')
                rmappdata(0, 'TestFramework_SuppressedWarnings');
            end
        end

        function warnings = getValidatedWarnings(config)
        % getValidatedWarnings - Extracts and validates config.SuppressedWarnings
        %
        % Validates that the field is a string array. Removes any empty
        % strings from the array. Returns string.empty if the field is empty.
        %
        % Input:
        %   config - Configuration struct with config.SuppressedWarnings field
        %
        % Output:
        %   warnings - Validated (:,1) string array of warning IDs
        %
        % Throws:
        %   TestExecutor:InvalidSuppressedWarnings if not a string array

            warnings = config.SuppressedWarnings;
            if isempty(warnings)
                warnings = string.empty;
                return;
            end
            if ~isstring(warnings)
                error("TestExecutor:InvalidSuppressedWarnings", ...
                    "config.SuppressedWarnings must be a string array. Got: %s", class(warnings));
            end
            % Remove any empty strings
            warnings = warnings(strlength(warnings) > 0);
        end

        function suite = buildSmokeTestSuite(testRoot, paramName, fileList, testMethodSubstring)
        % buildSmokeTestSuite - Creates a filtered parameterized test suite
        %
        % Builds a test suite from ProjectSmokeTests.m parameterized by the
        % given file list, then filters to only the specified test method.
        % Uses Parameter.fromData to inject file names as external parameters
        % and selectIf to retain only the relevant test method.
        %
        % The non-active parameter is set to {"__skip__"} so that
        % ProjectSmokeTests can use assumeNotEqual to skip it gracefully.
        %
        % Inputs:
        %   testRoot            - Path to the Test/ folder
        %   paramName           - "modelName" or "scriptName"
        %   fileList            - String array of discovered file paths
        %   testMethodSubstring - Substring to filter test names (e.g., "TestModelSimulation")
        %
        % Output:
        %   suite - Filtered matlab.unittest.TestSuite array

            import matlab.unittest.parameters.Parameter;

            [~, names, exts] = fileparts(fileList);
            fileNames = cellstr(names + exts);

            if paramName == "modelName"
                param = Parameter.fromData("modelName", fileNames, "scriptName", {"__skip__"});
            else
                param = Parameter.fromData("modelName", {"__skip__"}, "scriptName", fileNames);
            end

            suite = matlab.unittest.TestSuite.fromFile( ...
                fullfile(testRoot, "Framework", "ProjectSmokeTests.m"), ...
                ExternalParameters=param);

            suite = suite.selectIf(matlab.unittest.selectors.HasName( ...
                matlab.unittest.constraints.ContainsSubstring(testMethodSubstring)));
        end

        function suite = buildCustomSuite(prjRoot, customTests)
        % buildCustomSuite - Loads test suites from custom test files and directories
        %
        % Processes both sources of custom tests:
        %   1. Files: Each entry in customTests.Files is resolved to an absolute
        %      path relative to prjRoot. If the file exists, its TestCase suite
        %      is loaded via TestSuite.fromFile(). Missing files produce a warning.
        %   2. Directories: Each entry in customTests.Directories is resolved to
        %      an absolute path relative to prjRoot. If the folder exists, all
        %      TestCase classes within it and its subfolders are discovered via
        %      TestSuite.fromFolder() with IncludingSubfolders=true.
        %      Missing directories produce a warning.
        %
        % Inputs:
        %   prjRoot     - Project root path
        %   customTests - Struct with fields:
        %                   Files       - (:,1) string array of relative paths
        %                                 to individual TestCase .m files
        %                   Directories - (:,1) string array of relative paths
        %                                 to folders containing TestCase files
        %
        % Output:
        %   suite - matlab.unittest.TestSuite array (may be empty if nothing valid found)

            suite = matlab.unittest.Test.empty;

            % Load from individual files
            for i = 1:numel(customTests.Files)
                testFile = fullfile(prjRoot, customTests.Files(i));
                if isfile(testFile)
                    suite = [suite, matlab.unittest.TestSuite.fromFile(testFile)]; %#ok<AGROW>
                else
                    warning("TestExecutor:FileNotFound", ...
                        "Custom test file not found: %s", testFile);
                end
            end

            % Load from directories (always recursive into subfolders)
            for i = 1:numel(customTests.Directories)
                testDir = fullfile(prjRoot, customTests.Directories(i));
                if isfolder(testDir)
                    suite = [suite, matlab.unittest.TestSuite.fromFolder(testDir, ...
                        "IncludingSubfolders", true)]; %#ok<AGROW>
                else
                    warning("TestExecutor:DirectoryNotFound", ...
                        "Custom test directory not found: %s", testDir);
                end
            end
        end

        function tf = hasCustomTests(customTests)
        % hasCustomTests - Returns true if any custom tests are configured
        %
        % Checks whether either Files or Directories contains at least one entry.
        %
        % Input:
        %   customTests - Struct with fields: Files, Directories
        %
        % Output:
        %   tf - Logical true if at least one custom test source is configured
            tf = ~isempty(customTests.Files) || ~isempty(customTests.Directories);
        end

        function validateFolderName(folderName)
        % validateFolderName - Ensures Reports.FolderName is valid for use as a directory
        %
        % Checks that the folder name is non-empty and does not contain
        % characters that are invalid in file system paths on Windows/Linux.
        % Throws a descriptive error if validation fails.
        %
        % Input:
        %   folderName - String to validate as a directory name

            if strlength(folderName) == 0
                error("TestExecutor:InvalidFolderName", ...
                    "config.Reports.FolderName must not be empty.");
            end

            invalidChars = regexp(folderName, '[<>:"/\\|?*]', 'match');
            if ~isempty(invalidChars)
                error("TestExecutor:InvalidFolderName", ...
                    "config.Reports.FolderName contains invalid characters: %s", ...
                    strjoin(string(invalidChars), " "));
            end
        end

        function [runner, covReportPath] = configureRunner(config, reportFolder, releaseStr, coverageFiles)
        % configureRunner - Creates and configures a test runner with plugins
        %
        % Builds a TestRunner with detailed text output and attaches reporting
        % plugins based on the config.Reports flags:
        %   - GenerateJUnitXML: Attaches XMLPlugin for CI pipeline consumption
        %   - GenerateHTMLReport: Attaches TestReportPlugin for HTML output
        %   - GenerateCodeCoverage: Attaches CodeCoveragePlugin (only if
        %     coverageFiles is non-empty)
        %
        % Inputs:
        %   config           - Configuration struct (uses config.Reports fields)
        %   reportFolder  - Path to write reports to
        %   releaseStr    - MATLAB release string for file naming
        %   coverageFiles - (Optional) String array of source files for coverage.
        %                   Pass string.empty or omit to skip coverage plugin.
        %
        % Outputs:
        %   runner        - Configured TestRunner ready to execute
        %   covReportPath - Path to coverage report (empty string if not generated)

            if nargin < 4
                coverageFiles = string.empty;
            end

            runner = matlab.unittest.TestRunner.withTextOutput( ...
                OutputDetail=matlab.unittest.Verbosity.Detailed, ...
                LoggingLevel="Detailed");

            covReportPath = "";

            if config.Reports.GenerateJUnitXML
                addPlugin(runner, TestReportBuilder.addJUnitPlugin(reportFolder, releaseStr));
            end

            if config.Reports.GenerateHTMLReport
                [htmlPlugin, ~] = TestReportBuilder.addHTMLReportPlugin(reportFolder, releaseStr);
                addPlugin(runner, htmlPlugin);
            end

            if config.Reports.GenerateCodeCoverage && ~isempty(coverageFiles)
                [covPlugin, covReportPath] = TestReportBuilder.addCoveragePlugin( ...
                    coverageFiles, reportFolder, releaseStr);
                addPlugin(runner, covPlugin);
            end
        end

        function files = discoverFiles(configSection, prjRoot, excludeFunctions)
        % discoverFiles - Generic file discovery from a config sub-struct
        %
        % Delegates to TestFileDiscovery.find() which implements the two-phase
        % inclusion/exclusion approach:
        %   Phase 1: Merges files from IncludeDirectories (always recursive)
        %            and IncludeFiles into a unified candidate list.
        %   Phase 2: Applies ExcludeFunctionFiles, ExcludeDirectories, and
        %            ExcludeFiles filters. Exclusion always wins.
        %
        % The ExcludeFunctionFiles behavior is determined by the caller based
        % on the section type:
        %   - Models: false (irrelevant — no .m files in model search)
        %   - Workflows: true (function files cannot be executed as scripts)
        %   - CodeCoverage: false (function files are the source code to measure)
        %
        % Inputs:
        %   configSection    - Struct with fields: IncludeDirectories, FileTypes,
        %                      IncludeFiles, ExcludeDirectories, ExcludeFiles
        %   prjRoot          - Project root path
        %   excludeFunctions - Logical flag to exclude function files
        %
        % Output:
        %   files - (:,1) string array of absolute file paths

            files = TestFileDiscovery.find( ...
                ProjectRoot=prjRoot, ...
                IncludeDirectories=configSection.IncludeDirectories, ...
                FileTypes=configSection.FileTypes, ...
                IncludeFiles=configSection.IncludeFiles, ...
                ExcludeDirectories=configSection.ExcludeDirectories, ...
                ExcludeFiles=configSection.ExcludeFiles, ...
                ExcludeFunctionFiles=excludeFunctions, ...
                DisplayList=true);
        end

        function [prjRoot, releaseStr, testRoot] = resolvePaths(config)
        % resolvePaths - Derives project root, release string, and test root from config
        %
        % Reads config.ProjectRoot, validates that it is a valid directory,
        % and derives the test root path. The MATLAB release string is
        % determined from the running MATLAB instance.
        %
        % Input:
        %   config - Configuration struct (must have config.ProjectRoot field)
        %
        % Outputs:
        %   prjRoot    - Validated absolute path to the project root
        %   releaseStr - MATLAB release string (e.g., "R2025b")
        %   testRoot   - Path to the Test folder (prjRoot + "Test")

            if ~isfield(config, 'ProjectRoot')
                error("TestExecutor:MissingProjectRoot", ...
                    "config.ProjectRoot is required. Set it to the absolute path of your project root.");
            end

            prjRoot = string(config.ProjectRoot);

            if ~isfolder(prjRoot)
                error("TestExecutor:InvalidProjectRoot", ...
                    "config.ProjectRoot does not exist or is not a directory: %s", prjRoot);
            end

            releaseStr = matlabRelease().Release;
            testRoot = fullfile(prjRoot, "Test");
        end
    end
end

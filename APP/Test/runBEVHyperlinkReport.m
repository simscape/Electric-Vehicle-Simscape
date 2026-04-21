function results = runBEVHyperlinkReport()
%RUNBEVHYPERLINKREPORT Run hyperlink validation tests and generate reports.
%
%   results = runBEVHyperlinkReport
%
%   Report saved to:  APP/Test/Reports/HyperlinkReport_<release>.html
%   Results saved to: APP/Test/Reports/HyperlinkResults_<release>.xml
%
%   Copyright 2026 The MathWorks, Inc.

    import matlab.unittest.TestSuite
    import matlab.unittest.TestRunner
    import matlab.unittest.Verbosity
    import matlab.unittest.plugins.XMLPlugin
    import matlab.unittest.plugins.TestReportPlugin

    releaseStr  = char(matlabRelease().Release);
    projectRoot = char(currentProject().RootFolder);

    %% Ensure APP/Test is on path
    appTestDir = fullfile(projectRoot, 'APP', 'Test');
    addpath(appTestDir);

    %% Build suite
    suite = TestSuite.fromClass(?BEVHyperlinkTest);

    fprintf('Running %d hyperlink checks (%s)\n', numel(suite), releaseStr);

    %% Report folder
    reportDir = fullfile(appTestDir, 'Reports');
    if ~isfolder(reportDir), mkdir(reportDir); end

    %% Runner with plugins
    runner = TestRunner.withTextOutput('OutputDetail', Verbosity.Detailed);

    % JUnit XML (CI-friendly)
    xmlFile = fullfile(reportDir, ['HyperlinkResults_' releaseStr '.xml']);
    addPlugin(runner, XMLPlugin.producingJUnitFormat(xmlFile));

    % HTML report
    htmlFile = fullfile(reportDir, ['HyperlinkReport_' releaseStr '.html']);
    addPlugin(runner, TestReportPlugin.producingHTML(htmlFile));

    %% Run
    results = run(runner, suite);

    %% Summary
    fprintf('\n=== Hyperlink Report ===\n');
    fprintf('  Passed:  %d\n', nnz([results.Passed]));
    fprintf('  Failed:  %d\n', nnz([results.Failed]));
    fprintf('  HTML:    %s\n', htmlFile);
    fprintf('  XML:     %s\n', xmlFile);
end

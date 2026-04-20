function results = runBEVFidelityReport(templateFilter)
%RUNBEVFIDELITYREPORT Run preset fidelity tests and generate an HTML report.
%
%   results = runBEVFidelityReport
%   results = runBEVFidelityReport('VehicleElecAux')
%
%   Report saved to:  APP/Test/Reports/FidelityReport_<release>.html
%   Results saved to: APP/Test/Reports/FidelityResults_<release>.xml
%
%   Copyright 2026 The MathWorks, Inc.

    import matlab.unittest.TestSuite
    import matlab.unittest.TestRunner
    import matlab.unittest.Verbosity
    import matlab.unittest.plugins.XMLPlugin
    import matlab.unittest.plugins.TestReportPlugin

    releaseStr = char(matlabRelease().Release);
    projectRoot = char(currentProject().RootFolder);

    %% Ensure APP/Test is on path
    appTestDir = fullfile(projectRoot, 'APP', 'Test');
    addpath(appTestDir);

    %% Build suite
    suite = TestSuite.fromClass(?BEVPresetFidelityTest);

    if nargin > 0 && ~isempty(templateFilter)
        suite = suite.selectIf( ...
            matlab.unittest.selectors.HasParameter( ...
                'Property', 'Setup', 'Name', ['*' char(templateFilter) '*']));
    end

    fprintf('Running %d test points (%s)\n', numel(suite), releaseStr);

    %% Report folder
    reportDir = fullfile(appTestDir, 'Reports');
    if ~isfolder(reportDir), mkdir(reportDir); end

    %% Runner with plugins
    runner = TestRunner.withTextOutput('OutputDetail', Verbosity.Detailed);

    % JUnit XML (CI-friendly)
    xmlFile = fullfile(reportDir, ['FidelityResults_' releaseStr '.xml']);
    addPlugin(runner, XMLPlugin.producingJUnitFormat(xmlFile));

    % HTML report
    htmlFile = fullfile(reportDir, ['FidelityReport_' releaseStr '.html']);
    addPlugin(runner, TestReportPlugin.producingHTML(htmlFile));

    %% Run
    results = run(runner, suite);

    %% Summary
    fprintf('\n=== Fidelity Report ===\n');
    fprintf('  Passed:  %d\n', nnz([results.Passed]));
    fprintf('  Failed:  %d\n', nnz([results.Failed]));
    fprintf('  Errors:  %d\n', nnz([results.Errored]));
    fprintf('  HTML:    %s\n', htmlFile);
    fprintf('  XML:     %s\n', xmlFile);
end

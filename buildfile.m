function plan = buildfile
% buildfile - Defines the build plan for the Simscape library project
%
% This function creates a build plan with various tasks for building,
% checking, testing, reporting, and packaging a Simscape library that is
% generated from SPICE netlists.
%
% Returns:
%   plan - A buildplan object containing all defined tasks
%
% Copyright 2026 The MathWorks, Inc.

% Open project
prj = matlab.project.loadProject(pwd);

% Create an empty build plan
plan = buildplan;

% --- Test configurations ---
config = testConfig();

% Define individual tasks for the build plan
% Task to check code for issues in specified directories
plan("Check") = matlab.buildtool.TaskGroup(Description = "Static checks code related issues.");
plan("Check:CodeAnalyzer") = matlab.buildtool.tasks.CodeIssuesTask( ...
    SourceFiles=prj.RootFolder, ...
    IncludeSubfolders=true, ...
    Results=TestExecutor.getCodeAnalyzerPaths(config));

% Create external test task
plan("AllTest")= matlab.buildtool.Task(Description="Run all smoke tests.",...
    Actions=@(ctx)runAllSmokeTests(ctx,config));

plan("ModelTest")= matlab.buildtool.Task(Description="Run model smoke tests.",...
    Actions=@(ctx)runModelSmokeTests(ctx,config));

plan("WorkflowTest")= matlab.buildtool.Task(Description="Run workflow smoke tests.",...
    Actions=@(ctx)runWorkflowSmokeTests(ctx,config));

plan("CustomTest")= matlab.buildtool.Task(Description="Run custom tests.",...
    Actions=@(ctx)runCustomTests(ctx,config));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET TASKS FROM "OTHER" BUILDFILES AND ADD THEM TO THE MAIN PLAN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
buildfileList = dir(fullfile(prj.RootFolder, "*", "buildfileInternal.m"));
% Loop through the buildfile list and add tasks from each buildfile
for iFile = 1:length(buildfileList)
    [~,name,~] = fileparts(buildfileList(iFile).name);
    filePlan = feval(name);
    nTasks = numel(filePlan.Tasks);
    for taskIdx = 1:nTasks
        if ~ismember(filePlan.Tasks(taskIdx).Name,cellstr({plan.Tasks.Name}))
            plan(filePlan.Tasks(taskIdx).Name) = filePlan.Tasks(taskIdx);
        else
            fprintf("THERE ALREADY EXIST A TASK OF NAME: ""%s"" IN THE MAIN BUILD FILE. IGNORING TASK FROM OTHER BUILDFILES.", filePlan.Tasks(taskIdx).Name);
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function status = runAllSmokeTests(~, config)
status = 1;
results = TestExecutor.runAll(config);
if ~any([results.Failed])
    fprintf("\nAll tests passed!\n");
    status = 0;
end
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function status = runModelSmokeTests(~, config)
status = 1;
results = TestExecutor.runModelsOnly(config);
if ~any([results.Failed])
    fprintf("\nAll tests passed!\n");
    status = 0;
end
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function status = runWorkflowSmokeTests(~, config)
status = 1;
results = TestExecutor.runWorkflowsOnly(config);
if ~any([results.Failed])
    fprintf("\nAll tests passed!\n");
    status = 0;
end
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function status = runCustomTests(~, config)
status = 1;
results = TestExecutor.runCustomOnly(config);
if ~any([results.Failed])
    fprintf("\nAll tests passed!\n");
    status = 0;
end
end
%--------------------------------------------------------------------------

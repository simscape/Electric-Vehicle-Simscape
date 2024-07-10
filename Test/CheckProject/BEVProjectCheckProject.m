% This test checks if project status is passed
% Copyright 2023 The MathWorks, Inc.


relstr = matlabRelease().Release;
disp("This is MATLAB " + relstr + ".");

prj = currentProject;
updateDependencies(prj);
checkResults = runChecks(prj);
resultTable = table(checkResults);  % *.Passed, *.ID, *.Description
disp(resultTable(:, ["Passed", "Description"]));

assert(all(resultTable.Passed==true));

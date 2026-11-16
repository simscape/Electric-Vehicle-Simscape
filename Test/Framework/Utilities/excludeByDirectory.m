function filtered = excludeByDirectory(paths, directories, projectRoot)
% excludeByDirectory - Removes file paths under specified directories relative to project root
%
% Filters a list of file paths by checking whether each file resides under
% any of the specified directories. Each directory entry is a path relative
% to the project root.
%
% This function is used during Phase 2 (Exclusion) of the file discovery
% pipeline in TestFileDiscovery. It applies to the unified candidate list
% after IncludeDirectories and IncludeFiles have been merged, ensuring
% that exclusion rules always take precedence over inclusion.
%
% Each entry in directories is resolved to an absolute path:
%   fullfile(projectRoot, directories(i))
% A file is excluded if its absolute path starts with any resolved directory
% path followed by a file separator. This means all files under that
% directory (including all subfolders) are excluded.
%
% Matching is case-sensitive. Directory paths must be specified with the
% exact case as they appear on the file system.
%
% Syntax: filtered = excludeByDirectory(paths, directories, projectRoot)
%
% Inputs:
%   paths       - (:,1) string array of absolute file paths to filter
%   directories - (:,1) string array of directory paths relative to project
%                 root to exclude (e.g., "Workflow", "Components/archive")
%   projectRoot - string, absolute path to the project root
%
% Output:
%   filtered - (:,1) string array of paths with excluded directories removed
%
% Examples:
%   % Exclude all files under <ProjectRoot>/Workflow/
%   filtered = excludeByDirectory(paths, "Workflow", "C:\project")
%
%   % Exclude files under multiple directories
%   filtered = excludeByDirectory(paths, ["Components/archive"; "Test"], "C:\project")

% Copyright 2026 The MathWorks, Inc.

    arguments
        paths (:,1) string
        directories (:,1) string
        projectRoot string {mustBeNonempty}
    end

    if isempty(paths) || all(directories == "")
        filtered = paths;
        return;
    end

    excludeMask = false(size(paths));

    for i = 1:numel(directories)
        % Resolve the directory to an absolute path and append filesep
        % so that "Models" does not accidentally match "ModelsV2"
        absDirPath = fullfile(projectRoot, directories(i)) + filesep;
        excludeMask = excludeMask | startsWith(paths, absDirPath);
    end

    filtered = paths(~excludeMask);
end

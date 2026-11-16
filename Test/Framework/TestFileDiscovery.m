classdef TestFileDiscovery
% TestFileDiscovery - Finds test target files by type and directory with filtering
%
% This class encapsulates the file discovery logic used by TestExecutor to
% locate models, workflow scripts, and source files for code coverage.
%
% Discovery follows a two-phase approach:
%   Phase 1 (Inclusion): Builds a unified candidate list by combining files
%       found via recursive directory search (IncludeDirectories) with any
%       explicitly listed files (IncludeFiles). The combined list is
%       deduplicated to produce a single unique set of candidates.
%       IncludeDirectories always searches recursively into all subfolders.
%
%   Phase 2 (Exclusion): Applies all exclusion filters to the unified list:
%       - ExcludeFunctionFiles: removes .m files whose first meaningful line
%         is a function declaration (keeps only scripts and classes)
%       - ExcludeDirectories: removes files that reside under any of the
%         specified directories (paths relative to project root)
%       - ExcludeFiles: removes files whose relative path (from project
%         root) matches any entry in the exclude list
%
% This means exclusion rules always take precedence over inclusion. If a
% file appears in both IncludeFiles and ExcludeFiles, it will be excluded.
% Similarly, a file found by IncludeDirectories that resides under an
% ExcludeDirectories path will be excluded.
%
% Supported features:
%   - Always-recursive search of specified directories via dir()
%   - Multiple file type filters (SLX, MDL, M, MLX)
%   - Explicit file inclusion (IncludeFiles) merged before filtering
%   - Directory-based exclusion (ExcludeDirectories)
%   - File-name-based exclusion (ExcludeFiles)
%   - Function file filtering (ExcludeFunctionFiles) for script-only discovery
%   - Case-sensitive matching for all exclusion checks
%
% Static Methods:
%   find - Discovers files matching given directories, types, and filters

% Copyright 2026 The MathWorks, Inc.

    methods (Static)
        function files = find(NameValueArgs)
        % find - Locate files for testing based on directories and file types
        %
        % This method implements the two-phase discovery approach:
        %
        %   1. INCLUSION PHASE:
        %      a) Searches each directory in IncludeDirectories (always
        %         recursively, including all subfolders) for files matching
        %         the specified FileTypes (e.g., *.slx, *.m).
        %      b) Resolves each entry in IncludeFiles to a full path and adds
        %         it to the candidate list (warns if a file does not exist).
        %      c) Deduplicates the combined list using unique().
        %
        %   2. EXCLUSION PHASE (applied in order):
        %      a) ExcludeFunctionFiles: If true, removes any .m file that
        %         defines a function (as determined by isFunctionFile()).
        %      b) ExcludeDirectories: Removes files that reside under any of
        %         the listed directories (relative to project root).
        %      c) ExcludeFiles: Removes files whose relative path (from
        %         project root) matches any entry in the exclude list.
        %
        % Exclusion always wins over inclusion. A file present in both
        % IncludeFiles and ExcludeFiles will be excluded from the final list.
        %
        % Syntax: files = TestFileDiscovery.find(Name,Value)
        %
        % Name-Value Arguments:
        %   ProjectRoot            - String path to project root (required)
        %   IncludeDirectories     - String array of directories relative to
        %                            the project root to search. Directories
        %                            are always searched recursively (all
        %                            subfolders are included automatically).
        %                            The ** wildcard is no longer required but
        %                            still works if specified. (required)
        %   FileTypes              - String array of file type labels to search
        %                            for: "M-file", "SLX-file", "MDL-file",
        %                            "MLX-file" (required)
        %   IncludeFiles           - String array of relative paths to specific
        %                            files to include in the candidate list.
        %                            These are merged with directory-discovered
        %                            files BEFORE exclusion filters are applied.
        %                            (default: string.empty)
        %   ExcludeDirectories     - String array of directory paths (relative to
        %                            project root) to exclude. Any file under
        %                            these directories will be removed.
        %                            (default: string.empty)
        %   ExcludeFiles           - String array of file paths relative to the
        %                            project root to exclude from the final
        %                            list. (default: string.empty)
        %   ExcludeFunctionFiles   - Logical flag to exclude .m files that are
        %                            functions (keeps scripts and classdefs).
        %                            (default: false)
        %   DisplayList            - Logical flag to print the final discovered
        %                            file list to the command window.
        %                            (default: false)
        %
        % Output:
        %   files - (:,1) string array of absolute file paths that passed all
        %           inclusion and exclusion criteria

            arguments
                NameValueArgs.ProjectRoot string {mustBeNonempty}
                NameValueArgs.IncludeDirectories (:,1) string = string.empty
                NameValueArgs.FileTypes (:,1) string {mustBeNonempty}
                NameValueArgs.IncludeFiles (:,1) string = string.empty
                NameValueArgs.ExcludeDirectories (:,1) string = string.empty
                NameValueArgs.ExcludeFiles (:,1) string = string.empty
                NameValueArgs.ExcludeFunctionFiles logical = false
                NameValueArgs.DisplayList logical = false
            end

            % Unpack for readability
            prjRoot         = NameValueArgs.ProjectRoot;
            directories     = NameValueArgs.IncludeDirectories;
            fileTypes       = NameValueArgs.FileTypes;
            includeFiles    = NameValueArgs.IncludeFiles;
            excludeDirs     = NameValueArgs.ExcludeDirectories;
            excludeFiles    = NameValueArgs.ExcludeFiles;
            excludeFunctions = NameValueArgs.ExcludeFunctionFiles;
            displayList     = NameValueArgs.DisplayList;

            % ==============================================================
            % PHASE 1: INCLUSION — Build unified candidate list
            % ==============================================================

            files = strings(0,1);

            % Map file type labels to glob extensions
            typeMap = dictionary( ...
                "M-file", "*.m", ...
                "SLX-file", "*.slx", ...
                "MDL-file", "*.mdl", ...
                "MLX-file", "*.mlx");

            % 1a) Search each directory for each file type (always recursive)
            for p = 1:numel(directories)
                directories(p) = strrep(strrep(directories(p), '/', filesep), '\', filesep);
                searchPath = fullfile(prjRoot, directories(p));

                % Make search always recursive: if the path doesn't already
                % contain a wildcard, append ** to recurse into all subfolders
                if ~contains(searchPath, '*')
                    searchPath = fullfile(searchPath, "**");
                end

                for t = 1:numel(fileTypes)
                    ext = typeMap(fileTypes(t));
                    found = TestFileDiscovery.searchForFiles(searchPath, ext);
                    files = [files; found]; %#ok<AGROW>
                end
            end

            % 1b) Add explicitly included individual files to the same pool
            if ~isempty(includeFiles)
                for i = 1:numel(includeFiles)
                    includeFiles(i) = strrep(strrep(includeFiles(i), '/', filesep), '\', filesep);
                    filePath = fullfile(prjRoot, includeFiles(i));
                    if isfile(filePath)
                        files(end+1,1) = filePath; %#ok<AGROW>
                    else
                        warning("TestFileDiscovery:FileNotFound", ...
                            "IncludeFiles entry not found: %s", filePath);
                    end
                end
            end

            % 1c) Deduplicate the combined candidate list
            files = unique(files);

            % ==============================================================
            % PHASE 2: EXCLUSION — Apply all filters to the unified list
            % ==============================================================

            % 2a) Filter out function files if requested (only applies to .m files)
            if excludeFunctions && any(contains(fileTypes, "M"))
                keepMask = true(size(files));
                for i = 1:numel(files)
                    [~,~,ext] = fileparts(files(i));
                    if ext == ".m" && isFunctionFile(files(i))
                        keepMask(i) = false;
                    end
                end
                files = files(keepMask);
            end

            % 2b) Apply directory exclusions (relative to project root)
            if ~isempty(excludeDirs)
                files = excludeByDirectory(files, excludeDirs, prjRoot);
            end

            % 2c) Exclude specific files by relative path
            if ~isempty(excludeFiles)
                % Convert absolute paths to relative (strip project root + filesep)
                relPaths = erase(files, prjRoot + filesep);
                % Normalize separators for comparison
                relPaths = replace(relPaths, "\", "/");
                excludeNorm = replace(excludeFiles, "\", "/");
                keepMask = ~ismember(relPaths, excludeNorm);
                files = files(keepMask);
            end

            % ==============================================================
            % OUTPUT
            % ==============================================================

            % Display results
            if displayList
                fprintf("[TestFileDiscovery] Found %d file(s):\n", numel(files));
                for i = 1:numel(files)
                    fprintf("  %s\n", files(i));
                end
            end

            if isempty(files)
                warning("TestFileDiscovery:NoFilesFound", ...
                    "No files found for directories: %s", strjoin(string(directories), ", "));
            end
        end
    end

    methods (Static, Access=private)
        function files = searchForFiles(searchPath, extension)
        % searchForFiles - Low-level directory search for files of given extension
        %
        % Searches for files matching the given extension within the specified
        % search path. Handles both wildcard (**) patterns (which dir() resolves
        % recursively) and direct folder paths.
        %
        % Inputs:
        %   searchPath - String path that may contain ** wildcards
        %   extension  - Glob pattern for file extension (e.g., "*.m", "*.slx")
        %
        % Output:
        %   files - (:,1) string array of absolute file paths found

            files = strings(0,1);

            % Strategy 1: Use dir with the full pattern including extension
            % This handles ** wildcards natively
            fullPattern = fullfile(searchPath, extension);
            L = dir(fullPattern);
            if ~isempty(L)
                files = [files; string(fullfile({L.folder}, {L.name}))'];
            end

            % Strategy 2: If searchPath is a plain folder (no wildcards), search it directly
            if ~contains(searchPath, '*') && isfolder(searchPath)
                L = dir(fullfile(searchPath, extension));
                if ~isempty(L)
                    files = [files; string(fullfile({L.folder}, {L.name}))'];
                end
            end

            files = unique(files);
        end
    end
end

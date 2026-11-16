function isFunc = isFunctionFile(file)
% isFunctionFile - Returns true if the .m file defines a function (not a script or class)
%
% Reads the first non-comment, non-blank line of the given .m file to
% determine its type. Returns true only for function files. Returns false
% for scripts, classdef files, and invalid/empty files.
%
% This function is used during Phase 2 (Exclusion) of the file discovery
% pipeline in TestFileDiscovery when ExcludeFunctionFiles is set to true.
% It allows the framework to filter out function files from workflow
% discovery, since only scripts (not functions) should be executed as
% standalone workflows.
%
% Detection logic:
%   - Opens the file for reading
%   - Skips blank lines and lines starting with '%' (comments)
%   - Checks if the first meaningful line starts with 'function'
%   - If yes, the file is a function; otherwise it is a script or classdef
%
% Syntax: isFunc = isFunctionFile(file)
%
% Input:
%   file - String or char absolute file path to a .m file to check
%
% Output:
%   isFunc - Logical true if the file defines a function, false otherwise
%            (scripts, classdefs, empty files, or unreadable files)

% Copyright 2026 The MathWorks, Inc.

    isFunc = false;

    try
        fid = fopen(file, 'r');
        if fid == -1
            return;
        end
        cleanup = onCleanup(@() fclose(fid));

        while ~feof(fid)
            line = strtrim(fgetl(fid));
            % Skip blank lines and comment lines
            if isempty(line) || startsWith(line, '%')
                continue;
            end
            % First meaningful line determines file type
            isFunc = startsWith(line, 'function');
            return;
        end
    catch
        % If anything goes wrong reading the file, assume not a function
        isFunc = false;
    end
end

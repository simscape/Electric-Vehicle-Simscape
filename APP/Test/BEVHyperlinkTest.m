classdef BEVHyperlinkTest < matlab.unittest.TestCase
%BEVHYPERLINKTEST Verify all hyperlinks and image references in project HTML files.
%   Scans every tracked HTML file in the project and checks:
%     - Relative file links (href to .html, .png, etc.) resolve on disk
%     - Image src attributes resolve on disk
%     - matlab: command targets (open, open_system, edit, run, web) point
%       to files that exist in the project
%     - External URLs (http/https) are flagged but not validated
%
%   Run all:
%     results = runtests('BEVHyperlinkTest');
%
%   Run with HTML report:
%     runBEVHyperlinkReport
%
%   Copyright 2026 The MathWorks, Inc.

    properties (TestParameter)
        HtmlFile = localDiscoverHtmlFiles()
    end

    properties (Access = private)
        ProjectRoot
        ProjectFiles  % containers.Map of lowercase relative paths → true
    end

    methods (TestClassSetup)
        function buildFileIndex(testCase)
        %BUILDFILEINDEX Index all project files for fast lookup.
            testCase.ProjectRoot = char(matlab.project.rootProject().RootFolder);

            % Build index of all files in project tree
            allFiles = dir(fullfile(testCase.ProjectRoot, '**', '*'));
            allFiles = allFiles(~[allFiles.isdir]);

            testCase.ProjectFiles = containers.Map();
            for k = 1:numel(allFiles)
                relPath = localMakeRelative( ...
                    fullfile(allFiles(k).folder, allFiles(k).name), ...
                    testCase.ProjectRoot);
                testCase.ProjectFiles(lower(relPath)) = true;
            end
        end
    end

    methods (Test)
        function verifyLinks(testCase, HtmlFile)
        %VERIFYLINKS Check all links in a single HTML file.

            htmlPath = fullfile(testCase.ProjectRoot, HtmlFile);
            htmlDir  = fileparts(htmlPath);
            content  = fileread(htmlPath);

            % ---- Extract all href and src values ----
            links = localExtractLinks(content);

            brokenLinks = {};

            for k = 1:numel(links)
                link = links{k};

                % Skip anchors, empty, and external URLs
                if isempty(link) || startsWith(link, '#')
                    continue;
                end
                if startsWith(link, 'http://') || startsWith(link, 'https://')
                    continue;
                end

                % ---- matlab: command links ----
                if startsWith(link, 'matlab:')
                    matlabCmd = link(8:end);  % strip 'matlab:'
                    targets = localExtractMatlabTargets(matlabCmd);

                    for t = 1:numel(targets)
                        target = targets{t};
                        if ~localFileExistsInProject(testCase, target)
                            brokenLinks{end+1} = sprintf( ...
                                'matlab: target not found — %s (from %s)', ...
                                target, link); %#ok<AGROW>
                        end
                    end
                    continue;
                end

                % ---- Relative file links ----
                % Strip anchor from link (e.g. file.html#section)
                cleanLink = regexprep(link, '#.*$', '');
                if isempty(cleanLink), continue; end

                resolvedPath = fullfile(htmlDir, cleanLink);
                resolvedPath = localNormalizePath(resolvedPath);

                if ~isfile(resolvedPath)
                    brokenLinks{end+1} = sprintf( ...
                        'File not found — %s', cleanLink); %#ok<AGROW>
                end
            end

            % ---- Assert ----
            if ~isempty(brokenLinks)
                failMsg = sprintf('Broken links in %s:\n  %s', ...
                    HtmlFile, strjoin(brokenLinks, '\n  '));
                testCase.verifyTrue(false, failMsg);
            end
        end
    end
end


%% ========================= Discovery =========================

function htmlFiles = localDiscoverHtmlFiles()
%LOCALDISCOVERHTMLFILES Find all tracked HTML files in the project.
    projectRoot = char(matlab.project.rootProject().RootFolder);

    % Use git to get tracked HTML files only
    [status, output] = system(sprintf( ...
        'git -C "%s" ls-files -- "*.html"', projectRoot));

    if status ~= 0
        % Fallback: scan disk
        allHtml = dir(fullfile(projectRoot, '**', '*.html'));
        htmlFiles = struct();
        for k = 1:numel(allHtml)
            relPath = localMakeRelative( ...
                fullfile(allHtml(k).folder, allHtml(k).name), projectRoot);
            key = matlab.lang.makeValidName(relPath);
            htmlFiles.(key) = relPath;
        end
        return;
    end

    lines = strsplit(strtrim(output), newline);
    lines = lines(~cellfun('isempty', lines));

    htmlFiles = struct();
    for k = 1:numel(lines)
        relPath = strrep(strtrim(lines{k}), '/', filesep);
        key = matlab.lang.makeValidName(relPath);
        htmlFiles.(key) = relPath;
    end
end


%% ========================= Link Extraction =========================

function links = localExtractLinks(htmlContent)
%LOCALEXTRACTLINKS Extract all href and src attribute values from HTML.
    hrefTokens = regexp(htmlContent, 'href\s*=\s*"([^"]*)"', 'tokens');
    srcTokens  = regexp(htmlContent, 'src\s*=\s*"([^"]*)"', 'tokens');

    allTokens = [hrefTokens, srcTokens];
    links = cell(1, numel(allTokens));
    for k = 1:numel(allTokens)
        links{k} = allTokens{k}{1};
    end
end


function targets = localExtractMatlabTargets(matlabCmd)
%LOCALEXTRACTMATLABTARGETS Extract file targets from a matlab: command string.
%   Handles: open('file'), open_system('file'), edit('file'),
%            run('file'), web('file'), load_system('file')

    targets = {};

    % Match quoted string arguments to known commands
    tokens = regexp(matlabCmd, ...
        '(?:open_system|load_system|open|edit|run|web)\s*\(\s*[''"]([^''"]+)[''"]', ...
        'tokens');

    for k = 1:numel(tokens)
        target = tokens{k}{1};

        % web() with .html is a relative HTML reference — skip (checked as file link)
        % But open_system/open/edit/run targets are MATLAB files
        targets{end+1} = target; %#ok<AGROW>
    end

    % Handle bare command form: open_system("model") with %22 encoding
    tokens = regexp(matlabCmd, ...
        '(?:open_system|load_system|open|edit|run|web)\s*\(\s*%22([^%]+)%22', ...
        'tokens');
    for k = 1:numel(tokens)
        targets{end+1} = tokens{k}{1}; %#ok<AGROW>
    end
end


%% ========================= File Lookup =========================

function found = localFileExistsInProject(testCase, target)
%LOCALFILEEXISTSINPROJECT Check whether a matlab: target file exists.
%   Searches the project file index for the target by name.

    % Direct path check
    fullTarget = fullfile(testCase.ProjectRoot, target);
    if isfile(fullTarget)
        found = true;
        return;
    end

    % Strip path separators from target for filename-only search
    [~, baseName, ext] = fileparts(target);
    if isempty(ext)
        % Could be a model name (open_system) — try .slx and .mdl
        candidates = {[baseName '.slx'], [baseName '.mdl']};
    else
        candidates = {[baseName ext]};
    end

    found = false;
    keys = testCase.ProjectFiles.keys();
    for c = 1:numel(candidates)
        searchName = lower(candidates{c});
        for k = 1:numel(keys)
            if endsWith(keys{k}, [filesep searchName]) || strcmp(keys{k}, searchName)
                found = true;
                return;
            end
        end
    end
end


%% ========================= Path Helpers =========================

function relPath = localMakeRelative(absPath, rootFolder)
%LOCALMAKERELATIVE Convert absolute path to project-relative path.
    relPath = strrep(absPath, [rootFolder filesep], '');
    relPath = strrep(relPath, '/', filesep);
end


function normalized = localNormalizePath(rawPath)
%LOCALNORMALIZEPATH Resolve . and .. in a path string.
    parts = strsplit(strrep(rawPath, '/', filesep), filesep);
    resolved = {};
    for k = 1:numel(parts)
        if strcmp(parts{k}, '.')
            continue;
        elseif strcmp(parts{k}, '..')
            if ~isempty(resolved)
                resolved(end) = [];
            end
        else
            resolved{end+1} = parts{k}; %#ok<AGROW>
        end
    end
    normalized = strjoin(resolved, filesep);
end

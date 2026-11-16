function zipPath = exportPresetPackage(presetFolder)
%EXPORTPRESETPACKAGE Package a preset with all required model/param files into a zip.
%   zipPath = bevPresetUI.exportPresetPackage(presetFolder)
%
%   Collects the top model, vehicle template, component models, param files,
%   library packages, controller, and preset scripts into a project-like
%   folder structure, creates a .prj with resources/, and zips the archive.
%
% Copyright 2026 The MathWorks, Inc.

    projectRoot = char(matlab.project.rootProject().RootFolder);

    [~, presetName] = fileparts(presetFolder);

    % ---- Parse preset files to discover dependencies ----
    ssrScript = fullfile(presetFolder, 'setupModelReferences.m');
    paramScript = fullfile(presetFolder, 'setupModelParameters.m');

    if ~isfile(ssrScript)
        error('bevPresetUI:noSSR', 'setupModelReferences.m not found in %s', presetFolder);
    end
    if ~isfile(paramScript)
        error('bevPresetUI:noParam', 'setupModelParameters.m not found in %s', presetFolder);
    end

    ssrText = fileread(ssrScript);
    paramText = fileread(paramScript);

    % ---- Identify top model ----
    topModel = extractTopModel(ssrText);

    % ---- Identify vehicle template ----
    vehicleTemplate = extractVehicleTemplate(ssrText);

    % ---- Identify component references (model names) ----
    componentModels = extractComponentModels(ssrText);

    % ---- Identify controller ----
    controllerModel = extractController(ssrText);

    % ---- Identify param files called in setupModelParameters ----
    paramFiles = extractParamCalls(paramText);

    % ---- Build export staging folder ----
    exportDir = fullfile(projectRoot, 'Script_Data', 'Setup', 'Export');
    if ~isfolder(exportDir)
        mkdir(exportDir);
    end

    stageDir = fullfile(exportDir, presetName);
    if isfolder(stageDir)
        rmdir(stageDir, 's');
    end
    mkdir(stageDir);

    % ---- Copy top-level model ----
    modelDir = fullfile(stageDir, 'Model');
    mkdir(modelDir);
    topModelFile = fullfile(projectRoot, 'Model', [topModel '.slx']);
    if isfile(topModelFile)
        copyfile(topModelFile, modelDir);
    end

    % ---- Copy vehicle template ----
    templateDir = fullfile(modelDir, 'VehicleTemplate');
    mkdir(templateDir);
    templateFile = fullfile(projectRoot, 'Model', 'VehicleTemplate', [vehicleTemplate '.slx']);
    if isfile(templateFile)
        copyfile(templateFile, templateDir);
    end

    % ---- Copy component model .slx files and their Library folders ----
    componentsDir = fullfile(stageDir, 'Components');
    mkdir(componentsDir);

    allModels = [componentModels; {controllerModel}];
    allModels = allModels(~cellfun(@isempty, allModels));

    copiedComponents = {};
    for k = 1:numel(allModels)
        mdlName = allModels{k};
        [compFolder, compName] = locateComponentFolder(projectRoot, mdlName);
        if isempty(compFolder), continue; end

        destCompDir = fullfile(componentsDir, compName);
        if ~isfolder(destCompDir)
            mkdir(destCompDir);
        end

        % Model subfolder
        destModelDir = fullfile(destCompDir, 'Model');
        if ~isfolder(destModelDir)
            mkdir(destModelDir);
        end

        % Copy .slx
        slxFile = fullfile(compFolder, 'Model', [mdlName '.slx']);
        if isfile(slxFile)
            copyfile(slxFile, destModelDir);
        end

        % Copy Library folder if present (contains Simscape packages)
        libFolder = fullfile(compFolder, 'Library');
        if isfolder(libFolder) && ~ismember(compName, copiedComponents)
            destLibDir = fullfile(destCompDir, 'Library');
            copyfile(libFolder, destLibDir);
            copiedComponents{end+1} = compName; %#ok<AGROW>
        end
    end

    % ---- Copy param files ----
    for k = 1:numel(paramFiles)
        paramName = paramFiles{k};
        paramPath = locateParamFile(projectRoot, paramName);
        if isempty(paramPath), continue; end

        % Determine which component this param belongs to
        relPath = strrep(paramPath, [projectRoot filesep], '');
        parts = strsplit(relPath, filesep);

        if numel(parts) >= 3 && strcmp(parts{1}, 'Components')
            compName = parts{2};
            subFolder = parts{3};
            destDir = fullfile(componentsDir, compName, subFolder);
            if ~isfolder(destDir)
                mkdir(destDir);
            end
            copyfile(paramPath, destDir);
        end
    end

    % ---- Copy preset scripts ----
    presetDestDir = fullfile(stageDir, 'Preset');
    mkdir(presetDestDir);
    presetFiles = dir(fullfile(presetFolder, '*'));
    presetFiles = presetFiles(~[presetFiles.isdir]);
    for k = 1:numel(presetFiles)
        copyfile(fullfile(presetFiles(k).folder, presetFiles(k).name), presetDestDir);
    end

    % ---- Create MATLAB project (.prj + resources/) ----
    createMATLABProject(stageDir, presetName);

    % ---- Zip ----
    zipPath = fullfile(exportDir, [presetName '.zip']);
    zip(zipPath, presetName, exportDir);

    % ---- Clean up staging folder ----
    rmdir(stageDir, 's');
end


%% ========================= Parsing Helpers =========================

function topModel = extractTopModel(ssrText)
    tok = regexp(ssrText, "topModelName\s*=\s*'([^']+)'", 'tokens', 'once');
    if isempty(tok)
        topModel = 'BEVsystemModel';
    else
        topModel = tok{1};
    end
end

function template = extractVehicleTemplate(ssrText)
    tok = regexp(ssrText, "vehTarget\s*=\s*'([^']+)'", 'tokens', 'once');
    if isempty(tok)
        template = '';
    else
        template = tok{1};
    end
end

function models = extractComponentModels(ssrText)
    toks = regexp(ssrText, "setRef\([^,]+,\s*'([^']+)'\)", 'tokens');
    models = cellfun(@(t) t{1}, toks, 'UniformOutput', false);
    models = unique(models(:));
end

function ctrl = extractController(ssrText)
    tok = regexp(ssrText, "setRef\('[^']*Controller[^']*',\s*'([^']+)'\)", 'tokens', 'once');
    if isempty(tok)
        ctrl = '';
    else
        ctrl = tok{1};
    end
end

function paramFiles = extractParamCalls(paramText)
    toks = regexp(paramText, '^\s*([A-Za-z]\w+Params)\s*;', 'tokens', 'lineanchors');
    paramFiles = cellfun(@(t) t{1}, toks, 'UniformOutput', false);
    paramFiles = unique(paramFiles(:));
end


%% ========================= File Location Helpers =========================

function [compFolder, compName] = locateComponentFolder(projectRoot, modelName)
    compRoot = fullfile(projectRoot, 'Components');
    entries = dir(compRoot);
    entries = entries([entries.isdir]);
    entries = entries(~ismember({entries.name}, {'.','..'}));

    compFolder = '';
    compName = '';

    for k = 1:numel(entries)
        candidate = fullfile(compRoot, entries(k).name, 'Model', [modelName '.slx']);
        if isfile(candidate)
            compFolder = fullfile(compRoot, entries(k).name);
            compName = entries(k).name;
            return;
        end
    end
end

function paramPath = locateParamFile(projectRoot, paramName)
    compRoot = fullfile(projectRoot, 'Components');
    hits = dir(fullfile(compRoot, '**', [paramName '.m']));
    if ~isempty(hits)
        paramPath = fullfile(hits(1).folder, hits(1).name);
    else
        paramPath = '';
    end
end


%% ========================= Project Generator =========================

function createMATLABProject(stageDir, presetName)
% Write .prj and resources/ XML files directly (no API call, no project switch).

    % ---- Write .prj stub ----
    prjFile = fullfile(stageDir, [presetName '.prj']);
    fid = fopen(prjFile, 'w');
    fprintf(fid, '<?xml version="1.0" encoding="UTF-8"?>\n');
    fprintf(fid, '<MATLABProject xmlns="http://www.mathworks.com/MATLABProjectFile" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.0"/>\n');
    fclose(fid);

    % ---- Build resources/project/ structure ----
    resDir = fullfile(stageDir, 'resources', 'project');
    mkdir(resDir);

    % Top-level metadata
    writeXml(fullfile(resDir, 'Project.xml'), '<Info MetadataType="fixedPathV2"/>');
    writeXml(fullfile(resDir, 'rootp.xml'), '<Info/>');

    % Root folder
    rootDir = fullfile(resDir, 'root');
    mkdir(rootDir);

    % Project name
    writeXml(fullfile(rootDir, 'projectNamed.xml'), ...
        sprintf('<Info Name="%s"/>', presetName));
    writeXml(fullfile(rootDir, 'projectNamep.xml'), ...
        '<Info location="ProjectData" type="Info"/>');

    % Path container pointer
    pathContainerId = 'pathContainer01';
    writeXml(fullfile(rootDir, 'pathContainerp.xml'), ...
        '<Info location="Root" type="ProjectPath"/>');

    % Files container pointer
    writeXml(fullfile(rootDir, 'filesContainerp.xml'), ...
        '<Info location="Root" type="Files"/>');

    % ---- Collect path folders ----
    pathFolders = {'Model', 'Model/VehicleTemplate', 'Preset'};

    compDir = fullfile(stageDir, 'Components');
    if isfolder(compDir)
        entries = dir(compDir);
        entries = entries([entries.isdir]);
        entries = entries(~ismember({entries.name}, {'.','..'}));
        for k = 1:numel(entries)
            subEntries = dir(fullfile(compDir, entries(k).name));
            subEntries = subEntries([subEntries.isdir]);
            subEntries = subEntries(~ismember({subEntries.name}, {'.','..'}));
            for j = 1:numel(subEntries)
                pathFolders{end+1} = ['Components/' entries(k).name '/' subEntries(j).name]; %#ok<AGROW>
            end
        end
    end

    % ---- Write path entries ----
    pathDir = fullfile(resDir, pathContainerId);
    mkdir(pathDir);

    for k = 1:numel(pathFolders)
        tag = sprintf('path%03d', k);
        writeXml(fullfile(pathDir, [tag 'd.xml']), ...
            sprintf('<Info Ref="%s" Type="Relative"/>', pathFolders{k}));
        writeXml(fullfile(pathDir, [tag 'p.xml']), ...
            sprintf('<Info location="%s" type="Reference"/>', tag));
    end

    % ---- Write file entries ----
    fileDir = fullfile(resDir, 'fileEntries');
    mkdir(fileDir);

    allFiles = dir(fullfile(stageDir, '**', '*'));
    allFiles = allFiles(~[allFiles.isdir]);
    fileIdx = 0;
    for k = 1:numel(allFiles)
        filePath = fullfile(allFiles(k).folder, allFiles(k).name);
        if contains(filePath, fullfile(stageDir, 'resources'))
            continue;
        end
        relFile = strrep(filePath, [stageDir filesep], '');
        relFile = strrep(relFile, '\', '/');
        fileIdx = fileIdx + 1;
        tag = sprintf('file%04d', fileIdx);
        writeXml(fullfile(fileDir, [tag 'p.xml']), ...
            sprintf('<Info location="%s" type="File"/>', relFile));
    end
end


function writeXml(filePath, content)
    fid = fopen(filePath, 'w');
    fprintf(fid, '<?xml version="1.0" encoding="UTF-8"?>\n');
    fprintf(fid, '%s', content);
    fclose(fid);
end

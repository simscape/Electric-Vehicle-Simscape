function outPath = exportParamScript(app, outFile, state)
%EXPORTPARAMSCRIPT Generate a BEV parameter setup script.
%   outPath = exportParamScript(app)                — save dialog, builds state
%   outPath = exportParamScript(app, outFile)       — explicit path, builds state
%   outPath = exportParamScript(app, outFile, state) — explicit path and state
%
%   The generated script requires the BEV project to be open. In-project
%   param folders resolve automatically through the project's path
%   management. addpath calls are emitted only for param files linked
%   from outside the project tree; these are flagged as machine-specific
%   in the generated script.

    if nargin < 2, outFile = ""; end
    if nargin < 3, state = buildSetupState(app); end

    % ---- Read identifiers from flat state ----
    try
        projectRoot = char(matlab.project.rootProject().RootFolder);
    catch ME
        warning('BEVapp:exportParamScript', ...
            'Project not loaded, using state.Root: %s', ME.message);
        projectRoot = state.Root;
    end

    topModel = state.BEVModel;
    if isempty(topModel)
        error('exportParamScript:NoTopModel', ...
            'Top model name is missing or empty.');
    end

    % Default output path — show save dialog defaulting to Script_Data/Setup/User/
    if strlength(string(outFile)) == 0
        defaultDir    = getUserSetupScriptFolder(projectRoot);
        suggestedName = 'setupModelParameters.m';
        [file, path]  = uiputfile('*.m', 'Save Param Setup Script', ...
            fullfile(defaultDir, suggestedName));
        if isequal(file, 0)
            outPath = '';
            return;
        end
        outFile = fullfile(path, file);
    end
    outFile = string(ensureExtension(char(outFile), '.m'));

    % ---- Extract environment values from state ----
    env = state.Environment;
    ambTempKelvin    = sprintf('%g+273.15', double(env.AmbientTemp));
    cabinTempKelvin  = sprintf('%g+273.15', double(env.CabinSetpoint));
    acStatusStr      = mat2str(logical(state.OperatingModes.ACOn));
    ambPressureMPa   = sprintf('%g/10',     double(env.AmbPressure));
    relHumidityStr   = sprintf('%g',        double(env.RelHumidity));
    co2FractionStr   = sprintf('%g',        double(env.CO2Fraction));
    acEnabled        = state.OperatingModes.ACEnabled;
    controlActive    = state.Controls.Enabled;

    % ---- Collect and validate param file links ----
    paramLinks = collectParamLinksFromState(state);
    if isempty(paramLinks)
        error('exportParamScript:NoComponents', ...
            'No component instances found.');
    end

    paramPaths = {paramLinks.ParamFilePath};
    isMissing = cellfun(@(p) isempty(p) || exist(p, 'file') ~= 2, paramPaths);
    if any(isMissing)
        offenders = strjoin({paramLinks(isMissing).Comp}, ', ');
        warning('exportParamScript:MissingParams', ...
            'Param file(s) not linked on: %s. Link them before exporting.', ...
            offenders);
    end
    paramLinks(isMissing) = [];

    % ---- Build param call lines and addpath entries ----
    [paramCallLines, externalFolders] = buildParamCallLines(paramLinks, projectRoot);

    % ---- Assemble script ----
    L = strings(0, 1);

    % Header
    L = [L;
        "%% BEV plant model main param file"
        "% Parameters for BEV plant model"
        "% Set the environment and HVAC variables"
        "% Load battery characteristics"
        "% Load all supporting Param files and data"
        "%"
        "% NOTE: Run setupModelReferences.m first to set all Subsystem"
        "% References before running this parameter script."
        "%"
        "% Copyright 2022 - 2026 The MathWorks, Inc."
        ""];

    % Environment
    L = [L;
        "%% Environment setting"
        "% Scenario settings"
        sprintf("vehicleThermal.ambient   = %s;          %% [K] Ambient temperature", ...
            ambTempKelvin)
        ""];

    % Project-open check preamble
    L = [L;
        "%% Check that project is open"
        "try"
        "    prjRoot = matlab.project.rootProject().RootFolder;"
        "catch"
        "    error(['This script requires the BEV project to be open. ' ..."
        "           'Open ElectricVehicleSimscape.prj and re-run.']);"
        "end"
        ""];

    % External addpath block (only for param files outside the project tree)
    if ~isempty(externalFolders)
        L = [L; "%% External param file folders (machine-specific)"];
        for i = 1:numel(externalFolders)
            L = [L; sprintf("addpath('%s');   %% External - %s", ...
                escapeSingleQuotes(char(externalFolders(i).Folder)), ...
                externalFolders(i).Component)]; %#ok<AGROW>
        end
        L = [L; ""];
    end

    % Thermal / HVAC initialization
    if acEnabled
        acComment = "";
    else
        acComment = "**NOT USED** ";
    end
    L = [L;
        "%% Initialization from the UI for thermal and HVAC"
        sprintf("vehicleThermal.CabinSpTp = %s;        %% %s[K] Cabin set point for HVAC", ...
            cabinTempKelvin, acComment)
        sprintf("vehicleThermal.AConoff   = %s;        %% %sAC on/off flag, On==1, Off==0", ...
            acStatusStr, acComment)
        sprintf("vehicleThermal.cabin_T_init    = vehicleThermal.ambient;   %% [K] Cabin initial temp")
        sprintf("vehicleThermal.coolant_T_init  = vehicleThermal.ambient;   %% [K] Coolant initial temp")
        sprintf("vehicleThermal.cabin_CO2_init  = %s;   %% Cabin initial CO2", co2FractionStr)
        sprintf("vehicleThermal.cabin_RH_init   = %s;   %% Cabin initial humidity", relHumidityStr)
        sprintf("vehicleThermal.cabin_p_init    = %s;   %% [MPa] Cabin initial pressure", ambPressureMPa)
        sprintf("vehicleThermal.coolant_p_init  = %s;   %% [MPa] Coolant initial pressure", ambPressureMPa)
        ""];

    % Component params
    L = [L;
        "%% Component params"
        string(paramCallLines(:))
        ""];

    % Controller params
    controllerParamFile = fullfile(projectRoot, ...
        'Components', 'Controller', 'Model', 'ControllerParams.m');
    if controlActive && exist(controllerParamFile, 'file') == 2
        L = [L;
            "%% Controller params"
            "ControllerParams;"
            ""];
    end

    % System parameters
    L = appendSystemParams(L, state.SystemParameter);

    % ---- Write file ----
    fid = fopen(outFile, 'w');
    if fid <= 0
        error('exportParamScript:WriteFail', ...
            'Unable to open file for writing: %s', outFile);
    end
    fileCleanup = onCleanup(@() fclose(fid));
    fprintf(fid, '%s\n', strjoin(cellstr(L), newline));

    outPath = char(outFile);

    % Notify user
    try
        uialert(app.UIFigure, ...
            sprintf('Param setup script written:\n%s', outPath), ...
            'Param Script Exported', 'Icon', 'success');
    catch
        fprintf('Param setup script written: %s\n', outPath);
    end
end

%% ========================= Local helpers =========================

function [callLines, externalFolders] = buildParamCallLines(paramLinks, projectRoot)
%BUILDPARAMCALLLINES Convert param file links into script call lines.
%   For .m files with valid MATLAB names: emit bare function call.
%   Otherwise: emit run('full/path').
%   Duplicate param files (e.g. two instances sharing the same script)
%   are emitted only once — calling a stateless param script twice is
%   redundant and clutters the generated output.
%   In-project param folders are discarded (the project path handles them).
%   Only external (out-of-project) folders are returned for addpath emission.
    callLines  = strings(0, 1);
    extFolders = strings(0, 1);
    extComps   = strings(0, 1);
    seenFiles  = containers.Map();

    % Normalize projectRoot for comparison
    normRoot = strrep(char(projectRoot), '\', '/');
    if ~endsWith(normRoot, '/'), normRoot = [normRoot '/']; end

    for i = 1:numel(paramLinks)
        filePath = paramLinks(i).ParamFilePath;

        % ---- Skip duplicate param files ----
        normPath = lower(strrep(char(filePath), '\', '/'));
        if isKey(seenFiles, normPath), continue; end
        seenFiles(normPath) = true;

        [folder, baseName, ext] = fileparts(filePath);

        if strcmpi(ext, '.m') && isvarname(baseName)
            callLines(end+1) = sprintf('%s;', baseName); %#ok<AGROW>

            % Only collect external (out-of-project) folders
            normFolder = strrep(char(folder), '\', '/');
            if ~startsWith(normFolder, normRoot, 'IgnoreCase', ispc)
                extFolders(end+1) = string(folder); %#ok<AGROW>
                extComps(end+1)   = string(paramLinks(i).Comp); %#ok<AGROW>
            end
        else
            callLines(end+1) = sprintf("run('%s');", ...
                escapeSingleQuotes(filePath)); %#ok<AGROW>
        end
    end

    % Deduplicate external folders
    externalFolders = struct('Folder', {}, 'Component', {});
    if ~isempty(extFolders)
        [uFolders, idx] = unique(extFolders);
        for j = 1:numel(uFolders)
            externalFolders(end+1).Folder    = char(uFolders(j)); %#ok<AGROW>
            externalFolders(end).Component   = char(extComps(idx(j)));
        end
    end
end

function L = appendSystemParams(L, sysParam)
%APPENDSYSTEMPARAMS Add system parameter calls to script lines.
    if iscell(sysParam), sysParam = string(sysParam); end
    sysParam = sysParam(strlength(sysParam) > 0 & sysParam ~= "NA");
    if isempty(sysParam), return; end

    L = [L; "%% System parameters"];
    for sp = 1:numel(sysParam)
        L = [L; sprintf('%s;', sysParam(sp))]; %#ok<AGROW>
    end
    L = [L; ""];
end

function paramLinks = collectParamLinksFromState(state)
%COLLECTPARAMLINKSFROMSTATE Extract param file paths from state Components.
%   Supports both unified (Selections) and legacy (Instances as struct) format.
    paramLinks = struct('Comp', {}, 'ParamFilePath', {});
    if ~isfield(state, 'Components'), return; end

    compTypes = fieldnames(state.Components);
    for c = 1:numel(compTypes)
        comp = state.Components.(compTypes{c});

        if isfield(comp, 'Selections') && isstruct(comp.Selections)
            selData = comp.Selections;
        elseif isfield(comp, 'Instances') && isstruct(comp.Instances)
            selData = comp.Instances;
        else
            continue;
        end

        instKeys = fieldnames(selData);
        for i = 1:numel(instKeys)
            inst = selData.(instKeys{i});

            paramPath = '';
            if isfield(inst, 'ParamFile')
                paramPath = char(inst.ParamFile);
            end

            instanceLabel = instKeys{i};
            if isfield(inst, 'Label')
                instanceLabel = char(inst.Label);
            end

            paramLinks(end+1).Comp = sprintf('%s / %s', compTypes{c}, instanceLabel); %#ok<AGROW>
            paramLinks(end).ParamFilePath = paramPath;
        end
    end
end

function outPath = ensureExtension(pathStr, ext)
%ENSUREEXTENSION Append extension if not already present.
    [p, f, e] = fileparts(pathStr);
    if strcmpi(e, ext)
        outPath = pathStr;
    else
        outPath = fullfile(p, [f ext]);
    end
end

function s = escapeSingleQuotes(p)
%ESCAPESINGLEQUOTES Double-up single quotes for MATLAB string literals.
    s = strrep(p, '''', '''''');
end

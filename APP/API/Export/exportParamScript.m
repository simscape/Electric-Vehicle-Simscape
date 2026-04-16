function exportParamScript(app, outFile, state)
%EXPORTPARAMSCRIPT Generate a BEV parameter setup script.
%   exportParamScript(app, outFile)          — builds state from app
%   exportParamScript(app, outFile, state)   — uses pre-built setupState
%
%   The generated script:
%     - Sets environment/thermal variables from the app UI
%     - Calls all linked per-instance param files
%     - Optionally includes controller and system parameter calls

    if nargin < 2, outFile = ""; end
    if nargin < 3, state = buildSetupState(app); end

    % ---- Read identifiers from flat state ----
    try
        projectRoot = char(matlab.project.rootProject().RootFolder);
    catch
        projectRoot = state.Root;
    end

    topModel = state.BEVModel;
    if isempty(topModel)
        error('exportParamScript:NoTopModel', ...
            'Top model name is missing or empty.');
    end

    % Default output path
    if strlength(string(outFile)) == 0
        outFile = fullfile(projectRoot, 'Model', ...
            sprintf('%s_params_setup.m', topModel));
    end
    outFile = string(ensureExtension(char(outFile), '.m'));

    % ---- Extract environment values from state ----
    env = state.Environment;
    ambTempKelvin    = sprintf('%g+273.15', double(env.AmbientTemp));
    cabinTempKelvin  = sprintf('%g+273.15', double(env.CabinSetpoint));
    acStatusStr      = mat2str(logical(state.Dashboard.ACOn));
    ambPressureMPa   = sprintf('%g/10',     double(env.AmbPressure));
    relHumidityStr   = sprintf('%g',        double(env.RelHumidity));
    co2FractionStr   = sprintf('%g',        double(env.CO2Fraction));
    acEnabled        = state.Dashboard.ACEnabled;
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
    [paramCallLines, addpathFolders] = buildParamCallLines(paramLinks);

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
        "% Copyright 2022 - 2025 The MathWorks, Inc."
        ""];

    % Environment
    L = [L;
        "%% Environment setting"
        "% Scenario settings"
        sprintf("vehicleThermal.ambient   = %s;          %% [K] Ambient temperature", ...
            ambTempKelvin)
        ""];

    % Addpath block (only if param scripts are not on path)
    if ~isempty(addpathFolders)
        L = [L; "%% Ensure Param script folders are on path"];
        for i = 1:numel(addpathFolders)
            L = [L; sprintf("addpath('%s');", ...
                escapeSingleQuotes(char(addpathFolders(i))))]; %#ok<AGROW>
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

    % Notify user
    try
        uialert(app.UIFigure, ...
            sprintf('Param setup script written:\n%s', char(outFile)), ...
            'Param Script Exported', 'Icon', 'success');
    catch
        fprintf('Param setup script written: %s\n', char(outFile));
    end
end

%% ========================= Local helpers =========================

function [callLines, addpathFolders] = buildParamCallLines(paramLinks)
%BUILDPARAMCALLLINES Convert param file links into script call lines.
%   For .m files with valid MATLAB names: emit bare function call.
%   Otherwise: emit run('full/path').
    callLines    = strings(0, 1);
    addpathFolders = strings(0, 1);

    for i = 1:numel(paramLinks)
        filePath = paramLinks(i).ParamFilePath;
        [folder, baseName, ext] = fileparts(filePath);

        if strcmpi(ext, '.m') && isvarname(baseName)
            callLines(end+1) = sprintf('%s;', baseName); %#ok<AGROW>
            addpathFolders(end+1) = string(folder); %#ok<AGROW>
        else
            callLines(end+1) = sprintf("run('%s');", ...
                escapeSingleQuotes(filePath)); %#ok<AGROW>
        end
    end

    % Deduplicate folders and remove ones already on path
    addpathFolders = unique(addpathFolders(addpathFolders ~= ""));
    onPath = arrayfun(@(f) ~isempty(which(f)), addpathFolders);
    addpathFolders(onPath) = [];
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

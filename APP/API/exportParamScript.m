function exportParamScript(app, outFile, state)
% EXPORTPARAMSCRIPT
% Generate a thin BEV *parameter* setup script that:
%   - Assigns a few high-level parameters from the App UI
%   - Calls all linked per-instance Param files (in a readable list)
%
% Usage:
%   exportParamScript(app, outFile)          % builds state from app
%   exportParamScript(app, outFile, state)   % uses pre-built setupState

    if nargin < 2, outFile = ""; end
    if nargin < 3, state = buildSetupState(app); end

    % ---- Resolve template from state ----
    flds = fieldnames(state);
    templateName = flds{1};
    tmpl = state.(templateName);

    try
        projRoot = char(matlab.project.rootProject().RootFolder);
    catch
        projRoot = tmpl.Root;
    end
    topModel = tmpl.BEVModel;
    if isempty(topModel)
        error('exportParamScript:NoTopModel','Top model name is missing or empty.');
    end

    if strlength(string(outFile)) == 0
        outFile = fullfile(projRoot, 'Model', sprintf('%s_params_setup.m', topModel));
    end
    outFile  = string(ensureExt(char(outFile), '.m'));

    % ---- Read selections from state ----
    ambTemp  = tmpl.Environment.AmbientTemp;
    cabTemp  = tmpl.Environment.CabinSetpoint;
    ambPress = tmpl.Environment.AmbPressure;
    relHumid = tmpl.Environment.RelHumidity;
    co2Frac  = tmpl.Environment.CO2Fraction;

    acOn      = tmpl.Dashboard.ACOn;
    acEnabled = tmpl.Dashboard.ACEnabled;

    controlActive = tmpl.Controls.Enabled;

    % Convert to emitted literals (all must be strings for %s in emit block)
    ambTempK = sprintf('%g+273.15', double(ambTemp));
    cabTempK = sprintf('%g+273.15', double(cabTemp));
    acStatus = mat2str(logical(acOn));
    ambPress = sprintf('%g/10', double(ambPress));
    relHumid = sprintf('%g', double(relHumid));
    co2Frac  = sprintf('%g', double(co2Frac));

    % ---- Collect linked Param files from state ----
    compInfo = collectParamLinksFromState(tmpl);
    if isempty(compInfo)
        error('exportParamScript:NoComponents','No component instances found.');
    end

    % Fail fast if any link is missing/broken
    pths = {compInfo.ParamFilePath};
    missingFile  = cellfun(@(p) isempty(p) || exist(p,'file')~=2, pths);
    if any(missingFile)
        offenders = strjoin({compInfo(missingFile).Comp}, ', ');
        warning('exportParamScript:MissingParams', ...
            'Param file(s) not linked on: %s. Link them before exporting.', offenders);
    end
    compInfo(missingFile) = [];

    % Create emission plan: for each file, prefer bare function call if valid MATLAB name.
    calls  = strings(0,1);
    folders = strings(0,1);
    params = strings(0,1);
    for i = 1:numel(compInfo)
        p = compInfo(i).ParamFilePath;
        [folder, base, ext] = fileparts(p);
        if ~strcmpi(ext,'.m')
            calls(end+1) = sprintf("run('%s');", escapePath(p)); %#ok<AGROW>
        else
            if isvarname(base)
                calls(end+1) = sprintf('%s;', base); %#ok<AGROW>
                folders(end+1) = string(folder);     %#ok<AGROW>
                params(end+1) = string(base);        %#ok<AGROW>
            else
                calls(end+1) = sprintf("run('%s');", escapePath(p)); %#ok<AGROW>
            end
        end
    end
    folders = unique(folders(folders~=""));

    % ---- Emit script lines ----
    L = strings(0,1);

    L = [L;
        "%% BEV plant model main param file"
        "% Parameters for BEV plant model"
        "% Set the environment and HVAC variables"
        "% Load battery characteristics"
        "% Load all supporting Param files and data"
        "%"
        "% Copyright 2022 - 2025 The MathWorks, Inc."
        ""
        "%% Environment setting"
        "% Scenario settings"
        sprintf("vehicleThermal.ambient   = %s;          %% [K] Ambient temperature in K", ambTempK)
        ""
    ];

    % Addpath block (only if needed)
    if ~isempty(folders)
        L = [L; "%% Ensure Param script folders are on path"];
        for i = 1:numel(folders)
            if isempty(which(params(i)))
                L = [L; sprintf("addpath('%s');", escapePath(char(folders(i))))]; %#ok<AGROW>
            end
        end
        L = [L; ""];
    end

    % Initialization from the UI for thermal and HVAC
    L = [L; "%% Initialization from the UI for thermal and HVAC, only used when present"];
    if acEnabled
        L = [L;
            sprintf("vehicleThermal.CabinSpTp = %s;        %% [K] Cabin set point for HVAC",   cabTempK)
            sprintf("vehicleThermal.AConoff   = %s;        %% AC on/off flag, On==1, Off==0", acStatus)
        ];
    else
        L = [L;
            sprintf("vehicleThermal.CabinSpTp = %s;        %% **NOT USED** [K] Cabin set point for HVAC",   cabTempK)
            sprintf("vehicleThermal.AConoff   = %s;        %% **NOT USED** AC on/off flag, On==1, Off==0", acStatus)
        ];
    end
    L = [L;
        sprintf("vehicleThermal.cabin_T_init    = vehicleThermal.ambient;   %% [K] Cabin initial temp")
        sprintf("vehicleThermal.coolant_T_init  = vehicleThermal.ambient;   %% [K] Coolant initital temp")
        sprintf("vehicleThermal.cabin_CO2_init  = %s;   %% Cabin initital CO2",co2Frac)
        sprintf("vehicleThermal.cabin_RH_init  = %s;   %% Cabin initital humidity",relHumid)
        sprintf("vehicleThermal.cabin_p_init  = %s;   %% [Mpa] Cabin initital pressure",ambPress)
        sprintf("vehicleThermal.coolant_p_init  = %s;   %% [Mpa] Coolant initital pressure",ambPress)
        ""
    ];

    % Component params section
    L = [L; "%% Component params"];
    L     = string(L(:));
    calls = string(calls(:));
    L = [L; calls; ""];

    % ---- Controller params ----
    try
        controllerParamFile = fullfile(projRoot, 'Components', 'Controller', 'Model', 'ControllerParams.m');
        if app.ControlSelectionDropDown.Enable == "on" && exist(controllerParamFile, 'file') == 2
            L = [L; "%% Controller params"];
            L = [L; "ControllerParams;"; ""];
        end
    catch
    end

    % ---- System params from state ----
    sysParam = tmpl.SystemParameter;
    if iscell(sysParam), sysParam = string(sysParam); end
    sysParam = sysParam(strlength(sysParam) > 0 & sysParam ~= "NA");
    if ~isempty(sysParam)
        L = [L; "%% System parameters"];
        for sp = 1:numel(sysParam)
            L = [L; sprintf('%s;', sysParam(sp))]; %#ok<AGROW>
        end
        L = [L; ""];
    end

    % ---- Write file ----
    fid = fopen(outFile,'w');
    if fid <= 0
        error('exportParamScript:WriteFail','Unable to open file for writing: %s', outFile);
    end
    c = onCleanup(@() fclose(fid));
    fprintf(fid,'%s\n', strjoin(cellstr(L), newline));

    try
        uialert(app.UIFigure, sprintf('Param setup script written:\n%s', char(outFile)), ...
            'Param Script Exported','Icon','success');
    catch
        fprintf('Param setup script written: %s\n', char(outFile));
    end
end

% ======================================================================
% Local helpers
% ======================================================================

function info = collectParamLinksFromState(tmpl)
% Build struct array from state Components hierarchy.
% Supports both unified format (Selections) and legacy format (Instances as struct).
    info = struct('Comp',{},'ParamFilePath',{});
    if ~isfield(tmpl, 'Components'), return; end
    compTypes = fieldnames(tmpl.Components);
    for c = 1:numel(compTypes)
        comp = tmpl.Components.(compTypes{c});
        % Unified format: Selections; legacy: Instances (as struct)
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
            pth = '';
            if isfield(inst, 'ParamFile'), pth = char(inst.ParamFile); end
            label = instKeys{i};
            if isfield(inst, 'Label'), label = char(inst.Label); end
            info(end+1).Comp = sprintf('%s / %s', compTypes{c}, label); %#ok<AGROW>
            info(end).ParamFilePath = pth;
        end
    end
end

function out = ensureExt(pathStr, ext)
    [p,f,e] = fileparts(pathStr);
    if ~strcmpi(e, ext), out = fullfile(p, [f ext]);
    else,                out = pathStr;
    end
end

function s = escapePath(p)
    s = strrep(p, '''', '''''');
end

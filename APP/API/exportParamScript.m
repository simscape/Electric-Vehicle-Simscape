function exportParamScript(app, outFile)
% EXPORTPARAMSCRIPT
% Generate a thin BEV *parameter* setup script that:
%   - Assigns a few high-level parameters from the App UI
%   - Calls all linked per-instance Param files (in a readable list)
%
%
% Usage:
%   exportParamScript(app);  % writes <ProjectRoot>/Model/<TopModelName>_params_setup.m
%   exportParamScript(app, 'C:\path\MyParams.m');

    arguments
        app
        outFile string = ""
    end

    % -------- Resolve basics --------
    projRoot = resolveProjectRoot(app);
    topModel = erase(app.BEVModelDropDown.Value,'.slx');
    if isempty(topModel)
        error('exportParamScript:NoTopModel','app.TopModelName is missing or empty.');
    end

    if strlength(outFile) == 0
        outFile = fullfile(projRoot, 'Model', sprintf('%s_params_setup.m', topModel));
    end
    outFile  = string(ensureExt(char(outFile), '.m'));
    outDir   = fileparts(outFile);
    % if ~isempty(outDir) && ~exist(outDir,'dir'), mkdir(outDir); end

    % -------- Gather UI inputs (with sensible defaults) --------
    ambTemp   = getIfExists(app,'AmbTempEditField',       25);   % deg C
    cabTemp   = getIfExists(app,'CabinTempSetpointEditField', 20);   % deg C
    acButton   = getIfExists(app,'ACButton',            true);% boolean
    ambPress   = getIfExists(app,'AmbPressEditField',            1);% bar
    relHumid   = getIfExists(app,'RelHumidityEditField',            0.5);
    co2Frac   = getIfExists(app,'CO2FractionEditField',            0.0004);

    % Convert to emitted literals
    ambTempK = sprintf('%g+273.15', double(ambTemp));
    cabTempK = sprintf('%g+273.15', double(cabTemp));
    acStatus   = mat2str(logical(acButton));
    ambPress   =  sprintf('%g/10', double(ambPress));


    % -------- Collect linked Param files --------
    compInfo = collectComponentParamLinks(app);   % struct: Comp, ParamFilePath
    if isempty(compInfo)
        error('exportParamScript:NoComponents','No component dropdowns / instances found.');
    end

    % Fail fast if any link is missing/broken
    pths = {compInfo.ParamFilePath};
    missingFile  = cellfun(@(p) isempty(p) || exist(p,'file')~=2, pths);
    if any(missingFile)
        offenders = strjoin({compInfo(missingFile).Comp}, ', ');
        warning('exportParamScript:MissingParams', ...
            'Param file(s) not linked on: %s. Link them before exporting.', offenders);
    end
       compInfo(find(missingFile)) = [];
    % Create emission plan: for each file, prefer bare function call if valid MATLAB name.
    calls  = strings(0,1);
    folders = strings(0,1);
    params = strings(0,1);
    for i = 1:numel(compInfo)
        p = compInfo(i).ParamFilePath;
        [folder, base, ext] = fileparts(p);
        if ~strcmpi(ext,'.m'), % non .m — force run
            calls(end+1) = sprintf("run('%s');", escapePath(p)); %#ok<AGROW>
        else
            if isvarname(base)
                % We can call as a function/script on path; remember folder for addpath
                calls(end+1) = sprintf('%s;', base); %#ok<AGROW>
                folders(end+1) = string(folder);     %#ok<AGROW>
                params(end+1) = string(base);     %#ok<AGROW>
            else
                % Weird name — fall back to run('fullpath')
                calls(end+1) = sprintf("run('%s');", escapePath(p)); %#ok<AGROW>
            end
        end
    end

    % Unique folders for addpath (only for those we plan to call bare)
    folders = unique(folders(folders~=""));

    % -------- Emit script lines --------
    L = strings(0,1);

    % Header (mirrors your style)
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
        L = [L;
            "%% Ensure Param script folders are on path"
        ];
        for i = 1:numel(folders)
            if isempty(which(params(i)))
                L = [L; sprintf("addpath('%s');", escapePath(char(folders(i))))]; %#ok<AGROW>
            end

            
        end
        L = [L; ""];
    end

    % Component params section
    L = [L;
        "%% Component params"
        ];
    % If you want a fixed canonical ordering, sort here:
    % [~, order] = sort(lower({compInfo.Comp})); calls = calls(order);
    L     = string(L(:));
    calls = string(calls(:));
    L = [L; calls; ""];

    % Optional derived/thermal section
    L = [L;
        "%%VehicleThermal based parameters"
        "% (Place any derived vehicle thermal params here if needed)"
        ""
        "%% Initialization from the UI for thermal and HVAC, only used when present"
        ];
    if app.ACButton.Enable == "on"
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
        sprintf("vehicleThermal.coolant_T_init  = vehicleThermal.ambient;   %% [K] Coolant initital temp")
        sprintf("vehicleThermal.cabin_CO2_init  = %s;   %% Cabin initital CO2",co2Frac)
        sprintf("vehicleThermal.cabin_RH_init  = %s;   %% Cabin initital humidity",relHumid)
        sprintf("vehicleThermal.cabin_p_init  = %s;   %% [Mpa] Cabin initital pressure",ambPress)
        sprintf("vehicleThermal.coolant_P_init  = %s;   %% [Mpa] Coolant initital pressure",ambPress)
        ""
        ];
    % -------- Write file --------
    fid = fopen(outFile,'w');
    if fid <= 0
        error('exportParamScript:WriteFail','Unable to open file for writing: %s', outFile);
    end
    c = onCleanup(@() fclose(fid));
    fprintf(fid,'%s\n', strjoin(cellstr(L), newline));

    % Minimal confirmation
    try
        uialert(app.UIFigure, sprintf('Param setup script written:\n%s', char(outFile)), ...
            'Param Script Exported','Icon','success');
    catch
        fprintf('Param setup script written: %s\n', char(outFile));
    end
end

% ======================================================================
% Local helpers (same file)
% ======================================================================

function val = getIfExists(app, prop, defaultVal)
    try
        if isprop(app, prop)
            v = app.(prop).Value;
            if ~isempty(v), val = v; return; end
        end
    catch
    end
    val = defaultVal;
end

function info = collectComponentParamLinks(app)
% Build struct array: info(i).Comp, info(i).ParamFilePath
    info = struct('Comp',{},'ParamFilePath',{});
    if ~isstruct(app.ComponentDropdowns), return; end
    Comps = fieldnames(app.ComponentDropdowns);
    for k = 1:numel(Comps)
        Component  = app.ComponentDropdowns.(Comps{k});
        pth = '';
        try
            if isprop(Component,'UserData') && ~isempty(Component.UserData) && isfield(Component.UserData,'ParamFile')
                pth = char(Component.UserData.ParamFile);
            end
        catch
        end
        info(end+1).Comp = Comps{k}; %#ok<AGROW>
        info(end).ParamFilePath = pth;
    end
end

function root = resolveProjectRoot(app)
% Use app.ProjectRoot if set; else MATLAB Project; else pwd.
root = getBEVProjectRoot(app);              % full path to the root folder
if isempty(root)
    try
        root = getBEVProjectRoot(app);                          % project root
    catch
        root = pwd;
    end
end
end

% function name = resolveTopModelName(app)
% % Return model name without .slx if provided.
%     name = '';
%     try
%         name = string(app.TopModelName);
%         if endsWith(name,".slx",'IgnoreCase',true)
%             name = erase(name,".slx");
%         end
%     catch
%     end
% end

function out = ensureExt(pathStr, ext)
    [p,f,e] = fileparts(pathStr);
    if ~strcmpi(e, ext)
        out = fullfile(p, [f ext]);
    else
        out = pathStr;
    end
end

function s = escapePath(p)
% Escape single quotes in a path literal.
    s = strrep(p, '''', '''''');
end

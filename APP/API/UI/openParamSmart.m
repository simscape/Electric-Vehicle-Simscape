function openParamSmart(app, compName, dd, rootFolder)
%OPENPARAMSMART Open linked param file, or fall back to auto-detect.

    % ---- 1. If a user-linked file exists, open it ----
    if isstruct(dd.UserData) && isfield(dd.UserData, 'ParamFile')
        linked = string(dd.UserData.ParamFile);

        if strlength(linked) > 0
            if exist(linked, 'file')
                edit(char(linked));
                return;
            end

            % Stale link: clear it and inform user
            try
                uialert(app.UIFigure, ...
                    "The linked param file no longer exists:" + newline + ...
                    linked + newline + newline + ...
                    "Clearing the link. Will fall back to auto-detect.", ...
                    "Linked File Missing", 'Icon', 'warning');
            catch ME
                warning('BEVapp:openParamSmart', 'uialert failed: %s', ME.message);
            end

            ud = dd.UserData;
            if isfield(ud, 'ParamFile')
                ud = rmfield(ud, 'ParamFile');
                dd.UserData = ud;
            end
        end
    end

    % ---- 2. Auto-derivation fallback ----
    openParamForCurrentSelection(app, compName, dd, rootFolder);
end

function openParamForCurrentSelection(app, compName, dd, rootFolder)
%OPENPARAMFORCURRENTSELECTION Derive <ModelName>Params.m from dropdown selection.

    val = char(dd.Value);

    if startsWith(string(val), "__MISSING__")
        try
            uialert(app.UIFigure, ...
                "This model is marked as missing on disk.", ...
                "Unavailable", "Icon", "warning");
        catch
        end
        return;
    end

    base      = regexprep(val, '\.slx$', '', 'ignorecase');
    paramName = [base 'Params.m'];

    % Prefer the component's Model folder
    modelFolder = '';
    if isstruct(dd.UserData) && isfield(dd.UserData, 'ModelFolder')
        modelFolder = dd.UserData.ModelFolder;
    end

    if ~isempty(modelFolder)
        candidate = fullfile(char(modelFolder), paramName);
    else
        candidate = fullfile(char(rootFolder), 'Components', char(compName), 'Model', paramName);
    end

    if exist(candidate, 'file')
        edit(candidate);
        return;
    end

    % Fallback: search the whole project
    hit = dir(fullfile(char(rootFolder), '**', paramName));
    if ~isempty(hit)
        edit(fullfile(hit(1).folder, hit(1).name));
        return;
    end

    % Not found
    try
        uialert(app.UIFigure, ...
            "Parameter script not found:" + newline + string(paramName), ...
            'Script not found', 'Icon', 'warning');
    catch
        warndlg("Parameter script not found: " + string(paramName), 'Script not found');
    end
end

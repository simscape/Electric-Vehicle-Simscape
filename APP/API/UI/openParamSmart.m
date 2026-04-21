function openParamSmart(app, compName, dd, rootFolder)
% OPENPARAMSMART Open the linked param file for a component instance.
%   openParamSmart(app, compName, dd, rootFolder)
%
%   If a user-linked file exists, opens it directly. If the link is stale,
%   clears it and falls back to auto-detection via <ModelName>Params.m.
%
% Copyright 2026 The MathWorks, Inc.

    % ---- 1. If a user-linked file exists, open it ----
    if isstruct(dd.UserData) && isfield(dd.UserData, 'ParamFile')
        linked = string(dd.UserData.ParamFile);

        if strlength(linked) > 0
            if exist(linked, 'file')
                edit(char(linked));
                return;
            end

            % Stale link: clear it and reset to default
            ud = dd.UserData;
            if isfield(ud, 'ParamFile')
                ud = rmfield(ud, 'ParamFile');
                dd.UserData = ud;
            end

            % Re-discover default param file
            if isstruct(dd.UserData) && isfield(dd.UserData, 'CompName')
                computeParamMissingNote(dd.UserData.CompName, dd, dd.UserData.RootFolder);
            end

            % Update tooltip
            if isstruct(dd.UserData) ...
                    && isfield(dd.UserData, 'ParamButton') ...
                    && ~isempty(dd.UserData.ParamButton) ...
                    && isvalid(dd.UserData.ParamButton)
                updateParamTooltip(dd.UserData.ParamButton, dd);
            end

            try
                uialert(app.UIFigure, ...
                    "The linked param file no longer exists:" + newline + ...
                    linked + newline + newline + ...
                    "Clearing the link. Will fall back to auto-detect.", ...
                    "Linked File Missing", 'Icon', 'warning');
            catch ME
                warning('BEVapp:openParamSmart', 'uialert failed: %s', ME.message);
            end
        end
    end

    % ---- 2. Auto-derivation fallback ----
    openParamForCurrentSelection(app, compName, dd, rootFolder);
end

function openParamForCurrentSelection(app, compName, dd, rootFolder)
% OPENPARAMFORCURRENTSELECTION Derive and open <ModelName>Params.m from the dropdown selection.
%   Checks the component's Model folder first, then falls back to project-wide search.

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

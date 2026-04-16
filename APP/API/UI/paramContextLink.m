function paramContextLink(app, btn, dd, rootFolder)
%PARAMCONTEXTLINK Context menu action: link a param file to this instance.
    % Prefer: existing linked folder > instance Model folder > project root
    startFolder = getParamStartFolder(dd, rootFolder);

    [f, p] = uigetfile({'*.m','MATLAB Files (*.m)'}, 'Select parameter file', startFolder);
    if isequal(f,0) || isequal(p,0)
        return; % canceled
    end

    chosen = fullfile(p, f);

    % Persist link without clobbering other UserData fields
    userDataSetField(dd, 'ParamFile', char(chosen));

    % Optional: show feedback & open immediately
    try
        msg = "Linked param file:" + newline + string(chosen);
        uialert(app.UIFigure, msg, "Param Linked", 'Icon','info');
    catch
    end
    edit(chosen);
    % After setting/clearing dd.UserData.ParamFile:
    updateParamTooltip(btn, dd, rootFolder);

    % Also refresh the red line:
    try
        if isstruct(dd.UserData) && isfield(dd.UserData,'ParamStatusLabel') && isvalid(dd.UserData.ParamStatusLabel)
            L = dd.UserData.ParamStatusLabel;
            % After linking: hide the "no param" message (auto is overridden by link)
            L.Text = "";
            L.Visible = 'off';
        end
    catch
    end
end

function startFolder = getParamStartFolder(dd, rootFolder)
%GETPARAMSTARTFOLDER Determine best starting folder for param file picker.
    startFolder = char(rootFolder);

    % If a linked file exists, start there
    try
        if isstruct(dd.UserData) && isfield(dd.UserData,'ParamFile')
            linked = string(dd.UserData.ParamFile);
            if strlength(linked) > 0
                lf = fileparts(char(linked));
                if exist(lf, 'dir')
                    startFolder = lf;
                    return
                end
            end
        end
    catch
    end

    % Else prefer the ModelFolder recorded on the dropdown
    try
        if isstruct(dd.UserData) && isfield(dd.UserData,'ModelFolder')
            mf = dd.UserData.ModelFolder;
            if (ischar(mf) || isstring(mf))
                mf = char(mf);
                if exist(mf, 'dir')
                    startFolder = mf;
                    return
                end
            end
        end
    catch
    end

    % Else, if current dropdown value is a model in that folder, use that folder
    try
        val = string(dd.Value);
        if ~startsWith(val,"__MISSING__")
            if isstruct(dd.UserData) && isfield(dd.UserData,'ModelFolder')
                candidate = fullfile(char(dd.UserData.ModelFolder), char(val));
                if exist(fileparts(candidate), 'dir')
                    startFolder = fileparts(candidate);
                    return
                end
            end
        end
    catch
    end
end

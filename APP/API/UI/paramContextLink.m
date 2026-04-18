function paramContextLink(app, btn, dd, rootFolder)
%PARAMCONTEXTLINK Context menu action: link a param file to this instance.

    startFolder = getParamStartFolder(dd, rootFolder);

    [f, p] = uigetfile({'*.m', 'MATLAB Files (*.m)'}, 'Select parameter file', startFolder);
    if isequal(f, 0) || isequal(p, 0)
        return;
    end

    chosen = fullfile(p, f);

    % Persist link without clobbering other UserData fields
    userDataSetField(dd, 'ParamFile', char(chosen));

    % Show feedback and open immediately
    try
        uialert(app.UIFigure, ...
            "Linked param file:" + newline + string(chosen), ...
            "Param Linked", 'Icon', 'info');
    catch ME
        warning('BEVapp:paramContextLink', 'uialert failed: %s', ME.message);
    end

    edit(chosen);

    % Refresh tooltip
    updateParamTooltip(btn, dd);

    % Hide the red "no param" note
    if isstruct(dd.UserData) ...
            && isfield(dd.UserData, 'ParamStatusLabel') ...
            && isvalid(dd.UserData.ParamStatusLabel)
        dd.UserData.ParamStatusLabel.Text    = "";
        dd.UserData.ParamStatusLabel.Visible = 'off';
    end
end

function startFolder = getParamStartFolder(dd, rootFolder)
%GETPARAMSTARTFOLDER Determine best starting folder for param file picker.
    startFolder = char(rootFolder);

    % If a linked file exists, start in its folder
    if isstruct(dd.UserData) && isfield(dd.UserData, 'ParamFile')
        linked = string(dd.UserData.ParamFile);

        if strlength(linked) > 0
            linkedFolder = fileparts(char(linked));
            if isfolder(linkedFolder)
                startFolder = linkedFolder;
                return;
            end
        end
    end

    % Else prefer the ModelFolder recorded on the dropdown
    if isstruct(dd.UserData) && isfield(dd.UserData, 'ModelFolder')
        mf = char(dd.UserData.ModelFolder);

        if isfolder(mf)
            startFolder = mf;
        end
    end
end

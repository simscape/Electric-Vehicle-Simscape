function paramContextLink(app, btn, dd, rootFolder)
% PARAMCONTEXTLINK Link a user-chosen param file to this component instance.
%   paramContextLink(app, btn, dd, rootFolder)
%
%   Opens a file picker, persists the chosen file in dd.UserData.ParamFile,
%   refreshes the tooltip, and hides the "no param" warning label.
%
% Copyright 2026 The MathWorks, Inc.

    startFolder = getParamStartFolder(dd, rootFolder);

    [fileName, selectedFolder] = uigetfile({'*.m', 'MATLAB Files (*.m)'}, 'Select parameter file', startFolder);
    if isequal(fileName, 0) || isequal(selectedFolder, 0)
        return;
    end

    chosen = fullfile(selectedFolder, fileName);

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
% GETPARAMSTARTFOLDER Pick the best starting folder for the param file browser.
%   Prefers the current linked file's folder, then the model folder, then rootFolder.
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
        modelFolder = char(dd.UserData.ModelFolder);

        if isfolder(modelFolder)
            startFolder = modelFolder;
        end
    end
end

function promoteToPreset(state, sourceFolder)
% PROMOTETOPRESET Offer to save the current model setup as a reusable preset.
%   promoteToPreset(state, sourceFolder)
%
%   After Model Setup completes, asks the user whether to save the
%   generated folder as a preset under Script_Data/Setup/Preset/.
%   Existing presets are replaced after the new files are prepared.
%
% Copyright 2026 The MathWorks, Inc.

    suppressDialogs = isequal( ...
        getappdata(groot, 'BEV_SUPPRESS_DIALOGS'), true);

    if ~suppressDialogs
        [saveRequested, folderName] = requestPresetName(state);
        if saveRequested
            projectRoot = getProjectRoot(state);
            presetDir = fullfile( ...
                projectRoot, 'Script_Data', 'Setup', 'Preset');
            targetDir = fullfile(presetDir, folderName);

            overwriteApproved = ~isfolder(targetDir);
            if isfolder(targetDir)
                overwrite = questdlg( ...
                    sprintf( ...
                        'Preset "%s" already exists. Overwrite?', ...
                        folderName), ...
                    'Overwrite Preset', ...
                    'Overwrite', 'Cancel', 'Cancel');
                overwriteApproved = strcmp(overwrite, 'Overwrite');
            end

            if overwriteApproved
                replacePresetFolder(sourceFolder, targetDir);
                fprintf('Preset saved: %s\n', targetDir);
            end
        end
    end
end


function [saveRequested, folderName] = requestPresetName(state)
% REQUESTPRESETNAME Ask whether and where to save the generated preset.

    saveRequested = false;
    folderName = '';

    answer = questdlg( ...
        'Save this setup as a preset?', ...
        'Save Preset', 'Yes', 'No', 'No');

    if strcmp(answer, 'Yes')
        defaultName = [char(state.TemplateName) '_custom'];
        result = inputdlg( ...
            'Preset folder name:', 'Save as Preset', 1, {defaultName});

        if ~isempty(result) && ~isempty(strtrim(result{1}))
            candidateName = strtrim(result{1});
            hasInvalidCharacter = ~isempty( ...
                regexp(candidateName, '[<>:"/\\|?*]', 'once'));

            if hasInvalidCharacter
                errordlg( ...
                    'Folder name contains invalid characters.', ...
                    'Invalid Name');
            else
                folderName = candidateName;
                saveRequested = true;
            end
        end
    end
end


function projectRoot = getProjectRoot(state)
% GETPROJECTROOT Resolve the active project root with a state fallback.

    try
        projectRoot = char(matlab.project.rootProject().RootFolder);
    catch
        projectRoot = state.Root;
    end
end

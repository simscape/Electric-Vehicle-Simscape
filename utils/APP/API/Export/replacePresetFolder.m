function replacePresetFolder(sourceFolder, targetFolder)
% REPLACEPRESETFOLDER Replace a preset after preparing its files.
%   The existing preset is restored when installation fails.
%
% Copyright 2026 The MathWorks, Inc.

    arguments
        sourceFolder {mustBeTextScalar}
        targetFolder {mustBeTextScalar}
    end

    sourceFolder = char(sourceFolder);
    targetFolder = char(targetFolder);

    if ~isfolder(sourceFolder)
        error("BEVapp:replacePresetFolder:SourceMissing", ...
            "Preset source folder does not exist: %s", sourceFolder);
    end

    if isfile(targetFolder)
        error("BEVapp:replacePresetFolder:InvalidTarget", ...
            "Preset target exists but is not a folder: %s", targetFolder);
    end

    targetParent = fileparts(targetFolder);
    if ~isfolder(targetParent)
        mkdir(targetParent);
    end

    temporaryFolder = tempname(targetParent);
    stagedFolder = fullfile(temporaryFolder, "new");
    backupFolder = fullfile(temporaryFolder, "old");

    mkdir(temporaryFolder);
    folderCleanup = onCleanup(@() cleanPresetFolders( ...
        temporaryFolder, backupFolder, targetFolder));

    copyfile(sourceFolder, stagedFolder);

    paramFiles = dir(fullfile(stagedFolder, "*_params_setup.m"));
    paramFiles = paramFiles(~[paramFiles.isdir]);
    if ~isempty(paramFiles)
        oldParamName = paramFiles(1).name;
        newParamName = "setupModelParameters.m";
        oldParamPath = fullfile(stagedFolder, oldParamName);
        newParamPath = fullfile(stagedFolder, newParamName);

        movefile(oldParamPath, newParamPath);

        applyFile = fullfile(stagedFolder, "applyPreset.m");
        if isfile(applyFile)
            applyText = fileread(applyFile);
            applyText = strrep(applyText, oldParamName, newParamName);
            writelines(string(applyText), applyFile);
        end
    end

    if isfolder(targetFolder)
        movefile(targetFolder, backupFolder);
    end

    movefile(stagedFolder, targetFolder);

    if isfolder(backupFolder)
        [backupRemoved, removeMessage] = rmdir(backupFolder, "s");
        if ~backupRemoved
            warning("BEVapp:replacePresetFolder:BackupCleanupFailed", ...
                "The preset was saved, but its backup remains at %s: %s", ...
                backupFolder, removeMessage);
        end
    end
end


function cleanPresetFolders(temporaryFolder, backupFolder, targetFolder)
% CLEANPRESETFOLDERS Restore the previous preset and remove temporary files.

    stagedFolder = fullfile(temporaryFolder, "new");
    targetExists = isfile(targetFolder) || isfolder(targetFolder);
    if isfolder(backupFolder) && ~targetExists
        [restored, restoreMessage] = movefile(backupFolder, targetFolder);
        if ~restored
            warning("BEVapp:replacePresetFolder:RestoreFailed", ...
                "Cannot restore preset backup from %s: %s", ...
                backupFolder, restoreMessage);
        end
    end

    if isfolder(stagedFolder)
        [removed, removeMessage] = rmdir(stagedFolder, "s");
        if ~removed
            warning("BEVapp:replacePresetFolder:StagingCleanupFailed", ...
                "Cannot remove preset staging folder %s: %s", ...
                stagedFolder, removeMessage);
        end
    end

    if isfolder(temporaryFolder) && ~isfolder(backupFolder)
        [removed, removeMessage] = rmdir(temporaryFolder, "s");
        if ~removed
            warning("BEVapp:replacePresetFolder:TemporaryCleanupFailed", ...
                "Cannot remove temporary preset folder %s: %s", ...
                temporaryFolder, removeMessage);
        end
    end
end

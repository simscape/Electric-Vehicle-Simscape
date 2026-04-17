function folder = getPresetSetupScriptFolder(projectRoot)
%GETPRESETSETUPSCRIPTFOLDER Return absolute path to Script_Data/Setup/Preset.
    folder = fullfile(projectRoot, 'Script_Data', 'Setup', 'Preset');
end

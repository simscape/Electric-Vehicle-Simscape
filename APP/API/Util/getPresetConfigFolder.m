function folder = getPresetConfigFolder()
%GETPRESETCONFIGFOLDER Return the absolute path to APP/Config/Preset.
    appFolder = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    folder    = fullfile(appFolder, 'Config', 'Preset');
end

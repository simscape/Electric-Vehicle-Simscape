function folder = getPresetConfigFolder()
%GETPRESETCONFIGFOLDER Return the absolute path to APP/Config/Preset.
%
% Copyright 2026 The MathWorks, Inc.
    appFolder = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    folder    = fullfile(appFolder, 'Config', 'Preset');
end

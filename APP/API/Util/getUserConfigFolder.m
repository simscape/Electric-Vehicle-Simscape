function folder = getUserConfigFolder()
%GETUSERCONFIGFOLDER Return the absolute path to APP/Config/User.
%   Creates the folder on first call if it does not exist.
%
% Copyright 2026 The MathWorks, Inc.
    appFolder = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    folder    = fullfile(appFolder, 'Config', 'User');

    if ~isfolder(folder)
        mkdir(folder);
    end
end

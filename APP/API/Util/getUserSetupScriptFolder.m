function folder = getUserSetupScriptFolder(projectRoot)
%GETUSERSETUPSCRIPTFOLDER Return absolute path to Script_Data/Setup/User.
%   Creates the folder on first call if it does not exist.
%
% Copyright 2026 The MathWorks, Inc.
    folder = fullfile(projectRoot, 'Script_Data', 'Setup', 'User');

    if ~isfolder(folder)
        mkdir(folder);
    end
end

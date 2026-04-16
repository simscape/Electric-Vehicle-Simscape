function jsonFiles = getJSONFiles(folderPath)
%GETJSONFILES List all .json files in a folder, returning their filenames.
    if isfolder(folderPath)
        files     = dir(fullfile(folderPath, '*.json'));
        jsonFiles = {files.name};
    else
        jsonFiles = {};
    end
end

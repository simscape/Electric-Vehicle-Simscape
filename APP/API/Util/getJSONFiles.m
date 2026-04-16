function jsonFiles = getJSONFiles(folderPath)
    % Ensure folder exists
    if isfolder(folderPath)
        files = dir(fullfile(folderPath, '*.json'));
        jsonFiles = {files.name};
    else
        jsonFiles = {}; % Return empty if folder doesn't exist
    end
end
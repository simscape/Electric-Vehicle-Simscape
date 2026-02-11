function slxFiles = getSLXFiles(folderPath)
    % Ensure folder exists
    if isfolder(folderPath)
        files = dir(fullfile(folderPath, '*.slx'));
        slxFiles = {files.name};
    else
        slxFiles = {}; % Return empty if folder doesn't exist
    end
end
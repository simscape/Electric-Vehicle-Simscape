function slxFiles = getSLXFiles(folderPath)
%GETSLXFILES List all .slx files in a folder, returning their filenames.
    if isfolder(folderPath)
        files    = dir(fullfile(folderPath, '*.slx'));
        slxFiles = {files.name};
    else
        slxFiles = {};
    end
end

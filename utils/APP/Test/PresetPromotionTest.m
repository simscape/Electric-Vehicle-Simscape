classdef PresetPromotionTest < matlab.unittest.TestCase
% PRESETPROMOTIONTEST Verify safe preset-folder replacement.
%
% Copyright 2026 The MathWorks, Inc.

    properties (SetAccess = private)
        TempDir
    end

    methods (TestClassSetup)
        function addExportApiToPath(testCase)
            testFile = mfilename("fullpath");
            projectRoot = fileparts(fileparts(fileparts(fileparts(testFile))));
            exportApiPath = fullfile(projectRoot, "utils", "APP", "API", "Export");

            testCase.applyFixture( ...
                matlab.unittest.fixtures.PathFixture(exportApiPath));
        end
    end

    methods (TestMethodSetup)
        function createTempDir(testCase)
            testCase.TempDir = tempname;
            mkdir(testCase.TempDir);
            testCase.addTeardown(@() rmdir(testCase.TempDir, "s"));
        end
    end

    methods (Test)
        function missingSourcePreservesExistingPreset(testCase)
            sourceFolder = fullfile(testCase.TempDir, "missing-source");
            targetFolder = fullfile(testCase.TempDir, "ExistingPreset");
            originalFile = fullfile(targetFolder, "original.txt");

            mkdir(targetFolder);
            testCase.writeText(originalFile, "original preset");

            testCase.verifyError( ...
                @() replacePresetFolder(sourceFolder, targetFolder), ...
                "BEVapp:replacePresetFolder:SourceMissing");

            testCase.verifyTrue(isfolder(targetFolder));
            testCase.verifyEqual(fileread(originalFile), 'original preset');
        end

        function targetFileIsNotOverwritten(testCase)
            sourceFolder = fullfile(testCase.TempDir, "source");
            targetPath = fullfile(testCase.TempDir, "ExistingPreset");

            mkdir(sourceFolder);
            testCase.writeText(targetPath, "existing file");
            testCase.verifyError( ...
                @() replacePresetFolder(sourceFolder, targetPath), ...
                "BEVapp:replacePresetFolder:InvalidTarget");

            testCase.verifyEqual(fileread(targetPath), 'existing file');
        end

        function successfulOverwriteReplacesAndNormalizesPreset(testCase)
            sourceFolder = fullfile(testCase.TempDir, "source");
            targetFolder = fullfile(testCase.TempDir, "ExistingPreset");
            oldParamName = "Vehicle_params_setup.m";

            mkdir(sourceFolder);
            mkdir(targetFolder);
            testCase.writeText( ...
                fullfile(targetFolder, "original.txt"), "original preset");
            testCase.writeText( ...
                fullfile(sourceFolder, "new.txt"), "new preset");
            testCase.writeText( ...
                fullfile(sourceFolder, oldParamName), "parameter setup");
            testCase.writeText( ...
                fullfile(sourceFolder, "applyPreset.m"), ...
                "run('" + oldParamName + "');");

            replacePresetFolder(sourceFolder, targetFolder);

            testCase.assertFalse( ...
                isfile(fullfile(targetFolder, "original.txt")));
            testCase.verifyTrue(isfile(fullfile(targetFolder, "new.txt")));
            testCase.verifyFalse( ...
                isfile(fullfile(targetFolder, oldParamName)));
            testCase.verifyTrue( ...
                isfile(fullfile(targetFolder, "setupModelParameters.m")));

            applyText = string(fileread( ...
                fullfile(targetFolder, "applyPreset.m")));
            testCase.verifyFalse(contains(applyText, oldParamName));
            testCase.verifyTrue( ...
                contains(applyText, "setupModelParameters.m"));

            temporaryFiles = dir(testCase.TempDir);
            temporaryNames = string({temporaryFiles.name});
            temporaryNames = temporaryNames( ...
                ~ismember(temporaryNames, [".", ".."]));
            testCase.verifyEqual( ...
                sort(temporaryNames), sort(["ExistingPreset", "source"]));
        end
    end

    methods (Access = private)
        function writeText(testCase, filePath, content)
            fileID = fopen(filePath, "w");
            testCase.assertGreaterThan(fileID, 0);
            fileCleanup = onCleanup(@() fclose(fileID));
            fprintf(fileID, "%s", content);
        end
    end
end

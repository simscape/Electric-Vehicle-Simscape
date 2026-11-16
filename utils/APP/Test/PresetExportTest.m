classdef PresetExportTest < matlab.unittest.TestCase
% PRESETEXPORTTEST Verify preset ZIP export from the Preset Picker.

% Copyright 2026 The MathWorks, Inc.

    properties (Access = private)
        Root
    end

    methods (TestClassSetup)
        function captureProjectRoot(testCase)
            testCase.Root = string(matlab.project.rootProject().RootFolder);
        end
    end

    methods (Test)
        function presetPickerOffersExportZip(testCase)
            pickerCleanup = onCleanup(@localClosePresetPicker); %#ok<NASGU>
            clear("bevPresetUI.openPresetPicker");

            bevPresetUI.openPresetPicker();

            picker = getappdata(groot, "BEV_PRESET_PICKER_HANDLE");
            testCase.assertNotEmpty(picker);
            buttons = findall(picker, "Type", "uibutton");
            exportButton = buttons(strcmp({buttons.Text}, "Export Zip"));

            testCase.assertNumElements(exportButton, 1);
            testCase.verifyEqual(string(exportButton.Enable), "on");
        end

        function exportedPackageContainsPresetDependencies(testCase)
            sourceFolder = string(tempname);
            mkdir(sourceFolder);
            [~, presetName] = fileparts(sourceFolder);
            exportFolder = fullfile( ...
                testCase.Root, "Script_Data", "Setup", "Export");
            zipPath = fullfile(exportFolder, presetName + ".zip");
            stageFolder = fullfile(exportFolder, presetName);
            extractFolder = string(tempname);
            cleanup = onCleanup(@() localRemoveTestArtifacts( ...
                sourceFolder, zipPath, stageFolder, extractFolder)); %#ok<NASGU>

            localWriteFile( ...
                fullfile(sourceFolder, "setupModelReferences.m"), [ ...
                "topModelName = 'BEVsystemModel';" newline ...
                "vehTarget = 'VehicleElectric';" newline ...
                "setRef('BEVsystemModel/Vehicle/Battery'," + ...
                " 'BatteryLumped');" newline]);
            localWriteFile( ...
                fullfile(sourceFolder, "setupModelParameters.m"), ...
                "BatteryLumpedParams;" + newline);

            actualZipPath = bevPresetUI.exportPresetPackage(char(sourceFolder));

            testCase.verifyEqual(string(actualZipPath), zipPath);
            testCase.assertTrue(isfile(zipPath));
            testCase.verifyFalse(isfolder(stageFolder));

            mkdir(extractFolder);
            unzip(zipPath, extractFolder);
            packageRoot = fullfile(extractFolder, presetName);
            expectedFiles = [ ...
                fullfile(packageRoot, "Model", "BEVsystemModel.slx")
                fullfile(packageRoot, "Model", "VehicleTemplate", ...
                    "VehicleElectric.slx")
                fullfile(packageRoot, "Components", "BatteryHV", ...
                    "Model", "BatteryLumped.slx")
                fullfile(packageRoot, "Components", "BatteryHV", ...
                    "Model", "BatteryLumpedParams.m")
                fullfile(packageRoot, "Preset", "setupModelReferences.m")
                fullfile(packageRoot, "Preset", "setupModelParameters.m")
                fullfile(packageRoot, presetName + ".prj")];

            for k = 1:numel(expectedFiles)
                testCase.verifyTrue(isfile(expectedFiles(k)), ...
                    "Missing exported file: " + expectedFiles(k));
            end
        end
    end
end

function localWriteFile(path, content)
    fileId = fopen(path, "w");
    assert(fileId >= 0, ...
        "PresetExportTest:fileOpenFailed", "Could not create %s.", path);
    cleanup = onCleanup(@() fclose(fileId)); %#ok<NASGU>
    fprintf(fileId, "%s", content);
end

function localClosePresetPicker()
    if isappdata(groot, "BEV_PRESET_PICKER_HANDLE")
        picker = getappdata(groot, "BEV_PRESET_PICKER_HANDLE");
        if ~isempty(picker) && isvalid(picker)
            close(picker);
        else
            rmappdata(groot, "BEV_PRESET_PICKER_HANDLE");
        end
    end
end

function localRemoveTestArtifacts( ...
        sourceFolder, zipPath, stageFolder, extractFolder)
    paths = [sourceFolder, stageFolder, extractFolder];
    for k = 1:numel(paths)
        if isfolder(paths(k))
            rmdir(paths(k), "s");
        end
    end
    if isfile(zipPath)
        delete(zipPath);
    end
end

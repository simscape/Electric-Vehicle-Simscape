function config = testConfig()
% testConfig - Test configuration for the EV repository
%
% Copyright 2026 The MathWorks, Inc.

%% Get project Root
try
    projectRoot = string(currentProject().RootFolder);
catch
    try
        prj = matlab.project.loadProject(pwd);
        projectRoot = string(prj.RootFolder);
    catch
        error("testConfig:NoProject", ...
            "Could not resolve ProjectRoot. Open the MATLAB project or run from the project root.");
    end
end

%% Project Root
config.ProjectRoot = projectRoot;

%% Model Discovery
config.Models.IncludeDirectories = ["Model", "Workflow"]; %#ok<*NBRAK2>
config.Models.IncludeFiles = string.empty;
config.Models.FileTypes = ["SLX-file"; "MDL-file"];
config.Models.ExcludeDirectories = string.empty;
config.Models.ExcludeFiles = string.empty;

%% Workflow Discovery
config.Workflows.IncludeDirectories = string.empty;
config.Workflows.IncludeFiles = [   "Workflow\Battery\BatterySizing\BEVBatterySizingMain.mlx";...
                                    "Workflow\Battery\VirtualSensorNeuralNetModel\VirtualSensorNeuralNetModel.mlx";...
                                    "Workflow\MotorDrive\GearRatioSelect\minimumRequiredGearRatio.mlx";...
                                    "Workflow\MotorDrive\GenerateMotInvLoss\generateDULossMap.mlx";...
                                    "Workflow\MotorDrive\InverterLife\inverterPowerModuleLife.mlx";...
                                    "Workflow\MotorDrive\ThermalDurability\DUThermalDurability.mlx";...
                                    "Workflow\Vehicle\RangeEstimation\BEVRangeEstimationMain.mlx";...
                                    "Workflow\Driveline\DrivelineNVH\generateOrderMap.mlx";...
                                    "Workflow\Driveline\DrivelineNVH\optimizeVehicleLaunch.mlx"];
config.Workflows.FileTypes = ["MLX-file"; "M-file"];
config.Workflows.ExcludeDirectories = string.empty;
config.Workflows.ExcludeFiles = string.empty;

%% Custom Tests
config.CustomTests.Files = string.empty;
config.CustomTests.Directories = string.empty;

%% Code Coverage
config.CodeCoverage.IncludeDirectories = ["Script_Data"; "Workflow"];
config.CodeCoverage.IncludeFiles = string.empty;
config.CodeCoverage.FileTypes = ["M-file"; "MLX-file"];
config.CodeCoverage.ExcludeDirectories = "Test";
config.CodeCoverage.ExcludeFiles = string.empty;

%% Reporting
config.Reports.FolderName = "BEV";
config.Reports.GenerateJUnitXML = true;
config.Reports.GenerateHTMLReport = true;
config.Reports.GenerateCodeCoverage = true;
config.Reports.OpenInBrowser = false;

%% Warning Suppression
config.SuppressedWarnings = ["MATLAB:hg:AutoSoftwareOpenGL"];

end

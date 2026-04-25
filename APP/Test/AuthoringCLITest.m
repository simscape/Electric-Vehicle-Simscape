classdef AuthoringCLITest < matlab.unittest.TestCase
% AUTHORINGCLITEST Unit tests for authoring CLI functions.
%   Tests bevConfigRead, bevConfigWrite, bevAddFidelity (struct-level).
%   No Simulink or project dependency — uses temp JSON files only.
%
%   Run all:
%     results = runtests('AuthoringCLITest');
%
% Copyright 2026 The MathWorks, Inc.

    properties (Access = private)
        TempDir
    end

    methods (TestMethodSetup)
        function createTempDir(testCase)
        % CREATETEMPDIR Create a temp folder for each test.
            testCase.TempDir = tempname;
            mkdir(testCase.TempDir);
            testCase.addTeardown(@() rmdir(testCase.TempDir, 's'));
        end
    end

    methods (Test)

        % ---- bevConfigWrite / bevConfigRead round-trip ----

        function testRoundTripPreservesStructure(testCase)
        % TESTROUNDTRIPPRESERVESSTRUCTURE Write then read, verify fields survive.
            cfg = testCase.buildSampleConfig();
            jsonPath = fullfile(testCase.TempDir, 'test.json');

            bevConfigWrite(cfg, jsonPath);
            [restored, ~] = bevConfigRead(jsonPath, testCase.TempDir);

            testCase.verifyTrue(isfield(restored, 'TestTemplate'));
            comp = restored.TestTemplate.Components.MotorDrive;
            testCase.verifyEqual(comp.Instances, {'Rear Motor', 'Front Motor'});
            testCase.verifyEqual(comp.Models, {'MotorA', 'MotorB'});
        end

        function testRoundTripSingleElementArrays(testCase)
        % TESTROUNDTRIPSINGLEELEMENTARRAYS Single-element arrays survive decode.
            cfg.T.Components.Battery.Instances = {'Battery'};
            cfg.T.Components.Battery.Models = {'BattLumped'};
            cfg.T.SystemParameter = {'NA'};
            jsonPath = fullfile(testCase.TempDir, 'single.json');

            bevConfigWrite(cfg, jsonPath);
            [restored, ~] = bevConfigRead(jsonPath, testCase.TempDir);

            testCase.verifyClass(restored.T.Components.Battery.Instances, 'cell');
            testCase.verifyClass(restored.T.Components.Battery.Models, 'cell');
            testCase.verifyClass(restored.T.SystemParameter, 'cell');
        end

        function testRoundTripWithSelections(testCase)
        % TESTROUNDTRIPWITHSELECTIONS Selections section survives write/read.
            cfg = testCase.buildSampleConfig();
            cfg.TestTemplate.Components.MotorDrive.Selections.RearMotor = struct( ...
                'Label', 'Rear Motor', ...
                'Model', 'MotorA', ...
                'ParamFile', 'MotorAParams.m');
            jsonPath = fullfile(testCase.TempDir, 'sel.json');

            bevConfigWrite(cfg, jsonPath);
            [restored, ~] = bevConfigRead(jsonPath, testCase.TempDir);

            sel = restored.TestTemplate.Components.MotorDrive.Selections.RearMotor;
            testCase.verifyEqual(sel.Label, 'Rear Motor');
            testCase.verifyEqual(sel.Model, 'MotorA');
            testCase.verifyEqual(sel.ParamFile, 'MotorAParams.m');
        end

        function testRoundTripWithControls(testCase)
        % TESTROUNDTRIPWITHCONTROLS Controls section preserved.
            cfg = testCase.buildSampleConfig();
            cfg.TestTemplate.Controls = struct( ...
                'Instances', {{'Controller'}}, ...
                'Models', {{'ControllerFRM'}});
            jsonPath = fullfile(testCase.TempDir, 'ctrl.json');

            bevConfigWrite(cfg, jsonPath);
            [restored, ~] = bevConfigRead(jsonPath, testCase.TempDir);

            testCase.verifyEqual(restored.TestTemplate.Controls.Instances, {'Controller'});
            testCase.verifyEqual(restored.TestTemplate.Controls.Models, {'ControllerFRM'});
        end

        % ---- bevConfigRead missing file ----

        function testReadMissingFileReturnsEmptyStruct(testCase)
        % TESTREADMISSINGFILERETURNSEMPTYSTRUCT Non-existent file returns struct().
            [cfg, ~] = bevConfigRead('nonexistent.json', testCase.TempDir);
            testCase.verifyTrue(isstruct(cfg));
            testCase.verifyEmpty(fieldnames(cfg));
        end

        % ---- bevAddFidelity Level 3 — struct manipulation ----

        function testAddFidelityAppends(testCase)
        % TESTADDFIDELITYAPPENDS New model appended to end of Models list.
            cfg = testCase.buildSampleConfig();
            jsonPath = fullfile(testCase.TempDir, 'add.json');
            bevConfigWrite(cfg, jsonPath);

            bevAddFidelity(jsonPath, 'TestTemplate', 'MotorDrive', 'MotorC', ...
                DryRun = false, ProjectRoot = testCase.TempDir);

            [result, ~] = bevConfigRead(jsonPath, testCase.TempDir);
            models = result.TestTemplate.Components.MotorDrive.Models;
            testCase.verifyEqual(models{end}, 'MotorC');
            testCase.verifyEqual(numel(models), 3);
        end

        function testAddFidelityMakeDefault(testCase)
        % TESTADDFIDELITYMAKEDEFAULT MakeDefault puts model first.
            cfg = testCase.buildSampleConfig();
            jsonPath = fullfile(testCase.TempDir, 'default.json');
            bevConfigWrite(cfg, jsonPath);

            bevAddFidelity(jsonPath, 'TestTemplate', 'MotorDrive', 'MotorC', ...
                MakeDefault = true, DryRun = false, ProjectRoot = testCase.TempDir);

            [result, ~] = bevConfigRead(jsonPath, testCase.TempDir);
            models = result.TestTemplate.Components.MotorDrive.Models;
            testCase.verifyEqual(models{1}, 'MotorC');
        end

        function testAddFidelityDuplicateSkips(testCase)
        % TESTADDFIDELITYDUPLICATESKIPS Existing model is not added again.
            cfg = testCase.buildSampleConfig();
            jsonPath = fullfile(testCase.TempDir, 'dup.json');
            bevConfigWrite(cfg, jsonPath);

            bevAddFidelity(jsonPath, 'TestTemplate', 'MotorDrive', 'MotorA', ...
                DryRun = false, ProjectRoot = testCase.TempDir);

            [result, ~] = bevConfigRead(jsonPath, testCase.TempDir);
            models = result.TestTemplate.Components.MotorDrive.Models;
            testCase.verifyEqual(numel(models), 2);
        end

        function testAddFidelityWithParamCreatesSelections(testCase)
        % TESTADDFIDELITYWITHPARAMCREATESSELECTIONS ParamFile triggers Selections.
            cfg = testCase.buildSampleConfig();
            jsonPath = fullfile(testCase.TempDir, 'param.json');
            bevConfigWrite(cfg, jsonPath);

            bevAddFidelity(jsonPath, 'TestTemplate', 'MotorDrive', 'MotorC', ...
                ParamFile = 'CustomParams.m', DryRun = false, ...
                ProjectRoot = testCase.TempDir);

            [result, ~] = bevConfigRead(jsonPath, testCase.TempDir);
            comp = result.TestTemplate.Components.MotorDrive;

            testCase.verifyTrue(isfield(comp, 'Selections'));
            selKeys = fieldnames(comp.Selections);
            testCase.verifyEqual(numel(selKeys), 2);

            sel = comp.Selections.(selKeys{1});
            testCase.verifyEqual(sel.Model, 'MotorC');
            testCase.verifyEqual(sel.ParamFile, 'CustomParams.m');
        end

        function testAddFidelityBadTemplateErrors(testCase)
        % TESTADDFIDELITYBADTEMPLATEERRORS Non-existent template throws error.
            cfg = testCase.buildSampleConfig();
            jsonPath = fullfile(testCase.TempDir, 'err.json');
            bevConfigWrite(cfg, jsonPath);

            testCase.verifyError( ...
                @() bevAddFidelity(jsonPath, 'NoSuchTemplate', ...
                    'MotorDrive', 'MotorC', ProjectRoot = testCase.TempDir), ...
                'bevAddFidelity:TemplateNotFound');
        end

        function testAddFidelityBadComponentErrors(testCase)
        % TESTADDFIDELITYBADCOMPONENTERRORS Non-existent component throws error.
            cfg = testCase.buildSampleConfig();
            jsonPath = fullfile(testCase.TempDir, 'err2.json');
            bevConfigWrite(cfg, jsonPath);

            testCase.verifyError( ...
                @() bevAddFidelity(jsonPath, 'TestTemplate', ...
                    'NoSuchComp', 'MotorC', ProjectRoot = testCase.TempDir), ...
                'bevAddFidelity:ComponentNotFound');
        end

        % ---- validateVehicleConfig on CLI output ----

        function testCLIOutputPassesValidation(testCase)
        % TESTCLIOUTPUTPASSESVALIDATION Config built by CLI passes validation.
            cfg = testCase.buildSampleConfig();
            valid = validateVehicleConfig(cfg, 'TestTemplate');
            testCase.verifyTrue(valid);
        end

        function testCLIOutputWithSelectionsPassesValidation(testCase)
        % TESTCLIOUTPUTWITHSELECTIONSPASSESVALIDATION Selections don't break validation.
            cfg = testCase.buildSampleConfig();
            cfg.TestTemplate.Components.MotorDrive.Selections.RearMotor = struct( ...
                'Label', 'Rear Motor', ...
                'Model', 'MotorA', ...
                'ParamFile', 'MotorAParams.m');

            valid = validateVehicleConfig(cfg, 'TestTemplate');
            testCase.verifyTrue(valid);
        end

        % ---- bevAddFidelity — modify existing fidelity ----

        function testModifyExistingMakeDefault(testCase)
        % TESTMODIFYEXISTINGMAKEDEFAULT Existing model moved to first position.
            cfg = testCase.buildSampleConfig();
            jsonPath = fullfile(testCase.TempDir, 'mod.json');
            bevConfigWrite(cfg, jsonPath);

            bevAddFidelity(jsonPath, 'TestTemplate', 'MotorDrive', 'MotorB', ...
                MakeDefault = true, DryRun = false, ProjectRoot = testCase.TempDir);

            [result, ~] = bevConfigRead(jsonPath, testCase.TempDir);
            models = result.TestTemplate.Components.MotorDrive.Models;
            testCase.verifyEqual(models{1}, 'MotorB');
            testCase.verifyEqual(numel(models), 2);
        end

        function testModifyExistingParamFile(testCase)
        % TESTMODIFYEXISTINGPARAMFILE Existing model gets Selections when ParamFile specified.
            cfg = testCase.buildSampleConfig();
            jsonPath = fullfile(testCase.TempDir, 'modparam.json');
            bevConfigWrite(cfg, jsonPath);

            bevAddFidelity(jsonPath, 'TestTemplate', 'MotorDrive', 'MotorA', ...
                ParamFile = 'NewParams.m', DryRun = false, ...
                ProjectRoot = testCase.TempDir);

            [result, ~] = bevConfigRead(jsonPath, testCase.TempDir);
            comp = result.TestTemplate.Components.MotorDrive;
            testCase.verifyEqual(numel(comp.Models), 2);
            testCase.verifyTrue(isfield(comp, 'Selections'));
            sel = comp.Selections.(fieldnames(comp.Selections){1});
            testCase.verifyEqual(sel.ParamFile, 'NewParams.m');
            testCase.verifyEqual(sel.Model, 'MotorA');
        end

        function testModifyExistingBothOptions(testCase)
        % TESTMODIFYEXISTINGBOTHOPTIONS MakeDefault + ParamFile on existing model.
            cfg = testCase.buildSampleConfig();
            jsonPath = fullfile(testCase.TempDir, 'modboth.json');
            bevConfigWrite(cfg, jsonPath);

            bevAddFidelity(jsonPath, 'TestTemplate', 'MotorDrive', 'MotorB', ...
                MakeDefault = true, ParamFile = 'CustomB.m', ...
                DryRun = false, ProjectRoot = testCase.TempDir);

            [result, ~] = bevConfigRead(jsonPath, testCase.TempDir);
            comp = result.TestTemplate.Components.MotorDrive;
            testCase.verifyEqual(comp.Models{1}, 'MotorB');
            testCase.verifyTrue(isfield(comp, 'Selections'));
        end

        % ---- bevUpdateTemplate — config sync ----

        function testUpdateAddsNewComponent(testCase)
        % TESTUPDATEADDSNEWCOMPONENT New component in scan gets added to config.
            [cfg, presetDir] = testCase.writePresetConfig('add.json');

            freshEntry = cfg.TestTemplate;
            freshEntry.Components.HeatPump.Instances = {'HeatPump'};
            freshEntry.Components.HeatPump.Models = {'HeatPumpDefault'};

            bevUpdateTemplate('Model/VehicleTemplate/TestTemplate.slx', ...
                ScanOverride = freshEntry, DryRun = false, ...
                ProjectRoot = testCase.TempDir);

            [result, ~] = bevConfigRead( ...
                fullfile(presetDir, 'add.json'), testCase.TempDir);
            testCase.verifyTrue( ...
                isfield(result.TestTemplate.Components, 'HeatPump'));
            testCase.verifyEqual( ...
                result.TestTemplate.Components.HeatPump.Models, {'HeatPumpDefault'});
        end

        function testUpdateRemovesComponent(testCase)
        % TESTUPDATEREMOVESCOMPONENT Component not in scan gets removed.
            [cfg, presetDir] = testCase.writePresetConfig('rm.json');

            freshEntry = cfg.TestTemplate;
            freshEntry.Components = rmfield(freshEntry.Components, 'Battery');

            bevUpdateTemplate('Model/VehicleTemplate/TestTemplate.slx', ...
                ScanOverride = freshEntry, DryRun = false, ...
                ProjectRoot = testCase.TempDir);

            [result, ~] = bevConfigRead( ...
                fullfile(presetDir, 'rm.json'), testCase.TempDir);
            testCase.verifyFalse( ...
                isfield(result.TestTemplate.Components, 'Battery'));
            testCase.verifyTrue( ...
                isfield(result.TestTemplate.Components, 'MotorDrive'));
        end

        function testUpdateInstancesChanged(testCase)
        % TESTUPDATEINSTANCESCHANGED Changed instances taken from template.
            [cfg, presetDir] = testCase.writePresetConfig('inst.json');

            freshEntry = cfg.TestTemplate;
            freshEntry.Components.MotorDrive.Instances = ...
                {'Rear Motor', 'Front Motor', 'Center Motor'};

            bevUpdateTemplate('Model/VehicleTemplate/TestTemplate.slx', ...
                ScanOverride = freshEntry, DryRun = false, ...
                ProjectRoot = testCase.TempDir);

            [result, ~] = bevConfigRead( ...
                fullfile(presetDir, 'inst.json'), testCase.TempDir);
            instances = result.TestTemplate.Components.MotorDrive.Instances;
            testCase.verifyEqual(numel(instances), 3);
            testCase.verifyTrue(ismember('Center Motor', instances));
        end

        function testUpdatePreservesFidelities(testCase)
        % TESTUPDATEPRESERVESFIDELITIES Extra fidelities not removed by sync.
            [cfg, presetDir] = testCase.writePresetConfig('fid.json');

            freshEntry = cfg.TestTemplate;
            freshEntry.Components.MotorDrive.Models = {'MotorA'};

            bevUpdateTemplate('Model/VehicleTemplate/TestTemplate.slx', ...
                ScanOverride = freshEntry, DryRun = false, ...
                ProjectRoot = testCase.TempDir);

            [result, ~] = bevConfigRead( ...
                fullfile(presetDir, 'fid.json'), testCase.TempDir);
            models = result.TestTemplate.Components.MotorDrive.Models;
            testCase.verifyTrue(ismember('MotorA', models));
            testCase.verifyTrue(ismember('MotorB', models));
        end

        function testUpdateAddsSSRModel(testCase)
        % TESTUPDATEADDSSSRMODEL New SSR model added to existing models list.
            [cfg, presetDir] = testCase.writePresetConfig('ssrm.json');

            freshEntry = cfg.TestTemplate;
            freshEntry.Components.MotorDrive.Models = {'MotorNew'};

            bevUpdateTemplate('Model/VehicleTemplate/TestTemplate.slx', ...
                ScanOverride = freshEntry, DryRun = false, ...
                ProjectRoot = testCase.TempDir);

            [result, ~] = bevConfigRead( ...
                fullfile(presetDir, 'ssrm.json'), testCase.TempDir);
            models = result.TestTemplate.Components.MotorDrive.Models;
            testCase.verifyTrue(ismember('MotorNew', models));
            testCase.verifyTrue(ismember('MotorA', models));
            testCase.verifyTrue(ismember('MotorB', models));
        end

        function testUpdateCleansSelectionsForRemovedInstance(testCase)
        % TESTUPDATECLEANSSELECTIONSFORREMOVEDINSTANCE Selection for removed instance cleaned up.
            cfg = testCase.buildSampleConfig();
            cfg.TestTemplate.Components.MotorDrive.Selections.RearMotor = struct( ...
                'Label', 'Rear Motor', 'Model', 'MotorA', 'ParamFile', 'P.m');
            cfg.TestTemplate.Components.MotorDrive.Selections.FrontMotor = struct( ...
                'Label', 'Front Motor', 'Model', 'MotorA', 'ParamFile', 'P.m');

            presetDir = fullfile(testCase.TempDir, 'APP', 'Config', 'Preset');
            mkdir(presetDir);
            bevConfigWrite(cfg, fullfile(presetDir, 'sel.json'));

            freshEntry = cfg.TestTemplate;
            freshEntry.Components.MotorDrive.Instances = {'Rear Motor'};
            freshEntry.Components.MotorDrive = rmfield( ...
                freshEntry.Components.MotorDrive, 'Selections');

            bevUpdateTemplate('Model/VehicleTemplate/TestTemplate.slx', ...
                ScanOverride = freshEntry, DryRun = false, ...
                ProjectRoot = testCase.TempDir);

            [result, ~] = bevConfigRead( ...
                fullfile(presetDir, 'sel.json'), testCase.TempDir);
            selKeys = fieldnames(result.TestTemplate.Components.MotorDrive.Selections);
            testCase.verifyEqual(numel(selKeys), 1);
        end

        function testUpdateNoChanges(testCase)
        % TESTUPDATENOCHANGES Identical scan produces no write.
            [cfg, presetDir] = testCase.writePresetConfig('noop.json');

            freshEntry = cfg.TestTemplate;

            bevUpdateTemplate('Model/VehicleTemplate/TestTemplate.slx', ...
                ScanOverride = freshEntry, DryRun = false, ...
                ProjectRoot = testCase.TempDir);

            [result, ~] = bevConfigRead( ...
                fullfile(presetDir, 'noop.json'), testCase.TempDir);
            testCase.verifyEqual( ...
                result.TestTemplate.Components.MotorDrive.Models, {'MotorA', 'MotorB'});
        end

        function testUpdateNotFoundInConfig(testCase)
        % TESTUPDATENOTFOUNDINCONFIG Template not in any config prints message.
            mkdir(fullfile(testCase.TempDir, 'APP', 'Config', 'Preset'));

            freshEntry.Components.Motor.Instances = {'Motor'};
            freshEntry.Components.Motor.Models = {'MotorA'};
            freshEntry.SystemParameter = {'NA'};

            testCase.verifyWarningFree( ...
                @() bevUpdateTemplate('Model/VehicleTemplate/NoSuch.slx', ...
                    ScanOverride = freshEntry, ProjectRoot = testCase.TempDir));
        end

        % ---- Discovery levels (Level 1 and 2 print without error) ----

        function testDiscoveryLevel1NoError(testCase)
        % TESTDISCOVERYLEVEL1NOERROR Calling with just config+template prints list.
            cfg = testCase.buildSampleConfig();
            jsonPath = fullfile(testCase.TempDir, 'disc.json');
            bevConfigWrite(cfg, jsonPath);

            testCase.verifyWarningFree( ...
                @() bevAddFidelity(jsonPath, 'TestTemplate', ...
                    ProjectRoot = testCase.TempDir));
        end

        function testDiscoveryLevel2NoError(testCase)
        % TESTDISCOVERYLEVEL2NOERROR Calling with component but no model prints list.
            cfg = testCase.buildSampleConfig();
            jsonPath = fullfile(testCase.TempDir, 'disc2.json');
            bevConfigWrite(cfg, jsonPath);

            testCase.verifyWarningFree( ...
                @() bevAddFidelity(jsonPath, 'TestTemplate', 'MotorDrive', ...
                    ProjectRoot = testCase.TempDir));
        end

    end

    methods (Static, Access = private)

        function cfg = buildSampleConfig()
        % BUILDSAMPLECONFIG Create a minimal valid config for testing.
            cfg.TestTemplate.Description = 'Test template';
            cfg.TestTemplate.Components.MotorDrive.Instances = {'Rear Motor', 'Front Motor'};
            cfg.TestTemplate.Components.MotorDrive.Models = {'MotorA', 'MotorB'};
            cfg.TestTemplate.Components.Battery.Instances = {'Battery'};
            cfg.TestTemplate.Components.Battery.Models = {'BattLumped'};
            cfg.TestTemplate.SystemParameter = {'NA'};
        end
    end

    methods (Access = private)

        function [cfg, presetDir] = writePresetConfig(testCase, filename)
        % WRITEPRESETCONFIG Write a sample config into APP/Config/Preset/ under TempDir.
            presetDir = fullfile(testCase.TempDir, 'APP', 'Config', 'Preset');
            mkdir(presetDir);
            cfg = AuthoringCLITest.buildSampleConfig();
            bevConfigWrite(cfg, fullfile(presetDir, filename));
        end

    end
end

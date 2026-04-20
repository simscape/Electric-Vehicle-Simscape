classdef BuildComponentEntriesTest < matlab.unittest.TestCase
%BUILDCOMPONENTENTRIESTEST Unit tests for buildComponentEntries.
%   Validates struct array output from parsed JSON config input.

    methods (Test)

        function testSingleComponentSingleInstance(testCase)
            rawCfg.MyTemplate.Components.BatteryHV.Instances = {'Battery'};
            rawCfg.MyTemplate.Components.BatteryHV.Models    = {'BatteryLumped'};

            entries = buildComponentEntries(rawCfg, 'MyTemplate');

            testCase.verifyNumElements(entries, 1);
            testCase.verifyEqual(entries(1).Comp,  'BatteryHV');
            testCase.verifyEqual(entries(1).Label, 'Battery');
            testCase.verifyEqual(entries(1).Models, {'BatteryLumped'});
        end

        function testSingleComponentMultipleInstances(testCase)
            rawCfg.T.Components.MotorDrive.Instances = {'Rear Motor (EM2)', 'Front Motor (EM1)'};
            rawCfg.T.Components.MotorDrive.Models    = {'MotorDriveGearTh', 'MotorDriveLube'};

            entries = buildComponentEntries(rawCfg, 'T');

            testCase.verifyNumElements(entries, 2);
            testCase.verifyEqual(entries(1).Label, 'Rear Motor (EM2)');
            testCase.verifyEqual(entries(2).Label, 'Front Motor (EM1)');
            % Both instances share the same model list
            testCase.verifyEqual(entries(1).Models, entries(2).Models);
        end

        function testMultipleComponents(testCase)
            rawCfg.T.Components.BatteryHV.Instances  = {'Battery'};
            rawCfg.T.Components.BatteryHV.Models     = {'BatteryLumped'};
            rawCfg.T.Components.Charger.Instances     = {'Charger'};
            rawCfg.T.Components.Charger.Models        = {'Charger', 'ChargerDummy'};

            entries = buildComponentEntries(rawCfg, 'T');

            testCase.verifyNumElements(entries, 2);
            comps = {entries.Comp};
            testCase.verifyTrue(ismember('BatteryHV', comps));
            testCase.verifyTrue(ismember('Charger', comps));
        end

        function testNoInstancesFieldDefaultsToCompName(testCase)
            % When Instances is missing, should default to component type name
            rawCfg.T.Components.Radiator.Models = {'Radiator'};

            entries = buildComponentEntries(rawCfg, 'T');

            testCase.verifyNumElements(entries, 1);
            testCase.verifyEqual(entries(1).Comp,  'Radiator');
            testCase.verifyEqual(entries(1).Label, 'Radiator');
        end

        function testOutputFieldsExist(testCase)
            rawCfg.T.Components.Pump.Instances = {'Battery Pump', 'Motor Pump'};
            rawCfg.T.Components.Pump.Models    = {'Pump', 'PumpDummy'};

            entries = buildComponentEntries(rawCfg, 'T');

            for i = 1:numel(entries)
                testCase.verifyTrue(isfield(entries(i), 'Comp'));
                testCase.verifyTrue(isfield(entries(i), 'Label'));
                testCase.verifyTrue(isfield(entries(i), 'Models'));
            end
        end

        function testEmptyComponentsReturnsEmpty(testCase)
            rawCfg.T.Components = struct();

            entries = buildComponentEntries(rawCfg, 'T');

            testCase.verifyEmpty(entries);
        end

        function testRealConfigShape(testCase)
            % Mirror the actual VehicleElectroThermal config structure
            rawCfg.VehicleElectroThermal.Components.BatteryHV.Instances  = {'Battery'};
            rawCfg.VehicleElectroThermal.Components.BatteryHV.Models     = {'BatteryTableBased', 'BatteryLumpedThermal'};
            rawCfg.VehicleElectroThermal.Components.MotorDrive.Instances = {'Rear Motor (EM2)', 'Front Motor (EM1)'};
            rawCfg.VehicleElectroThermal.Components.MotorDrive.Models    = {'MotorDriveGearTh', 'MotorDriveLube'};
            rawCfg.VehicleElectroThermal.Components.Pump.Instances       = {'Battery Pump', 'Motor Pump'};
            rawCfg.VehicleElectroThermal.Components.Pump.Models          = {'Pump', 'PumpDummy'};

            entries = buildComponentEntries(rawCfg, 'VehicleElectroThermal');

            % 1 Battery + 2 Motors + 2 Pumps = 5
            testCase.verifyNumElements(entries, 5);

            labels = {entries.Label};
            testCase.verifyTrue(ismember('Battery', labels));
            testCase.verifyTrue(ismember('Front Motor (EM1)', labels));
            testCase.verifyTrue(ismember('Motor Pump', labels));
        end

        function testModelsPreservedAsCellArray(testCase)
            rawCfg.T.Components.HVAC.Instances = {'HVAC'};
            rawCfg.T.Components.HVAC.Models    = {'HVACsimpleTh', 'HVACEmpiricalRef'};

            entries = buildComponentEntries(rawCfg, 'T');

            testCase.verifyClass(entries(1).Models, 'cell');
            testCase.verifyNumElements(entries(1).Models, 2);
        end

    end
end

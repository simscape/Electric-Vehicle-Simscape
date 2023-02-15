%% Battery parameters

% Copyright 2022 The MathWorks, Inc.

%% ModuleType1
ModuleType1.SOC_vec = battery.SOC_vec; % Vector of state-of-charge values, SOC
ModuleType1.T_vec = battery.T_vec; % Vector of temperatures, T, K
ModuleType1.V0_mat = battery.V0_mat; % Open-circuit voltage, V0(SOC,T), V
ModuleType1.V_range = [0, inf]; % Terminal voltage operating range [Min Max], V
ModuleType1.R0_mat = battery.R0_mat; % Terminal resistance, R0(SOC,T), Ohm
ModuleType1.AH = battery.AH; % Cell capacity, AH, A*hr
ModuleType1.thermal_mass = battery.MdotCp; % Thermal mass, J/K
ModuleType1.CoolantThermalPathResistance = battery.coolantRes; % Cell level coolant thermal path resistance, K/W

%% ParallelAssemblyType1
ParallelAssemblyType1.SOC_vec = battery.SOC_vec; % Vector of state-of-charge values, SOC
ParallelAssemblyType1.T_vec = battery.T_vec; % Vector of temperatures, T, K
ParallelAssemblyType1.V0_mat = battery.V0_mat; % Open-circuit voltage, V0(SOC,T), V
ParallelAssemblyType1.V_range = [0, inf]; % Terminal voltage operating range [Min Max], V
ParallelAssemblyType1.R0_mat = battery.R0_mat; % Terminal resistance, R0(SOC,T), Ohm
ParallelAssemblyType1.AH = battery.AH; % Cell capacity, AH, A*hr♦
ParallelAssemblyType1.thermal_mass = 100; % Thermal mass, J/K
ParallelAssemblyType1.CoolantThermalPathResistance = battery.coolantRes; % Cell level coolant thermal path resistance, K/W

%% Battery initial targets

%% ModuleAssembly1.Module1
ModuleAssembly1.Module1.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly1.Module1.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly1.Module1.socCellModel = battery.initialPackSOC; % Cell model state of charge
ModuleAssembly1.Module1.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly1.Module1.temperatureCellModel = vehicleThermal.ambient; % Cell model temperature, K
ModuleAssembly1.Module1.vParallelAssembly = repmat(0, 11, 1); % Parallel Assembly Voltage, V
ModuleAssembly1.Module1.socParallelAssembly = repmat(1, 11, 1); % Parallel Assembly state of charge

%% ModuleAssembly1.Module2
ModuleAssembly1.Module2.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly1.Module2.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly1.Module2.socCellModel = battery.initialPackSOC; % Cell model state of charge
ModuleAssembly1.Module2.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly1.Module2.temperatureCellModel =  vehicleThermal.ambient; % Cell model temperature, K
ModuleAssembly1.Module2.vParallelAssembly = repmat(0, 11, 1); % Parallel Assembly Voltage, V
ModuleAssembly1.Module2.socParallelAssembly = repmat(1, 11, 1); % Parallel Assembly state of charge

%% ModuleAssembly2.Module1
ModuleAssembly2.Module1.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly2.Module1.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly2.Module1.socCellModel = battery.initialPackSOC; % Cell model state of charge
ModuleAssembly2.Module1.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly2.Module1.temperatureCellModel =  vehicleThermal.ambient; % Cell model temperature, K
ModuleAssembly2.Module1.vParallelAssembly = repmat(0, 11, 1); % Parallel Assembly Voltage, V
ModuleAssembly2.Module1.socParallelAssembly = repmat(1, 11, 1); % Parallel Assembly state of charge

%% ModuleAssembly2.Module2
ModuleAssembly2.Module2.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly2.Module2.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly2.Module2.socCellModel = battery.initialPackSOC; % Cell model state of charge
ModuleAssembly2.Module2.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly2.Module2.temperatureCellModel =  vehicleThermal.ambient; % Cell model temperature, K
ModuleAssembly2.Module2.vParallelAssembly = repmat(0, 11, 1); % Parallel Assembly Voltage, V
ModuleAssembly2.Module2.socParallelAssembly = repmat(1, 11, 1); % Parallel Assembly state of charge

%% ModuleAssembly3.Module1
ModuleAssembly3.Module1.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly3.Module1.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly3.Module1.socCellModel = battery.initialPackSOC; % Cell model state of charge
ModuleAssembly3.Module1.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly3.Module1.temperatureCellModel =  vehicleThermal.ambient; % Cell model temperature, K
ModuleAssembly3.Module1.vParallelAssembly = repmat(0, 11, 1); % Parallel Assembly Voltage, V
ModuleAssembly3.Module1.socParallelAssembly = repmat(1, 11, 1); % Parallel Assembly state of charge

%% ModuleAssembly3.Module2
ModuleAssembly3.Module2.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly3.Module2.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly3.Module2.socCellModel = battery.initialPackSOC; % Cell model state of charge
ModuleAssembly3.Module2.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly3.Module2.temperatureCellModel =  vehicleThermal.ambient; % Cell model temperature, K
ModuleAssembly3.Module2.vParallelAssembly = repmat(0, 11, 1); % Parallel Assembly Voltage, V
ModuleAssembly3.Module2.socParallelAssembly = repmat(1, 11, 1); % Parallel Assembly state of charge

%% ModuleAssembly4.Module1
ModuleAssembly4.Module1.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly4.Module1.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly4.Module1.socCellModel = battery.initialPackSOC; % Cell model state of charge
ModuleAssembly4.Module1.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly4.Module1.temperatureCellModel =  vehicleThermal.ambient; % Cell model temperature, K
ModuleAssembly4.Module1.vParallelAssembly = repmat(0, 11, 1); % Parallel Assembly Voltage, V
ModuleAssembly4.Module1.socParallelAssembly = repmat(1, 11, 1); % Parallel Assembly state of charge

%% ModuleAssembly4.Module2
ModuleAssembly4.Module2.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly4.Module2.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly4.Module2.socCellModel = battery.initialPackSOC; % Cell model state of charge
ModuleAssembly4.Module2.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly4.Module2.temperatureCellModel =  vehicleThermal.ambient; % Cell model temperature, K
ModuleAssembly4.Module2.vParallelAssembly = repmat(0, 11, 1); % Parallel Assembly Voltage, V
ModuleAssembly4.Module2.socParallelAssembly = repmat(1, 11, 1); % Parallel Assembly state of charge

%% ModuleAssembly5.Module1
ModuleAssembly5.Module1.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly5.Module1.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly5.Module1.socCellModel = battery.initialPackSOC; % Cell model state of charge
ModuleAssembly5.Module1.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly5.Module1.temperatureCellModel =  vehicleThermal.ambient; % Cell model temperature, K
ModuleAssembly5.Module1.vParallelAssembly = repmat(0, 11, 1); % Parallel Assembly Voltage, V
ModuleAssembly5.Module1.socParallelAssembly = repmat(1, 11, 1); % Parallel Assembly state of charge

%% ModuleAssembly5.Module2
ModuleAssembly5.Module2.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly5.Module2.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly5.Module2.socCellModel = battery.initialPackSOC; % Cell model state of charge
ModuleAssembly5.Module2.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly5.Module2.temperatureCellModel =  vehicleThermal.ambient; % Cell model temperature, K
ModuleAssembly5.Module2.vParallelAssembly = repmat(0, 11, 1); % Parallel Assembly Voltage, V
ModuleAssembly5.Module2.socParallelAssembly = repmat(1, 11, 1); % Parallel Assembly state of charge

% Suppress MATLAB editor message regarding readability of repmat
%#ok<*REPMAT>

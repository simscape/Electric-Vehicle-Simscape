function breakdown = extractEnergyBreakdown(logsout)
% EXTRACTENERGYBREAKDOWN Extract per-component energy data from logsout
%
%   breakdown = extractEnergyBreakdown(simout.logsout)
%
%   Scans logsout for all signals named 'energy', maps each to its
%   source component using the BlockPath, and returns a struct with
%   per-component values, a total, and Controller range signals.
%
%   Output struct fields:
%     EnergyCons   - Total energy across all components (Wh)
%     EM1energy    - Front motor energy
%     EM2energy    - Rear motor energy
%     HVACenergy   - HVAC system energy
%     HeaterEnergy - Heater energy
%     ChillerEnergy - Chiller energy
%     BattPumpEnergy  - Battery pump energy
%     MotorPumpEnergy - Motor pump energy
%     AuxEnergy    - Total auxiliary (Chiller+Heater+Pumps)
%     Distance     - Distance from Controller (m)
%     RangeRating  - Range rating from Controller (km)
%     Energy       - Total energy from Controller range estimator (Wh)
%
%   Not all fields appear in every run. Only components present in the
%   active Vehicle template produce energy signals.
%
% Copyright 2024-2026 The MathWorks, Inc.

breakdown = struct();

%% ====================================================================
%  SECTION 1: Discover energy signals
%  All components log their energy output with the signal name 'energy'.
%  logsout.get("energy") returns one Signal (single component) or a
%  Dataset (multiple components).
%  ====================================================================

energySigs = logsout.get("energy");

if isempty(energySigs)
    warning('extractEnergyBreakdown:noEnergy', ...
        'No signals named "energy" found in logsout.');
    breakdown.EnergyCons = 0;
    return;
end

if isa(energySigs, 'Simulink.SimulationData.Signal')
    nSigs = 1;
    sigCell = {energySigs};
else
    nSigs = energySigs.numElements;
    sigCell = cell(nSigs, 1);
    for k = 1:nSigs
        sigCell{k} = energySigs.getElement(k);
    end
end

%% ====================================================================
%  SECTION 2: Component mapping
%  Each energy signal carries a BlockPath that identifies which component
%  produced it. The table below maps a substring in the BlockPath to a
%  human-readable field name.
%
%  To add a new component:
%    1. Add a row  { 'BlockPath substring', 'FieldName' }
%    2. The substring must be unique enough to avoid false matches
%    3. More specific entries must come BEFORE generic ones
%       (e.g. 'Battery Pump' before 'Pump')
%
%  If no row matches, the signal gets a generic name 'energy_N'.
%  ====================================================================

componentMap = {
    % BlockPath substring     Output field name
    % -----------------------  -----------------
    'Front Motor',             'EM1energy'          % Front motor / EM1
    'Rear Motor',              'EM2energy'          % Rear motor / EM2
    'HVAC',                    'HVACenergy'         % HVAC system
    'Chiller',                 'ChillerEnergy'      % Chiller
    'Heater',                  'HeaterEnergy'       % Heater
    'Battery Pump',            'BattPumpEnergy'     % Battery coolant pump
    'Motor Pump',              'MotorPumpEnergy'    % Motor coolant pump
    'Pump',                    'PumpEnergy'         % Generic pump fallback
};

% Pre-fill all mapped fields to 0 so consumers get a complete struct
for m = 1:size(componentMap, 1)
    breakdown.(componentMap{m, 2}) = 0;
end

%% ====================================================================
%  SECTION 3: Extract and sum energy values
%  ====================================================================

totalEnergy = 0;

for k = 1:nSigs
    sig = sigCell{k};
    vals = getValuesFromLogsout(sig);
    finalVal = vals.Data(end);

    % Read block path string
    bp = sig.BlockPath;
    if isa(bp, 'Simulink.SimulationData.BlockPath')
        pathStr = bp.getBlock(1);
    else
        pathStr = char(bp);
    end

    % Match against component map
    fieldName = '';
    for m = 1:size(componentMap, 1)
        if contains(pathStr, componentMap{m, 1})
            fieldName = componentMap{m, 2};
            break;
        end
    end

    % Fallback for unknown components
    if isempty(fieldName)
        fieldName = sprintf('energy_%d', k);
    end

    breakdown.(fieldName) = finalVal;
    totalEnergy = totalEnergy + finalVal;
end

breakdown.EnergyCons = totalEnergy;

% Computed auxiliary total (everything except motors and HVAC)
auxFields = {'ChillerEnergy','HeaterEnergy','BattPumpEnergy','MotorPumpEnergy','PumpEnergy'};
auxTotal = 0;
for k = 1:numel(auxFields)
    if isfield(breakdown, auxFields{k})
        auxTotal = auxTotal + breakdown.(auxFields{k});
    end
end
breakdown.AuxEnergy = auxTotal;

%% ====================================================================
%  SECTION 4: Controller range signals
%  These come from the Controller/Range Estimator subsystem and are
%  independent of the component energy logging.
%  ====================================================================

controllerSignals = {"Distance", "RangeRating", "Energy"};
for k = 1:numel(controllerSignals)
    sigName = controllerSignals{k};
    try
        vals = getValuesFromLogsout(logsout.get(sigName));
        breakdown.(sigName) = vals.Data(end);
    catch
        breakdown.(sigName) = NaN;
    end
end

end

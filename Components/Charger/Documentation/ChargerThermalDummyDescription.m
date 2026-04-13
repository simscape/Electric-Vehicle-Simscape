%% ChargerThermalDummy
% Dummy variant of the thermal charger with coolant port pass-through.

%% Overview
% The ChargerThermalDummy block exposes the same thermal ports as
% ChargerThermal so the coolant loop remains closed, but requires no
% internal parameter data. It is used when real charger thermal data is not
% yet available or when the charger thermal behavior is not the focus of
% the study.
%
% *Model:* |ChargerThermalDummy.slx|
%
% *Parameters:* |ChargerThermalDummyParams.m|
%
% *Thermal Coupling:* Yes (port-compatible pass-through)

%% Open Model

open_system('ChargerThermalDummy')

%% Ports
% *Inputs*
%
% * *Relay command* - Charger enable.
% * *Battery cell voltage* - CC-CV feedback.
% * *Charging status* - Charge mode signal.
% * *Coolant port* - Thermal-liquid interface (pass-through).
%
% *Outputs*
%
% * *Charging Current* - Nominal or zero current.
% * *HV Power* - Nominal or zero power.
% * *Converter Thermal States* - Minimal thermal output.

%% Workflows
% The ChargerThermalDummy block is a placeholder for thermal-loop
% integration testing when real charger thermal parameters are unavailable.

%% See Also
% * <ChargerDescription.html Charger>
% * <ChargerDummyDescription.html ChargerDummy>
% * <ChargerThermalDescription.html ChargerThermal>
% * <ChargerWithThermalDescription.html ChargerWithThermal>

% Copyright 2022 - 2025 The MathWorks, Inc.

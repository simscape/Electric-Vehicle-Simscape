%% ChargerDummy
% Minimal stub charger providing the same port interface as the full
% Charger model.

%% Overview
% The ChargerDummy block is a pass-through placeholder that exposes the
% same ports as the full Charger block but requires no internal parameter
% data. It is used when the charger subsystem is not the focus of a study
% but the system model needs a connected charger block to simulate without
% errors.
%
% *Model:* <matlab:open_system('ChargerDummy') ChargerDummy.slx>
%
% *Parameters:* <matlab:edit('ChargerDummyParams.m') ChargerDummyParams.m>
%
% *Thermal Coupling:* None

%% Open Model

open_system('ChargerDummy')

%% Ports
% *Inputs*
%
% * *Relay command* - Charger enable.
% * *Battery cell voltage* - CC-CV feedback (passed through).
% * *Charging state* - Charge mode signal.
%
% *Outputs*
%
% * *Charging Current* - Nominal or zero current.
% * *HV Power* - Nominal or zero power.

%% Workflows
% The ChargerDummy block is a placeholder variant for integration testing
% or when charger behavior is not under study.

%% See Also
% * <ChargerDescription.html Charger>
% * <ChargerThermalDescription.html ChargerThermal>
% * <ChargerThermalDummyDescription.html ChargerThermalDummy>
% * <ChargerTestHarnessDescription.html Charger Test Harness>

% Copyright 2022 - 2026 The MathWorks, Inc.

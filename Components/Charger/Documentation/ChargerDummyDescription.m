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
%
% <html>
% <h3>Input Bus &mdash; <code>s</code></h3>
% <p>Input bus <code>s</code> is terminated in this fidelity.</p>
% <h3>Output Bus</h3>
% <p>No output bus.</p>
% <h3>Physical Ports</h3>
% <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse">
% <tr><th>Port</th><th>Domain</th><th>Description</th></tr>
% <tr><td>HV</td><td>Electrical</td><td>High-voltage bus connection</td></tr>
% </table>
% </html>

%% Workflows
% The ChargerDummy block is a placeholder variant for integration testing
% or when charger behavior is not under study.

%% See Also
% * <ChargerDescription.html Charger>
% * <ChargerThermalDescription.html ChargerThermal>
% * <ChargerThermalDummyDescription.html ChargerThermalDummy>
% * <ChargerTestHarnessDescription.html Charger Test Harness>

% Copyright 2022 - 2026 The MathWorks, Inc.

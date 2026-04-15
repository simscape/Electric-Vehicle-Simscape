%% HVAC Test Harness
% Standalone test environment for the HVAC component.

%% Overview
% The HVACTestHarness provides a standalone simulation environment for
% validating the HVAC subsystem. The harness supplies ambient temperature,
% blower/PTC/compressor commands, battery voltage, and SOC to exercise the
% HVAC model through heating and cooling scenarios.
%
% The default fidelity in the harness is *HVACEmpiricalRef*, which uses
% empirical performance curves for the cabin blower, PTC heater, and
% compressor. A controlled current source represents the electrical load
% on the HV bus. Parameters are initialized by |HVACTestHarnessParams.m|,
% which loads |HVACEmpiricalRefParams.m|.
%
% *Harness:* <matlab:open_system('HVACTestHarness') HVACTestHarness.slx>
%
% *Parameters:* <matlab:edit('HVACTestHarnessParams.m') HVACTestHarnessParams.m>
%
% *Test Case:* <matlab:edit('HVACPassTests.m') HVACPassTests.m>
%
% *Fidelity:* HVACEmpiricalRef

%% Setup
% Load parameters and open the test harness.

model = 'HVACTestHarness';
HVACTestHarnessParams;
load_system(model)

%% Run Simulation and Results

simout = sim(model, 'SrcWorkspace', 'current');
plotHVACHarnessResults(simout.logsout)

%% Running Unit Tests
% Run the MQC test suite from the command line:
%
%   results = runtests('HVACPassTests');
%   disp(results)

%% See Also
% * <HVACEmpiricalRefDescription.html HVACEmpiricalRef>
% * <HVACSimpleThDescription.html HVACsimpleTh>

% Copyright 2022 - 2025 The MathWorks, Inc.

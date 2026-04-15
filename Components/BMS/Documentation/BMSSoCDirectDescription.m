%% BMSSoCDirect
% BMS variant with direct coulomb-counting SOC estimation.

%% Overview
% The BMSSoCDirect uses direct coulomb-counting to estimate the battery
% state of charge. SOC is computed by integrating pack current over time
% from a known initial condition. This approach is simple and
% computationally inexpensive but subject to drift over long simulations
% without periodic recalibration.
%
% *Model:* |SOC/BMSSoCDirect.slx|
%
% *Parameters:* <matlab:edit('BMSSoCDirectParams.m') BMSSoCDirectParams.m>
%
% *Thermal Coupling:* Yes

%% Open Model

open_system('BMSSoCDirect')

%% Ports
% Same port interface as the base <BMSDescription.html BMS>. The SOC
% output is computed via coulomb counting instead of the default estimator.

%% Workflows
% The BMSSoCDirect serves as a baseline SOC estimator for simulations where
% SOC accuracy is secondary. It can be swapped with
% <BMSSoCEKFDescription.html BMSSoCEKF> for algorithm comparison studies.

%% Parameters
% The BMSSoCDirect shares the same parameter file as the base BMS.
%
% See |BMSParams.m| for a complete list.

%% See Also
% * <BMSDescription.html BMS>
% * <BMSSoCEKFDescription.html BMSSoCEKF>
% * <matlab:web('ControllerDescription.html') Controller>

% Copyright 2022 - 2025 The MathWorks, Inc.

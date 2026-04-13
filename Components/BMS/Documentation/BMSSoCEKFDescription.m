%% BMSSoCEKF
% BMS variant with extended Kalman filter (EKF) SOC estimation.
%
% *Model:* |SOC/BMSSoCEKF.slx|
%
% *Parameters:* |BMSParams.m|
%
% *Thermal Coupling:* Yes

%% Overview
% The BMSSoCEKF combines a battery equivalent-circuit model with noisy
% voltage and current measurements to produce a filtered SOC estimate with
% improved accuracy compared to direct coulomb counting. The extended
% Kalman filter provides noise rejection and corrects for model
% uncertainties during the estimation process.

open_system('BMSSoCEKF')

%% Ports
% Same port interface as the base <BMSDescription.html BMS>. The SOC
% output is computed via the EKF observer instead of the default estimator.

%% Workflows
% The BMSSoCEKF is used in BMS algorithm development and SOC estimation
% accuracy studies. It is useful for evaluating observer tuning and noise
% rejection in realistic drive-cycle scenarios. It can be swapped with
% <BMSSoCDirectDescription.html BMSSoCDirect> for algorithm comparison.

%% Parameters
% The BMSSoCEKF shares the same parameter file as the base BMS.
%
% See |BMSParams.m| for a complete list.

%% See Also
% * <BMSDescription.html BMS>
% * <BMSSoCDirectDescription.html BMSSoCDirect>
% * <matlab:web('ControllerDescription.html') Controller>

% Copyright 2022 - 2025 The MathWorks, Inc.

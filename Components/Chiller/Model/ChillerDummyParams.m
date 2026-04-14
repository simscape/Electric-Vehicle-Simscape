% Chiller Dummy Parameters
% Minimal parameter set — fixed electrical load only.

% Copyright 2025 The MathWorks, Inc.

chiller.chillerMaxPower = 6000; % [W] Fixed electrical load when active

% Coolant pass-through (needed by vehicle-level solver)
vehicleThermal.coolant_p_init  = 0.101325;    % [MPa]
vehicleThermal.coolant_T_init  = 25 + 273.15; % [K]
vehicleThermal.coolant_pipe_D  = 0.019;       % [m]

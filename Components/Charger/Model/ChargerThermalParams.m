% Copyright 2025 The MathWorks, Inc.

%
%% Battery CC-CV batteryCharger parameters
batteryCharger.MaxVolt = 4.2; % Maximum voltage for batteryCharger V
batteryCharger.Kp = 1; % Charger controller proportional gain
batteryCharger.Ki = 1; % Charger controller integral gain
batteryCharger.Kaw = 1; % Charger controller anti-windup gain
batteryCharger.CC_A=50;      % Charger constant current value (A)


%batteryChargerWithThermal
vehicleThermal.coolant_p_init = 0.101325;
vehicleThermal.coolant_T_init=25+273.155;  % [K] Coolant initial temperature
vehicleThermal.coolant_channel_D = 0.0092; % [m] Coolant jacket channels diameter

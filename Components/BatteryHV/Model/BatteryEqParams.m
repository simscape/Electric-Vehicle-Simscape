%% BatteryEqParams — Parameters for BatteryEq (Piaggio Ape E-City)
% BatteryEqParams Battery equivalent circuit parameters for the
% three-wheel BEV.
%
%   Cell: 3.2 V nominal, 156 Ah, ~3.2 kg
%   Pack: 15S1P — 48 V, 156 Ah, 7.5 kWh
%
% Copyright 2026 The MathWorks, Inc.

%% Pack Structure
battery.Ns = 15;
battery.Np = 1;

%% Electrical
battery.Vnom = 3.2 * battery.Ns;                     % [V] pack nominal voltage (48 V)
battery.R1 = 5.92;                                   % [mOhm] cell internal resistance
battery.AH = 156 * battery.Np;                       % [Ah] pack capacity
battery.V1 = 47;                                     % [V] voltage at AH1
battery.AH1 = battery.AH / 2;                        % [Ah] capacity at V1
battery.initialPackSOC = 0.5;                        % [-] initial state of charge

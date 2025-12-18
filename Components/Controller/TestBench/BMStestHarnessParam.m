% Copyright 2022 - 2023 The MathWorks, Inc.

% Voltage Fault parameters
battery.MinVoltLmt=3;    % Min Cell Voltage limit (V)
battery.MaxVoltLmt=4.2;  % Max Cell Voltage limit (V)
battery.VoltOffset=0.2;     % Voltage offset for immediate fault (V)

% Current fault parameters
battery.MaxChrgCurLim=100;   % Max Charging Current (A)
battery.MaxDchrgCurLim=120;  % Max Discharging Current (A)
battery.ChargerCC_A=50;      % Charger constant current value (A)
battery.ChargerCV_V=62;      % Constant voltage charger value (V)
battery.CurrOffset=20;       % Current offset for immediate fault (A)

% Thermal Fault parameters
battery.MinThLmt=263.15;    % [K] Min Cell temp for fault in K - 10 deg Celcius
battery.MaxThLmt=333.15;    % [K] Max Cell temp for fault in K - 60 deg Celcius

%% Module Electrical
battery.Ns=110;    % Number of series connected strings
battery.Np=3;      % Number of parallel cells per string

%% Environment setting
vehicleThermal.ambient=25+273.15;          %[K] Ambient temperature in K
battery.CoolantSwitchOnTp=320; % [K] Temperature to switch on coolant flow
battery.CoolantSwitchOffTp=303; % [K] temperature to switch of coolant flow
vehicleThermal.coolant_T_init=25+273.155;  % [K] Coolant initial temperature

load('TestSeqBusObject.mat')


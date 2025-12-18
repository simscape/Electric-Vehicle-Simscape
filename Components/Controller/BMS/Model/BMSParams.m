% Copyright 2025 The MathWorks, Inc.

% Voltage Fault parameters
BMSData.MinVoltLmt=3;    % Min Cell Voltage limit (V)
BMSData.MaxVoltLmt=4.2;  % Max Cell Voltage limit (V)
BMSData.VoltOffset=0.2;     % Voltage offset for immediate fault (V)

% Current fault parameters
BMSData.MaxChrgCurLim=100;   % Max Charging Current (A)
BMSData.MaxDchrgCurLim=120;  % Max Discharging Current (A)
BMSData.ChargerCC_A=50;      % Charger constant current value (A)
BMSData.ChargerCV_V=62;      % Constant voltage charger value (V)
BMSData.CurrOffset=20;       % Current offset for immediate fault (A)

% Thermal Fault parameters
BMSData.MinThLmt=233.15;    % [K] Min Cell temp for fault in K - (-40) deg Celcius
BMSData.MaxThLmt=333.15;    % [K] Max Cell temp for fault in K - 60 deg Celcius

%% Module Electrical
BMSData.Ns=110;    % Number of series connected strings
BMSData.Np=3;      % Number of parallel cells per string

%% Environment setting
vehicleThermal.ambient=25+273.15;          %[K] Ambient temperature in K
BMSData.CoolantSwitchOnTp=320; % [K] Temperature to switch on coolant flow
BMSData.CoolantSwitchOffTp=303; % [K] temperature to switch of coolant flow
vehicleThermal.coolant_T_init=25+273.155;  % [K] Coolant initial temperature

%Bus Data
load('BMSBusInspector.mat'); % BMS bus data
load('BMSbatCmdData.mat'); % Battery command data
%% Parameters for Lithium-Ion Battery Pack BMS example
% Battery parameters

% Copyright 2022 The MathWorks, Inc.
 

battery.samplingTime=1;   % Sampling time (s)

%% Cell Electrical

battery.V0_mat=[
    3.4966    3.5057    3.5148
    3.5519    3.5660    3.5653
    3.6183    3.6337    3.6402
    3.7066    3.7127    3.7213
    3.9131    3.9259    3.9376
    4.0748    4.0777    4.0821
    4.1923    4.1928    4.1930]; % [V] Em open-circuit voltage vs SOC rows and T columns
battery.R0_mat=[
    0.0117    0.0085    0.0090
    0.0110    0.0085    0.0090
    0.0114    0.0087    0.0092
    0.0107    0.0082    0.0088
    0.0107    0.0083    0.0091
    0.0113    0.0085    0.0089
    0.0116    0.0085    0.0089]; % [Ohm] R0 resistance vs SOC rows and T columns

battery.R1_mat=[
    0.0109    0.0029    0.0013
    0.0069    0.0024    0.0012
    0.0047    0.0026    0.0013
    0.0034    0.0016    0.0010
    0.0033    0.0023    0.0014
    0.0033    0.0018    0.0011
    0.0028    0.0017    0.0011]; % [Ohm] R1 Resistance vs SOC rows and T columns
battery.C1_mat=[
    1913.6    12447    30609
    4625.7    18872    32995
    23306     40764    47535
    10736     18721    26325
    18036     33630    48274
    12251     18360    26839
    9022.9    23394    30606]; % [F] C1 Capacitance vs SOC rows and T columns
battery.Tau1_mat=battery.R1_mat .* battery.C1_mat;

%% Cell Thermal
battery.MdotCp=100;        % Cell thermal mass (mass times specific heat [J/K])
battery.coolantRes=1.2; % Cell level coolant thermal path resistance, K/W

%% Module Electrical
battery.Ns=110;    % Number of series connected strings
battery.Np=3;      % Number of parallel cells per string

%% Cell-to-cell variation
battery.iniT=vehicleThermal.ambient*ones(1,battery.Ns*battery.Np);  % Module-1 Cell-to-Cell initial Temperature variation
battery.iniSOC=battery.initialPackSOC*ones(1,battery.Ns*battery.Np);        % Module-1 Cell-to-Cell initial SOC variation

%% Cell Thermal
battery.MdotCp=100;        % Cell thermal mass (mass times specific heat [J/K])
battery.CoolantRes=1.2; % Cell level coolant thermal path resistance, K/W
battery.CoolantSwitchOnTp=320; % [K] Temperature to switch on coolant flow
battery.CoolantSwitchOffTp=303; % [K] temperature to switch of coolant flow

%% Module Electrical
battery.Ns=110;             % Number of series connected strings
battery.Np=3;             % Number of parallel cells per string

%% Battery CC-CV charger parameters
battery.ChargeMaxVolt = 4.2; % Maximum voltage for charger V
battery.ChargeKp = 1; % Charger controller proportional gain
battery.ChargerKi = 1; % Charger controller integral gain
battery.ChargerKaw = 1; % Charger controller anti-windup gain

%% Battery Fault Parameters

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


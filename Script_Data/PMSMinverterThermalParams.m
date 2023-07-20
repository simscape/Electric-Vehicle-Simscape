%% Parameters for Inverter Liquid Cooling Example

% Copyright 2022 The MathWorks, Inc.

fsw  = 2000;         % Inverter switching frequency [Hz]
Ts   = 1/fsw/100;  % Fundamental sample time      [s]
Tsc = 0; % continuous controller
Vdc = 1000;
pumpFlowRate = 20; % [lpm]
WEGdensity = 1000; %[kg/m^3]
pumpFlowRateM = pumpFlowRate*WEGdensity/60000; %[kg/sec]
Tamb = 25; % initial fluid temperature in flow lines  [degC]


% Heatsink
HeatsinkParams = struct();
HeatsinkParams.Height = 50e-3;
HeatsinkParams.Thick = 1.5e-3;
HeatsinkParams.Gap = 2.5e-3;
HeatsinkParams.Depth = 1.5e-3;
HeatsinkParams.NumFins =3*120; % No of fins must be a multiple of 3
HeatsinkParams.Mass = 8960*HeatsinkParams.Height*HeatsinkParams.Thick*HeatsinkParams.Depth*HeatsinkParams.NumFins;
HeatsinkParams.ChennelHeight = 1.01*HeatsinkParams.Height;
HeatsinkParams.ChennelWidth = 1.01*(sqrt(HeatsinkParams.NumFins)*(HeatsinkParams.Thick+HeatsinkParams.Gap)-HeatsinkParams.Gap);
HeatsinkParams.ChennelLength = 3*HeatsinkParams.ChennelWidth;
HeatsinkParams.numFinsCross = sqrt(HeatsinkParams.NumFins/3);
HeatsinkParams.ChennelArea = HeatsinkParams.ChennelWidth*HeatsinkParams.ChennelHeight - HeatsinkParams.numFinsCross*(HeatsinkParams.Height*HeatsinkParams.Thick);
HeatsinkParams.ChennelPerimeter = 2*(HeatsinkParams.ChennelWidth+HeatsinkParams.ChennelHeight);
HeatsinkParams.EqPipeDia = 4*HeatsinkParams.ChennelArea/HeatsinkParams.ChennelPerimeter;
HeatsinkParams.EqPipeRoughness = HeatsinkParams.numFinsCross*(HeatsinkParams.Thick*HeatsinkParams.Height)/(2*(HeatsinkParams.Thick+HeatsinkParams.Gap));
HeatsinkParams.EqLengthRough = HeatsinkParams.NumFins*(HeatsinkParams.Height + HeatsinkParams.Thick)/2;
% Coolant resvoir
TankParams = struct();
TankParams.Temp = 298.15; % resvoir temperature (fixed) [K]
%Pipe Params
PipeParams.Diameter = 0.1; %[m]
% Cooling plate
CaseParams = struct();
CaseParams.Area = HeatsinkParams.ChennelLength*HeatsinkParams.ChennelWidth;
CaseParams.Thickness = 5e-3;
CaseParams.ThermalConductivity = 300;
CaseParams.Mass = 896*CaseParams.Area*CaseParams.Thickness;
CaseParams.SpHeat = 385;
% Diode and IGBT Rth 
RthIGBT = [0.01,0.07,0.08,0.045];
tauthIGBT = [0.001,0.03,0.25,1.5];
RthDiode = [0.017,0.12,0.1,0.038];
tauthDiode = [0.001,0.03,0.25,1.5];

TinitStruct = struct();
TinitStruct.IGBT_AH.IGBT = [25,25,25,25];
TinitStruct.IGBT_AL.IGBT = [25,25,25,25];
TinitStruct.IGBT_BH.IGBT = [25,25,25,25];
TinitStruct.IGBT_BL.IGBT = [25,25,25,25];
TinitStruct.IGBT_CH.IGBT = [25,25,25,25];
TinitStruct.IGBT_CL.IGBT = [25,25,25,25];
TinitStruct.IGBT_AH.Body_Diode = [25,25,25,25];
TinitStruct.IGBT_AL.Body_Diode = [25,25,25,25];
TinitStruct.IGBT_BH.Body_Diode = [25,25,25,25];
TinitStruct.IGBT_BL.Body_Diode = [25,25,25,25];
TinitStruct.IGBT_CH.Body_Diode = [25,25,25,25];
TinitStruct.IGBT_CL.Body_Diode = [25,25,25,25];
%% Motor Thermal parameters 
% Script to generate PMSM Motor Thermal Parameters.

% Copyright 2022 - 2023 The MathWorks, Inc.

%% Material Properties
electricDrive.IronDensity = 760.0; % Iron density in Kg/m3
electricDrive.IronThConductivity = 50; % Iron Thermal conductivity W/(K*m)
electricDrive.IronSpHeat = 447.0; % Iron specific heat J/(K*kg)
electricDrive.CopperDensity = 896.0; % Copper Density in Kg/m3
electricDrive.CopperThconductivity = 300; % Copper Thermal conductivity W/(K*m)
electricDrive.CopperSpHeat = 385.0; % Copper specific heat J/(K*kg)

%% Parameters
% Stator Input Parameters
electricDrive.MotorThermal.Npl = 4; % no of PM pole pairs on the rotor
electricDrive.MotorThermal.No_stator_slot = 48; % no of stator slot
electricDrive.MotorThermal.Statotor_Bore_id = 130.96/1000; % Stator bore ID (mm/1000)
electricDrive.MotorThermal.stator_od = 198.12/1000; % Stator bore OD (mm/1000)
electricDrive.MotorThermal.stator_tooth_width = 4.15/1000; %(mm/1000)
electricDrive.MotorThermal.slotDepth = 21.1/1000; %(mm/1000)
electricDrive.MotorThermal.stackLength = 151.38/1000; %(mm/1000)
%Rotor Input Parameters
electricDrive.MotorThermal.rotorStackLength = 151.6/1000; %(mm/1000)
electricDrive.MotorThermal.rotor_od = 129.97/1000; %(mm/1000)
electricDrive.MotorThermal.BridgeThickness = 1.5/1000; %(mm/1000)
electricDrive.MotorThermal.GrossRotorMass = 16.45;
electricDrive.MotorThermal.magnetMass = 1.895;

% 3-Phase Winding Input Parameters
electricDrive.MotorThermal.WindingOverhang = 0.2; % fraction of stator stack length
electricDrive.MotorThermal.SlotPackingFactor = 0.4;
%Coolant jacket Input Parameters
electricDrive.MotorThermal.ChennelSection = [5,10];
electricDrive.MotorThermal.NoOfChennelTurns = 5;
% U pin winding oil cooling parameters 
electricDrive.MotorThermal.ODpcd = 200; %winding outer envalope diameter(mm)
electricDrive.MotorThermal.barW = 5;% Winding Bar section width(mm)
electricDrive.MotorThermal.barH = 5;% Winding Bar section height(mm)
electricDrive.MotorThermal.Oft = 0.2;%Oil Film Thickness(mm)
electricDrive.MotorThermal.Pr = 330;%ATF Prandtl No
electricDrive.MotorThermal.KinVisc = 9.87; %Kinamatic viscosity of ATF(cSt)
electricDrive.MotorThermal.motorOilflow = 5/60000; %Oil flow rate m^3/sec
electricDrive.MotorThermal.oilDensity = 850; % Kg/m^3
electricDrive.MotorThermal.oilSpHeat = 2150; % J/Kg-K
%Mass & Volume Calculations
electricDrive.MotorThermal.GrossToothMass = electricDrive.IronDensity*...
                                          electricDrive.MotorThermal.No_stator_slot*...
                                          electricDrive.MotorThermal.stator_tooth_width*...
                                          electricDrive.MotorThermal.slotDepth*...
                                          electricDrive.MotorThermal.stackLength;
electricDrive.MotorThermal.StatorBackIronMass = electricDrive.IronDensity*...
                                              (pi/4)*((electricDrive.MotorThermal.stator_od^2)-...
                                              (electricDrive.MotorThermal.Statotor_Bore_id^2))*...
                                              electricDrive.MotorThermal.stackLength;
electricDrive.MotorThermal.Bridgemass=electricDrive.IronDensity*...
                                      (pi)*(electricDrive.MotorThermal.rotor_od-...
                                      electricDrive.MotorThermal.BridgeThickness)*...
                                      electricDrive.MotorThermal.rotorStackLength*...
                                      electricDrive.MotorThermal.BridgeThickness;
electricDrive.MotorThermal.RotorBackIronMass = electricDrive.MotorThermal.GrossRotorMass-...
                                             electricDrive.MotorThermal.Bridgemass;
electricDrive.MotorThermal.RotorBackIronId = (electricDrive.MotorThermal.rotor_od-...
                                           electricDrive.MotorThermal.BridgeThickness);
electricDrive.MotorThermal.StatorRootDia = (electricDrive.MotorThermal.Statotor_Bore_id+...
                                         electricDrive.MotorThermal.slotDepth);
electricDrive.MotorThermal.RotorAreaCyl = pi*electricDrive.MotorThermal.rotorStackLength*...
                                        electricDrive.MotorThermal.rotor_od;
electricDrive.MotorThermal.RotorAreaER = (pi/2)*electricDrive.MotorThermal.rotor_od^2;
electricDrive.MotorThermal.StatorWindingOhArea = 2*pi*(electricDrive.MotorThermal.stackLength*...
                                               electricDrive.MotorThermal.WindingOverhang)*...
                                               (electricDrive.MotorThermal.Statotor_Bore_id+...
                                               electricDrive.MotorThermal.StatorRootDia);
electricDrive.MotorThermal.WindingMass = electricDrive.CopperDensity*...
                                       electricDrive.MotorThermal.SlotPackingFactor*...
                                      ((pi/4)*((electricDrive.MotorThermal.Statotor_Bore_id+...
                                       2*electricDrive.MotorThermal.slotDepth)^2-...
                                       electricDrive.MotorThermal.Statotor_Bore_id^2)-...
                                       electricDrive.MotorThermal.No_stator_slot*...
                                       electricDrive.MotorThermal.stator_tooth_width*...
                                       electricDrive.MotorThermal.slotDepth)*...
                                       (1+2*electricDrive.MotorThermal.WindingOverhang)*...
                                       electricDrive.MotorThermal.stackLength;
electricDrive.MotorThermal.IronLossMass = electricDrive.MotorThermal.Bridgemass+...
                                        electricDrive.MotorThermal.GrossToothMass;
electricDrive.MotorThermal.vFractBridge = electricDrive.MotorThermal.Bridgemass/...
                                        electricDrive.MotorThermal.IronLossMass;
electricDrive.MotorThermal.vFractTooth = 1-electricDrive.MotorThermal.vFractBridge;
electricDrive.MotorThermal.PhaseWindingThMass = electricDrive.MotorThermal.WindingMass*...
                                              electricDrive.CopperSpHeat/3;
electricDrive.MotorThermal.RotorThMass = electricDrive.MotorThermal.GrossRotorMass*...
                                       electricDrive.IronSpHeat;


%Coolant Channel Calculation
electricDrive.MotorThermal.ChannelSection = electricDrive.MotorThermal.ChennelSection(1,1)*...
                                          electricDrive.MotorThermal.ChennelSection(1,2);
electricDrive.MotorThermal.Perimeter = 2*(electricDrive.MotorThermal.ChennelSection(1,1)+...
                                     electricDrive.MotorThermal.ChennelSection(1,2));
electricDrive.MotorThermal.ChannelHydraulicdia = 4*electricDrive.MotorThermal.ChannelSection/...
                                               electricDrive.MotorThermal.Perimeter;
electricDrive.MotorThermal.ChannelLength = pi*electricDrive.MotorThermal.NoOfChennelTurns*...
                                         (electricDrive.MotorThermal.stator_od+...
                                         electricDrive.MotorThermal.ChennelSection(1,1));
electricDrive.MotorThermal.uWindingArea = 2*(electricDrive.MotorThermal.barH+electricDrive.MotorThermal.barW)...
                                            *2*electricDrive.MotorThermal.WindingOverhang*1e-6;

electricDrive.p = [10000 100000	5000000	10000000 15000000 20000000 25000000	30000000 35000000 40000000 45000000	50000000];
electricDrive.dt = 1e-3;
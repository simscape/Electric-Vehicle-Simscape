% This script plots the temperature of magnet & copper coil 

% Copyright 2022 - 2023 The MathWorks, Inc.

figure();
Tmag = simlogPmsmThermalTestbench.PMSM_Drive.Temperature.Rotor_Thermal_Block.Magnet_Temperature.T.series;
Twin= simlogPmsmThermalTestbench.PMSM_Drive.Temperature.Stator_Thermal_Block.Stator_winding.T.series;
plot(Tmag.time,Tmag.values,"LineWidth",2,"Color",'red');
hold on;  
grid on;
plot(Twin.time,Twin.values,"Color",'yellow',"LineWidth",2);
title("Magnet and Winding Temperatures")
legend({'Magnet T', 'Winding T'})
xlabel('Time [s]')
ylabel('Temperature [K]')
hold off;
function [motorTorque,solTime] = simulateElectricModel(modelName,nominalRPM,simTime,options)
%simulateElectricModel Simulate electric motor model and return torque output.
%   [motorTorque, solTime] = simulateElectricModel(modelName, nominalRPM,
%   simTime) runs the specified motor model and returns the torque sensor
%   output and solution time vector.

% Copyright 2026 The MathWorks, Inc.

arguments(Input)
    modelName {mustBeText}
    nominalRPM {simscape.mustBeCommensurateUnit(nominalRPM,"rpm")} 
    simTime {mustBePositive mustBeFinite}
    options.BatteryVoltage {simscape.mustBeCommensurateUnit(options.BatteryVoltage,"V")} = simscape.Value(325,"V")
    options.MaxCurrent {simscape.mustBeCommensurateUnit(options.MaxCurrent,"A")} = simscape.Value(200,"A")
    options.MotorTorqueSetPoint{simscape.mustBeCommensurateUnit(options.MotorTorqueSetPoint,"N*m")}...
                    = simscape.Value(50,"N*m") %
end
Vnom = value(options.BatteryVoltage,"V");
Imax = value(options.MaxCurrent,"A");
Tstart = value(options.MotorTorqueSetPoint,"N*m");
p = get_param(modelName+"/Inverter and Motor/IPMSM","value@nPolePairs");
psim = get_param(modelName+"/Inverter and Motor/IPMSM","value@pm_flux_linkage");
Tmax = 1.5*p*psim*Imax; % Max electromagnetic torque
Pmax = value(nominalRPM,"rad/s")*Tmax;   % Maximum power
% Set simulation parameters based on options
set_param(modelName + "/Battery/Battery","Vnom", num2str(Vnom));
set_param(modelName +"/Motor Control/PMSM Field-Oriented Control","Pmax",num2str(Pmax));
set_param(modelName + "/Starting Torque","After",num2str(Tstart));
modelOut = sim(modelName,"StopTime",num2str(simTime));
motorTorque = modelOut.simlogmotorDrivelineElectricalTRQControl.Mechanical_sensor.Ideal_Torque_Sensor.T.series.values;
solTime = modelOut.simlogmotorDrivelineElectricalTRQControl.Mechanical_sensor.Ideal_Torque_Sensor.T.series.time;
% save("motorStartTorque","solTime","motorTorque");
plot(solTime,motorTorque,"Color","b");
xlabel("Time(s)");
ylabel("Motor Torque(N*m)")

end
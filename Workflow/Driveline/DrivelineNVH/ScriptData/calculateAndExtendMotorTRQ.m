function calculateAndExtendMotorTRQ(modelName,startingMotorTorqueVect,launchTimeVector)
%calculateAndExtendMotorTRQ Simulate motor torque for multiple setpoints and extend profiles.
%   calculateAndExtendMotorTRQ(modelName, startingMotorTorqueVect, launchTimeVector)
%   runs the electrical motor model for each torque setpoint, then extends
%   each resulting torque signal to cover the full launch duration. Results
%   are saved to extendedVehicleLaunchTorque.mat.

% Copyright 2026 The MathWorks, Inc.

arguments
    modelName {mustBeText}
    startingMotorTorqueVect {simscape.mustBeCommensurateUnit(startingMotorTorqueVect,"N*m")}
    launchTimeVector {simscape.mustBeCommensurateUnit(launchTimeVector,"s")}
end
nominalMotorRPM = simscape.Value(1800,"rpm");
batteryVoltage = simscape.Value(550,"V");
timeCell   = cell(1, length(startingMotorTorqueVect));
EXTtorqueCell = cell(1, length(startingMotorTorqueVect));
timeCellMotor = cell(1, length(startingMotorTorqueVect));
motorTorqueCell = cell(1, length(startingMotorTorqueVect));
load_system(modelName);
for i = 1:length(startingMotorTorqueVect)
    % Calculate Motor Torque
    [motorTRQ,solutionTime] = simulateElectricModel("motorDrivelineElectricalTRQControl",nominalMotorRPM,0.15,BatteryVoltage=batteryVoltage,...
    MaxCurrent=simscape.Value(600,"A"),MotorTorqueSetPoint=startingMotorTorqueVect(i));
    timeCellMotor{i} = solutionTime;
    motorTorqueCell{i} = motorTRQ;
    % Calculate extended torque
    [timeVector_i, torqueVector_i] = extendMotorTorque( ...
        motorTRQ, solutionTime, value(max(launchTimeVector)), 0.1);

     % Resample to 1 ms uniform grid to reduce file size
    dtResample = 1e-3;
    tUni = (timeVector_i(1):dtResample:timeVector_i(end))';
    timeCell{i} = tUni;
    EXTtorqueCell{i} = interp1(timeVector_i, torqueVector_i, tUni, 'linear');

    tUniM = (solutionTime(1):dtResample:solutionTime(end))';
    timeCellMotor{i} = tUniM;
    motorTorqueCell{i} = interp1(solutionTime, motorTRQ, tUniM, 'linear');
end
save(fullfile(fileparts(mfilename('fullpath')), "extendedVehicleLaunchTorque.mat"), ...
    "timeCellMotor","motorTorqueCell","timeCell","EXTtorqueCell","startingMotorTorqueVect")
close_system(modelName,0)
end
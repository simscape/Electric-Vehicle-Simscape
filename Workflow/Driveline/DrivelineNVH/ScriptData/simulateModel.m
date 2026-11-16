function [bearingTorqVar,RPM,bendingForce] = simulateModel(model,averagingWindowSize,options)
%simulateModel Simulate driveline torsion model and extract torque and speed.
%   [bearingTorqVar, RPM, bendingForce] = simulateModel(model,
%   averagingWindowSize) runs the mechanical driveline torsion model and
%   returns the normalized torque variation, shaft RPM, and bearing bending
%   forces.

% Copyright 2026 The MathWorks, Inc.

arguments(Input)
    model
    averagingWindowSize
    options.MotorShaftBending {mustBeNumericOrLogical} = false;
end
model_name = get_param(model, 'Name');
variant_block = [model_name,'/Flexible Driveline/Motor Mechanical'];
if options.MotorShaftBending 
set_param(variant_block, 'LabelModeActiveChoice', 'false');
else
set_param(variant_block, 'LabelModeActiveChoice', 'true');
end

modelOut = sim(model);
solTime = modelOut.simlogMechanicalDLTorsion.Flexible_Driveline.Mechanical_sensor.Ideal_Torque_Sensor.T.series.time;
if options.MotorShaftBending 
bendingForce = simscape.Value(modelOut.simlogMechanicalDLTorsion.Flexible_Driveline.Motor_Mechanical.Bending_Vibrations.Flexible_Shaft_Dynamics.Fsupports.series.values...
    ,modelOut.simlogMechanicalDLTorsion.Flexible_Driveline.Motor_Mechanical.Bending_Vibrations.Flexible_Shaft_Dynamics.Fsupports.series.unit);

figure(1)
plot(solTime,value(bendingForce(:,1)));
hold on
plot(solTime,value(bendingForce(:,2)));
hold off
legend({"Bending Force X","Bending Force Y"},"Location","NorthWest");
xlabel("Time [s]");
ylabel("Force (N)");
title("Force on Bearing Due to Shaft Bending");
else
bendingForce = simscape.Value(zeros(numel(solTime),2),"N");
end
figure();
torqueVector = simscape.Value(modelOut.simlogMechanicalDLTorsion.Flexible_Driveline.Mechanical_sensor.Ideal_Torque_Sensor.T.series.values,...
    modelOut.simlogMechanicalDLTorsion.Flexible_Driveline.Mechanical_sensor.Ideal_Torque_Sensor.T.series.unit);
bearingTorqVar = simscape.Value(value(torqueVector) - movmean(value(torqueVector),averagingWindowSize),...
    modelOut.simlogMechanicalDLTorsion.Flexible_Driveline.Mechanical_sensor.Ideal_Torque_Sensor.T.series.unit);
plot(solTime,value(torqueVector));
hold on
plot(solTime,value(bearingTorqVar));
hold off
legend({"Output Torque","Normalized Torque"},"Location","NorthWest");
xlabel("Time [s]");
ylabel("Torque (N*m)");
title("Motor Shaft Output Torque");
RPM = 30*(modelOut.simlogMechanicalDLTorsion.Flexible_Driveline.Mechanical_sensor.Ideal_Rotational_Motion_Sensor.W.series.values)/pi + 0.001;
end

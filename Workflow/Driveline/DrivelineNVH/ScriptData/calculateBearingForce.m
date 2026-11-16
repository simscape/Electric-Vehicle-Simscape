function netBearingForceVector = calculateBearingForce(torqueVector,rotorMass,gearDia,options)
%calculateBearingForce Compute net radial load on the bearing.
%   netBearingForceVector = calculateBearingForce(torqueVector, rotorMass,
%   gearDia) calculates the resultant bearing force from gear mesh tangential
%   forces, rotor weight, and optional bending forces.

% Copyright 2026 The MathWorks, Inc.

    arguments(Input)
        torqueVector {simscape.mustBeCommensurateUnit(torqueVector,"N*m")};
        rotorMass {simscape.mustBeCommensurateUnit(rotorMass,"kg")} = simscape.Value(0,"kg");
        gearDia {simscape.mustBeCommensurateUnit(gearDia,"mm")} = simscape.Value(1,"mm");
        options.gearMeshPointAngularPosition simscape.Value = simscape.Value(45,"deg");
        options.gearMeshDirection {mustBeMember(options.gearMeshDirection,[1,-1])} = 1;
        options.BendingXforceVector simscape.Value = simscape.Value(0,"N");
        options.BendingYforceVector simscape.Value = simscape.Value(0,"N");       
    end
    g = simscape.Value(9.81,"m/s^2");
    gearTForceVector = convert(2*torqueVector/gearDia,"N");
    bearingXforceVector = options.gearMeshDirection*gearTForceVector*cos(value(options.gearMeshPointAngularPosition,"rad"))+options.BendingXforceVector;
    bearingYforceVector = g*rotorMass + options.gearMeshDirection*gearTForceVector*sin(value(options.gearMeshPointAngularPosition,"rad"))+options.BendingYforceVector;                  
    netBearingForceVector = convert(sqrt(bearingXforceVector.^2+bearingYforceVector.^2),"N");  
 
end

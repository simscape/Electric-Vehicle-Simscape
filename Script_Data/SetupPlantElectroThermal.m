%% Setup plant for abstract fast running model

set_param('BEVsystemModel/Controller','ReferencedSubsystem','Controller');
set_param('BEVsystemModel/Vehicle','ReferencedSubsystem','VehicleElectroThermal');

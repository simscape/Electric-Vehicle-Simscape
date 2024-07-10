%% Setup plant for absract fast running model

set_param('BEVsystemModel/Controller','ReferencedSubsystem','Controller');
set_param('BEVsystemModel/Vehicle','ReferencedSubsystem','VehicleElectroThermal');
set_param('BEVsystemModel/Energy Consumption','ReferencedSubsystem','EnergyElectroThermal');

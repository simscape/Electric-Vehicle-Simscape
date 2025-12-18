%% Setup plant for absract fast running model

set_param('BEVsystemModel/Controller','ReferencedSubsystem','ControllerFRM');
set_param('BEVsystemModel/Vehicle','ReferencedSubsystem','VehicleElectric');
set_param('BEVsystemModel/Energy Consumption','ReferencedSubsystem','EnergyElectric');


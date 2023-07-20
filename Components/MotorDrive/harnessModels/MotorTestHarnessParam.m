% Copyright 2022 - 2023 The MathWorks, Inc.
vehicleThermal.coolant_T_init=25+273.155;  % [K] Coolant initial temperature

run('PMSMthermalParams');                  % Motor thermal param file
run('PMSMmotorDriveParms');                % Motor param file
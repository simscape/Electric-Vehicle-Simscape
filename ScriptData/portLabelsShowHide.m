% Copyright 2022 - 2023 The MathWorks, Inc.

function portLabelsShowHide(mdl,showHide)
sublist = ...
    {'Front Motor (EM1)','Charger','Heater','Chiller','Radiator','DCDC','Rear Motor (EM2)','HVAC','Driveline','Motor Pump','Battery Pump'};

switch lower(showHide)
    case 'show', opaqueSetting = 'opaque-with-ports';
    case 'hide', opaqueSetting = 'opaque';
end

for i = 1:length(sublist)
    maskObj = get_param([mdl '/Vehicle/' sublist{i}],'MaskObject');
    maskObj.IconOpaque = opaqueSetting;
end
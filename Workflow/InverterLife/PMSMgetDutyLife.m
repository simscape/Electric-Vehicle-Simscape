% This function returns the inverter switch life for the duty cycle by fitting a regression curve for the test cycle

% Copyright 2022 - 2023 The MathWorks, Inc.
function dutyLife = PMSMgetDutyLife(peakItest,EOLrth,eqTest)
testLife = 1e6*(1.25e-17*peakItest^7.4566 + sqrt((1.25e-17*peakItest^7.4566)^2 +...
    4*2e-11*peakItest^2.9177*EOLrth))/(2*2e-11*peakItest^2.9177); % Test data regression fit
dutyLife = testLife/eqTest;
end
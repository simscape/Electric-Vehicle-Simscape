function dutyLife = PMSMgetDutyLife(peakItest,EOLrth,eqTest)
    testLife = 1e6*(-0.0000000000000000125*peakItest^7.4566 + sqrt((0.0000000000000000125*peakItest^7.4566)^2 +...
        4*0.00000000002*peakItest^2.9177*EOLrth))/(2*0.00000000002*peakItest^2.9177); % Test data regrassion fit
    dutyLife = testLife/eqTest;
end 
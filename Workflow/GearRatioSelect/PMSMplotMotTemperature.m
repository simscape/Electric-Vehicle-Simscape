%% Function for Plotting Motor winding and magnet temperature 
% The script plots the temperatures which were obtained in Gear ratio
% selection DoE run.

% Copyright 2022 - 2023 The MathWorks, Inc.
function PMSMplotMotTemperature(tst,Ngrr)
allResults = load('PMSMbatchRunTemp.mat');
compT=["W-EUDC","W-US06","M-EUDC","M-US06"];
GrstrArr = string(zeros(size(Ngrr)));
for test = 1:numel(tst)
   figure("Name",compT(test));
   
    for grr= 1:numel(Ngrr)
        GrstrArr(1,grr) = "Gear Ratio " + num2str(Ngrr(grr));
        plot(allResults.PMSMallTempBatch{grr,test,1},allResults.PMSMallTempBatch{grr,test,2});
        hold on
    end
    hold off;
    xlabel('Time [s]')
    ylabel('Temperature [K]')
    legend("Position", [0.15223,0.7056,0.24606,0.16142])
    
    legend(GrstrArr)

    title('Winding Temperatures(K) for Different Gear Ratios, '+tst(test))
end
for test = 1:numel(tst)
    figure("Name",compT(test+2));
    
    for grr= 1:numel(Ngrr)
        plot(allResults.PMSMallTempBatch{grr,test,1},allResults.PMSMallTempBatch{grr,test,3});
        hold on
    end
    hold off;
    xlabel('Time [s]')
    ylabel('Temperature [K]')
    legend("Position", [0.15223,0.7056,0.24606,0.16142])
    hold on
    for grr= 1:numel(Ngrr) 
    legend(GrstrArr)
    end
    hold off
    title('Magnet Temperatures(K) for Different Gear Ratios, '+tst(test))
end
function fitResult = checkFinalBatteryParameters(cellParameters, option, nRCshort, nRClong)
    finalColumn = size(cellParameters.("Parameterized Cell Data"){1,1},2);
    if finalColumn ~= 4 + nRCshort*4 + 2*nRClong
         error('Check final parameterized file data');
    end
    finalColumnShort = 4 + nRCshort*4; % nRCshort has charge/discharge pulse; Hence *4 comes from (2 of R & Tau X 2 for charge/discharge)
    if option == "long"
        fitResult = any(any(table2array(cellParameters.("Parameterized Cell Data"){1,1}(:,[1:4,(finalColumnShort+1):finalColumn]))<0));
    end
    if option == "short"
        fitResult = any(any(table2array(cellParameters.("Parameterized Cell Data"){1,1}(:,1:finalColumnShort))<0));
    end
end  
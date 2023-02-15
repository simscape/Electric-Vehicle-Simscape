%% Function for running FEM PMSM with Field weakning controls
% Script to generate Power Loss matrix for FEM PMSM 

% Copyright 2022 - 2023 The MathWorks, Inc.

function lossMat = PMSMgetLoss(trq,spd,powMax)
   lossMat=zeros(numel(spd),numel(trq));
   lossMatCu=zeros(numel(spd),numel(trq));
   lossMatIr=zeros(numel(spd),numel(trq));
   open PMSMfocControlLossMapGen.slx
  fdWkPmsmMdl='PMSMfocControlLossMapGen';
    for i= 1:numel(spd)
        mspd1=string(spd(i));
        set_param([fdWkPmsmMdl,'/spdLim'],'UpperLimit',mspd1)
        simTm=string(spd(i)/3500+0.4);

        for j=1:numel(trq)
            if spd(i)*trq(j) <powMax*60/(2*pi)
                mtrq1=string(-1*trq(j));
                open_system('PMSMfocControlLossMapGen.slx')
                set_param([fdWkPmsmMdl,'/trqStp'],'After',mtrq1)
                simModel=sim('PMSMfocControlLossMapGen','StopTime',simTm);
                lossMatCu(i,j)=3*mean(simModel.PMSMfocControlLossMapGen.Heat_Flow_Rate_Sensor.H.series.values);       
                lossMatIr(i,j)=mean(simModel.PMSMfocControlLossMapGen.Heat_Flow_Rate_Sensor1.H.series.values);
            else
                lossMatCu(i,j)=0.4*spd(i)*trq(j)*2*pi/60;    
                lossMatIr(i,j)=0.1*spd(i)*trq(j)*2*pi/60;
            end

            disp(['*** Completed Run ',num2str(i),'-',num2str(j)])
        end
    end
    lossMat=lossMatIr+lossMatCu;
end   
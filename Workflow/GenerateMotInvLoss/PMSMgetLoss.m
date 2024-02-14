%% Function for running FEM PMSM with Field weakning controls
% Script to generate Power Loss Table for FEM PMSM & Inverter for given
% speed torque and temperature vectors.

% Copyright 2022 - 2023 The MathWorks, Inc.

function lossMatDU = PMSMgetLoss(tqMat,spMat,temp,powMax,varargin)

ORmotLossMap = false;
ORinvLossMap = false;
if ~isempty(varargin) && strcmp(varargin{1},'overWriteMotLossMap')
    ORmotLossMap = true;
elseif ~isempty(varargin) && strcmp(varargin{1},'overWriteInvLossMap')
    ORinvLossMap = true;
elseif isequal(numel(varargin),2) && (strcmp(varargin{1},'overWriteMotLossMap') ...
        && strcmp(varargin{2},'overWriteInvLossMap'))
    ORmotLossMap = true;
    ORinvLossMap = true;
end

   % Initializing matrices to store losses
   lossMatCu=zeros(numel(spMat),numel(tqMat));
   lossMatIr=zeros(numel(spMat),numel(tqMat));
   lossMatIgbt=zeros(numel(spMat),numel(tqMat),numel(temp));
   lossMatDiode=zeros(numel(spMat),numel(tqMat),numel(temp));

   % Open the simulink model
   open PMSMfocControlLossMapGen.slx

   % Set the model path
   fdWkPmsmMdl='PMSMfocControlLossMapGen';

   % Loop through each speed
   for i= 1:numel(spMat)

        % Get the current speed and set the speed limit 
        mspd1=string(spMat(i));
        set_param([fdWkPmsmMdl,'/spdLim'],'UpperLimit',mspd1)
        
        % Calculate and set the simulation time based on the speed
        simTm=string(spMat(i)/3500+0.4);

        % Loop through each torque
        for j=1:numel(tqMat)
            % Get the current torque and set the torque step
            mtrq1=string(-1*tqMat(j));
            set_param([fdWkPmsmMdl,'/trqStp'],'After',mtrq1)

            % Loop through each temperature
            for tm = 1:numel(temp)
                % Get the current temperature and set the IGBT junction temperature
                tempLcl=string(temp(tm));
                set_param([fdWkPmsmMdl,'/inverter/IGBTAH/jnTemp'],'constant',tempLcl)

                % Check if the power exceeds the power limit
                if spMat(i)*tqMat(j)*2*pi/60 < powMax
                    
                    % Run the simulation and calculate the losses
                    simModel = sim('PMSMfocControlLossMapGen','StopTime',simTm);
                    lossTable = table2array(simModel.yout.extractTimetable);
                    lossMatIgbt(i,j,tm) = mean(lossTable(:,1));       
                    lossMatDiode(i,j,tm) = mean(lossTable(:,2));
                
                % If the power exceeds the power limit, calculate the losses using a fixed efficiency
                else
                    lossMatIgbt(i,j,tm)=0.04*spMat(i)*tqMat(j)*2*pi/60;    
                    lossMatDiode(i,j,tm)=0.01*spMat(i)*tqMat(j)*2*pi/60;
                end
            end

            % Check if the power exceeds the power limit
            if spMat(i)*tqMat(j)*2*pi/60 < powMax

                % Calculate losses due to copper and iron losses
                lossMatCu(i,j) = 3*mean(simModel.simlogPMSMfocControlLossMapGen.Heat_Flow_Rate_Sensor.H.series.values);       
                lossMatIr(i,j) = mean(simModel.simlogPMSMfocControlLossMapGen.Heat_Flow_Rate_Sensor1.H.series.values);
            
            % If the power exceeds the power limit, calculate the losses using a fixed efficiency
            else
                lossMatCu(i,j) = 0.4*spMat(i)*tqMat(j)*2*pi/60;    
                lossMatIr(i,j) = 0.1*spMat(i)*tqMat(j)*2*pi/60;
            end

            disp(['*** Completed Run ',num2str(i),'-',num2str(j)])
        end
    end

    % Calculate the total losses
    lossMat = lossMatIr+lossMatCu;
    lossMatDU = {lossMat tqMat spMat lossMatIgbt lossMatDiode};
    if ORmotLossMap 
    % Save the motor loss to a file
    save(currentProject().RootFolder+'\Script_Data\PMSMmotorLossMap','lossMat','tqMat','spMat')
    end
    if ORinvLossMap
    % Save the IGBT and Diode losses to a file
    save(currentProject().RootFolder+'\Script_Data\PMSMinverterLossMap','lossMatIgbt','lossMatDiode')
    end

    % Close the simulink model
    close_system('PMSMfocControlLossMapGen.slx',0)
end

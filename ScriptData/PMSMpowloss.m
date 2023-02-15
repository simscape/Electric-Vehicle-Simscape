%% Parameters for models/pmsm_foc_drive
% Script to generate Loss matrix for FEM PMSM 

% Copyright 2022 - 2023 The MathWorks, Inc.

%% Set the desired torque(N-m) vector  motor speed (RPM) Vector below  

tqMat = [10 20 40 60 80 100 120 150 180 200];% Desired torque Points N-m 
spMat= [500 1000 2000 3000 4000 5000 6000 7000 8000];% Desired speed points RPM
maxMotorPower=60000.00;% Watts  Maximum allowed Motor Power

%****Calling function to generate loss table******
lossMat1=PMSMgetLoss(tqMat,spMat,maxMotorPower);

%****Saving Motor loss table******
save motorLossMap.mat lossMat1
save tqVec.mat tqMat
save spVec.mat spMat

%% Reporting
disp('Motor losses computed successfully')
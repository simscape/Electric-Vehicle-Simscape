% Inverter parameters

% Copyright 2022 - 2023 The MathWorks, Inc.

electricDrive.PMparams.RthDiode= [0.017,0.12,0.1,0.038]/6;
electricDrive.PMparams.RthIGBT = [0.01,0.07,0.08,0.045]/6;
electricDrive.PMparams.tauthDiode = [0.001,0.03,0.25,1.5]*6;
electricDrive.PMparams.tauthIGBT = [0.001,0.03,0.25,1.5]*6;
electricDrive.PMparams.TinitDiode = [298.15,298.15,298.15,298.15];
electricDrive.PMparams.TinitIGBT= [298.15,298.15,298.15,298.15];
electricDrive.PMparams.TinitCase = 298.15;
electricDrive.HeatsinkParams.Height = 0.05;
electricDrive.HeatsinkParams.Thick = 0.0015;
electricDrive.HeatsinkParams.Depth = 0.0015;
electricDrive.HeatsinkParams.Gap = 0.0030;
electricDrive.HeatsinkParams.NumFins = 225;
electricDrive.HeatsinkParams.Mass = 0.2268;
electricDrive.PmsmControlParams.fsw=10000;


electricDrive.PMlossParams.tempArray = [25,125,175];
electricDrive.PMlossParams.curMatrix = [0 0.1 100 200 300 400 500 600 700 800 900 1000 1100 1200 1300];
electricDrive.PMlossParams.volMatrix = [0 0.75506 1.1384 1.33 1.6295 1.8783 2.0802 2.4465 2.7492 3.0445 3.3263 3.5832 3.8425 4.0827 4.33;...
             0 0.6867 1.3248 1.6153 2.0802 2.43 2.72 3.2546 3.7063 4.143 4.5427 4.9186 5.3041 5.6757 6.0291;...
             0 0.76883 1.3819 1.6982 2.2006 2.5955 2.9185 3.4928 4.0072 4.4618 4.9031 5.3205 5.73 6.1368 6.5196];
electricDrive.PMlossParams.switchOnLoss = [0 0.15945978 0.56427834 0.9706587 1.3603278 1.7359407 2.1209244 2.5059081 2.8799592 3.2540103 3.67023 4.1 4.5065739 4.9259172 5.4381876 5.9020422 6.434616 6.9874932 7.5372468 8.168214 8.863215 9.519171;...
                0 0.20416896 0.72261 1.2434 1.7417 2.2232 2.7159 3.2086 3.688 4.1674 4.7004 5.25 5.7705 6.3077 6.9638 7.5583 8.2404 8.9484 9.6516 10.458 11.349 12.19;...
                0 0.26104743 0.79794 1.3364 1.896 2.5039 3.0672 3.6022 4.1598 4.6881 5.1973 5.8 6.3461 6.9176 7.5574 8.1972 8.8603 9.6012 10.36 11.178 12.091 13.003];
electricDrive.PMlossParams.switchOffLoss = [0 0.17218278 0.57884211 0.9760135 1.4123032 1.882034 2.263107 2.698619 3.079692 3.4615427 3.8317279 4.2 4.5798753 4.9586152 5.3365774 5.7153173 6.0995011 6.4836849 6.9191969 7.3430434 7.792554 8.228066;...
                 0 0.22136347 0.74431 1.2546 1.8163 2.4195 2.9098 3.47 3.9604 4.4507 4.9268 5.4 5.8894 6.3759 6.8624 7.349 7.8428 8.3366 8.8974 9.4421 10.019 10.58;...
                 0 0.28404653 0.81005 1.3446 1.9373 2.519 3.1005 3.6454 4.1642 4.6829 5.1947 5.65 6.1916 6.664 7.1742 7.6844 8.215 8.7456 9.3142 9.9151 10.525 11.194]; 
electricDrive.PMlossParams.curForSwitchLoss = [0 0.1 100 200 300 400 500 600 700 800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2000];
electricDrive.PMlossParams.resArray = electricDrive.PMlossParams.volMatrix/electricDrive.PMlossParams.curMatrix;

electricDrive.inverter_loss_map = load("PMSMinverterLossMap.mat"); % Inverter thermal map

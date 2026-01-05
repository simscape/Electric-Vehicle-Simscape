% Function for estimating equivalent count of temperature fluctuations during a real life vehicle run 

% Copyright 2022 - 2023 The MathWorks, Inc.

function eqTest = countEqTest(peakItest)
load InverterTemp.mat %#ok<*LOAD>
load TestCycleTemp.mat
tsrIGBT = [allTime,TigbtJ];
TinitTest = 25;
% High frequency peak to valley temperature difference for IGBT
[Tpks,locs] = findpeaks(TigbtJ);
invTigbt = -1*TigbtJ;
[Tvalley,Ivloc] = findpeaks(invTigbt);
TdeltaIGBT = Tpks-(-1*Tvalley);
%Plotting
[Tpkspt,locspt] = findpeaks(TigbtJ,"MinPeakProminence",1);
invTigbt = -1*TigbtJ;
[Tvalleypt,Ivlocpt] = findpeaks(invTigbt,"MinPeakProminence",1);

figure("Name","IGBT_duty");
plot(tsrIGBT(:,1),tsrIGBT(:,2),allTime(locspt),Tpkspt,'o');
hold on
plot(allTime(Ivlocpt),-1*Tvalleypt,'*');
title('IGBT Junction Temperature For Duty cycle (C)');
xlabel('Time [s]')
hold Off
% delta T 1 to 5 degrees C
Tdelta_count1to5 = sum((1<TdeltaIGBT) & (TdeltaIGBT<5));
Tdelta1to5 = TdeltaIGBT.*(1<TdeltaIGBT & TdeltaIGBT<5);
Tdelta1to5(Tdelta1to5 == 0) = [];
mTdeltaT1to5 = mean(Tdelta1to5);
cur1_5 = abs(cur(locs).*(1<TdeltaIGBT & TdeltaIGBT<5));
cur1_5(cur1_5 == 0) = [];
mcur1_5 = mean(cur1_5);
juncT1_5 = (Tpks.*(1<TdeltaIGBT & TdeltaIGBT<5));
juncT1_5(juncT1_5 == 0) = [];
mjuncT1_5 = mean(juncT1_5);
dtime = abs(allTime(locs)-allTime(Ivloc));
dt1_5 = dtime.*(1<TdeltaIGBT & TdeltaIGBT<5);
dt1_5(dt1_5 == 0) = [];
mdt1_5 = mean(dt1_5);

% delta T 5 degrees C  to 10 degrees C
Tdelta_count5to10 = sum((5<TdeltaIGBT) & (TdeltaIGBT<10));
Tdelta5to10 = TdeltaIGBT.*(5<TdeltaIGBT & TdeltaIGBT<10);
Tdelta5to10(Tdelta5to10 == 0) = [];
mTdeltaT5to10 = mean(Tdelta5to10);
cur5_10 = abs((cur(locs).*(5<TdeltaIGBT & TdeltaIGBT<10)));
cur5_10(cur5_10 == 0) = [];
mcur5_10 = mean(cur5_10);
juncT5_10 = Tpks.*(5<TdeltaIGBT & TdeltaIGBT<10);
juncT5_10(juncT5_10 == 0) = [];
mjuncT5_10 = mean(juncT5_10);
dtime = abs(allTime(locs)-allTime(Ivloc));
dt5_10 = dtime.*(5<TdeltaIGBT & TdeltaIGBT<10);
dt5_10(dt5_10 == 0) = [];
mdt5_10 = mean(dt5_10);

% Low frequency peak to valley temperature delta for IGBT

[Tpkslf,locslf] = findpeaks(TigbtJ,MinPeakDistance=5);

[Tvalleylf,Ivloclf] = findpeaks(invTigbt,MinPeakDistance=5);
Tpkslf = Tpkslf(1:numel(Tvalleylf),:);
TdeltaIGBTlf = Tpkslf-(-1*Tvalleylf);
Tdelta_countlf = sum(TdeltaIGBTlf>5);
TdeltaIGBTlf(TdeltaIGBTlf<5) = [];
mTdeltaTlf = mean(TdeltaIGBTlf);
mcurlf = mean(abs(cur(locslf)));

mjuncTlf = mean(Tpkslf);
locslf=locslf(1:numel(Ivloclf),:);

timeDeltaLf = mean(abs(allTime(Ivloclf)- allTime(locslf)));

% Test cycle temperature delta calculation
[TpksTest,locsTest] = findpeaks(TigbtTest);

invTigbtTest =-1*TigbtTest;
[TvalleyTest,vlocsTest] = findpeaks(invTigbtTest);
figure("Name","IGBT_test");
plot(allTimeTest,TigbtTest,allTimeTest(locsTest),TpksTest,'o');
hold on
plot(allTimeTest(vlocsTest),-1*TvalleyTest,'*');
title("IGBT Junction Temperature For Test (C)")
xlabel('Time [s]')
hold Off

TpksTest = TpksTest(1:end-1,:);
deltaTtest = TpksTest-(-1*TvalleyTest);
mdeltaTtest = mean(deltaTtest);
TdeltaCountTest = sum(deltaTtest>0.01);

mjunctTest = mean(TpksTest);
locsTest = locsTest(1:numel(vlocsTest));
dtTest = abs(allTimeTest(locsTest)-allTimeTest(vlocsTest));
dtTest(dtTest == 0) = [];
mdtTest = mean(dtTest);

maxdeltaTtest = max(TigbtTest)-TinitTest;
maxjunctTest = max(TigbtTest);
% Calculation of equivalent to test high frequency temperature fluctuations cycles
num1to5hf = (mTdeltaT1to5^(-3.483))*exp(1917/(mjuncT1_5+273))*mdt1_5^(-0.438)*mcur1_5^(-0.717);
num5to10hf = (mTdeltaT5to10^(-3.483))*exp(1917/(mjuncT5_10+273))*mdt5_10^(-0.438)*mcur5_10^(-0.717);
numtesthf = (mdeltaTtest^(-3.483))*exp(1917/(mjunctTest+273))*mdtTest^(-0.438)*(0.707*peakItest)^(-0.717);
eqtestHf = (numtesthf/num1to5hf)*(Tdelta_count1to5/TdeltaCountTest) + (numtesthf/num5to10hf)*(Tdelta_count5to10/TdeltaCountTest);
% Calculation of equivalent to test  low frequency temperature cycles
numlfDuty = (mTdeltaTlf^(-3.483))*exp(1917/(mjuncTlf+273))*timeDeltaLf^(-0.438)*mcurlf^(-0.717);
numtestlf = (maxdeltaTtest^(-3.483))*exp(1917/(maxjunctTest+273))*2^(-0.438)*(0.707*peakItest)^(-0.717);
eqtestLf = (numtestlf/numlfDuty)*Tdelta_countlf;
eqtestAvg = (eqtestHf+2*eqtestLf)/3;
eqTest = eqtestAvg;
end 
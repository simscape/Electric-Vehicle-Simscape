classdef MotorDriveUnit_UnitTest_MQC < matlab.unittest.TestCase
%% Class implementation of unit test

% Copyright 2023 The MathWorks, Inc.

%% Simple tests ... just run runnables

methods (Test)


%% Harness folder

function MQC_Harness_1(~)
  close all
  bdclose all
  mdl = "MotorTestHarness";
  load_system(mdl)
  sim(mdl);
  close all
  bdclose all
end

end

end  % classdef

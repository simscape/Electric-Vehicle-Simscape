classdef HVACPassTests < matlab.unittest.TestCase
%% Class implementation of unit test
%
% These are tests to achieve the Minimum Quality Criteria (MQC).
% MQC is achieved when all runnables (models, scripts, functions) run
% without any errors.
%
% You can run this test by opening in MATLAB Editor and clicking
% Run Tests button or Run Current Test button.
% You can also run this test using test runner (the *_runtests.m script)


% Copyright 2025 The MathWorks, Inc.


%% Simple tests ... just run runnables

methods (Test)
    function TestModel(~)
        model = 'HVACTestHarness';
        load_system(model)
        HVACTestHarnessParams;
        sim(model, 'SrcWorkspace', 'current');
    end
end

end  % classdef



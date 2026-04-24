classdef BMSPassTests < matlab.unittest.TestCase
   %BMS Pass Test

    % Copyright 2025 The MathWorks, Inc.

    methods (Test)
        function TestModel(~)
            model = 'BMSTestHarness';
            load_system(model)
            BMSTestHarnessParams;
            sim(model, 'SrcWorkspace', 'current');
        end
    end

end  % classdef



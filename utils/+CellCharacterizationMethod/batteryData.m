classdef batteryData 
% This class defines functions useful for the parameterization of the 
% Battery (Table-Based) block in Simscape Battery library. The typical 
% input is battery test data, HPPC profile. The typical output is the 
% battery parameters based on the number of RC pairs you select (cell 
% dynamics).
% 
% -------------------------------------------------------------------------
% 
% To characterize a battery cell, run the following command at the command
% line:
% 
% >> battery_params = batteryData(hppc_data,cellProp,hppcProtocol,...
%                                          numPairShort, iniEstimateShort,...
%                                          numPairLong, iniEstimateLong,...
%                                          fit_method, debugMode);
% 
%        where:
% 
%              hppc_data = [time, current, voltage]; 
%                           or 
%                          [time, current, voltage, SOC];
%                          
%                          time, current, voltage, and SOC are column vectors
%                          (from HPPC test data). The SOC data is optional.
%                          SOC = State of Charge of cell
%                          current, voltage, and SOC are column vectors
%                          with each row denoting an instance in time.
%                          (a) time vector is defined in seconds
%                          (b) current vector is defined in Amperes
%                          (c) voltage vector is defined in Volts
%                          (d) SOC vector is defined between 0-1
% 
%                          hppc_data can be:
%                              (1) Worspace variable
%                              (2) MAT/TX/XLSX filename with data as column
%                              vectors
% 
%               cellProp = [cell_capacity, cell_state_of_charge]
%                          cell_capacity and cell_state_of_charge are
%                          scalars for cell capacity in Ahr and cell initial 
%                          state of charge (0-1)
% 
%          hppcProtocol  = [dischg_pulse_mag, ...
%                           chg_pulse_mag, ...
%                           soc_sweep_curr, ...
%                           tolerance]
% 
%                          (a) dischg_pulse_mag is the magnitude of discharge
%                          pulse current, in A (scalar)
%                          (b) chg_pulse_mag is the magnitude of the charge
%                          pulse current, in A (scalar)
%                          (c) soc_sweep_curr is the constant current value
%                          used to move from one cell state of charge point 
%                          to the next, in A (scalar)
%                          (d) tolerance parameter is used to detect the
%                          pulses in the methods internally. It defines the
%                          % difference between actual current pulse
%                          magnitude and the value set in (a) - (c), above.
%                               
%       
%           numPairShort = Integer, equal to the number of RC pairs to be             
%                          fitted to the test data (short relaxation)
% 
%       iniEstimateShort = Initial guesses for Resistance (Ohm) and the 
%                          Time Constant (seconds) values (short relaxation). 
%                          Size of InitVal is a row vector of 2 x numPairShort.
%                          example:
%                              numPairShort     = 2;
%                              iniEstimateShort = [R1, Tau1, R2, Tau2];
%           
%                              numPairShort     = 3;
%                              iniEstimateShort = [R1, Tau1, R2, Tau2, R3, tau3];
%       
%            numPairLong = Integer, equal to the number of RC pairs to be             
%                          fitted to the test data (long relaxation)
% 
%        iniEstimateLong = Initial guesses for Resistance (Ohm) and the 
%                          Time Constant (seconds) values (long relaxation). 
%                          Size of InitVal is a row vector of 2 x numPairShort.
%                          example:
%                              numPairLongt     = 2;
%                              iniEstimateLong = [R1, Tau1, R2, Tau2];
%           
%                              numPairLong     = 3;
%                              iniEstimateLong = [R1, Tau1, R2, Tau2, R3, tau3];
% 
% numPairLong & iniEstimateLong are optional arguments. If not specified,
% they are assumed to be same as numPairShort & iniEstimateShort.
% 
%              fit_method= "fminsearch" or "curvefit"
%                          (a) fminsearch uses MATLAB function fminsearch to
%                          fit the RC pairs to test data
%                          (b) curvefit used Curve Fitting Toolbox to fit the
%                          RC pairs to the test data
% 
%              debugMode = true/false (boolean). If true, the method plots
%                          intermediate results that may aid in debugging 
%                          problems if the parameterization does not work well.
% 
% -------------------------------------------------------------------------
% 
% To plot where the program detects the pulses, run:
% 
% >> visualizePointsForFitting(battery_params)
%       
%       where: 
% 
%              battery_params = output of batteryData()
% 
% The plot shows points (different colors) that have been selected for
% calculating ohmic resistance and fitting RC pairs. This is again useful
% as a debugging tool, if some pulses are not detected by the code.
%
% -------------------------------------------------------------------------
% 
% To fit parameters to the battery HPPC test data, run:
% 
% >> battery_params_data = extractParameters(battery_params, false);
%
%       where:
%               battery_params is the output of batteryData()
%               the 2nd argument, if true, plots all the fit data
% 
% -------------------------------------------------------------------------
% 
% To generate results suitable for export to the battery LUT library block,
% run:
% 
% >> dataForLib = exportResultsForLib(battery_params,userSOCpoints,plotOption)
% 
%       where: 
% 
%              battery_params = output of batteryData()
% 
%              userSOCpoints  = vector of SOC break points at which 
%                               parameters are required. 
%                               example: 0:0.01:1 gives parameters at every
%                               1% of SOC change
%              plotOption     = true/false; If true, provides plot of the
%                               final results
% 
% -------------------------------------------------------------------------


% Copyright 2022-2024 The MathWorks, Inc.

    properties
        CellCapacity
        InputTestData
        OCVdataIndices
        InitialCellSOC
        DischargePulseCurr
        ChargePulseCurr
        ConstantCurrDischarge
        HPPCpulseSequence
        FinalDataPointIndex
        Tolerance
        NumOfRCpairs
        NumOfRCpairsLongRest
        RCpairsInitVal
        RCpairsInitValLongRest
        FittingMethod
        OhmicResistance
        OpenCircuitPotential
        DynamicRC
        DynamicRClongRest
        DynamicRCerr
    end
    
    properties(Access = private)
        FileFullPath
        FileType
        FileDirectory
        Name 
    end
    
    methods

        function obj = batteryData(varargin)
            filename     = varargin{1};
            cellProperty = varargin{2};
            hppcCurrents = varargin{3};
            nTimeConst   = varargin{4};
            RCvecInitVal = varargin{5};
            if nargin == 9 
                nTimeConstLongRest   = varargin{6};
                RCvecInitValLongRest = varargin{7};
                fitMethod            = varargin{8};
                debugMode            = varargin{9};
            elseif nargin == 7
                nTimeConstLongRest   = nTimeConst;
                RCvecInitValLongRest = RCvecInitVal;
                fitMethod            = varargin{6};
                debugMode            = varargin{7};
            else % error in number of inputs
                pm_error('Missing arguments in the function call');
            end

            if fitMethod ~= "curvefit" && fitMethod ~="fminsearch"
                pm_error('Fit method must be fminsearch or curvefit');
            end
            if length(RCvecInitVal) ~= 2*nTimeConst
                pm_error(strcat('Initial R and Time Constant InitVal vector must be of size ',num2str(nTimeConst)));
            end
            if cellProperty(1,1) > 0
                obj.CellCapacity = cellProperty(1,1);
            else
                pm_error('Cell capacity must be greater than zero');
            end
            if cellProperty(2,1) > 0 && cellProperty(2,1) <= 1
                obj.InitialCellSOC = cellProperty(2,1);
            else
                pm_error('Cell initial state of charge must be between 0 and 1');
            end
            if any(hppcCurrents < 0)
                pm_error('Pulse charge, discharge, and constant current must be positive');
            else
                obj.DischargePulseCurr    = hppcCurrents(1,1);
                obj.ChargePulseCurr       = hppcCurrents(2,1);
                obj.ConstantCurrDischarge = hppcCurrents(3,1);
                obj.Tolerance             = hppcCurrents(4,1);
            end
            if nTimeConst > 0 && mod(nTimeConst,1) == 0
                obj.NumOfRCpairs = nTimeConst;
                obj.NumOfRCpairsLongRest = nTimeConstLongRest;
            else
                pm_error('Number of time constants must be an integer and greater than zero');
            end
            % Read Input Data - eg: HPPC
            if isnumeric(filename) % check if arg. filename is a file or a matrix
                if size(filename,2) > 4 || size(filename,2) < 3 % Check input parameter matrix size
                    pm_error('Input data must be a column vector of time, Current, Voltage, and SOC');
                elseif size(filename,2) == 4 % SOC input by user
                    obj.InputTestData = array2table(filename,'VariableNames',{'time','I','V','SOC'}); % renaming table to be consistent
                else % Calculate SOC based on current and time data
                    data = addSOCvectorToInputData(filename, obj.InitialCellSOC, obj.CellCapacity);
                    obj.InputTestData = array2table(data,'VariableNames',{'time','I','V','SOC'}); % renaming table to be consistent
                end
                obj.Name = "batteryTestMeas";
            else
                obj.FileFullPath  = filename;
                [obj.FileDirectory, ...
                    obj.Name, ...
                    obj.FileType] = fileparts(filename);
                obj.FileType      = upper(erase(obj.FileType,'.'));
                obj.InputTestData = obj.getDataFromFile;
            end
            isDataHavingErrors = checkInputData([obj.InputTestData.time,...
                                                 obj.InputTestData.I,...
                                                 obj.InputTestData.V,...
                                                 obj.InputTestData.SOC]);
            if isDataHavingErrors
                pm_error('Input data must not have any NaN or Inf. Check input data');
            end
            
            if debugMode, disp('Read input data'); end

            [obj.OCVdataIndices, obj.HPPCpulseSequence, ...
                obj.FinalDataPointIndex] = obj.getPulsesFromHPPCdata;
            
            if debugMode, disp('Extracted pulse data from input data'); end
            
            if debugMode
                visualizePointsForFitting(obj);
                disp('Visualized pulses identified by the method');
            end
            
            obj.RCpairsInitVal         = RCvecInitVal;
            obj.RCpairsInitValLongRest = RCvecInitValLongRest;
            obj.FittingMethod          = fitMethod;
        end

        function obj = extractParameters(obj, debugMode)
            obj.OhmicResistance = obj.getOhmicResistanceData;
            if debugMode, disp('Calculated ohmic resistance'); end
            
            [obj.DynamicRC, obj.DynamicRCerr, obj.DynamicRClongRest] = ...
                obj.getRCparametersData(obj.RCpairsInitVal, obj.RCpairsInitValLongRest, ...
                obj.FittingMethod, debugMode);
            if debugMode, disp('Calculated RC parameters');end
            
            obj.OpenCircuitPotential = obj.getOpenCircuitPotentialData;
            if debugMode, disp('Completed OCV data extraction'); end
        end

        function result = extractPointsDuringAutoPick(obj, debugMode)
            sortedIndices = obj.HPPCpulseSequence{2};
            testDataCoord = obj.InputTestData;
            idx1 = sortedIndices(:,1);
            idx2 = sortedIndices(:,2);
            idx4 = sortedIndices(:,4);
            startPulse = [testDataCoord.time(idx1),testDataCoord.V(idx1)];
            endPulse   = [testDataCoord.time(idx2),testDataCoord.V(idx2)];
            startRelax = [testDataCoord.time(idx4),testDataCoord.V(idx4)];
            testData   = [testDataCoord.time testDataCoord.V];
            result     = cell2table({testData,startPulse, endPulse, startRelax},...
                'VariableNames',{'Test Data (t,V)','Pulse Start (t,V)',...
                'Pulse End (t,V)','Relaxation Start (t,V)',});
            if debugMode
                figure('Name', 'Auto-detected points for data-fit' );
                plot(testDataCoord.time,testDataCoord.V,'k-');
                hold on
                plot(startPulse(:,1),startPulse(:,2),'ro');hold on
                plot(endPulse(:,1),endPulse(:,2),'go');hold on
                plot(startRelax(:,1),startRelax(:,2),'bo');hold off
                title('Time vs Voltage plot');
                legend('Test Data','Start Pulse Indices',...
                    'End Pulse Indices','Start Relaxation Indices');
            end
        end

        function obj = insertUpdatedPoints(obj,updatedIndices)
            sortedIndices  = obj.HPPCpulseSequence{2};
            testDataCoord  = obj.InputTestData;
            userStartPulse = updatedIndices.("Pulse Start (t,V)"){1};
            userEndPulse   = updatedIndices.("Pulse End (t,V)"){1};
            userStartRelax = updatedIndices.("Relaxation Start (t,V)"){1};
            idx1 = sortedIndices(:,1);
            idx2 = sortedIndices(:,2);
            idx4 = sortedIndices(:,4);
            origStartPulse = [testDataCoord.time(idx1),testDataCoord.V(idx1)];
            origEndPulse   = [testDataCoord.time(idx2),testDataCoord.V(idx2)];
            origStartRelax = [testDataCoord.time(idx4),testDataCoord.V(idx4)];
            if size(userStartPulse,1) ~= size(origStartPulse,1)
                pm_error('Number of pulse start points in user defined list must be same as in the original list.');
            end
            if size(userEndPulse,1) ~= size(origEndPulse,1)
                pm_error('Number of pulse end points in user defined list must be same as in the original list.');
            end
            if size(userStartRelax,1) ~= size(origStartRelax,1)
                pm_error('Number of pulse relaxation start points in user defined list must be same as in the original list.');
            end
            % StartPulse is stored in index '1' and hence 'sortedIndices(:,1)' as argument below
            if sum(sum(userStartPulse-origStartPulse)) ~= 0
                obj.HPPCpulseSequence{2}(:,1) = getUpdatedDataSet(sortedIndices(:,1),...
                                                [testDataCoord.time,testDataCoord.V],...
                                                userStartPulse);
                obj.HPPCpulseSequence{2}(:,3) = obj.HPPCpulseSequence{2}(:,1) + 1; % when '1' changes, change '3' also.
            end
            if sum(sum(userEndPulse-origEndPulse)) ~= 0
                obj.HPPCpulseSequence{2}(:,2) = getUpdatedDataSet(sortedIndices(:,2),[time,voltage],userEndPulse);
            end
            if sum(sum(userStartRelax-origStartRelax)) ~= 0
                obj.HPPCpulseSequence{2}(:,4) = getUpdatedDataSet(sortedIndices(:,4),[time,voltage],userStartRelax);
            end
        end

        function h = visualizePointsForFitting(obj, plotPulseWiseData)
            time    = obj.InputTestData.time;
            voltage = obj.InputTestData.V;
            current = obj.InputTestData.I;
            hppcSeqSorted    = obj.HPPCpulseSequence{2};
            nDischargePulses = obj.HPPCpulseSequence{3};
            nChargePulses    = obj.HPPCpulseSequence{4};
            nSOCsweepPulses  = obj.HPPCpulseSequence{5};
            
            h = figure('Name', 'Plot and Verify Pulse Data' );
            plot(time,voltage,'k-')
            hold on
            scatter(time(hppcSeqSorted(:,1)),voltage(hppcSeqSorted(:,1)),'o','r');
            scatter(time(hppcSeqSorted(:,2)),voltage(hppcSeqSorted(:,2)),'o','b');
            scatter(time(hppcSeqSorted(:,4)),voltage(hppcSeqSorted(:,4)),'o','g');
            hold off
            xlabel('Time (s)')
            ylabel('Voltage (V)')
            title('Pulse_s_t_a_r_t (r), Pulse_e_n_d (b), Relaxation_s_t_a_r_t (g)')
            % 
            if plotPulseWiseData
                lenData = length(hppcSeqSorted(:,1));
                figCount = 0;
                for i1 = 1:3:lenData
                    figCount = figCount + 1;
                    figName = strcat('Normalized I & V for RC fit - ',num2str(figCount));
                    figure('Name', figName);
                    i2 = min(lenData,i1+1);
                    i3 = min(lenData,i1+2);
                    fullDataStart = hppcSeqSorted(i1,1) - 1;
                    fullDataEnd   = hppcSeqSorted(i3,4) + 1;
                    maxVoltage    = max(voltage(fullDataStart:fullDataEnd));
                    minVoltage    = min(voltage(fullDataStart:fullDataEnd));
                    maxCurrent    = max(abs(current(fullDataStart:fullDataEnd)));
                    minCurrent    = min(current(fullDataStart:fullDataEnd));
                    % i1
                    iR01 = hppcSeqSorted(i1,1);
                    iR02 = hppcSeqSorted(i1,3);
                    idx0 = hppcSeqSorted(i1,2);
                    idx1 = hppcSeqSorted(i1,4);
                    idx2 = hppcSeqSorted(i2,1);
                    if hppcSeqSorted(i1,5) == 1 % discharge
                        plot(time(idx1:idx2),(voltage(idx1:idx2)-minVoltage)/(maxVoltage-minVoltage),'g-','LineWidth',3);
                        hold on
                        plot(time(idx0:idx1),(voltage(idx0:idx1)-minVoltage)/(maxVoltage-minVoltage),'g--','LineWidth',2);
                        hold on
                        scatter(time(iR01),(voltage(iR01)-minVoltage)/(maxVoltage-minVoltage),'x','g');
                        scatter(time(iR02),(voltage(iR02)-minVoltage)/(maxVoltage-minVoltage),'x','g');
                        scatter(time(idx0),(voltage(idx0)-minVoltage)/(maxVoltage-minVoltage),'o','g');
                        scatter(time(idx1),(voltage(idx1)-minVoltage)/(maxVoltage-minVoltage),'*','g');
                        scatter(time(idx2),(voltage(idx2)-minVoltage)/(maxVoltage-minVoltage),'*','g');
                    elseif hppcSeqSorted(i1,5) == -1 % charge
                        plot(time(idx1:idx2),(voltage(idx1:idx2)-minVoltage)/(maxVoltage-minVoltage),'b-','LineWidth',3);
                        hold on
                        plot(time(idx0:idx1),(voltage(idx0:idx1)-minVoltage)/(maxVoltage-minVoltage),'b--','LineWidth',2);
                        hold on
                        scatter(time(iR01),(voltage(iR01)-minVoltage)/(maxVoltage-minVoltage),'x','b');
                        scatter(time(iR02),(voltage(iR02)-minVoltage)/(maxVoltage-minVoltage),'x','b');
                        scatter(time(idx0),(voltage(idx0)-minVoltage)/(maxVoltage-minVoltage),'o','b');
                        scatter(time(idx1),(voltage(idx1)-minVoltage)/(maxVoltage-minVoltage),'*','b');
                        scatter(time(idx2),(voltage(idx2)-minVoltage)/(maxVoltage-minVoltage),'*','b');
                    else % hppcSeqSorted(i1,5) == 0 % SOC sweep
                        plot(time(idx1:idx2),(voltage(idx1:idx2)-minVoltage)/(maxVoltage-minVoltage),'r-','LineWidth',3);
                        scatter(time(idx1),(voltage(idx1)-minVoltage)/(maxVoltage-minVoltage),'o','r');
                        scatter(time(idx2),(voltage(idx2)-minVoltage)/(maxVoltage-minVoltage),'o','r');
                    end
                    hold on
                    % i2
                    iR01 = hppcSeqSorted(i2,1);
                    iR02 = hppcSeqSorted(i2,3);
                    idx0 = hppcSeqSorted(i2,2);
                    idx1 = hppcSeqSorted(i2,4);
                    idx2 = hppcSeqSorted(i3,1);
                    if hppcSeqSorted(i2,5) == 1 % discharge
                        plot(time(idx1:idx2),(voltage(idx1:idx2)-minVoltage)/(maxVoltage-minVoltage),'g-','LineWidth',3);
                        hold on
                        plot(time(idx0:idx1),(voltage(idx0:idx1)-minVoltage)/(maxVoltage-minVoltage),'g--','LineWidth',2);
                        hold on
                        scatter(time(iR01),(voltage(iR01)-minVoltage)/(maxVoltage-minVoltage),'x','g');
                        scatter(time(iR02),(voltage(iR02)-minVoltage)/(maxVoltage-minVoltage),'x','g');
                        scatter(time(idx0),(voltage(idx0)-minVoltage)/(maxVoltage-minVoltage),'o','g');
                        scatter(time(idx1),(voltage(idx1)-minVoltage)/(maxVoltage-minVoltage),'*','g');
                        scatter(time(idx2),(voltage(idx2)-minVoltage)/(maxVoltage-minVoltage),'*','g');
                    elseif hppcSeqSorted(i2,5) == -1 % charge
                        plot(time(idx1:idx2),(voltage(idx1:idx2)-minVoltage)/(maxVoltage-minVoltage),'b-','LineWidth',3);
                        hold on
                        plot(time(idx0:idx1),(voltage(idx0:idx1)-minVoltage)/(maxVoltage-minVoltage),'b--','LineWidth',2);
                        hold on
                        scatter(time(iR01),(voltage(iR01)-minVoltage)/(maxVoltage-minVoltage),'x','b');
                        scatter(time(iR02),(voltage(iR02)-minVoltage)/(maxVoltage-minVoltage),'x','b');
                        scatter(time(idx0),(voltage(idx0)-minVoltage)/(maxVoltage-minVoltage),'o','b');
                        scatter(time(idx1),(voltage(idx1)-minVoltage)/(maxVoltage-minVoltage),'*','b');
                        scatter(time(idx2),(voltage(idx2)-minVoltage)/(maxVoltage-minVoltage),'*','b');
                    else % hppcSeqSorted(i2,5) == 0 % SOC sweep
                        plot(time(idx1:idx2),(voltage(idx1:idx2)-minVoltage)/(maxVoltage-minVoltage),'r-','LineWidth',3);
                        hold on
                        scatter(time(idx1),(voltage(idx1)-minVoltage)/(maxVoltage-minVoltage),'o','r');
                        scatter(time(idx2),(voltage(idx2)-minVoltage)/(maxVoltage-minVoltage),'o','r');
                    end
                    hold on
                    % i3
                    iR01 = hppcSeqSorted(i3,1);
                    iR02 = hppcSeqSorted(i3,3);
                    idx0 = hppcSeqSorted(i3,2);
                    idx1 = hppcSeqSorted(i3,4);
                    idx2 = hppcSeqSorted(min(lenData,i3+1),1);
                    if hppcSeqSorted(i3,5) == 1 % discharge
                        plot(time(idx1:idx2),(voltage(idx1:idx2)-minVoltage)/(maxVoltage-minVoltage),'g-','LineWidth',3);
                        hold on;
                        plot(time(idx0:idx1),(voltage(idx0:idx1)-minVoltage)/(maxVoltage-minVoltage),'g--','LineWidth',2);
                        hold on
                        scatter(time(iR01),(voltage(iR01)-minVoltage)/(maxVoltage-minVoltage),'x','g');
                        scatter(time(iR02),(voltage(iR02)-minVoltage)/(maxVoltage-minVoltage),'x','g');
                        scatter(time(idx0),(voltage(idx0)-minVoltage)/(maxVoltage-minVoltage),'o','g');
                        scatter(time(idx1),(voltage(idx1)-minVoltage)/(maxVoltage-minVoltage),'*','g');
                        scatter(time(idx2),(voltage(idx2)-minVoltage)/(maxVoltage-minVoltage),'*','g');
                    elseif hppcSeqSorted(i3,5) == -1 % charge
                        plot(time(idx1:idx2),(voltage(idx1:idx2)-minVoltage)/(maxVoltage-minVoltage),'b-','LineWidth',3);
                        hold on;
                        plot(time(idx0:idx1),(voltage(idx0:idx1)-minVoltage)/(maxVoltage-minVoltage),'b--','LineWidth',2);
                        hold on
                        scatter(time(iR01),(voltage(iR01)-minVoltage)/(maxVoltage-minVoltage),'x','b');
                        scatter(time(iR02),(voltage(iR02)-minVoltage)/(maxVoltage-minVoltage),'x','b');
                        scatter(time(idx0),(voltage(idx0)-minVoltage)/(maxVoltage-minVoltage),'o','b');
                        scatter(time(idx1),(voltage(idx1)-minVoltage)/(maxVoltage-minVoltage),'*','b');
                        scatter(time(idx2),(voltage(idx2)-minVoltage)/(maxVoltage-minVoltage),'*','b');
                    else % hppcSeqSorted(i3,5) == 0 % SOC sweep
                        plot(time(idx1:idx2),(voltage(idx1:idx2)-minVoltage)/(maxVoltage-minVoltage),'r-','LineWidth',3);
                        hold on;
                        scatter(time(idx1),(voltage(idx1)-minVoltage)/(maxVoltage-minVoltage),'o','r');
                        scatter(time(idx2),(voltage(idx2)-minVoltage)/(maxVoltage-minVoltage),'o','r');
                    end
                    hold on
                    plot(time(fullDataStart:fullDataEnd), (voltage(fullDataStart:fullDataEnd)-minVoltage)/(maxVoltage-minVoltage),'k--');
                    hold on
                    plot(time(fullDataStart:fullDataEnd), current(fullDataStart:fullDataEnd)/maxCurrent,'y--');
                    title(figName);
                    ylim([-1.1 1.1]);
                    hold off
                end
            end
        end
        
        function result = exportResultsForLib(obj,userSOCpoints,plotOption)
            hppcSeqSorted = obj.HPPCpulseSequence{2};
            nChargePulses = obj.HPPCpulseSequence{4};
            nDischargePulses = obj.HPPCpulseSequence{3};
            if size(userSOCpoints,1) ~= 1
                pm_error('Enter SOC data as row vector');
            end
            if min(diff(userSOCpoints)) <= 0
                pm_error('SOC points must be in ascending order');
            end
            if min(userSOCpoints) < 0 || max(userSOCpoints) > 1
                pm_error('SOC points out of bound. SOC vector values must be between 0 and 1');
            end
            
            batteryLUTparam = obj.getBatteryParamTable(userSOCpoints);
            batteryTestData = obj.InputTestData;
            batteryCapacity = obj.CellCapacity;
            
            dataPointsForParam = reshape(hppcSeqSorted(:,1:4)',1,[]);
            hppcDataPointsParam = batteryTestData(dataPointsForParam,1:4);

            result = cell2table({batteryTestData, batteryCapacity, batteryLUTparam, hppcDataPointsParam},...
                               'VariableNames',{'Test Data', 'Cell Capacity (Ahr)', 'Parameterized Cell Data', 'Data Points used for Cell Parameterization'});
            if plotOption
                figure('Name','Battery Open Circuit Potential');
                plot(userSOCpoints',batteryLUTparam.V0')
                xlabel("SOC");
                ylabel("V0 (V)");
                title('V0');
                if nDischargePulses > 0
                    figure('Name', 'Battery Ohmic Resistance - discharge');
                    plot(userSOCpoints',batteryLUTparam.R0discharge')
                    xlabel("SOC");
                    ylabel("R0 (\Omega)");
                    title('R0_d_i_s_c_h_a_r_g_e');
                end
                if nChargePulses > 0
                    figure('Name', 'Battery Ohmic Resistance - charge');
                    plot(userSOCpoints',batteryLUTparam.R0charge')
                    xlabel("SOC");
                    ylabel("R0 (\Omega)");
                    title('R0_c_h_a_r_g_e');
                end
                for i = 1 : obj.NumOfRCpairs
                    if nDischargePulses > 0
                        fig_name = strcat('Battery Dynamics R-',num2str(i),'discharge');
                        figure('Name', fig_name);
                        plot(userSOCpoints',batteryLUTparam.("R"+i+"discharge"));
                        xlabel("SOC");
                        ylabel("R (\Omega)");
                        title(strcat('R',num2str(i)),'_d_i_s_c_h_a_r_g_e');
                        %
                        fig_name = strcat('Battery Dynamics Time Constant-',num2str(i),'discharge');
                        figure('Name', fig_name);
                        plot(userSOCpoints',batteryLUTparam.("Tau"+i+"discharge"));
                        xlabel("SOC");
                        ylabel("\tau");
                        title(strcat('\tau',num2str(i)),'_d_i_s_c_h_a_r_g_e');
                    end
                    if nChargePulses > 0
                        fig_name = strcat('Battery Dynamics R-',num2str(i),'charge');
                        figure('Name', fig_name);
                        plot(userSOCpoints',batteryLUTparam.("R"+i+"charge"));
                        xlabel("SOC");
                        ylabel("R (\Omega)");
                        title(strcat('R',num2str(i)),'_c_h_a_r_g_e');
                        %
                        fig_name = strcat('Battery Dynamics Time Constant-',num2str(i),'charge');
                        figure('Name', fig_name);
                        plot(userSOCpoints',batteryLUTparam.("Tau"+i+"charge"));
                        xlabel("SOC");
                        ylabel("\tau");
                        title(strcat('\tau',num2str(i)),'_c_h_a_r_g_e');
                    end                
                end
                for i = 1 : obj.NumOfRCpairsLongRest
                    fig_name = strcat('Battery Dynamics R-',num2str(i),'rest');
                    figure('Name', fig_name);
                    plot(userSOCpoints',batteryLUTparam.("R"+i+"rest"));
                    xlabel("SOC");
                    ylabel("R (\Omega)");
                    title(strcat('R',num2str(i)),'_r_e_s_t');
                    %
                    fig_name = strcat('Battery Dynamics Time Constant-',num2str(i),'rest');
                    figure('Name', fig_name);
                    plot(userSOCpoints',batteryLUTparam.("Tau"+i+"rest"));
                    xlabel("SOC");
                    ylabel("\tau");
                    title(strcat('\tau',num2str(i)),'_r_e_s_t');
                end
            end
        end
           
    end
    
    methods(Access = private)
        
        function [indxOCVpoints, hppcPulseSequence, finalDataPointId] = getPulsesFromHPPCdata(obj)
            % Discharge Pulse
            indxDischgPulseStart = find(abs(abs(diff(obj.InputTestData.I)) - obj.DischargePulseCurr) < obj.Tolerance*abs(obj.DischargePulseCurr) & ...
                                        diff(obj.InputTestData.I) < 0); % include the pulse current portion
            nPulsesDischarge    = length(indxDischgPulseStart);
            disp(strcat('*** Number of discharge pulses = ',num2str(nPulsesDischarge)));
            if nPulsesDischarge > 0
                indxDischgPulseEnd   = find(abs(abs(diff(obj.InputTestData.I)) - obj.DischargePulseCurr) < obj.Tolerance*abs(obj.DischargePulseCurr) & ...
                                            diff(obj.InputTestData.I) > 0);
                indxDischgPulseEnd   = indxDischgPulseEnd(indxDischgPulseEnd > indxDischgPulseStart(1));
                indxDischgPulseMid   = indxDischgPulseStart + 1;
                indxDischgRelaxStart = indxDischgPulseEnd + 1;
            else
                indxDischgPulseEnd   = indxDischgPulseStart;
                indxDischgPulseMid   = indxDischgPulseStart;
                indxDischgRelaxStart = indxDischgPulseStart;
            end
            
            % Charge Pulse
            indxChgPulseStart = find(abs(abs(diff(obj.InputTestData.I)) - obj.ChargePulseCurr) < obj.Tolerance*abs(obj.ChargePulseCurr) & ...
                                     diff(obj.InputTestData.I) > 0); 
            nPulsesCharge    = length(indxChgPulseStart);
            disp(strcat('*** Number of charge pulses    = ',num2str(nPulsesCharge)));
            if nPulsesCharge > 0
                indxChgPulseEnd   = find(abs(abs(diff(obj.InputTestData.I)) - obj.ChargePulseCurr) < obj.Tolerance*abs(obj.ChargePulseCurr) & ...
                                         diff(obj.InputTestData.I) < 0);
                indxChgPulseEnd   = indxChgPulseEnd(indxChgPulseEnd > indxChgPulseStart(1));
                indxChgPulseMid   = indxChgPulseStart + 1;
                indxChgRelaxStart = indxChgPulseEnd + 1;
            else
                indxChgPulseEnd   = indxChgPulseStart;
                indxChgPulseMid   = indxChgPulseStart;
                indxChgRelaxStart = indxChgPulseStart;
            end
            
            % SOC Sweep
            indxSOCPulseStart = find(abs(abs(diff(obj.InputTestData.I)) - abs(obj.ConstantCurrDischarge)) < obj.Tolerance*abs(obj.ConstantCurrDischarge) & ...
                                     diff(obj.InputTestData.I) < 0); % include the pulse current portion
            % Limit SOC pulses between 1st and last pulse observed
            firstPulseIndex = min(indxDischgPulseStart(1),indxChgPulseStart(1));
            finalPulseIndex = min(indxDischgPulseStart(end),indxChgPulseStart(end));
            indxSOCPulseStart = indxSOCPulseStart(indxSOCPulseStart > firstPulseIndex);
            indxSOCPulseStart = indxSOCPulseStart(indxSOCPulseStart < finalPulseIndex);
            indxSOCPulseEnd   = find(abs(abs(diff(obj.InputTestData.I)) - abs(obj.ConstantCurrDischarge)) < obj.Tolerance*abs(obj.ConstantCurrDischarge) & ...
                                     diff(obj.InputTestData.I) > 0);
            indxSOCPulseEnd   = indxSOCPulseEnd(indxSOCPulseEnd > indxSOCPulseStart(1));
            indxSOCPulseEnd   = indxSOCPulseEnd(indxSOCPulseEnd < finalPulseIndex);
            
            if length(indxSOCPulseEnd) < length(indxSOCPulseStart)
                indxSOCPulseStart = indxSOCPulseStart(1:length(indxSOCPulseEnd));
            end
            indxSOCPulseMid   = indxSOCPulseStart + 1;
            indxSOCRelaxStart = indxSOCPulseEnd + 1;
            nSOCsweepPulses  = length(indxSOCPulseStart);
            disp(strcat('*** Number of SOC sweep pulses = ',num2str(nSOCsweepPulses))); 

            if nPulsesDischarge > 0
                dataDischg = [indxDischgPulseStart, ...
                              indxDischgPulseEnd, ...
                              indxDischgPulseMid, ...
                              indxDischgRelaxStart, ...getPulsesFromHPPCdata
                              ones(nPulsesDischarge,1)];
            else
                dataDischg = [0 0 0 0 1];
            end
            if nPulsesCharge > 0
                dataCharge = [indxChgPulseStart, ...
                              indxChgPulseEnd, ...
                              indxChgPulseMid, ...
                              indxChgRelaxStart, ...
                              -1*ones(nPulsesCharge,1)];
            else
                dataCharge = [0 0 0 0 -1];
            end
            dataSOCsweep = [indxSOCPulseStart, ...
                            indxSOCPulseEnd, ...
                            indxSOCPulseMid, ...
                            indxSOCRelaxStart, ...
                            zeros(nSOCsweepPulses,1)];
            if nPulsesCharge > 0 && nPulsesDischarge > 0
                hppcSeqSortData = vertcat(dataDischg,dataCharge,dataSOCsweep);
            elseif nPulsesCharge == 0 && nPulsesDischarge > 0
                hppcSeqSortData = vertcat(dataDischg,dataSOCsweep);
            elseif nPulsesCharge > 0 && nPulsesDischarge == 0
                hppcSeqSortData = vertcat(dataCharge,dataSOCsweep);
            else
                pm_error('Error in finding pulse indices for charge/discharge');
            end
            hppcSeqSorted     = sortrows(hppcSeqSortData,1); % sort based on start index
            hppcPulseSequence = {hppcSeqSortData,...
                                 hppcSeqSorted,...
                                 nPulsesDischarge,...
                                 nPulsesCharge,...
                                 nSOCsweepPulses};

            % Identify pulse patterns - required to find the end of sequence for
            % proper closure (final data point/index in the timeseries data)
            eventRelaxTimeVal = obj.InputTestData.time(hppcSeqSorted(2:end,1)) ...
                - obj.InputTestData.time(hppcSeqSorted(1:end-1,4));
            event_recorded    = hppcSeqSorted(1:end-1,5);
            eventFinal        = hppcSeqSorted(end,5);
            eventHistory      = mean(eventRelaxTimeVal(hppcSeqSorted(1:end-1,5)==eventFinal));
            eventStopTimeVal  = obj.InputTestData.time(hppcSeqSorted(end,4)) + eventHistory;
            [~, finalDataPointId] = min(abs(obj.InputTestData.time - eventStopTimeVal));
            finalDataPointId  = min(length(obj.InputTestData.time), finalDataPointId);

            indxOCVpoints = zeros(nSOCsweepPulses+3,1); % +3 == 2 at end, 1 at beginning
            indxOCVpoints(1,1) = hppcSeqSorted(1,1) - 1;
            for i = 1:nSOCsweepPulses % -1
                % Find data-index when SOC sweep starts
                i1 = hppcSeqSortData(nPulsesDischarge+nPulsesCharge+i,4);
                % Find sorted position of above data-index
                i2 = find(hppcSeqSorted(:,4)==i1);
                % Find data-index that comes after SOC sweep, choose a
                % point before that.
                i3 = min(nPulsesDischarge+nPulsesCharge+nSOCsweepPulses, i2+1);
                indxOCVpoints(i+1,1) = hppcSeqSorted(i3,1) - 1;
            end
            indxOCVpoints(end-1,1) = hppcSeqSorted(end,4) + 1;
            indxOCVpoints(end,1)   = length(obj.InputTestData.I);
        end
        
        function ocv = getOpenCircuitPotentialData(obj)
            ocv = array2table([obj.InputTestData.SOC(obj.OCVdataIndices),...
                               obj.InputTestData.V(obj.OCVdataIndices)],...
                               'VariableNames',{'SOC', 'OCV'});
        end
        
        function ohmicR = getOhmicResistanceData(obj)
            % Ohmic Resistance R0
            hppcSeqSortData  = obj.HPPCpulseSequence{1};
            nDischargePulses = obj.HPPCpulseSequence{3};
            nChargePulses    = obj.HPPCpulseSequence{4};
            %
            if nDischargePulses > 0
                idx1 = 1;
                idx2 = nDischargePulses;
                VdischgRestStart = obj.InputTestData.V(hppcSeqSortData(idx1:idx2,4));
                VdischgPulseEnd  = obj.InputTestData.V(hppcSeqSortData(idx1:idx2,2));
                Idischg          = obj.DischargePulseCurr;
                R0dischg         = abs(VdischgRestStart - VdischgPulseEnd) / Idischg;
                SOCdischg        = obj.InputTestData.SOC(hppcSeqSortData(idx1:idx2,4));
                ohmicRdischg     = array2table([SOCdischg, R0dischg],...
                                   'VariableNames',{'SOC', 'R0discharge'});
            end
            if nChargePulses > 0
                idx1 = nDischargePulses + 1;
                idx2 = nDischargePulses + nChargePulses;
                VchgRelaxStart = obj.InputTestData.V(hppcSeqSortData(idx1:idx2,4));
                VchgPulseEnd   = obj.InputTestData.V(hppcSeqSortData(idx1:idx2,2));
                Ichg           = obj.ChargePulseCurr;
                R0chg          = abs(VchgRelaxStart - VchgPulseEnd) / Ichg;
                SOCchg         = obj.InputTestData.SOC(hppcSeqSortData(idx1:idx2,4));
                ohmicRchg      = array2table([SOCchg, R0chg],...
                                 'VariableNames',{'SOC', 'R0charge'});
            end
            % Convert data to tables for charge and discharge scenarios
            if nDischargePulses > 0 && nChargePulses > 0
                ohmicR = {ohmicRdischg, ohmicRchg};
            elseif nDischargePulses > 0 && nChargePulses == 0
                ohmicR = {ohmicRdischg};
            elseif nDischargePulses == 0 && nChargePulses > 0
                ohmicR = {ohmicRchg};
            else
                pm_error('No charge or discharge pulse detected');
            end
            
        end

        function [RCpairs, fitErr, RCpairsLongRest] = getRCparametersData(obj, ...
                initialEstimate, initialEstimateLongRest, fitMethod, debugMode)
            N = obj.NumOfRCpairs;   
            NlongRest = obj.NumOfRCpairsLongRest;
            fitRMSE = zeros(2, 2);  
            % Find number of charge and discharge pulses
            nChargePulses    = obj.HPPCpulseSequence{4};
            nDischargePulses = obj.HPPCpulseSequence{3};
            nSOCsweepPulses  = obj.HPPCpulseSequence{5};
            totalNumPoints   = nChargePulses + nDischargePulses + nSOCsweepPulses;

            if nSOCsweepPulses > 0
                % Long rest after SOC sweep
                SOCdataSweep = obj.InputTestData.SOC(obj.HPPCpulseSequence{1}(nDischargePulses+nChargePulses+1:totalNumPoints,4));
                [ResLongRest, TauLongRest, ~] =  getTimeConstFromPulses(...
                                         0,NlongRest,obj.HPPCpulseSequence,...
                                         obj.InputTestData.time,...
                                         obj.InputTestData.V,...
                                         obj.ConstantCurrDischarge,...
                                         initialEstimateLongRest, fitMethod, ...
                                         obj.FinalDataPointIndex, debugMode);
                tableVarNamesRes = cell(1, NlongRest+1);
                tableVarNamesRes{1,1} = 'SOC';
                tableVarNamesTau = cell(1, NlongRest+1);
                tableVarNamesTau{1,1} = 'SOC';
                for j = 1 : NlongRest
                    tableVarNamesRes{1,j+1} = strcat('R',num2str(j),'rest');
                    tableVarNamesTau{1,j+1} = strcat('Tau',num2str(j),'rest');
                end
                nResLongRest = array2table([SOCdataSweep(1:length(ResLongRest)), ResLongRest],'VariableNames',tableVarNamesRes);
                nTauLongRest = array2table([SOCdataSweep(1:length(TauLongRest)), TauLongRest],'VariableNames',tableVarNamesTau);
            end

            if nDischargePulses > 0
                % Discharge pulse
                SOCdischg = obj.InputTestData.SOC(obj.HPPCpulseSequence{1}(1:nDischargePulses,4));
                [Rdischg, TauDischg, err] = getTimeConstFromPulses(...
                                         1,N,obj.HPPCpulseSequence,...
                                         obj.InputTestData.time,...
                                         obj.InputTestData.V,...
                                         obj.DischargePulseCurr,...
                                         initialEstimate, fitMethod,...
                                         obj.FinalDataPointIndex, debugMode);
                
                if debugMode, disp('*** Calculated RC parameters for discharge'); end
                
                fitRMSE(1,1) = min(err);
                fitRMSE(1,2) = max(err);
                % Save results in table
                tableVarNamesRes = cell(1, N+1);
                tableVarNamesRes{1,1} = 'SOC';
                tableVarNamesTau = cell(1, N+1);
                tableVarNamesTau{1,1} = 'SOC';
                for j = 1 : N
                    tableVarNamesRes{1,j+1} = strcat('R',num2str(j),'discharge');
                    tableVarNamesTau{1,j+1} = strcat('Tau',num2str(j),'discharge');
                end
                nRdischarge = array2table([SOCdischg, Rdischg],'VariableNames',tableVarNamesRes);
                nTauDischarge = array2table([SOCdischg, TauDischg],'VariableNames',tableVarNamesTau);
            end
            
            if nChargePulses > 0
                % Charge pulse
                SOCchg = obj.InputTestData.SOC(obj.HPPCpulseSequence{1}(nDischargePulses+1:nDischargePulses+nChargePulses,4));
                [Rchg, TauChg, err] = getTimeConstFromPulses(...
                                         -1,N,obj.HPPCpulseSequence,...
                                         obj.InputTestData.time,...
                                         obj.InputTestData.V,...
                                         obj.ChargePulseCurr,...
                                         initialEstimate, fitMethod,...
                                         obj.FinalDataPointIndex, debugMode);
                
                if debugMode, disp('*** Calculated RC parameters for charge'); end

                fitRMSE(2,1) = min(err);
                fitRMSE(2,2) = max(err);
                % Save results in table
                tableVarNamesRes = cell(1, N+1);
                tableVarNamesRes{1,1} = 'SOC';
                tableVarNamesTau = cell(1, N+1);
                tableVarNamesTau{1,1} = 'SOC';
                for j = 1 : N
                    tableVarNamesRes{1,j+1} = strcat('R',num2str(j),'charge');
                    tableVarNamesTau{1,j+1} = strcat('Tau',num2str(j),'charge');
                end
                nRcharge = array2table([SOCchg, Rchg],'VariableNames',tableVarNamesRes);
                nTauCharge = array2table([SOCchg, TauChg],'VariableNames',tableVarNamesTau);
            end
            % Return computed result
            if nChargePulses > 0 && nDischargePulses > 0
                RCpairs = {nRdischarge, nTauDischarge, nRcharge, nTauCharge};
            elseif nChargePulses > 0 && nDischargePulses == 0
                RCpairs = {nRcharge, nTauCharge};
            elseif nDischargePulses > 0 && nChargePulses == 0
                RCpairs = {nRdischarge, nTauDischarge};
            else
                RCpairs = {};
            end
            RCpairsLongRest = {nResLongRest, nTauLongRest};

            fitErr = array2table([max(fitRMSE(1,1),fitRMSE(2,1)), ...
                                  max(fitRMSE(1,2),fitRMSE(2,2))],...
                                  'VariableNames',{'min err','max err'});
            
            if debugMode, disp('*** Calculated rmse for the fit'); end
            
        end
        
        function data = getDataFromFile(obj)
            if isfile(obj.FileFullPath) % check if the data file exists or has a valid path
                fileIdData = fopen(obj.FileFullPath);
                if ~isequal(fileIdData,-1)
                    if obj.FileType == "MAT"
                        dataMAT = load(obj.FileFullPath);
                        signalCellarray = struct2cell(dataMAT);
                        datafile = signalCellarray{1};
                    elseif obj.FileType == "TXT" || obj.FileType == "XLSX"
                        datafile = readtable(obj.FileFullPath);
                    else
                        pm_error('Input data file type not supported. Use MAT / TXT / XLSX file');
                    end
                    
                    if size(datafile,2) > 4 || size(datafile,2) < 3 
                        fclose(fileIdData);
                        pm_error('Input data must be a column vector of time, Current, Voltage, and SOC; SOC column is optional');
                    else
                        if size(datafile,2) == 3
                            data = addSOCvectorToInputData(datafile, obj.InitialCellSOC, obj.CellCapacity);
                        else
                            data = datafile;
                        end
                        data.Properties.VariableNames{1} = 'time'; % renaming table to be consistent
                        data.Properties.VariableNames{2} = 'I';    % renaming table to be consistent
                        data.Properties.VariableNames{3} = 'V';    % renaming table to be consistent
                        data.Properties.VariableNames{4} = 'SOC';  % renaming table to be consistent    
                    end
                    
                    if min(diff(data.time)) < 0
                        pm_error('time data in the first column should be monotonically increasing data');
                    end
                else
                    fclose(fileIdData);
                    pm_error('UnableToOpenDataFile');
                end
            else
                pm_error('Unable to find file or the file directory. Specify a valid file name, path, and file extension');
            end
            fclose(fileIdData);
        end
        
        function batteryParameters = getBatteryParamTable(obj, userSOCpoints)
            nChargePulses    = obj.HPPCpulseSequence{4};
            nDischargePulses = obj.HPPCpulseSequence{3};
            nSOCsweepPoints  = obj.HPPCpulseSequence{5};

            OCV = interp1(obj.OpenCircuitPotential.SOC, obj.OpenCircuitPotential.OCV, ...
                           userSOCpoints, 'makima', 'extrap');

            if nDischargePulses > 0
                R0discharge = interp1(obj.OhmicResistance{1}.SOC, obj.OhmicResistance{1}.R0discharge, ...
                               userSOCpoints, 'makima', 'extrap');
            end
            if nChargePulses > 0
                R0charge = interp1(obj.OhmicResistance{2}.SOC, obj.OhmicResistance{2}.R0charge, ...
                            userSOCpoints, 'makima', 'extrap');
            end
            % Write data to table and export to a file
            % Below is an averaged data for easy import to Battery LUT block
            % 4 for SOC, OCV, R0charge, R0discharge, and twice the number of RC pairs
            if nDischargePulses > 0 && nChargePulses > 0
                dynData = 4;
                tableVarNames = cell(1, 4 + dynData*obj.NumOfRCpairs + 2*obj.NumOfRCpairsLongRest); 
            else
                dynData = 2;
                tableVarNames = cell(1, 3 + dynData*obj.NumOfRCpairs + 2*obj.NumOfRCpairsLongRest); 
            end

            tableVarNames{1,1} = 'SOC';
            tableVarNames{1,2} = 'V0';
            if nDischargePulses > 0 && nChargePulses > 0
                tableVarNames{1,3} = 'R0charge';
                tableVarNames{1,4} = 'R0discharge';
                idx0 = 4; % =4 as 4 data have been filled above
            elseif nDischargePulses > 0 && nChargePulses == 0
                tableVarNames{1,3} = 'R0discharge';
                idx0 = 3;
            elseif nDischargePulses == 0 && nChargePulses > 0
                tableVarNames{1,3} = 'R0charge';
                idx0 = 3;
            else
                pm_error('No charge or discharge pulse detected');
            end
            
            datavec = [];
            for i = 1 : obj.NumOfRCpairs
                idx = idx0 + dynData*(i-1) + 1;
                if nDischargePulses > 0
                    Rdischarge = interp1(obj.DynamicRC{1}.SOC, ...
                                          obj.DynamicRC{1}.("R"+i+"discharge"), ...
                                          userSOCpoints, 'makima', 'extrap');
                    TauDischarge = interp1(obj.DynamicRC{2}.SOC, ...
                                            obj.DynamicRC{2}.("Tau"+i+"discharge"), ...
                                            userSOCpoints, 'makima', 'extrap');
                end
                if nChargePulses > 0
                    Rcharge = interp1(obj.DynamicRC{3}.SOC, ...
                                       obj.DynamicRC{3}.("R"+i+"charge"), ...
                                       userSOCpoints, 'makima', 'extrap');
                    TauCharge = interp1(obj.DynamicRC{4}.SOC, ...
                                         obj.DynamicRC{4}.("Tau"+i+"charge"), ...
                                         userSOCpoints, 'makima', 'extrap');
                end
                if nDischargePulses > 0 && nChargePulses > 0                
                    tableVarNames{1,idx}   = strcat('R',num2str(i),'charge'); % R
                    tableVarNames{1,idx+1} = strcat('Tau',num2str(i),'charge'); % Tau
                    tableVarNames{1,idx+2} = strcat('R',num2str(i),'discharge'); % R
                    tableVarNames{1,idx+3} = strcat('Tau',num2str(i),'discharge'); % Tau
                    datavec = [datavec, Rcharge', TauCharge', Rdischarge', TauDischarge'];
                elseif nDischargePulses > 0 && nChargePulses == 0
                    tableVarNames{1,idx}   = strcat('R',num2str(i),'discharge'); % R
                    tableVarNames{1,idx+1} = strcat('Tau',num2str(i),'discharge'); % Tau
                    datavec = [datavec, Rdischarge', TauDischarge'];
                else % nDischargePulses == 0 && nChargePulses > 0
                    tableVarNames{1,idx}   = strcat('R',num2str(i),'charge'); % R
                    tableVarNames{1,idx+1} = strcat('Tau',num2str(i),'charge'); % Tau
                    datavec = [datavec, Rcharge', TauCharge'];
                end
            end

            dataVecLongRest = [];
            for i = 1 : obj.NumOfRCpairsLongRest
                idx = idx0 + dynData*obj.NumOfRCpairs + 2*(i-1) + 1;
                ResLongRest            = interp1(obj.DynamicRClongRest{1}.SOC, ...
                                         obj.DynamicRClongRest{1}.("R"+i+"rest"), ...
                                         userSOCpoints, 'makima', 'extrap');
                TauLongRest            = interp1(obj.DynamicRClongRest{2}.SOC, ...
                                         obj.DynamicRClongRest{2}.("Tau"+i+"rest"), ...
                                         userSOCpoints, 'makima', 'extrap');
                dataVecLongRest        = [dataVecLongRest, ResLongRest', TauLongRest'];
                tableVarNames{1,idx}   = strcat('R',num2str(i),'rest'); % R
                tableVarNames{1,idx+1} = strcat('Tau',num2str(i),'rest'); % Tau
            end
            
            if nDischargePulses > 0 && nChargePulses > 0
                batteryParameters = array2table([userSOCpoints', OCV', ...
                    R0charge', R0discharge', datavec, dataVecLongRest],'VariableNames',tableVarNames);
            elseif nDischargePulses > 0 && nChargePulses == 0
                batteryParameters = array2table([userSOCpoints', OCV', ...
                    R0discharge', datavec, dataVecLongRest],'VariableNames',tableVarNames);
            elseif nDischargePulses == 0 && nChargePulses > 0
                batteryParameters = array2table([userSOCpoints', OCV', ...
                    R0charge', datavec, dataVecLongRest],'VariableNames',tableVarNames);
            else
                pm_error('No charge or discharge pulse detected');
            end
        end
    end
end

% -------------------------------------------------------------------------
function [R_val, Tau_val, rmseFit] = getTimeConstFromPulses(dischgOrChg,N,...
                                     HPPCpulseSequence,ts,voltage,current,...
                                     InitVal,methodUsed,finalDataPointIndex,...
                                     debugMode)
    hppcSeqSortData  = HPPCpulseSequence{1};
    hppcSeqSorted    = HPPCpulseSequence{2};
    nPulsesDischarge = HPPCpulseSequence{3};
    nPulsesCharge    = HPPCpulseSequence{4};
    nSOCsweepPulses  = HPPCpulseSequence{5};
    totalLenData     = nPulsesDischarge + nPulsesCharge + nSOCsweepPulses;
    % Data in 'hppcSeqSortData' stored as discharge/charge/SOC-sweep data
    if dischgOrChg == 1
        % Discharge
        M = nPulsesDischarge;
        startM = 0;
        figNameDisplay = 'discharge';
    elseif dischgOrChg == -1
        % Charge
        M = nPulsesCharge;
        startM = nPulsesDischarge;
        figNameDisplay = 'charge';
    else% if set as Zero, or any num. other than 1 or -1
        % SOC sweep
        M = nSOCsweepPulses;
        startM = nPulsesDischarge + nPulsesCharge;
        figNameDisplay = 'SOC sweep';
    end
    
    R_val = zeros(M, N);
    Tau_val = zeros(M, N);
    rmseFit = zeros(M, 1);
    for i = 1 : M
        % Find indices for relaxation curve, ie. what comes after a charge
        % or discharge pulse. Is it long rest or another pulse ?
        
        % Start at relaxation start index, name it as 'i1'
        % relaxation starts, at index '4th' column
        i1 = hppcSeqSortData(startM+i, 4); 
        
        % Find which index comes next, and store it in 'i2'
        % Find 'i1' position in the sort order. It could be different that
        % 'i1' depending on the input data (nature of hppc, sequence of pulses).
        i1_sorted = find(hppcSeqSorted(:,4)==i1); 
        
        if i1_sorted < totalLenData
            % Find the pulse start index of the pulse/event after 'i1' from
            % the sorted list (must pick from sorted list to preserve info 
            % on what comes after a pulse); Hence, column 1 (pulse start) of 
            % the index 'i_sorted+1' needs to be picked.
            i2 = hppcSeqSorted(i1_sorted+1, 1);
            range = i1:i2;
        else
            range = i1:finalDataPointIndex;
        end
        
        % Find pulse start and end indices (from the un-sorted list, for
        % ease of reference only)
        j1 = hppcSeqSortData(startM+i, 1); % pulse start data at column 1
        j2 = hppcSeqSortData(startM+i, 2); % pulse end data at column 2
        pulseDuration = ts(j2) - ts(j1);

        % Data for fitting, relaxation curve, as defined by 'range'
        x = ts(range) - ts(range(1));
        if dischgOrChg == 0
            y = (voltage(range) - voltage(range(1)));
        else
            y = dischgOrChg * (voltage(range) - voltage(range(1)));
        end
        
        if debugMode
            figName = strcat(figNameDisplay, ' (', num2str(dischgOrChg), ') fit ',num2str(i),' pulse duration = ',num2str(pulseDuration));
            figure('Name', figName);
            plot(ts(range),voltage(range));title(figName);
        end

        
        if methodUsed == "fminsearch"
            if debugMode
                options = optimset('MaxIter',40000,'MaxFunEvals',40000,...
                                   'Display','final','TolFun',1e-4,'TolX',1e-4);
            else
                options = optimset('MaxIter',40000,'MaxFunEvals',40000,...
                                   'TolFun',1e-4,'TolX',1e-4);
            end
            [b_min, minErr] = fminsearch(@(b) fit_fminsearch(b,x,y,pulseDuration,N),...
                                                             InitVal,options);
            rmseFit(i, 1) = minErr;
            Rvec = [];
            tauvec = [];
            for j = 1 : N
                R.("R"+j) = b_min(2*j-1) / current;
                tau.("tau"+j) = b_min(2*j);
                Rvec = [Rvec, R.("R"+j)];
                tauvec = [tauvec, tau.("tau"+j)];
            end
        else % curvefit
            [out,gof] = fit_cfit(x,y,pulseDuration,N,InitVal);
            rmseFit(i, 1) = gof.rmse;
            Rvec = [];
            tauvec = [];
            for j = 1 : N
                R.("R"+j) = out.("A"+j) / current;
                tau.("tau"+j) = out.("tau"+j);
                Rvec = [Rvec, R.("R"+j)];
                tauvec = [tauvec, tau.("tau"+j)];
            end
        end
        
        R_val(i,1:N) = Rvec;
        Tau_val(i,1:N)  = tauvec;
    end
end

function [fitresult, gof] = fit_cfit(varargin)
    %% Fit: 'multiExponentialFit'.
    t = varargin{1};
    V = varargin{2};
    t0 = varargin{3};
    N = varargin{4};
    initialEstimate = varargin{5};
    
    [xData, yData] = prepareCurveData(t, V );
    
    % Set up fittype and options.
    v = "";
    if nargin == 5
        for i=1:N
            v = v+"+A"+i+"-A"+i+"*exp(-x/tau"+i+")+A"+i+"*exp(-(x+"+t0+")/tau"+i+")-A"+i+"*exp(-"+t0+"/tau"+i+")";
        end
        ft = fittype(v, 'independent', 'x', 'dependent', 'y');
        
    elseif nargin == 6
        Vss = varargin{6};
        for i=1:N
            v = v+"+A"+i+"-A"+i+"*exp(-x/tau"+i+")+A"+i+"*exp(-(x+"+t0+")/tau"+i+")-A"+i+"*exp(-"+t0+"/tau"+i+")";
        end
        ft = fittype(Vss+v, 'independent', 'x', 'dependent', 'y');
    end
    
    opts = fitoptions('Method', 'NonlinearLeastSquares');
    opts.Display = 'Off';
    opts.Lower = zeros(1,2*N);
    opts.Upper = Inf*ones(1,2*N);
    opts.Robust = 'LAR';
    opts.StartPoint = initialEstimate;
    
    % Fit model to data.
    [fitresult, gof] = fit(xData, yData, ft, opts);
    
end

function minFunc = fit_fminsearch(b,fit_arg_time,fit_arg_volt,pulseDuration,n) 
    val = 0;
    for i = 1 : n
        val = val + b(2*i-1)*(1-exp(-fit_arg_time./b(2*i))) + ...
                    b(2*i-1)*exp(-(fit_arg_time+pulseDuration)./b(2*i)) - ...
                    b(2*i-1)*exp(-pulseDuration/b(2*i));
    end   
    val     = val +  10^100*any(b<=0) + 10^100*any(diff(b(2:2:end))<=0); % exclude results for negative params.
    err     = val - fit_arg_volt; % Find error
    minFunc = abs(mean(err)); 
end

function data = addSOCvectorToInputData(inp_data, initial_soc, cellCapacity)
    current = inp_data(:,2);
    time    = inp_data(:,1);
    dataLen = size(inp_data,1);
    socVal  = zeros(dataLen,1);
    socVal(1,1) = initial_soc;
    socVal(2:end,1) = min(1, max(0, ...
        socVal(1,1)+cumsum(current(2:end,1).*diff(time(1:end,1))/(3600*cellCapacity)) ...
        ));
    data = [inp_data, socVal];
end

function boolVal = checkInputData(data)
    chkNaN  = any(any(isnan(data))); 
    chkInf  = any(any(isinf(data)));
    boolVal = or(chkNaN,chkInf);
end

function idxNew = getUpdatedDataSet(idx,testDataValues,userValues)
    idxNew = idx;
    origValues = testDataValues(idx,:);
    totalDataPoints = size(userValues,1);
    for itr = 1:totalDataPoints
        % Find the nearest point on test data that relates to user defined
        % point. t & V have different scale of values and a simple point
        % distance calculation may not work in edge cases, unless whole
        % data is normalized. Hence, data is normalized below.
        if origValues(itr,2) - userValues(itr,2) ~= 0 || origValues(itr,1) - userValues(itr,1) ~= 0
            disp(strcat('Replacing point (',num2str(origValues(itr,2)),') with (',num2str(userValues(itr,2)),') at time t = ',num2str(origValues(itr,1)),' => ',num2str(userValues(itr,1)),'s.'));
            if itr == 1, rangeStart = 1; else; rangeStart = idx(itr-1); end
            if itr == totalDataPoints, rangeEnd = size(testDataValues,1); else; rangeEnd = idx(itr+1); end
            t_min = testDataValues(rangeStart,1);
            t_max = testDataValues(rangeEnd,1);
            voltageValues = testDataValues(rangeStart:rangeEnd,2);
            V_min = min(voltageValues);
            V_max = max(voltageValues);
            normTimeHPPC = (testDataValues(:,1) - t_min)/(t_max - t_min);
            normVoltHPPC = (testDataValues(:,2) - V_min)/(V_max - V_min);
            normTimeUser = (userValues(itr,1) - t_min)/(t_max - t_min);
            normVoltUser = (userValues(itr,2) - V_min)/(V_max - V_min);
            [~, minValID] = min((normTimeUser-normTimeHPPC).^2 + (normVoltUser-normVoltHPPC).^2);
            idxNew(itr) = minValID;
            disp(strcat('*** Replacing data at id = <',num2str(idx(itr)),'> with id = <',num2str(idxNew(itr)),'>'));
        end
    end
end


classdef BEVauthorAppNative < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure

        % ---- Main grid ----
        GridLayout                      matlab.ui.container.GridLayout

        % ---- Left nav panel ----
        NavPanel                        matlab.ui.container.Panel
        NavGrid                         matlab.ui.container.GridLayout
        AppTitleLabel                   matlab.ui.control.Label
        WorkflowLabel                   matlab.ui.control.Label
        Nav1RegisterBtn                 matlab.ui.control.Button
        Nav2ComponentBtn                matlab.ui.control.Button
        Nav3FidelityBtn                 matlab.ui.control.Button
        UtilitiesLabel                  matlab.ui.control.Label
        NavUpdateBtn                    matlab.ui.control.Button
        NavCleanBtn                     matlab.ui.control.Button
        LaunchSetupAppBtn               matlab.ui.control.Button

        % ---- Center workspace ----
        CenterPanel                     matlab.ui.container.Panel
        CenterGrid                      matlab.ui.container.GridLayout

        % Step 1: Register Template
        RegisterPanel                   matlab.ui.container.Panel
        RegTemplateLabel                matlab.ui.control.Label
        RegTemplateDropDown             matlab.ui.control.DropDown
        RegDescLabel                    matlab.ui.control.Label
        RegDescField                    matlab.ui.control.EditField
        RegConfigLabel                  matlab.ui.control.Label
        RegConfigDropDown               matlab.ui.control.DropDown
        RegConfigBrowseBtn              matlab.ui.control.Button
        RegAllowUnmappedCB              matlab.ui.control.CheckBox
        RegOverwriteCB                  matlab.ui.control.CheckBox
        RegScanBtn                      matlab.ui.control.Button
        RegWriteBtn                     matlab.ui.control.Button
        RegLamp                         matlab.ui.control.Lamp

        % Step 2: Add/Delete Controller
        ControllerPanel                 matlab.ui.container.Panel
        CtrlConfigLabel                 matlab.ui.control.Label
        CtrlConfigDropDown              matlab.ui.control.DropDown
        CtrlTemplateLabel               matlab.ui.control.Label
        CtrlTemplateDropDown            matlab.ui.control.DropDown
        CtrlAddBtn                      matlab.ui.control.Button
        CtrlDeleteBtn                   matlab.ui.control.Button
        CtrlModelLabel                  matlab.ui.control.Label
        CtrlModelDropDown               matlab.ui.control.DropDown
        CtrlParamLabel                  matlab.ui.control.Label
        CtrlParamField                  matlab.ui.control.EditField
        CtrlParamBrowseBtn              matlab.ui.control.Button
        CtrlMakeDefaultCB               matlab.ui.control.CheckBox
        CtrlPreviewBtn                  matlab.ui.control.Button
        CtrlWriteBtn                    matlab.ui.control.Button
        CtrlLamp                        matlab.ui.control.Lamp

        % Step 3: Add/Delete Fidelity
        FidelityPanel                   matlab.ui.container.Panel
        FidConfigLabel                  matlab.ui.control.Label
        FidConfigDropDown               matlab.ui.control.DropDown
        FidTemplateLabel                matlab.ui.control.Label
        FidTemplateDropDown             matlab.ui.control.DropDown
        FidComponentLabel               matlab.ui.control.Label
        FidComponentDropDown            matlab.ui.control.DropDown
        FidModelLabel                   matlab.ui.control.Label
        FidModelDropDown                matlab.ui.control.DropDown
        FidParamLabel                   matlab.ui.control.Label
        FidParamField                   matlab.ui.control.EditField
        FidParamBrowseBtn              matlab.ui.control.Button
        FidMakeDefaultCB                matlab.ui.control.CheckBox
        FidPreviewBtn                   matlab.ui.control.Button
        FidWriteBtn                     matlab.ui.control.Button
        FidAddBtn                       matlab.ui.control.Button
        FidDeleteBtn                    matlab.ui.control.Button
        FidLamp                         matlab.ui.control.Lamp

        % Util: Update Config
        UpdatePanel                     matlab.ui.container.Panel
        UpdTemplateLabel                matlab.ui.control.Label
        UpdTemplateDropDown             matlab.ui.control.DropDown
        UpdHintLabel                    matlab.ui.control.Label
        UpdScanBtn                      matlab.ui.control.Button
        UpdApplyBtn                     matlab.ui.control.Button
        UpdLamp                         matlab.ui.control.Lamp

        % Util: Clean Config
        CleanPanel                      matlab.ui.container.Panel
        ClnConfigLabel                  matlab.ui.control.Label
        ClnConfigDropDown               matlab.ui.control.DropDown
        ClnHintLabel                    matlab.ui.control.Label
        ClnScanBtn                      matlab.ui.control.Button
        ClnApplyBtn                     matlab.ui.control.Button
        ClnLamp                         matlab.ui.control.Lamp

        % Util: Set System Params
        SysParamPanel                   matlab.ui.container.Panel
        SysConfigLabel                  matlab.ui.control.Label
        SysConfigDropDown               matlab.ui.control.DropDown
        SysTemplateLabel                matlab.ui.control.Label
        SysTemplateDropDown             matlab.ui.control.DropDown
        SysParamLabel                   matlab.ui.control.Label
        SysParamField                   matlab.ui.control.EditField
        SysParamBrowseBtn               matlab.ui.control.Button
        SysPreviewBtn                   matlab.ui.control.Button
        SysApplyBtn                     matlab.ui.control.Button
        SysLamp                         matlab.ui.control.Lamp
        NavSysParamBtn                  matlab.ui.control.Button

        % Results text area (shared across all steps)
        ResultsLabel                    matlab.ui.control.Label
        ResultsArea                     matlab.ui.control.TextArea

        % ---- Right preview panel ----
        RightPanel                      matlab.ui.container.Panel
        RightGrid                       matlab.ui.container.GridLayout
        PreviewConfigLabel              matlab.ui.control.Label
        PreviewConfigDropDown           matlab.ui.control.DropDown
        PreviewTemplateLabel            matlab.ui.control.Label
        PreviewTemplateDropDown         matlab.ui.control.DropDown
        PreviewRefreshBtn               matlab.ui.control.Button
        PreviewHTML                     matlab.ui.control.HTML
        ValidationLamp                  matlab.ui.control.Lamp
        ValidationLabel                 matlab.ui.control.Label
    end

    properties (Access = public, Hidden)
        ProjectRoot     string = ""
        CtrlMode        string = ""  % "add" or "delete"
        FidMode         string = ""  % "add" or "delete"
        NavButtons      % cell array of nav button handles
        StepPanels      % struct mapping panel name to handle
        PreviewFigure   % undocked preview window (uifigure or [])
        PreviewDocked   logical = true
        UndockBtn       matlab.ui.control.Button
        DefaultNavBg    double  % default nav button background
        DefaultNavFg    double  % default nav button foreground
    end

    % ---- Color constants ----
    properties (Constant)
        BLUE        = [0.3608 0.6314 0.8118]
        DARK_BLUE   = [0 0.4471 0.7412]
        GREEN       = [0.4660 0.6740 0.1880]
        AMBER       = [0.9290 0.6940 0.1250]
        RED         = [0.6350 0.0780 0.1840]
        WHITE       = [1 1 1]
        MUTED       = [0.5 0.5 0.5]
    end

    % ============================================================
    %  Callbacks — thin wrappers delegating to utils/APP/API/AuthorUI
    % ============================================================
    methods (Access = private)

        % ---- Nav buttons ----
        function Nav1Pushed(app, ~),       switchPanel(app, "register");   end
        function Nav2Pushed(app, ~),       switchPanel(app, "controller"); end
        function Nav3Pushed(app, ~),       switchPanel(app, "fidelity");   end
        function NavUpdatePushed(app, ~),  switchPanel(app, "update");     end
        function NavCleanPushed(app, ~),   switchPanel(app, "clean");      end
        function NavSysParamPushed(app, ~), switchPanel(app, "sysparam"); end
        function LaunchSetupAppPushed(app, ~), launchSetupAppFromAuthor(app); end

        % ---- Step 1: Register ----
        function RegNewConfigPushed(app, ~), registerAction(app, "newConfig"); end
        function RegScanPushed(app, ~),      registerAction(app, "scan");      end
        function RegWritePushed(app, ~),     registerAction(app, "write");     end

        % ---- Step 2: Add/Delete Controller ----
        function CtrlConfigChanged(app, ~)
            if ~isempty(app.CtrlConfigDropDown.Value)
                populateTemplateKeys(app, app.CtrlConfigDropDown.Value, app.CtrlTemplateDropDown);
            end
            resetCtrlMode(app);
        end

        function CtrlAddPushed(app, ~)
            app.CtrlMode = "add";
            app.CtrlAddBtn.BackgroundColor = app.DARK_BLUE;
            app.CtrlAddBtn.FontColor = app.WHITE;
            app.CtrlDeleteBtn.BackgroundColor = app.DefaultNavBg;
            app.CtrlDeleteBtn.FontColor = app.DefaultNavFg;
            populateControllerModels(app);
            app.CtrlModelDropDown.Enable = 'on';
            app.CtrlParamField.Enable = 'on';
            app.CtrlParamBrowseBtn.Enable = 'on';
            app.CtrlMakeDefaultCB.Enable = 'on';
            app.CtrlPreviewBtn.Enable = 'on';
            app.CtrlWriteBtn.Enable = 'off';
            app.CtrlWriteBtn.Text = 'Add Controller (Write)';
            app.CtrlParamField.Value = '';
            app.CtrlMakeDefaultCB.Value = false;
        end

        function CtrlDeletePushed(app, ~)
            app.CtrlMode = "delete";
            app.CtrlDeleteBtn.BackgroundColor = app.DARK_BLUE;
            app.CtrlDeleteBtn.FontColor = app.WHITE;
            app.CtrlAddBtn.BackgroundColor = app.DefaultNavBg;
            app.CtrlAddBtn.FontColor = app.DefaultNavFg;
            populateControllerModels(app, "config");
            app.CtrlModelDropDown.Enable = 'on';
            app.CtrlParamField.Enable = 'off';
            app.CtrlParamBrowseBtn.Enable = 'off';
            app.CtrlMakeDefaultCB.Enable = 'off';
            app.CtrlPreviewBtn.Enable = 'on';
            app.CtrlWriteBtn.Enable = 'off';
            app.CtrlWriteBtn.Text = 'Delete Controller (Write)';
            app.CtrlParamField.Value = '';
            app.CtrlMakeDefaultCB.Value = false;
        end

        function CtrlPreviewPushed(app, ~),    controllerAction(app, "preview"); end
        function CtrlWritePushed(app, ~),      controllerAction(app, "write");   end

        function CtrlParamBrowsePushed(app, ~)
            startDir = fullfile(app.ProjectRoot, 'Components', 'Controller', 'Model');
            if ~isfolder(startDir)
                startDir = fullfile(app.ProjectRoot, 'Components');
            end
            [f, ~] = uigetfile('*.m', 'Select Controller Param File', startDir);
            if ~isequal(f, 0)
                [~, baseName] = fileparts(f);
                app.CtrlParamField.Value = baseName;
            end
        end

        % ---- Step 3: Add/Delete Fidelity ----
        function FidConfigChanged(app, ~)
            if ~isempty(app.FidConfigDropDown.Value)
                populateTemplateKeys(app, app.FidConfigDropDown.Value, app.FidTemplateDropDown);
                app.FidComponentDropDown.Items = {'Select component...'};
                app.FidComponentDropDown.ItemsData = {''};
                app.FidModelDropDown.Items = {'Select model...'};
                app.FidModelDropDown.ItemsData = {''};
            end
            resetFidMode(app);
        end

        function FidTemplateChanged(app, ~)
            app.FidComponentDropDown.Items = {'Select component...'};
            app.FidComponentDropDown.ItemsData = {''};
            app.FidModelDropDown.Items = {'Select model...'};
            app.FidModelDropDown.ItemsData = {''};
            resetFidMode(app);
        end

        function FidAddPushed(app, ~)
            app.FidMode = "add";
            app.FidAddBtn.BackgroundColor = app.DARK_BLUE;
            app.FidAddBtn.FontColor = app.WHITE;
            app.FidDeleteBtn.BackgroundColor = app.DefaultNavBg;
            app.FidDeleteBtn.FontColor = app.DefaultNavFg;
            cfgVal  = string(app.FidConfigDropDown.Value);
            tmplVal = string(app.FidTemplateDropDown.Value);
            if strlength(cfgVal) > 0 && strlength(tmplVal) > 0
                populateComponentKeys(app, cfgVal, tmplVal, app.FidComponentDropDown);
            end
            app.FidModelDropDown.Items = {'Select model...'};
            app.FidModelDropDown.ItemsData = {''};
            app.FidComponentDropDown.Enable = 'on';
            app.FidModelDropDown.Enable = 'on';
            app.FidParamField.Enable = 'on';
            app.FidParamBrowseBtn.Enable = 'on';
            app.FidMakeDefaultCB.Enable = 'on';
            app.FidPreviewBtn.Enable = 'on';
            app.FidWriteBtn.Enable = 'off';
            app.FidWriteBtn.Text = 'Add Fidelity (Write)';
            app.FidParamField.Value = '';
            app.FidMakeDefaultCB.Value = false;
        end

        function FidDeletePushed(app, ~)
            app.FidMode = "delete";
            app.FidDeleteBtn.BackgroundColor = app.DARK_BLUE;
            app.FidDeleteBtn.FontColor = app.WHITE;
            app.FidAddBtn.BackgroundColor = app.DefaultNavBg;
            app.FidAddBtn.FontColor = app.DefaultNavFg;
            cfgVal  = string(app.FidConfigDropDown.Value);
            tmplVal = string(app.FidTemplateDropDown.Value);
            if strlength(cfgVal) > 0 && strlength(tmplVal) > 0
                populateComponentKeys(app, cfgVal, tmplVal, app.FidComponentDropDown);
            end
            app.FidModelDropDown.Items = {'Select model...'};
            app.FidModelDropDown.ItemsData = {''};
            app.FidComponentDropDown.Enable = 'on';
            app.FidModelDropDown.Enable = 'on';
            app.FidParamField.Enable = 'off';
            app.FidParamBrowseBtn.Enable = 'off';
            app.FidMakeDefaultCB.Enable = 'off';
            app.FidPreviewBtn.Enable = 'on';
            app.FidWriteBtn.Enable = 'off';
            app.FidWriteBtn.Text = 'Delete Fidelity (Write)';
            app.FidParamField.Value = '';
            app.FidMakeDefaultCB.Value = false;
        end

        function FidComponentChanged(app, ~)
            if ~isempty(app.FidConfigDropDown.Value) ...
                    && ~isempty(app.FidTemplateDropDown.Value) ...
                    && ~isempty(app.FidComponentDropDown.Value)
                populateModelChoices(app, app.FidConfigDropDown.Value, ...
                    app.FidTemplateDropDown.Value, ...
                    app.FidComponentDropDown.Value, app.FidModelDropDown, ...
                    app.FidMode);
            end
        end

        function FidParamBrowsePushed(app, ~)
            comp = string(app.FidComponentDropDown.Value);
            if strlength(comp) > 0
                startDir = fullfile(app.ProjectRoot, 'Components', comp, 'Model');
            else
                startDir = fullfile(app.ProjectRoot, 'Components');
            end
            [f, p] = uigetfile('*.m', 'Select Param File', startDir);
            if ~isequal(f, 0)
                fullPath = fullfile(p, f);
                if startsWith(fullPath, app.ProjectRoot)
                    app.FidParamField.Value = f;
                else
                    app.FidParamField.Value = fullPath;
                end
            end
        end

        function FidPreviewPushed(app, ~), fidelityAction(app, "preview"); end
        function FidWritePushed(app, ~),   fidelityAction(app, "write");   end

        % ---- Util: Update Config ----
        function UpdScanPushed(app, ~),  updateAction(app, "scan");  end
        function UpdApplyPushed(app, ~), updateAction(app, "apply"); end

        % ---- Util: Clean Config ----
        function ClnScanPushed(app, ~),  cleanAction(app, "scan");  end
        function ClnApplyPushed(app, ~), cleanAction(app, "apply"); end

        % ---- Util: Set System Params ----
        function SysConfigChanged(app, ~)
            if ~isempty(app.SysConfigDropDown.Value)
                populateTemplateKeys(app, app.SysConfigDropDown.Value, app.SysTemplateDropDown);
            end
        end

        function SysParamBrowsePushed(app, ~)
            startDir = fullfile(app.ProjectRoot, 'Script_Data');
            [f, ~] = uigetfile('*.m', 'Select System Parameter File', startDir);
            if ~isequal(f, 0)
                [~, baseName] = fileparts(f);
                app.SysParamField.Value = baseName;
            end
        end

        function SysPreviewPushed(app, ~), sysParamAction(app, "preview"); end
        function SysApplyPushed(app, ~),   sysParamAction(app, "apply");   end

        % ---- Preview panel ----
        function PreviewConfigChanged(app, ~)
            if ~isempty(app.PreviewConfigDropDown.Value)
                populateTemplateKeys(app, app.PreviewConfigDropDown.Value, app.PreviewTemplateDropDown);
            end
        end

        function PreviewTemplateChanged(app, ~), refreshPreview(app);      end
        function PreviewRefreshPushed(app, ~),   refreshPreview(app);      end
        function UndockBtnPushed(app, ~),        toggleDockPreview(app);   end
    end

    % ============================================================
    %  Component creation
    % ============================================================
    methods (Access = private)

        function createComponents(app)

            % ---- Figure ----
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1060 680];
            app.UIFigure.Name = 'BEV Config Author';
            app.UIFigure.Resize = 'on';

            % ---- Main 3-column grid ----
            app.GridLayout = uigridlayout(app.UIFigure, [1 3]);
            app.GridLayout.ColumnWidth = {220, '1x', 340};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];

            % ==== LEFT NAV ====
            app.NavPanel = uipanel(app.GridLayout);
            app.NavPanel.Layout.Row = 1; app.NavPanel.Layout.Column = 1;
            app.NavPanel.BorderType = 'none';

            app.NavGrid = uigridlayout(app.NavPanel, [13 1]);
            app.NavGrid.RowHeight = {36, 14, 14, 42, 42, 42, 42, 10, 14, 38, 38, '1x', 38};
            app.NavGrid.Padding = [8 8 8 8];
            app.NavGrid.RowSpacing = 2;

            app.AppTitleLabel = uilabel(app.NavGrid);
            app.AppTitleLabel.Layout.Row = 1; app.AppTitleLabel.Layout.Column = 1;
            app.AppTitleLabel.Text = 'BEV Config Author';
            app.AppTitleLabel.FontSize = 16; app.AppTitleLabel.FontWeight = 'bold';
            app.AppTitleLabel.FontColor = app.DARK_BLUE;

            app.WorkflowLabel = uilabel(app.NavGrid);
            app.WorkflowLabel.Layout.Row = 2; app.WorkflowLabel.Layout.Column = 1;
            app.WorkflowLabel.Text = 'AUTHORING WORKFLOW';
            app.WorkflowLabel.FontSize = 10; app.WorkflowLabel.FontColor = app.MUTED;

            % Nav buttons — workflow
            app.Nav1RegisterBtn = uibutton(app.NavGrid, 'push');
            app.Nav1RegisterBtn.Layout.Row = 4; app.Nav1RegisterBtn.Layout.Column = 1;
            app.Nav1RegisterBtn.Text = '1  Register Template';
            app.Nav1RegisterBtn.FontSize = 12;
            app.Nav1RegisterBtn.HorizontalAlignment = 'left';
            app.Nav1RegisterBtn.Tooltip = 'Scan a template and create a new config entry';
            app.Nav1RegisterBtn.ButtonPushedFcn = createCallbackFcn(app, @Nav1Pushed, true);

            app.Nav2ComponentBtn = uibutton(app.NavGrid, 'push');
            app.Nav2ComponentBtn.Layout.Row = 5; app.Nav2ComponentBtn.Layout.Column = 1;
            app.Nav2ComponentBtn.Text = '2  Add/Delete Controller';
            app.Nav2ComponentBtn.FontSize = 12;
            app.Nav2ComponentBtn.HorizontalAlignment = 'left';
            app.Nav2ComponentBtn.Tooltip = 'Add or update a controller model for a template';
            app.Nav2ComponentBtn.ButtonPushedFcn = createCallbackFcn(app, @Nav2Pushed, true);

            app.Nav3FidelityBtn = uibutton(app.NavGrid, 'push');
            app.Nav3FidelityBtn.Layout.Row = 6; app.Nav3FidelityBtn.Layout.Column = 1;
            app.Nav3FidelityBtn.Text = '3  Add/Delete Fidelity';
            app.Nav3FidelityBtn.FontSize = 12;
            app.Nav3FidelityBtn.HorizontalAlignment = 'left';
            app.Nav3FidelityBtn.Tooltip = 'Add or remove model fidelities';
            app.Nav3FidelityBtn.ButtonPushedFcn = createCallbackFcn(app, @Nav3Pushed, true);

            app.NavSysParamBtn = uibutton(app.NavGrid, 'push');
            app.NavSysParamBtn.Layout.Row = 7; app.NavSysParamBtn.Layout.Column = 1;
            app.NavSysParamBtn.Text = '4  Set System Parameter';
            app.NavSysParamBtn.FontSize = 12;
            app.NavSysParamBtn.HorizontalAlignment = 'left';
            app.NavSysParamBtn.Tooltip = 'Set the system parameter file for a template';
            app.NavSysParamBtn.ButtonPushedFcn = createCallbackFcn(app, @NavSysParamPushed, true);

            % Separator row (8) is just spacing

            app.UtilitiesLabel = uilabel(app.NavGrid);
            app.UtilitiesLabel.Layout.Row = 9; app.UtilitiesLabel.Layout.Column = 1;
            app.UtilitiesLabel.Text = 'UTILITIES';
            app.UtilitiesLabel.FontSize = 10; app.UtilitiesLabel.FontColor = app.MUTED;

            % Nav buttons — utilities
            app.NavUpdateBtn = uibutton(app.NavGrid, 'push');
            app.NavUpdateBtn.Layout.Row = 10; app.NavUpdateBtn.Layout.Column = 1;
            app.NavUpdateBtn.Text = [char(8635), '  Update Config'];
            app.NavUpdateBtn.FontSize = 12;
            app.NavUpdateBtn.HorizontalAlignment = 'left';
            app.NavUpdateBtn.Tooltip = 'Rescan a template and sync referencing configs';
            app.NavUpdateBtn.ButtonPushedFcn = createCallbackFcn(app, @NavUpdatePushed, true);

            app.NavCleanBtn = uibutton(app.NavGrid, 'push');
            app.NavCleanBtn.Layout.Row = 11; app.NavCleanBtn.Layout.Column = 1;
            app.NavCleanBtn.Text = [char(10005), '  Clean Config'];
            app.NavCleanBtn.FontSize = 12;
            app.NavCleanBtn.HorizontalAlignment = 'left';
            app.NavCleanBtn.Tooltip = 'Remove stale model entries from config';
            app.NavCleanBtn.ButtonPushedFcn = createCallbackFcn(app, @NavCleanPushed, true);

            % Launch Model Setup App button (bottom of nav)
            app.LaunchSetupAppBtn = uibutton(app.NavGrid, 'push');
            app.LaunchSetupAppBtn.Layout.Row = 13; app.LaunchSetupAppBtn.Layout.Column = 1;
            app.LaunchSetupAppBtn.Text = 'Launch Model Setup App';
            app.LaunchSetupAppBtn.FontSize = 11;
            app.LaunchSetupAppBtn.FontWeight = 'bold';
            app.LaunchSetupAppBtn.BackgroundColor = app.DARK_BLUE;
            app.LaunchSetupAppBtn.FontColor = app.WHITE;
            app.LaunchSetupAppBtn.Tooltip = 'Open BEV App with current config/template selection';
            app.LaunchSetupAppBtn.ButtonPushedFcn = createCallbackFcn(app, @LaunchSetupAppPushed, true);

            % Store nav buttons for styling
            app.NavButtons = {app.Nav1RegisterBtn, app.Nav2ComponentBtn, app.Nav3FidelityBtn, ...
                              app.NavSysParamBtn, app.NavUpdateBtn, app.NavCleanBtn};

            % ==== CENTER WORKSPACE ====
            app.CenterPanel = uipanel(app.GridLayout);
            app.CenterPanel.Layout.Row = 1; app.CenterPanel.Layout.Column = 2;
            app.CenterPanel.BorderType = 'none';

            app.CenterGrid = uigridlayout(app.CenterPanel, [3 1]);
            app.CenterGrid.RowHeight = {'fit', 18, '1x'};
            app.CenterGrid.Padding = [0 0 0 0];
            app.CenterGrid.RowSpacing = 0;

            % ---- Step panels (stacked, show one at a time) ----
            createRegisterPanel(app);
            createControllerPanel(app);
            createFidelityPanel(app);
            createUpdatePanel(app);
            createCleanPanel(app);
            createSysParamPanel(app);

            app.StepPanels = struct( ...
                'register',   app.RegisterPanel, ...
                'controller', app.ControllerPanel, ...
                'fidelity',   app.FidelityPanel, ...
                'update',     app.UpdatePanel, ...
                'clean',      app.CleanPanel, ...
                'sysparam',   app.SysParamPanel);

            % ---- Results area (shared) ----
            app.ResultsLabel = uilabel(app.CenterGrid);
            app.ResultsLabel.Layout.Row = 2; app.ResultsLabel.Layout.Column = 1;
            app.ResultsLabel.Text = '  Results';
            app.ResultsLabel.FontSize = 11; app.ResultsLabel.FontWeight = 'bold';
            app.ResultsLabel.FontColor = app.MUTED;

            app.ResultsArea = uitextarea(app.CenterGrid);
            app.ResultsArea.Layout.Row = 3; app.ResultsArea.Layout.Column = 1;
            app.ResultsArea.Editable = 'off';
            app.ResultsArea.FontName = 'Consolas';
            app.ResultsArea.FontSize = 11;
            app.ResultsArea.Value = {'Results will appear here after scanning...'};
            app.ResultsArea.FontColor = app.MUTED;

            % ==== RIGHT PREVIEW PANEL ====
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1; app.RightPanel.Layout.Column = 3;
            app.RightPanel.BorderType = 'none';

            app.RightGrid = uigridlayout(app.RightPanel, [7 2]);
            app.RightGrid.RowHeight = {26, 24, 24, 22, '1x', 4, 24};
            app.RightGrid.ColumnWidth = {'1x', 24};
            app.RightGrid.Padding = [0 0 0 0];
            app.RightGrid.RowSpacing = 4;

            % Custom title bar with undock button
            titleBar = uigridlayout(app.RightGrid, [1 2]);
            titleBar.Layout.Row = 1; titleBar.Layout.Column = [1 2];
            titleBar.ColumnWidth = {'1x', 24};
            titleBar.Padding = [10 0 2 0];
            titleBar.ColumnSpacing = 0;
            titleBar.BackgroundColor = app.BLUE;

            titleLbl = uilabel(titleBar);
            titleLbl.Layout.Row = 1; titleLbl.Layout.Column = 1;
            titleLbl.Text = 'Config Preview';
            titleLbl.FontWeight = 'bold';
            titleLbl.FontSize = 13;
            titleLbl.FontColor = app.WHITE;

            app.UndockBtn = uibutton(titleBar, 'push');
            app.UndockBtn.Layout.Row = 1; app.UndockBtn.Layout.Column = 2;
            app.UndockBtn.Text = char(8599);
            app.UndockBtn.FontSize = 14;
            app.UndockBtn.FontColor = app.WHITE;
            app.UndockBtn.BackgroundColor = app.BLUE;
            app.UndockBtn.Tooltip = 'Undock preview to separate window';
            app.UndockBtn.ButtonPushedFcn = createCallbackFcn(app, @UndockBtnPushed, true);

            % Config / Template selectors
            cfgRow = uigridlayout(app.RightGrid, [1 2]);
            cfgRow.Layout.Row = 2; cfgRow.Layout.Column = [1 2];
            cfgRow.ColumnWidth = {60, '1x'};
            cfgRow.Padding = [8 0 8 0]; cfgRow.ColumnSpacing = 4;

            app.PreviewConfigLabel = uilabel(cfgRow);
            app.PreviewConfigLabel.Layout.Row = 1; app.PreviewConfigLabel.Layout.Column = 1;
            app.PreviewConfigLabel.Text = 'Config';
            app.PreviewConfigLabel.FontSize = 11; app.PreviewConfigLabel.FontWeight = 'bold';
            app.PreviewConfigLabel.HorizontalAlignment = 'right';

            app.PreviewConfigDropDown = uidropdown(cfgRow);
            app.PreviewConfigDropDown.Layout.Row = 1; app.PreviewConfigDropDown.Layout.Column = 2;
            app.PreviewConfigDropDown.Items = {'Select config...'};
            app.PreviewConfigDropDown.ItemsData = {''};
            app.PreviewConfigDropDown.Tooltip = 'Select config to preview';
            app.PreviewConfigDropDown.ValueChangedFcn = createCallbackFcn(app, @PreviewConfigChanged, true);

            tmplRow = uigridlayout(app.RightGrid, [1 2]);
            tmplRow.Layout.Row = 3; tmplRow.Layout.Column = [1 2];
            tmplRow.ColumnWidth = {60, '1x'};
            tmplRow.Padding = [8 0 8 0]; tmplRow.ColumnSpacing = 4;

            app.PreviewTemplateLabel = uilabel(tmplRow);
            app.PreviewTemplateLabel.Layout.Row = 1; app.PreviewTemplateLabel.Layout.Column = 1;
            app.PreviewTemplateLabel.Text = 'Template';
            app.PreviewTemplateLabel.FontSize = 11; app.PreviewTemplateLabel.FontWeight = 'bold';
            app.PreviewTemplateLabel.HorizontalAlignment = 'right';

            app.PreviewTemplateDropDown = uidropdown(tmplRow);
            app.PreviewTemplateDropDown.Layout.Row = 1; app.PreviewTemplateDropDown.Layout.Column = 2;
            app.PreviewTemplateDropDown.Items = {'Select template...'};
            app.PreviewTemplateDropDown.ItemsData = {''};
            app.PreviewTemplateDropDown.Tooltip = 'Select template to preview';
            app.PreviewTemplateDropDown.ValueChangedFcn = createCallbackFcn(app, @PreviewTemplateChanged, true);

            app.PreviewRefreshBtn = uibutton(app.RightGrid, 'push');
            app.PreviewRefreshBtn.Layout.Row = 4; app.PreviewRefreshBtn.Layout.Column = [1 2];
            app.PreviewRefreshBtn.Text = [char(8635), ' Refresh'];
            app.PreviewRefreshBtn.FontSize = 10;
            app.PreviewRefreshBtn.Tooltip = 'Reload config from disk';
            app.PreviewRefreshBtn.ButtonPushedFcn = createCallbackFcn(app, @PreviewRefreshPushed, true);

            app.PreviewHTML = uihtml(app.RightGrid);
            app.PreviewHTML.Layout.Row = 5; app.PreviewHTML.Layout.Column = [1 2];
            app.PreviewHTML.HTMLSource = '<html><body style="font-family:Segoe UI;font-size:12px;color:#999;text-align:center;padding:40px;">Select a config and template to preview</body></html>';

            app.ValidationLamp = uilamp(app.RightGrid);
            app.ValidationLamp.Layout.Row = 7; app.ValidationLamp.Layout.Column = 1;
            app.ValidationLamp.Color = [0.8 0.8 0.8];

            app.ValidationLabel = uilabel(app.RightGrid);
            app.ValidationLabel.Layout.Row = 7; app.ValidationLabel.Layout.Column = 2;
            app.ValidationLabel.Text = 'No config loaded';
            app.ValidationLabel.FontSize = 11;
            app.ValidationLabel.FontColor = app.MUTED;

            % ---- Show figure ----
            app.UIFigure.Visible = 'on';
        end

        % ============================================================
        %  Step panel builders
        % ============================================================

        function createRegisterPanel(app)
            app.RegisterPanel = uipanel(app.CenterGrid);
            app.RegisterPanel.Layout.Row = 1; app.RegisterPanel.Layout.Column = 1;
            app.RegisterPanel.Title = '1  Register Template';
            app.RegisterPanel.FontWeight = 'bold';
            app.RegisterPanel.ForegroundColor = app.WHITE;
            app.RegisterPanel.BackgroundColor = app.BLUE;
            app.RegisterPanel.BorderWidth = 3;

            g = uigridlayout(app.RegisterPanel, [5 3]);
            g.RowHeight = {28, 28, 28, 28, 36};
            g.ColumnWidth = {110, '1x', 80};
            g.Padding = [12 12 12 8];
            g.RowSpacing = 6;

            app.RegTemplateLabel = uilabel(g);
            app.RegTemplateLabel.Layout.Row = 1; app.RegTemplateLabel.Layout.Column = 1;
            app.RegTemplateLabel.Text = 'Template';
            app.RegTemplateLabel.HorizontalAlignment = 'right'; app.RegTemplateLabel.FontWeight = 'bold';

            app.RegTemplateDropDown = uidropdown(g);
            app.RegTemplateDropDown.Layout.Row = 1; app.RegTemplateDropDown.Layout.Column = [2 3];
            app.RegTemplateDropDown.Items = {'Select template...'};
            app.RegTemplateDropDown.ItemsData = {''};
            app.RegTemplateDropDown.Tooltip = 'Vehicle template from Model/VehicleTemplate/';

            app.RegDescLabel = uilabel(g);
            app.RegDescLabel.Layout.Row = 2; app.RegDescLabel.Layout.Column = 1;
            app.RegDescLabel.Text = 'Description';
            app.RegDescLabel.HorizontalAlignment = 'right'; app.RegDescLabel.FontWeight = 'bold';

            app.RegDescField = uieditfield(g);
            app.RegDescField.Layout.Row = 2; app.RegDescField.Layout.Column = [2 3];
            app.RegDescField.Tooltip = 'Short description of this vehicle template';

            app.RegConfigLabel = uilabel(g);
            app.RegConfigLabel.Layout.Row = 3; app.RegConfigLabel.Layout.Column = 1;
            app.RegConfigLabel.Text = 'Target Config';
            app.RegConfigLabel.HorizontalAlignment = 'right'; app.RegConfigLabel.FontWeight = 'bold';

            app.RegConfigDropDown = uidropdown(g);
            app.RegConfigDropDown.Layout.Row = 3; app.RegConfigDropDown.Layout.Column = 2;
            app.RegConfigDropDown.Items = {'Select config...'};
            app.RegConfigDropDown.ItemsData = {''};
            app.RegConfigDropDown.Tooltip = 'JSON config file to write the entry into';

            app.RegConfigBrowseBtn = uibutton(g, 'push');
            app.RegConfigBrowseBtn.Layout.Row = 3; app.RegConfigBrowseBtn.Layout.Column = 3;
            app.RegConfigBrowseBtn.Text = 'New...';
            app.RegConfigBrowseBtn.Tooltip = 'Create a new empty JSON config file';
            app.RegConfigBrowseBtn.ButtonPushedFcn = createCallbackFcn(app, @RegNewConfigPushed, true);

            cbGrid = uigridlayout(g, [1 2]);
            cbGrid.Layout.Row = 4; cbGrid.Layout.Column = [2 3];
            cbGrid.Padding = [0 0 0 0]; cbGrid.ColumnWidth = {'1x','1x'};

            app.RegAllowUnmappedCB = uicheckbox(cbGrid);
            app.RegAllowUnmappedCB.Layout.Row = 1; app.RegAllowUnmappedCB.Layout.Column = 1;
            app.RegAllowUnmappedCB.Text = 'Allow unmapped';
            app.RegAllowUnmappedCB.Tooltip = 'Skip SSR blocks not found in Components/';

            app.RegOverwriteCB = uicheckbox(cbGrid);
            app.RegOverwriteCB.Layout.Row = 1; app.RegOverwriteCB.Layout.Column = 2;
            app.RegOverwriteCB.Text = 'Overwrite existing';
            app.RegOverwriteCB.Tooltip = 'Replace existing template entry in the config';

            % Action buttons
            actGrid = uigridlayout(g, [1 4]);
            actGrid.Layout.Row = 5; actGrid.Layout.Column = [1 3];
            actGrid.Padding = [0 0 0 0]; actGrid.ColumnWidth = {120, 120, '1x', 20};

            app.RegScanBtn = uibutton(actGrid, 'push');
            app.RegScanBtn.Layout.Row = 1; app.RegScanBtn.Layout.Column = 1;
            app.RegScanBtn.Text = 'Scan (Preview)';
            app.RegScanBtn.Tooltip = 'Dry-run scan — no files written';
            app.RegScanBtn.ButtonPushedFcn = createCallbackFcn(app, @RegScanPushed, true);

            app.RegWriteBtn = uibutton(actGrid, 'push');
            app.RegWriteBtn.Layout.Row = 1; app.RegWriteBtn.Layout.Column = 2;
            app.RegWriteBtn.Text = 'Register (Write)';
            app.RegWriteBtn.BackgroundColor = app.DARK_BLUE;
            app.RegWriteBtn.FontColor = app.WHITE;
            app.RegWriteBtn.FontWeight = 'bold';
            app.RegWriteBtn.Enable = 'off';
            app.RegWriteBtn.Tooltip = 'Write template to config file';
            app.RegWriteBtn.ButtonPushedFcn = createCallbackFcn(app, @RegWritePushed, true);

            app.RegLamp = uilamp(actGrid);
            app.RegLamp.Layout.Row = 1; app.RegLamp.Layout.Column = 4;
            app.RegLamp.Color = [0.8 0.8 0.8];
        end

        function createControllerPanel(app)
            app.ControllerPanel = uipanel(app.CenterGrid);
            app.ControllerPanel.Layout.Row = 1; app.ControllerPanel.Layout.Column = 1;
            app.ControllerPanel.Title = '2  Add/Delete Controller';
            app.ControllerPanel.FontWeight = 'bold';
            app.ControllerPanel.ForegroundColor = app.WHITE;
            app.ControllerPanel.BackgroundColor = app.BLUE;
            app.ControllerPanel.BorderWidth = 3;
            app.ControllerPanel.Visible = 'off';

            g = uigridlayout(app.ControllerPanel, [7 3]);
            g.RowHeight = {28, 28, 28, 28, 28, 28, 36};
            g.ColumnWidth = {110, '1x', 80};
            g.Padding = [12 12 12 8]; g.RowSpacing = 6;

            app.CtrlConfigLabel = uilabel(g);
            app.CtrlConfigLabel.Layout.Row = 1; app.CtrlConfigLabel.Layout.Column = 1;
            app.CtrlConfigLabel.Text = 'Config File';
            app.CtrlConfigLabel.HorizontalAlignment = 'right'; app.CtrlConfigLabel.FontWeight = 'bold';

            app.CtrlConfigDropDown = uidropdown(g);
            app.CtrlConfigDropDown.Layout.Row = 1; app.CtrlConfigDropDown.Layout.Column = [2 3];
            app.CtrlConfigDropDown.Tooltip = 'Config file containing the template';
            app.CtrlConfigDropDown.ValueChangedFcn = createCallbackFcn(app, @CtrlConfigChanged, true);

            app.CtrlTemplateLabel = uilabel(g);
            app.CtrlTemplateLabel.Layout.Row = 2; app.CtrlTemplateLabel.Layout.Column = 1;
            app.CtrlTemplateLabel.Text = 'Template';
            app.CtrlTemplateLabel.HorizontalAlignment = 'right'; app.CtrlTemplateLabel.FontWeight = 'bold';

            app.CtrlTemplateDropDown = uidropdown(g);
            app.CtrlTemplateDropDown.Layout.Row = 2; app.CtrlTemplateDropDown.Layout.Column = [2 3];
            app.CtrlTemplateDropDown.Items = {'Select template...'};
            app.CtrlTemplateDropDown.ItemsData = {''};
            app.CtrlTemplateDropDown.Tooltip = 'Template to add/delete the controller for';

            % Action toggle: Add / Delete
            actionLabel = uilabel(g);
            actionLabel.Layout.Row = 3; actionLabel.Layout.Column = 1;
            actionLabel.Text = 'Action';
            actionLabel.HorizontalAlignment = 'right'; actionLabel.FontWeight = 'bold';

            actionGrid = uigridlayout(g, [1 2]);
            actionGrid.Layout.Row = 3; actionGrid.Layout.Column = [2 3];
            actionGrid.Padding = [0 0 0 0]; actionGrid.ColumnWidth = {'1x', '1x'};
            actionGrid.ColumnSpacing = 6;

            app.CtrlAddBtn = uibutton(actionGrid, 'push');
            app.CtrlAddBtn.Layout.Row = 1; app.CtrlAddBtn.Layout.Column = 1;
            app.CtrlAddBtn.Text = 'Add';
            app.CtrlAddBtn.Tooltip = 'Add a controller model to the template';
            app.CtrlAddBtn.ButtonPushedFcn = createCallbackFcn(app, @CtrlAddPushed, true);

            app.CtrlDeleteBtn = uibutton(actionGrid, 'push');
            app.CtrlDeleteBtn.Layout.Row = 1; app.CtrlDeleteBtn.Layout.Column = 2;
            app.CtrlDeleteBtn.Text = 'Delete';
            app.CtrlDeleteBtn.Tooltip = 'Delete a controller model from the template';
            app.CtrlDeleteBtn.ButtonPushedFcn = createCallbackFcn(app, @CtrlDeletePushed, true);

            app.CtrlModelLabel = uilabel(g);
            app.CtrlModelLabel.Layout.Row = 4; app.CtrlModelLabel.Layout.Column = 1;
            app.CtrlModelLabel.Text = 'Controller';
            app.CtrlModelLabel.HorizontalAlignment = 'right'; app.CtrlModelLabel.FontWeight = 'bold';

            app.CtrlModelDropDown = uidropdown(g);
            app.CtrlModelDropDown.Layout.Row = 4; app.CtrlModelDropDown.Layout.Column = [2 3];
            app.CtrlModelDropDown.Items = {'Select controller...'};
            app.CtrlModelDropDown.ItemsData = {''};
            app.CtrlModelDropDown.Tooltip = 'Controller model';
            app.CtrlModelDropDown.Enable = 'off';

            app.CtrlParamLabel = uilabel(g);
            app.CtrlParamLabel.Layout.Row = 5; app.CtrlParamLabel.Layout.Column = 1;
            app.CtrlParamLabel.Text = 'Param File';
            app.CtrlParamLabel.HorizontalAlignment = 'right';
            app.CtrlParamLabel.FontColor = app.MUTED;

            app.CtrlParamField = uieditfield(g);
            app.CtrlParamField.Layout.Row = 5; app.CtrlParamField.Layout.Column = 2;
            app.CtrlParamField.Editable = 'off';
            app.CtrlParamField.Tooltip = 'Optional — controller parameter .m file';
            app.CtrlParamField.Enable = 'off';

            app.CtrlParamBrowseBtn = uibutton(g, 'push');
            app.CtrlParamBrowseBtn.Layout.Row = 5; app.CtrlParamBrowseBtn.Layout.Column = 3;
            app.CtrlParamBrowseBtn.Text = 'Browse...';
            app.CtrlParamBrowseBtn.Tooltip = 'Select from Components/Controller/Model/';
            app.CtrlParamBrowseBtn.Enable = 'off';
            app.CtrlParamBrowseBtn.ButtonPushedFcn = createCallbackFcn(app, @CtrlParamBrowsePushed, true);

            app.CtrlMakeDefaultCB = uicheckbox(g);
            app.CtrlMakeDefaultCB.Layout.Row = 6; app.CtrlMakeDefaultCB.Layout.Column = [2 3];
            app.CtrlMakeDefaultCB.Text = 'Make default (first in list)';
            app.CtrlMakeDefaultCB.Tooltip = 'Place this controller first in the Controls.Models list';
            app.CtrlMakeDefaultCB.Enable = 'off';

            actGrid = uigridlayout(g, [1 4]);
            actGrid.Layout.Row = 7; actGrid.Layout.Column = [1 3];
            actGrid.Padding = [0 0 0 0]; actGrid.ColumnWidth = {100, 160, '1x', 20};

            app.CtrlPreviewBtn = uibutton(actGrid, 'push');
            app.CtrlPreviewBtn.Layout.Row = 1; app.CtrlPreviewBtn.Layout.Column = 1;
            app.CtrlPreviewBtn.Text = 'Preview';
            app.CtrlPreviewBtn.Tooltip = 'Dry-run — preview changes';
            app.CtrlPreviewBtn.Enable = 'off';
            app.CtrlPreviewBtn.ButtonPushedFcn = createCallbackFcn(app, @CtrlPreviewPushed, true);

            app.CtrlWriteBtn = uibutton(actGrid, 'push');
            app.CtrlWriteBtn.Layout.Row = 1; app.CtrlWriteBtn.Layout.Column = 2;
            app.CtrlWriteBtn.Text = 'Add Controller (Write)';
            app.CtrlWriteBtn.BackgroundColor = app.DARK_BLUE;
            app.CtrlWriteBtn.FontColor = app.WHITE; app.CtrlWriteBtn.FontWeight = 'bold';
            app.CtrlWriteBtn.Enable = 'off';
            app.CtrlWriteBtn.ButtonPushedFcn = createCallbackFcn(app, @CtrlWritePushed, true);

            app.CtrlLamp = uilamp(actGrid);
            app.CtrlLamp.Layout.Row = 1; app.CtrlLamp.Layout.Column = 4;
            app.CtrlLamp.Color = [0.8 0.8 0.8];
        end

        function createFidelityPanel(app)
            app.FidelityPanel = uipanel(app.CenterGrid);
            app.FidelityPanel.Layout.Row = 1; app.FidelityPanel.Layout.Column = 1;
            app.FidelityPanel.Title = '3  Add/Delete Fidelity';
            app.FidelityPanel.FontWeight = 'bold';
            app.FidelityPanel.ForegroundColor = app.WHITE;
            app.FidelityPanel.BackgroundColor = app.BLUE;
            app.FidelityPanel.BorderWidth = 3;
            app.FidelityPanel.Visible = 'off';

            g = uigridlayout(app.FidelityPanel, [8 3]);
            g.RowHeight = {28, 28, 28, 28, 28, 28, 28, 36};
            g.ColumnWidth = {110, '1x', 80};
            g.Padding = [12 12 12 8]; g.RowSpacing = 6;

            app.FidConfigLabel = uilabel(g);
            app.FidConfigLabel.Layout.Row = 1; app.FidConfigLabel.Layout.Column = 1;
            app.FidConfigLabel.Text = 'Config File';
            app.FidConfigLabel.HorizontalAlignment = 'right'; app.FidConfigLabel.FontWeight = 'bold';

            app.FidConfigDropDown = uidropdown(g);
            app.FidConfigDropDown.Layout.Row = 1; app.FidConfigDropDown.Layout.Column = [2 3];
            app.FidConfigDropDown.Tooltip = 'Config file to edit';
            app.FidConfigDropDown.ValueChangedFcn = createCallbackFcn(app, @FidConfigChanged, true);

            app.FidTemplateLabel = uilabel(g);
            app.FidTemplateLabel.Layout.Row = 2; app.FidTemplateLabel.Layout.Column = 1;
            app.FidTemplateLabel.Text = 'Template';
            app.FidTemplateLabel.HorizontalAlignment = 'right'; app.FidTemplateLabel.FontWeight = 'bold';

            app.FidTemplateDropDown = uidropdown(g);
            app.FidTemplateDropDown.Layout.Row = 2; app.FidTemplateDropDown.Layout.Column = [2 3];
            app.FidTemplateDropDown.Items = {'Select template...'};
            app.FidTemplateDropDown.ItemsData = {''};
            app.FidTemplateDropDown.ValueChangedFcn = createCallbackFcn(app, @FidTemplateChanged, true);

            % Action toggle: Add / Delete
            actionLabel = uilabel(g);
            actionLabel.Layout.Row = 3; actionLabel.Layout.Column = 1;
            actionLabel.Text = 'Action';
            actionLabel.HorizontalAlignment = 'right'; actionLabel.FontWeight = 'bold';

            actionGrid = uigridlayout(g, [1 2]);
            actionGrid.Layout.Row = 3; actionGrid.Layout.Column = [2 3];
            actionGrid.Padding = [0 0 0 0]; actionGrid.ColumnWidth = {'1x', '1x'};
            actionGrid.ColumnSpacing = 6;

            app.FidAddBtn = uibutton(actionGrid, 'push');
            app.FidAddBtn.Layout.Row = 1; app.FidAddBtn.Layout.Column = 1;
            app.FidAddBtn.Text = 'Add';
            app.FidAddBtn.Tooltip = 'Add a model fidelity to the component';
            app.FidAddBtn.ButtonPushedFcn = createCallbackFcn(app, @FidAddPushed, true);

            app.FidDeleteBtn = uibutton(actionGrid, 'push');
            app.FidDeleteBtn.Layout.Row = 1; app.FidDeleteBtn.Layout.Column = 2;
            app.FidDeleteBtn.Text = 'Delete';
            app.FidDeleteBtn.Tooltip = 'Delete a model fidelity from the component';
            app.FidDeleteBtn.ButtonPushedFcn = createCallbackFcn(app, @FidDeletePushed, true);

            app.FidComponentLabel = uilabel(g);
            app.FidComponentLabel.Layout.Row = 4; app.FidComponentLabel.Layout.Column = 1;
            app.FidComponentLabel.Text = 'Component';
            app.FidComponentLabel.HorizontalAlignment = 'right'; app.FidComponentLabel.FontWeight = 'bold';

            app.FidComponentDropDown = uidropdown(g);
            app.FidComponentDropDown.Layout.Row = 4; app.FidComponentDropDown.Layout.Column = [2 3];
            app.FidComponentDropDown.Items = {'Select component...'};
            app.FidComponentDropDown.ItemsData = {''};
            app.FidComponentDropDown.Enable = 'off';
            app.FidComponentDropDown.ValueChangedFcn = createCallbackFcn(app, @FidComponentChanged, true);

            app.FidModelLabel = uilabel(g);
            app.FidModelLabel.Layout.Row = 5; app.FidModelLabel.Layout.Column = 1;
            app.FidModelLabel.Text = 'Model';
            app.FidModelLabel.HorizontalAlignment = 'right'; app.FidModelLabel.FontWeight = 'bold';

            app.FidModelDropDown = uidropdown(g);
            app.FidModelDropDown.Layout.Row = 5; app.FidModelDropDown.Layout.Column = [2 3];
            app.FidModelDropDown.Items = {'Select model...'};
            app.FidModelDropDown.ItemsData = {''};
            app.FidModelDropDown.Enable = 'off';

            app.FidParamLabel = uilabel(g);
            app.FidParamLabel.Layout.Row = 6; app.FidParamLabel.Layout.Column = 1;
            app.FidParamLabel.Text = 'Param File';
            app.FidParamLabel.HorizontalAlignment = 'right';
            app.FidParamLabel.FontColor = app.MUTED;

            app.FidParamField = uieditfield(g);
            app.FidParamField.Layout.Row = 6; app.FidParamField.Layout.Column = 2;
            app.FidParamField.Tooltip = 'Optional — leave blank for auto-detection';
            app.FidParamField.Enable = 'off';

            app.FidParamBrowseBtn = uibutton(g, 'push');
            app.FidParamBrowseBtn.Layout.Row = 6; app.FidParamBrowseBtn.Layout.Column = 3;
            app.FidParamBrowseBtn.Text = 'Browse...';
            app.FidParamBrowseBtn.Enable = 'off';
            app.FidParamBrowseBtn.ButtonPushedFcn = createCallbackFcn(app, @FidParamBrowsePushed, true);

            app.FidMakeDefaultCB = uicheckbox(g);
            app.FidMakeDefaultCB.Layout.Row = 7; app.FidMakeDefaultCB.Layout.Column = [2 3];
            app.FidMakeDefaultCB.Text = 'Make default (first in list)';
            app.FidMakeDefaultCB.Tooltip = 'Place this model first in the Models list';
            app.FidMakeDefaultCB.Enable = 'off';

            actGrid = uigridlayout(g, [1 4]);
            actGrid.Layout.Row = 8; actGrid.Layout.Column = [1 3];
            actGrid.Padding = [0 0 0 0]; actGrid.ColumnWidth = {100, 160, '1x', 20};

            app.FidPreviewBtn = uibutton(actGrid, 'push');
            app.FidPreviewBtn.Layout.Row = 1; app.FidPreviewBtn.Layout.Column = 1;
            app.FidPreviewBtn.Text = 'Preview';
            app.FidPreviewBtn.Tooltip = 'Dry-run — preview changes';
            app.FidPreviewBtn.Enable = 'off';
            app.FidPreviewBtn.ButtonPushedFcn = createCallbackFcn(app, @FidPreviewPushed, true);

            app.FidWriteBtn = uibutton(actGrid, 'push');
            app.FidWriteBtn.Layout.Row = 1; app.FidWriteBtn.Layout.Column = 2;
            app.FidWriteBtn.Text = 'Add Fidelity (Write)';
            app.FidWriteBtn.BackgroundColor = app.DARK_BLUE;
            app.FidWriteBtn.FontColor = app.WHITE; app.FidWriteBtn.FontWeight = 'bold';
            app.FidWriteBtn.Enable = 'off';
            app.FidWriteBtn.ButtonPushedFcn = createCallbackFcn(app, @FidWritePushed, true);

            app.FidLamp = uilamp(actGrid);
            app.FidLamp.Layout.Row = 1; app.FidLamp.Layout.Column = 4;
            app.FidLamp.Color = [0.8 0.8 0.8];
        end

        function createUpdatePanel(app)
            app.UpdatePanel = uipanel(app.CenterGrid);
            app.UpdatePanel.Layout.Row = 1; app.UpdatePanel.Layout.Column = 1;
            app.UpdatePanel.Title = [char(8635), '  Update Config'];
            app.UpdatePanel.FontWeight = 'bold';
            app.UpdatePanel.ForegroundColor = app.WHITE;
            app.UpdatePanel.BackgroundColor = app.BLUE;
            app.UpdatePanel.BorderWidth = 3;
            app.UpdatePanel.Visible = 'off';

            g = uigridlayout(app.UpdatePanel, [3 2]);
            g.RowHeight = {28, 40, 36};
            g.ColumnWidth = {110, '1x'};
            g.Padding = [12 12 12 8]; g.RowSpacing = 6;

            app.UpdTemplateLabel = uilabel(g);
            app.UpdTemplateLabel.Layout.Row = 1; app.UpdTemplateLabel.Layout.Column = 1;
            app.UpdTemplateLabel.Text = 'Template';
            app.UpdTemplateLabel.HorizontalAlignment = 'right'; app.UpdTemplateLabel.FontWeight = 'bold';

            app.UpdTemplateDropDown = uidropdown(g);
            app.UpdTemplateDropDown.Layout.Row = 1; app.UpdTemplateDropDown.Layout.Column = 2;
            app.UpdTemplateDropDown.Tooltip = 'Template to rescan and sync configs for';

            app.UpdHintLabel = uilabel(g);
            app.UpdHintLabel.Layout.Row = 2; app.UpdHintLabel.Layout.Column = [1 2];
            app.UpdHintLabel.Text = 'Rescans template for SSR changes and diffs against all referencing configs. User-added fidelities are preserved.';
            app.UpdHintLabel.FontSize = 11; app.UpdHintLabel.FontColor = app.MUTED;
            app.UpdHintLabel.WordWrap = 'on';

            actGrid = uigridlayout(g, [1 4]);
            actGrid.Layout.Row = 3; actGrid.Layout.Column = [1 2];
            actGrid.Padding = [0 0 0 0]; actGrid.ColumnWidth = {140, 120, '1x', 20};

            app.UpdScanBtn = uibutton(actGrid, 'push');
            app.UpdScanBtn.Layout.Row = 1; app.UpdScanBtn.Layout.Column = 1;
            app.UpdScanBtn.Text = 'Scan Changes';
            app.UpdScanBtn.Tooltip = 'Preview what would change';
            app.UpdScanBtn.ButtonPushedFcn = createCallbackFcn(app, @UpdScanPushed, true);

            app.UpdApplyBtn = uibutton(actGrid, 'push');
            app.UpdApplyBtn.Layout.Row = 1; app.UpdApplyBtn.Layout.Column = 2;
            app.UpdApplyBtn.Text = 'Apply All (Write)';
            app.UpdApplyBtn.BackgroundColor = app.DARK_BLUE;
            app.UpdApplyBtn.FontColor = app.WHITE; app.UpdApplyBtn.FontWeight = 'bold';
            app.UpdApplyBtn.Enable = 'off';
            app.UpdApplyBtn.ButtonPushedFcn = createCallbackFcn(app, @UpdApplyPushed, true);

            app.UpdLamp = uilamp(actGrid);
            app.UpdLamp.Layout.Row = 1; app.UpdLamp.Layout.Column = 4;
            app.UpdLamp.Color = [0.8 0.8 0.8];
        end

        function createCleanPanel(app)
            app.CleanPanel = uipanel(app.CenterGrid);
            app.CleanPanel.Layout.Row = 1; app.CleanPanel.Layout.Column = 1;
            app.CleanPanel.Title = [char(10005), '  Clean Config'];
            app.CleanPanel.FontWeight = 'bold';
            app.CleanPanel.ForegroundColor = app.WHITE;
            app.CleanPanel.BackgroundColor = app.BLUE;
            app.CleanPanel.BorderWidth = 3;
            app.CleanPanel.Visible = 'off';

            g = uigridlayout(app.CleanPanel, [3 3]);
            g.RowHeight = {28, 40, 36};
            g.ColumnWidth = {110, '1x', 80};
            g.Padding = [12 12 12 8]; g.RowSpacing = 6;

            app.ClnConfigLabel = uilabel(g);
            app.ClnConfigLabel.Layout.Row = 1; app.ClnConfigLabel.Layout.Column = 1;
            app.ClnConfigLabel.Text = 'Config File';
            app.ClnConfigLabel.HorizontalAlignment = 'right'; app.ClnConfigLabel.FontWeight = 'bold';

            app.ClnConfigDropDown = uidropdown(g);
            app.ClnConfigDropDown.Layout.Row = 1; app.ClnConfigDropDown.Layout.Column = [2 3];
            app.ClnConfigDropDown.Tooltip = 'Config file to scan for stale entries';

            app.ClnHintLabel = uilabel(g);
            app.ClnHintLabel.Layout.Row = 2; app.ClnHintLabel.Layout.Column = [2 3];
            app.ClnHintLabel.Text = 'Checks each model against Components/*/Model/ on disk. Removes stale entries and their ParamMap/Selections.';
            app.ClnHintLabel.FontSize = 11; app.ClnHintLabel.FontColor = app.MUTED;
            app.ClnHintLabel.WordWrap = 'on';

            actGrid = uigridlayout(g, [1 4]);
            actGrid.Layout.Row = 3; actGrid.Layout.Column = [1 3];
            actGrid.Padding = [0 0 0 0]; actGrid.ColumnWidth = {120, 110, '1x', 20};

            app.ClnScanBtn = uibutton(actGrid, 'push');
            app.ClnScanBtn.Layout.Row = 1; app.ClnScanBtn.Layout.Column = 1;
            app.ClnScanBtn.Text = 'Scan for Stale';
            app.ClnScanBtn.Tooltip = 'List stale entries (no files modified)';
            app.ClnScanBtn.ButtonPushedFcn = createCallbackFcn(app, @ClnScanPushed, true);

            app.ClnApplyBtn = uibutton(actGrid, 'push');
            app.ClnApplyBtn.Layout.Row = 1; app.ClnApplyBtn.Layout.Column = 2;
            app.ClnApplyBtn.Text = 'Clean (Write)';
            app.ClnApplyBtn.BackgroundColor = app.DARK_BLUE;
            app.ClnApplyBtn.FontColor = app.WHITE; app.ClnApplyBtn.FontWeight = 'bold';
            app.ClnApplyBtn.Enable = 'off';
            app.ClnApplyBtn.ButtonPushedFcn = createCallbackFcn(app, @ClnApplyPushed, true);

            app.ClnLamp = uilamp(actGrid);
            app.ClnLamp.Layout.Row = 1; app.ClnLamp.Layout.Column = 4;
            app.ClnLamp.Color = [0.8 0.8 0.8];
        end

        function createSysParamPanel(app)
            app.SysParamPanel = uipanel(app.CenterGrid);
            app.SysParamPanel.Layout.Row = 1; app.SysParamPanel.Layout.Column = 1;
            app.SysParamPanel.Title = '4  Set System Parameter';
            app.SysParamPanel.FontWeight = 'bold';
            app.SysParamPanel.ForegroundColor = app.WHITE;
            app.SysParamPanel.BackgroundColor = app.BLUE;
            app.SysParamPanel.BorderWidth = 3;
            app.SysParamPanel.Visible = 'off';

            g = uigridlayout(app.SysParamPanel, [4 3]);
            g.RowHeight = {28, 28, 28, 36};
            g.ColumnWidth = {110, '1x', 80};
            g.Padding = [12 12 12 8]; g.RowSpacing = 6;

            app.SysConfigLabel = uilabel(g);
            app.SysConfigLabel.Layout.Row = 1; app.SysConfigLabel.Layout.Column = 1;
            app.SysConfigLabel.Text = 'Config File';
            app.SysConfigLabel.HorizontalAlignment = 'right'; app.SysConfigLabel.FontWeight = 'bold';

            app.SysConfigDropDown = uidropdown(g);
            app.SysConfigDropDown.Layout.Row = 1; app.SysConfigDropDown.Layout.Column = [2 3];
            app.SysConfigDropDown.Tooltip = 'Config file containing the template';
            app.SysConfigDropDown.ValueChangedFcn = createCallbackFcn(app, @SysConfigChanged, true);

            app.SysTemplateLabel = uilabel(g);
            app.SysTemplateLabel.Layout.Row = 2; app.SysTemplateLabel.Layout.Column = 1;
            app.SysTemplateLabel.Text = 'Template';
            app.SysTemplateLabel.HorizontalAlignment = 'right'; app.SysTemplateLabel.FontWeight = 'bold';

            app.SysTemplateDropDown = uidropdown(g);
            app.SysTemplateDropDown.Layout.Row = 2; app.SysTemplateDropDown.Layout.Column = [2 3];
            app.SysTemplateDropDown.Items = {'Select template...'};
            app.SysTemplateDropDown.ItemsData = {''};
            app.SysTemplateDropDown.Tooltip = 'Template to set system parameter for';

            app.SysParamLabel = uilabel(g);
            app.SysParamLabel.Layout.Row = 3; app.SysParamLabel.Layout.Column = 1;
            app.SysParamLabel.Text = 'System Param';
            app.SysParamLabel.HorizontalAlignment = 'right'; app.SysParamLabel.FontWeight = 'bold';

            app.SysParamField = uieditfield(g);
            app.SysParamField.Layout.Row = 3; app.SysParamField.Layout.Column = 2;
            app.SysParamField.Tooltip = 'System parameter .m file name';

            app.SysParamBrowseBtn = uibutton(g, 'push');
            app.SysParamBrowseBtn.Layout.Row = 3; app.SysParamBrowseBtn.Layout.Column = 3;
            app.SysParamBrowseBtn.Text = 'Browse...';
            app.SysParamBrowseBtn.Tooltip = 'Select a .m param file from Script_Data/';
            app.SysParamBrowseBtn.ButtonPushedFcn = createCallbackFcn(app, @SysParamBrowsePushed, true);

            actGrid = uigridlayout(g, [1 4]);
            actGrid.Layout.Row = 4; actGrid.Layout.Column = [1 3];
            actGrid.Padding = [0 0 0 0]; actGrid.ColumnWidth = {100, 100, '1x', 20};

            app.SysPreviewBtn = uibutton(actGrid, 'push');
            app.SysPreviewBtn.Layout.Row = 1; app.SysPreviewBtn.Layout.Column = 1;
            app.SysPreviewBtn.Text = 'Preview';
            app.SysPreviewBtn.Tooltip = 'Dry-run — preview changes';
            app.SysPreviewBtn.ButtonPushedFcn = createCallbackFcn(app, @SysPreviewPushed, true);

            app.SysApplyBtn = uibutton(actGrid, 'push');
            app.SysApplyBtn.Layout.Row = 1; app.SysApplyBtn.Layout.Column = 2;
            app.SysApplyBtn.Text = 'Apply (Write)';
            app.SysApplyBtn.BackgroundColor = app.DARK_BLUE;
            app.SysApplyBtn.FontColor = app.WHITE; app.SysApplyBtn.FontWeight = 'bold';
            app.SysApplyBtn.Enable = 'off';
            app.SysApplyBtn.ButtonPushedFcn = createCallbackFcn(app, @SysApplyPushed, true);

            app.SysLamp = uilamp(actGrid);
            app.SysLamp.Layout.Row = 1; app.SysLamp.Layout.Column = 4;
            app.SysLamp.Color = [0.8 0.8 0.8];
        end

    end

    % ============================================================
    %  App creation and deletion
    % ============================================================
    methods (Access = public)

        function app = BEVauthorAppNative
            % Singleton — reuse existing window if open
            running = findall(groot, 'Type', 'figure', 'Name', 'BEV Config Author');
            if ~isempty(running)
                figure(running(1));
                if nargout == 0, clear app; end
                return;
            end

            createComponents(app)
            registerApp(app, app.UIFigure)
            runStartupFcn(app, @(~) authorAppStartup(app))
            if nargout == 0
                clear app
            end
        end

        function delete(app)
            if ~isempty(app.PreviewFigure) && isvalid(app.PreviewFigure)
                delete(app.PreviewFigure);
            end
            delete(app.UIFigure)
        end
    end
end

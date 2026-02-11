function ParamConfigButtonPushed(app)
% Check param file links; if any missing, show a single dialog listing all
% missing components with a Link... button next to each. Export when all set.

    offendersLabel = {};
    offendersKey = {};
    offendersSel = {};
    compList = fieldnames(app.ComponentDropdowns);
    for k = 1:numel(compList)
        dd = app.ComponentDropdowns.( compList{k});
        compLabel = dd.UserData.InstanceLabel;
        compSel = dd.UserData.LastValidValue;

        if ~isprop(dd,'UserData') ||  ~isfield(dd.UserData,'ParamFile') || ...
                isempty(dd.UserData.ParamFile) || ~isfile(dd.UserData.ParamFile)
            offendersLabel{end+1} = compLabel; %#ok<AGROW>
            offendersKey{end+1} = compList{k}; %#ok<AGROW>
            offendersSel{end+1} = compSel; %#ok<AGROW>
        end
    end

    % Get all target values
    targets = offendersSel;

    % Find entries starting with '_MISSING_'
    missingIdx = startsWith(targets, '__MISSING__');
    missingTargets = targets(missingIdx);

    % If any missing found, alert the user
    if any(missingIdx)
        msg = sprintf("Removed missing component links from export script:\n\n%s", strjoin(missingTargets, newline));
        uialert(app.UIFigure, msg, "Missing Links Removed", 'Icon', 'warning');
    end

    % Remove those entries from the structure
    offendersLabel = offendersLabel(~missingIdx);
    offendersKey = offendersKey(~missingIdx);

    % If nothing is missing, go straight to export
    if isempty(offendersLabel)
        doExport();
        return
    end

    

    % Show a floating modal dialog attached to app (no full overlay)
    showLinkDialog(offendersLabel);

    function doExport()
        try
            rootFolder = getBEVProjectRoot(app); 
            modelName = erase(app.BEVModelDropDown.Value,'.slx');
            outFile = fullfile(rootFolder,'Model',[modelName '_setup.m']);
            exportParamScript(app,outFile);
            % uialert(app.UIFigure,'Setup script generated successfully.','Export Complete','Icon','warning');
            open(outFile);
        catch ME
            uialert(app.UIFigure,sprintf('Export failed:\n\n%s',ME.message),'Error','Icon','error');
        end
    end

    function showLinkDialog(offenders)
        % Floating panel inside app.UIFigure (no external OS window)
        n = numel(offenders);
        rowH = 28; dlgW = 520; dlgH = 90 + n*rowH;

        % Capture and disable current top-level children for modal-like behavior
        topChildren = app.UIFigure.Children;

        % Centered panel inside the app window
        figPos = app.UIFigure.Position; % [x y w h]
        dlgX = max(10, round((figPos(3) - dlgW)/2));
        dlgY = max(10, round((figPos(4) - dlgH)/2));
        dlg = uipanel(app.UIFigure, 'Title','Missing Param Links', 'Units','pixels', ...
            'Position',[dlgX dlgY dlgW dlgH]);

        % Disable background content (store prior Enable states)
        stored = struct('h', {}, 'hadEnable', {}, 'Enable', {});
        for idx = 1:numel(topChildren)
            h = topChildren(idx);
            if isequal(h, dlg), continue; end
            hasEn = isprop(h, 'Enable');
            prev = '';
            if hasEn
                prev = h.Enable;
                h.Enable = 'off';
            end
            stored(end+1) = struct('h', h, 'hadEnable', hasEn, 'Enable', prev); %#ok<AGROW>
        end

        gl = uigridlayout(dlg, [n+1, 3]);
        gl.Padding = [10 10 10 10];
        gl.RowSpacing = 6; gl.ColumnSpacing = 8;
        gl.ColumnWidth = {'1x', 80, 90};
        gl.RowHeight = [repmat({rowH},1,n), {'fit'}];

        statusLabels = gobjects(n,1);

        for i = 1:n
            comp = offendersKey{i};
            uilabel(gl, 'Text', comp, 'HorizontalAlignment','left');
            statusLabels(i) = uilabel(gl, 'Text', 'Not linked', 'FontColor', [0.85 0.33 0.10]);
            uibutton(gl, 'Text', 'Link...', ...
                'ButtonPushedFcn', @(btn,evt) linkOne(comp, statusLabels(i)) );
        end

        % Bottom row: spacer, Done, Cancel
        uilabel(gl,'Text','');
        doneBtn = uibutton(gl,'Text','Done','Enable','off','ButtonPushedFcn', @(btn,evt) onDone());
        uibutton(gl,'Text','Cancel','ButtonPushedFcn', @(btn,evt) onCancel());

        updateDoneButton();
        % Resume the waiting caller if this panel gets deleted for any reason
        dlg.DeleteFcn = @(~,~) uiresume(app.UIFigure);

        % Block code execution (and make the rest of the app unclickable—you're already disabling controls)
        uiwait(app.UIFigure);

        function updateDoneButton()
            allLinked = true;
            for j = 1:n
                compName = compList{j};
                ddLocal = app.ComponentDropdowns.(compName);
                if ~isfield(ddLocal.UserData,'ParamFile') || isempty(ddLocal.UserData.ParamFile) || ~isfile(ddLocal.UserData.ParamFile)
                    allLinked = false; break;
                end
            end
            doneBtn.Enable = tern(allLinked,'on','off');
        end

        function linkOne(compName, statusLabel)
            [f,p] = uigetfile('*.m', sprintf('Select Param file for %s', compName));
            if isequal(f,0), return; end
            path = fullfile(p,f);
            app.ComponentDropdowns.(compName).UserData.ParamFile = path; % link param file
            msg = "Linked param file:" + newline + string(path);
            app.ComponentButtons.(compName).Tooltip = msg; % Tooltip update
            app.ComponentDropdowns.(compName).UserData.ParamStatusLabel.Text = ""; % missing param note removed
            statusLabel.Text = 'Linked';
            statusLabel.FontColor = [0.00 0.50 0.00];
            updateDoneButton();
        end

        function onDone()
            % Re-validate; if all set, close panel and export
            missing = {};
            for j = 1:size(compList,1)
                compName = compList{j};
                ddLocal = app.ComponentDropdowns.(compName);
                if ~isfield(ddLocal.UserData,'ParamFile') || isempty(ddLocal.UserData.ParamFile) || ~isfile(ddLocal.UserData.ParamFile)
                    missing{end+1} = compName; %#ok<AGROW>
                end
            end
            if ~isempty(missing)
                uialert(app.UIFigure, sprintf('Still missing param file for:\n\n%s', strjoin(missing, ', ')), ...
                    'Missing Param', 'icon','warning');
                return;
            end
            cleanup();
            doExport();
            uiresume(app.UIFigure);

        end

        function onCancel()
            cleanup();
            uialert(app.UIFigure, sprintf(['Still missing param file for few components \n\n ...' ...
                'aborting the param script creation']), ...
                'Missing Param', 'icon','warning');
            uiresume(app.UIFigure);
        end

        function cleanup()
            if isvalid(dlg), delete(dlg); end
            % Restore prior Enable states
            for ii = 1:numel(stored)
                rec = stored(ii);
                if ~isvalid(rec.h), continue; end
                if rec.hadEnable
                    try, rec.h.Enable = rec.Enable; catch, end
                end
            end
        end

        function out = tern(cond, a, b)
            if cond, out = a; else, out = b; end
        end
    end
end

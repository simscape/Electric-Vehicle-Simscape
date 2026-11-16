function html = buildConfigSummaryHTML(cfg, templateKey, root)
% BUILDCONFIGSUMMARYHTML Render a template config as a readable vertical HTML summary.
%   html = buildConfigSummaryHTML(cfg, templateKey, root)
%
%   Handles both preset configs (utils/APP/Config/Preset/) and saved user
%   setups (utils/APP/Config/User/). Produces a clean vertical layout with
%   instance/model/param mapping and validation warnings.
%
% Copyright 2026 The MathWorks, Inc.

    sectionHead = 'style="margin:10px 0 4px 0;font-weight:bold;font-size:13px;color:#333;background:#e8e8e8;padding:4px 8px;border-radius:4px;text-align:center;"';
    separator   = '<hr style="border:none;border-top:2px solid #aaa;margin:12px 0;">';

    % Shared table styles
    tblStyle  = 'style="width:100%;border-collapse:collapse;font-size:11px;margin:4px 0;"';
    thStyle   = 'style="text-align:left;padding:3px 6px;border:1px solid #ccc;color:#555;font-size:10px;"';
    tdStyle   = 'style="padding:2px 6px;border:1px solid #ccc;font-family:monospace;"';
    spanStyle = 'style="padding:2px 6px;font-weight:bold;color:#0072BD;background:#f0f4f8;font-size:11px;"';
    kvTd      = 'style="padding:2px 6px;border-bottom:1px solid #eee;"';
    kvVal     = 'style="padding:2px 6px;border-bottom:1px solid #eee;font-family:monospace;text-align:right;"';

    tmpl = cfg.(templateKey);
    warnings = {};
    lines = {};

    % ---- Description (presets only) ----
    if isfield(tmpl, 'Description') && ~isempty(tmpl.Description)
        lines{end+1} = sprintf('<div style="color:#555;margin-bottom:10px;">%s</div>', ...
            escHtml(tmpl.Description));
    end

    % ---- Components section ----
    if isfield(tmpl, 'Components') && isstruct(tmpl.Components)
        lines{end+1} = separator; %#ok<*AGROW>
        lines{end+1} = sprintf('<div %s>Components</div>', sectionHead);

        compNames = fieldnames(tmpl.Components);

        % Single table for all components
        lines{end+1} = sprintf('<table %s style="border:1px solid #ccc;">', tblStyle);
        lines{end+1} = sprintf('<tr><th %s>Model</th><th %s>Instance</th><th %s>Param</th></tr>', ...
            thStyle, thStyle, thStyle);

        for c = 1:numel(compNames)
            compName = compNames{c};
            comp = tmpl.Components.(compName);

            % Component name as spanning row
            lines{end+1} = sprintf('<tr><td colspan="3" %s>%s</td></tr>', ...
                spanStyle, escHtml(compName));

            models = {};
            if isfield(comp, 'Models')
                models = ensureCell(comp.Models);
            end

            instances = {};
            if isfield(comp, 'Instances')
                instances = ensureCell(comp.Instances);
            end

            % Build ParamMap lookup
            paramMap = struct();
            if isfield(comp, 'ParamMap') && isstruct(comp.ParamMap)
                paramMap = comp.ParamMap;
            end

            % Build Selections lookup (instance→model+param)
            selections = struct();
            if isfield(comp, 'Selections') && isstruct(comp.Selections)
                selections = comp.Selections;
            end

            % Build reverse map: model → {instances, paramFiles}
            modelInstMap  = struct();
            modelParamMap = struct();
            if ~isempty(fieldnames(selections))
                selKeys = fieldnames(selections);
                for s = 1:numel(selKeys)
                    sel = selections.(selKeys{s});
                    if isfield(sel, 'Model')
                        mKey = char(matlab.lang.makeValidName(sel.Model));
                        lbl = selKeys{s};
                        if isfield(sel, 'Label'), lbl = sel.Label; end
                        if isfield(modelInstMap, mKey)
                            modelInstMap.(mKey){end+1} = lbl;
                        else
                            modelInstMap.(mKey) = {lbl};
                        end
                        if isfield(sel, 'ParamFile')
                            modelParamMap.(mKey) = sel.ParamFile;
                        end
                    end
                end
            else
                % No Selections — map all instances to first model
                for ii = 1:numel(instances)
                    if ~isempty(models)
                        mKey = char(matlab.lang.makeValidName(models{1}));
                        if isfield(modelInstMap, mKey)
                            modelInstMap.(mKey){end+1} = instances{ii};
                        else
                            modelInstMap.(mKey) = {instances{ii}};
                        end
                    end
                end
            end

            % Iterate over all models
            for mi = 1:numel(models)
                model = models{mi};
                mKey  = char(matlab.lang.makeValidName(model));

                % Param file
                paramFile = '';
                if isfield(modelParamMap, mKey)
                    paramFile = modelParamMap.(mKey);
                elseif isfield(paramMap, model)
                    paramFile = paramMap.(model);
                end
                paramDisplay = '';
                if ~isempty(paramFile)
                    [~, pName, pExt] = fileparts(char(paramFile));
                    paramDisplay = [pName pExt];
                end

                % One row per instance; model name only on first row
                if isfield(modelInstMap, mKey)
                    instList = modelInstMap.(mKey);
                    lines{end+1} = sprintf('<tr><td rowspan="%d" %s>%s</td><td %s>%s</td><td %s>%s</td></tr>', ...
                        numel(instList), tdStyle, escHtml(model), tdStyle, escHtml(instList{1}), tdStyle, escHtml(paramDisplay));
                    for ii = 2:numel(instList)
                        lines{end+1} = sprintf('<tr><td %s>%s</td><td %s>%s</td></tr>', ...
                            tdStyle, escHtml(instList{ii}), tdStyle, escHtml(paramDisplay));
                    end
                else
                    lines{end+1} = sprintf('<tr><td %s>%s</td><td %s>%s</td><td %s>%s</td></tr>', ...
                        tdStyle, escHtml(model), tdStyle, '—', tdStyle, escHtml(paramDisplay));
                end

                % Validate model on disk
                if ~isempty(root)
                    modelPath = fullfile(root, 'Components', compName, 'Model', [model '.slx']);
                    if ~isfile(modelPath)
                        warnings{end+1} = sprintf('%s.slx not found in Components/%s/Model/', model, compName);
                    end
                end
            end
        end
        lines{end+1} = '</table>';
    end

    % ---- Controls section ----
    if isfield(tmpl, 'Controls') && isstruct(tmpl.Controls)
        lines{end+1} = separator;
        lines{end+1} = sprintf('<div %s>Controls</div>', sectionHead);

        ctrl = tmpl.Controls;

        % Saved setup: single Model field; Preset: Models array + Instances
        if isfield(ctrl, 'Model') && ~isfield(ctrl, 'Models')
            ctrlModel = char(ctrl.Model);
        elseif isfield(ctrl, 'Models')
            ctrlModels = ensureCell(ctrl.Models);
            ctrlModel = ctrlModels{1};
        else
            ctrlModel = '—';
        end

        ctrlParam = '';
        if isfield(ctrl, 'ParamFile') && ~isempty(ctrl.ParamFile)
            ctrlParam = char(ctrl.ParamFile);
            [~, pName, pExt] = fileparts(ctrlParam);
            ctrlParamDisplay = [pName pExt];
        else
            ctrlParamDisplay = '';
        end

        ctrlLabel = 'Controller';
        if isfield(ctrl, 'Instances')
            ctrlInst = ensureCell(ctrl.Instances);
            ctrlLabel = ctrlInst{1};
        end

        lines{end+1} = sprintf('<table %s>', tblStyle);
        lines{end+1} = sprintf('<tr><th %s>Model</th><th %s>Instance</th><th %s>Param</th></tr>', ...
            thStyle, thStyle, thStyle);
        lines{end+1} = sprintf('<tr><td %s>%s</td><td %s>%s</td><td %s>%s</td></tr>', ...
            tdStyle, escHtml(ctrlModel), tdStyle, escHtml(ctrlLabel), tdStyle, escHtml(ctrlParamDisplay));
        lines{end+1} = '</table>';
    end

    % ---- System Parameter section ----
    if isfield(tmpl, 'SystemParameter')
        sp = ensureCell(tmpl.SystemParameter);
        lines{end+1} = separator;
        lines{end+1} = sprintf('<div %s>System Parameter</div>', sectionHead);
        lines{end+1} = sprintf('<table %s>', tblStyle);
        for si = 1:numel(sp)
            lines{end+1} = sprintf('<tr><td %s>%s</td></tr>', ...
                tdStyle, escHtml(sp{si}));
        end
        lines{end+1} = '</table>';
    end

    % ---- DriveCycle (saved setups) ----
    if isfield(tmpl, 'DriveCycle') && isstruct(tmpl.DriveCycle)
        dc = tmpl.DriveCycle;
        if isfield(dc, 'Value') && ~isempty(dc.Value)
            lines{end+1} = separator;
            lines{end+1} = sprintf('<div %s>Drive Cycle</div>', sectionHead);
            lines{end+1} = sprintf('<table %s>', tblStyle);
            lines{end+1} = sprintf('<tr><td %s>%s</td></tr>', tdStyle, escHtml(dc.Value));
            lines{end+1} = '</table>';
        end
    end

    % ---- Environment (saved setups) ----
    if isfield(tmpl, 'Environment') && isstruct(tmpl.Environment)
        env = tmpl.Environment;
        envFields = fieldnames(env);
        if ~isempty(envFields)
            lines{end+1} = separator;
            lines{end+1} = sprintf('<div %s>Environment</div>', sectionHead);
            lines{end+1} = sprintf('<table %s>', tblStyle);
            for e = 1:numel(envFields)
                val = env.(envFields{e});
                lines{end+1} = sprintf('<tr><td %s>%s</td><td %s>%s</td></tr>', ...
                    kvTd, escHtml(envFields{e}), kvVal, escHtml(num2str(val)));
            end
            lines{end+1} = '</table>';
        end
    end

    % ---- OperatingModes (saved setups) ----
    if isfield(tmpl, 'OperatingModes') && isstruct(tmpl.OperatingModes)
        modes = tmpl.OperatingModes;
        modeFields = fieldnames(modes);
        if ~isempty(modeFields)
            lines{end+1} = separator;
            lines{end+1} = sprintf('<div %s>Operating Modes</div>', sectionHead);
            lines{end+1} = sprintf('<table %s>', tblStyle);
            for m = 1:numel(modeFields)
                val = modes.(modeFields{m});
                if islogical(val)
                    valStr = string(val);
                else
                    valStr = string(num2str(val));
                end
                lines{end+1} = sprintf('<tr><td %s>%s</td><td %s>%s</td></tr>', ...
                    kvTd, escHtml(modeFields{m}), kvVal, escHtml(valStr));
            end
            lines{end+1} = '</table>';
        end
    end

    % ---- Validation warnings ----
    if ~isempty(warnings)
        lines{end+1} = separator;
        lines{end+1} = sprintf('<div %s>Warnings</div>', sectionHead);
        lines{end+1} = sprintf('<table %s>', tblStyle);
        for w = 1:numel(warnings)
            lines{end+1} = sprintf('<tr><td %s style="color:#c00;">&#9888; %s</td></tr>', ...
                kvTd, escHtml(warnings{w}));
        end
        lines{end+1} = '</table>';
    end

    html = strjoin(lines, newline);
end


%% Local helpers

function txt = escHtml(str)
%ESCHTML Escape HTML special characters.
    txt = strrep(char(str), '&', '&amp;');
    txt = strrep(txt, '<', '&lt;');
    txt = strrep(txt, '>', '&gt;');
end


function v = ensureCell(v)
%ENSURECELL Force char/string to cell, row orientation.
    if ischar(v), v = {v};
    elseif isstring(v), v = cellstr(v);
    end
    if iscell(v), v = v(:)'; end
end

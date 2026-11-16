function saveSetupToFile(app)
%SAVESETUPTOFILE Save current app setup state to a unified JSON config.
%   saveSetupToFile(app)
%
%   Produces a JSON that is a superset of the raw template config:
%   it keeps Instances/Models arrays (so the file can be loaded back
%   through ConfigDropDown) and adds Selections, Environment, OperatingModes,
%   DriveCycle, and Environment/OperatingModes fields.
%
%   Raw config (no selections):         Saved setup (with selections):
%     Components.Battery.Instances        same + .Selections
%     Components.Battery.Models           same
%     Controls.Instances / .Models        same + .Model / .Enabled
%     SystemParameter                     same
%     (no Environment)                    + Environment
%     (no OperatingModes)                 + OperatingModes
%     (no DriveCycle)                     + DriveCycle
%
% Copyright 2026 The MathWorks, Inc.

    % ---- Build state from current UI ----
    try
        state = buildSetupState(app);
    catch ME
        uialert(app.UIFigure, ...
            sprintf('Failed to build setup state:\n%s', ME.message), ...
            'Save Failed', 'Icon', 'error');
        return
    end

    templateName = state.TemplateName;
    setupData    = rmfield(state, 'TemplateName');

    % ---- Determine save location ----
    defaultDir = getUserConfigFolder();

    suggestedName = sprintf('%s_%s_setup.json', setupData.BEVModel, templateName);
    [file, path]  = uiputfile('*.json', 'Save Setup As', ...
        fullfile(defaultDir, suggestedName));
    if isequal(file, 0), return; end
    outputFile = fullfile(path, file);

    % ---- Sanitize: remove non-portable fields ----
    if isfield(setupData, 'Root'),       setupData = rmfield(setupData, 'Root'); end
    if isfield(setupData, 'ConfigFile'), setupData = rmfield(setupData, 'ConfigFile'); end
    if isfield(setupData, 'Timestamp'),  setupData = rmfield(setupData, 'Timestamp'); end

    % Strip ModelFolder from each selection (absolute path, not portable)
    if isfield(setupData, 'Components')
        compTypes = fieldnames(setupData.Components);
        for c = 1:numel(compTypes)
            comp = setupData.Components.(compTypes{c});

            if isfield(comp, 'Selections') && isstruct(comp.Selections)
                instKeys = fieldnames(comp.Selections);
                for i = 1:numel(instKeys)
                    sel = comp.Selections.(instKeys{i});
                    if isfield(sel, 'ModelFolder')
                        comp.Selections.(instKeys{i}) = rmfield(sel, 'ModelFolder');
                    end
                end
                setupData.Components.(compTypes{c}) = comp;
            end
        end
    end

    % ---- Encode and write JSON ----
    outputStruct.(templateName) = setupData;

    try
        json = jsonencode(outputStruct, 'PrettyPrint', true);

        fid = fopen(outputFile, 'w');
        if fid <= 0
            error('saveSetup:WriteFail', 'Cannot open file for writing: %s', outputFile);
        end
        cleanup = onCleanup(@() fclose(fid));
        fwrite(fid, json, 'char');

        uialert(app.UIFigure, ...
            sprintf('Setup saved:\n%s', outputFile), ...
            'Setup Saved', 'Icon', 'success');

        % Refresh dropdown so the new file appears, then re-select it
        populateConfigDropDown(app);
        app.ConfigDropDown.Value = outputFile;
    catch ME
        uialert(app.UIFigure, ...
            sprintf('Save failed:\n%s', ME.message), ...
            'Save Failed', 'Icon', 'error');
    end
end

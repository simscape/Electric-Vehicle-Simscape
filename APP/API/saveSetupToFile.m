function saveSetupToFile(app)
%SAVESETUPTOFILE Save current app setup state to a unified JSON config.
%   saveSetupToFile(app)
%
%   Produces a JSON that is a superset of the raw template config:
%   it keeps Instances/Models arrays (so the file can be loaded back
%   through ConfigDropDown) and adds Selections, Environment, Dashboard,
%   DriveCycle, and a SchemaVersion marker.
%
%   Raw config (no selections):         Saved setup (with selections):
%     Components.Battery.Instances        same + .Selections
%     Components.Battery.Models           same
%     Controls.Instances / .Models        same + .Model / .Enabled
%     SystemParameter                     same
%     (no Environment)                    + Environment
%     (no Dashboard)                      + Dashboard
%     (no DriveCycle)                     + DriveCycle

    % Build state from current UI
    try
        state = buildSetupState(app);
    catch ME
        uialert(app.UIFigure, sprintf('Failed to build setup state:\n%s', ME.message), ...
            'Save Failed', 'Icon', 'error');
        return
    end

    flds = fieldnames(state);
    templateName = flds{1};
    tmpl = state.(templateName);

    % Default save location
    try
        root = char(matlab.project.rootProject.RootFolder);
    catch
        root = pwd;
    end
    defaultDir = fullfile(root, 'Model');
    if ~isfolder(defaultDir), defaultDir = root; end

    % Suggest filename from template + model
    suggestedName = sprintf('%s_%s_setup.json', tmpl.BEVModel, templateName);

    % Let user pick location
    [file, path] = uiputfile('*.json', 'Save Setup As', fullfile(defaultDir, suggestedName));
    if isequal(file, 0), return; end
    outFile = fullfile(path, file);

    % Remove non-portable fields
    if isfield(tmpl, 'Root'), tmpl = rmfield(tmpl, 'Root'); end
    if isfield(tmpl, 'ConfigFile'), tmpl = rmfield(tmpl, 'ConfigFile'); end
    if isfield(tmpl, 'Timestamp'), tmpl = rmfield(tmpl, 'Timestamp'); end

    % Strip ModelFolder from each selection (non-portable absolute path)
    if isfield(tmpl, 'Components')
        compTypes = fieldnames(tmpl.Components);
        for c = 1:numel(compTypes)
            comp = tmpl.Components.(compTypes{c});
            if isfield(comp, 'Selections') && isstruct(comp.Selections)
                instKeys = fieldnames(comp.Selections);
                for i = 1:numel(instKeys)
                    if isfield(comp.Selections.(instKeys{i}), 'ModelFolder')
                        comp.Selections.(instKeys{i}) = rmfield(comp.Selections.(instKeys{i}), 'ModelFolder');
                    end
                end
                tmpl.Components.(compTypes{c}) = comp;
            end
        end
    end

    % Rebuild output
    out.(templateName) = tmpl;

    % Write JSON
    try
        json = jsonencode(out, 'PrettyPrint', true);
        fid = fopen(outFile, 'w');
        if fid <= 0
            error('saveSetup:WriteFail', 'Cannot open file for writing: %s', outFile);
        end
        cl = onCleanup(@() fclose(fid));
        fwrite(fid, json, 'char');
        uialert(app.UIFigure, sprintf('Setup saved:\n%s', outFile), ...
            'Setup Saved', 'Icon', 'success');
    catch ME
        uialert(app.UIFigure, sprintf('Save failed:\n%s', ME.message), ...
            'Save Failed', 'Icon', 'error');
    end
end

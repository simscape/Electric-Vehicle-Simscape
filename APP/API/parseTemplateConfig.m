function groupedJsonInfo = parseTemplateConfig(app)
    % Load JSON file
    fid = fopen(jsonFile);  
    raw = fread(fid, inf);
    str = char(raw');
    fclose(fid);

    % Decode JSON
    config = jsondecode(str);

    % Initialize output
    templateNames = fieldnames(config);
    groupedJsonInfo = struct();

    for i = 1:numel(templateNames)
        tpl = templateNames{i};
        tplInfo = config.(tpl);
        try
            groupedJsonInfo.(tpl).Description = tplInfo.Description;
            compStruct = tplInfo.Components;
            compNames = fieldnames(compStruct);
        catch
            uialert(app.UIFigure, "No components section found in the config file", "Error");
            return;
        end


        try
            groupedJsonInfo.(tpl).Components = struct();
            groupedJsonInfo.(tpl).Controls = tplInfo.Controls;
        catch
            uialert(app.UIFigure, "No controller section found in the config file", "Error");
            return;
        end
        for j = 1:numel(compNames)
            comp  = compNames{j};
            entry = compStruct.(comp);

            if isstruct(entry) && isfield(entry, "Instances") && isfield(entry, "Models")
                % Explicit Instances + Models
                groupedJsonInfo.(tpl).Components.(comp).Instances = entry.Instances;
                groupedJsonInfo.(tpl).Components.(comp).Models    = entry.Models;
            else
                % Bare list => Instances = Models = that list
                groupedJsonInfo.(tpl).Components.(comp).Instances = entry(:)'; 
                groupedJsonInfo.(tpl).Components.(comp).Models    = entry(:)';
            end
        end
    end
end

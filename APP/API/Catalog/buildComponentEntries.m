function entries = buildComponentEntries(rawCfg, templateKey)
%BUILDCOMPONENTENTRIES Build flat instance entries from parsed JSON config.
%   entries = buildComponentEntries(rawCfg, templateKey)
%
%   Reads the Components section of the selected template config and
%   returns one entry per component instance:
%     entries(i).Comp   — component type name (e.g. 'MotorDrive')
%     entries(i).Label  — instance display name (e.g. 'Front Motor (EM1)')
%     entries(i).Models — cell array of configured model names

    templateConfig = rawCfg.(templateKey);
    componentNames = fieldnames(templateConfig.Components);

    entries = repmat(emptyEntry(), 0, 1);

    for i = 1:numel(componentNames)
        compName   = componentNames{i};
        compConfig = templateConfig.Components.(compName);

        modelNames = compConfig.Models;

        % Use explicit Instances if present, otherwise default to type name
        if isstruct(compConfig) && isfield(compConfig, 'Instances')
            instanceNames = compConfig.Instances;
        else
            instanceNames = {compName};
        end

        for j = 1:numel(instanceNames)
            entry        = emptyEntry();
            entry.Comp   = compName;
            entry.Label  = instanceNames{j};
            entry.Models = modelNames;

            entries(end+1) = entry;  %#ok<AGROW>
        end
    end
end

%% Local helper

function entry = emptyEntry()
%EMPTYENTRY Return an empty component entry struct with the standard fields.
    entry = struct('Comp', '', 'Label', '', 'Models', {{}});
end

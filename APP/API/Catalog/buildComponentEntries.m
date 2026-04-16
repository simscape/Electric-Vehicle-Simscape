function entries = buildComponentEntries(rawCfg, tmplName)
%BUILDCOMPONENTENTRIES Build flat instance entries from parsed JSON config.
%   entries = buildComponentEntries(rawCfg, tmplName) returns a struct array
%   with one entry per component instance:
%     entries(i).Comp      — component type (e.g. 'MotorDrive')
%     entries(i).Label     — instance name (e.g. 'Front Motor (EM1)')
%     entries(i).CfgModels — cell array of model names from config

    components = rawCfg.(tmplName).Components;
    compNames  = fieldnames(components);
    entries    = struct('Comp', {}, 'Label', {}, 'CfgModels', {});

    for c = 1:numel(compNames)
        compType  = compNames{c};
        compNode  = components.(compType);
        cfgModels = compNode.Models;

        % Use explicit Instances if present, otherwise default to type name
        if isstruct(compNode) && isfield(compNode, 'Instances')
            instanceNames = compNode.Instances;
        else
            instanceNames = {compType};
        end

        % One entry per instance, all sharing the same config models
        for j = 1:numel(instanceNames)
            entries(end+1).Comp      = compType;         %#ok<AGROW>
            entries(end  ).Label     = instanceNames{j};
            entries(end  ).CfgModels = cfgModels;
        end
    end
end

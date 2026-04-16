function entries = buildComponentEntries(rawCfg, tmplName)
%BUILDCOMPONENTENTRIES Build flat instance entries from parsed JSON config.
%   entries = buildComponentEntries(rawCfg, tmplName) returns a struct array
%   with one entry per component instance:
%     entries(i).Comp      — component type (e.g. 'MotorDrive')
%     entries(i).Label     — instance name (e.g. 'Front Motor (EM1)')
%     entries(i).CfgModels — cell array of model names from config
    compNames = fieldnames(rawCfg.(tmplName).Components);
    entries   = struct('Comp',{},'Label',{},'CfgModels',{});
    for c = 1:numel(compNames)
        comp   = compNames{c};
        models = rawCfg.(tmplName).Components.(comp).Models;
        if isstruct(rawCfg.(tmplName).Components.(comp)) && isfield(rawCfg.(tmplName).Components.(comp),'Instances')
            insts = rawCfg.(tmplName).Components.(comp).Instances;
        else
            insts = {comp};
        end
        for j = 1:numel(insts)
            entries(end+1).Comp      = comp;        %#ok<AGROW>
            entries(end  ).Label     = insts{j};
            entries(end  ).CfgModels = models;
        end
    end
end

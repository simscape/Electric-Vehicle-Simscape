function note = computeParamMissingNote(compName, dd, rootFolder)
%COMPUTEPARAMMISSINGNOTE Return red-note text if no auto param file found.
%   Returns "" if a param file exists, else a human-friendly note.
%
% Copyright 2026 The MathWorks, Inc.
    note = "";

    val = string(dd.Value);
    if startsWith(val,"__MISSING__")
        return; % model is missing; don't add param note
    end

    base = regexprep(char(val), '\.slx$', '', 'ignorecase');
    paramName = [base 'Params.m'];

    modelFolder = "";
    if isstruct(dd.UserData) && isfield(dd.UserData,'ModelFolder')
        modelFolder = string(dd.UserData.ModelFolder);
    end

    if strlength(modelFolder) > 0
        candidate = fullfile(char(modelFolder), paramName);
    else
        candidate = fullfile(char(rootFolder), 'Components', char(compName), 'Model', paramName);
    end

    if ~exist(candidate, 'file')
        note = sprintf("No param script found: %s  —  right-click 'Param' to link one.", paramName);
        % add paramfile missing note
        userDataSetField(dd, 'ParamFile', '');
    else
        % add paramfile name
        userDataSetField(dd, 'ParamFile', char(candidate));
    end
end

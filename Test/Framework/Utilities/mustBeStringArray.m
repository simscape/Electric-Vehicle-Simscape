function mustBeStringArray(value)
% mustBeStringArray - Validates that input is a non-empty string array (rejects cell arrays)
%
% This custom validator ensures that the input is of type string and is
% non-empty. Unlike MATLAB's built-in "string" type validation in argument
% blocks, this function does NOT accept cell arrays of character vectors.
%
% Usage (in arguments block):
%   NameValueArgs.Field {mustBeStringArray}
%
% Throws an error if:
%   - Input is not of class "string"
%   - Input is empty

% Copyright 2026 The MathWorks, Inc.

    if ~isstring(value)
        throwAsCaller(MException("mustBeStringArray:invalidType", ...
            "Value must be a string array, not a %s. Use ""value"" or [""a""; ""b""] syntax.", ...
            class(value)));
    end

    if isempty(value)
        throwAsCaller(MException("mustBeStringArray:emptyValue", ...
            "Value must be a non-empty string array."));
    end
end

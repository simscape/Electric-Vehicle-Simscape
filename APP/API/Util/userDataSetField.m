function userDataSetField(h, fieldName, value)
%USERDATASETFIELD Safely set a field in a UI component's UserData struct.
    try
        ud = struct();
        if isprop(h, 'UserData') && ~isempty(h.UserData) && isstruct(h.UserData)
            ud = h.UserData;
        end
        ud.(fieldName) = value;
        h.UserData = ud;
    catch
    end
end

function preventMissingSelection(dd)
%PREVENTMISSINGSELECTION Dropdown callback: block [missing] selections, manage param state.
    valStr = string(dd.Value);
    items  = string(dd.Items);
    itemsData = items;
    try
        if ~isempty(dd.ItemsData), itemsData = string(dd.ItemsData); end
    catch
    end

    isMissing = false;
    if any(itemsData == valStr) && startsWith(valStr,"__MISSING__")
        isMissing = true;
    else
        idx = find(items == valStr, 1, 'first');
        if ~isempty(idx) && contains(items(idx), "[missing]"), isMissing = true; end
    end

    if isMissing
        newVal = [];
        if isfield(dd.UserData,'LastValidValue'), newVal = dd.UserData.LastValidValue; end
        if isempty(newVal)
            nm = ~startsWith(itemsData,"__MISSING__") & ~contains(items,"[missing]");
            if any(nm), newVal = itemsData(find(nm,1,'first')); else, newVal = valStr; end
        end
        dd.Value = newVal;
        dd.UserData.LastValidValue = newVal;

        parentFig = ancestor(dd,'figure');
        msg = "That option is marked as [missing] on disk. Please choose an available model/configuration.";
        try uialert(parentFig, msg, 'Unavailable', 'Icon','warning');
        catch, warndlg(msg, 'Unavailable');
        end
    else
        dd.UserData.LastValidValue = dd.Value;
    end

    % Auto-unlink any manual link on selection change
    try
        if isstruct(dd.UserData) && isfield(dd.UserData,'ParamFile')
            ud = dd.UserData;
            ud = rmfield(ud,'ParamFile');
            dd.UserData = ud;
        end
    catch
    end

    % Update tooltip for the Param button
    try
        if isstruct(dd.UserData) && isfield(dd.UserData,'ParamButton') && ~isempty(dd.UserData.ParamButton) && isvalid(dd.UserData.ParamButton)
            updateParamTooltip(dd.UserData.ParamButton, dd, dd.UserData.RootFolder);
        end
    catch
    end

    % Update the red line with a param note (if no auto param file exists)
    try
        if isstruct(dd.UserData) && isfield(dd.UserData,'ParamStatusLabel') && ~isempty(dd.UserData.ParamStatusLabel) && isvalid(dd.UserData.ParamStatusLabel)
            L = dd.UserData.ParamStatusLabel;
            note = computeParamMissingNote(dd.UserData.CompName, dd, dd.UserData.RootFolder);
            if strlength(note) ~= 0
                L.Text = string(note);
                L.Visible = 'on';
            else
                if contains(string(L.Text), "No param script")
                    L.Text = "";
                    L.Visible = 'off';
                end
            end
        end
    catch
    end
end

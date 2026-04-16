function preventMissingSelection(dd)
%PREVENTMISSINGSELECTION Dropdown callback: block [missing] selections, manage param state.

    valStr    = string(dd.Value);
    items     = string(dd.Items);
    itemsData = items;

    if ~isempty(dd.ItemsData)
        itemsData = string(dd.ItemsData);
    end

    % ---- Detect if selected item is marked missing ----
    isMissing = false;

    if any(itemsData == valStr) && startsWith(valStr, "__MISSING__")
        isMissing = true;
    else
        idx = find(items == valStr, 1, 'first');
        if ~isempty(idx) && contains(items(idx), "[missing]")
            isMissing = true;
        end
    end

    % ---- Revert to last valid selection if missing ----
    if isMissing
        newVal = [];

        if isfield(dd.UserData, 'LastValidValue')
            newVal = dd.UserData.LastValidValue;
        end

        if isempty(newVal)
            nonMissing = ~startsWith(itemsData, "__MISSING__") ...
                       & ~contains(items, "[missing]");
            if any(nonMissing)
                newVal = itemsData(find(nonMissing, 1, 'first'));
            else
                newVal = valStr;
            end
        end

        dd.Value = newVal;
        dd.UserData.LastValidValue = newVal;

        parentFig = ancestor(dd, 'figure');
        msg = "That option is marked as [missing] on disk. " + ...
              "Please choose an available model/configuration.";

        try
            uialert(parentFig, msg, 'Unavailable', 'Icon', 'warning');
        catch
            warndlg(msg, 'Unavailable');
        end
    else
        dd.UserData.LastValidValue = dd.Value;
    end

    % ---- Auto-unlink param file on selection change ----
    if isstruct(dd.UserData) && isfield(dd.UserData, 'ParamFile')
        ud = dd.UserData;
        ud = rmfield(ud, 'ParamFile');
        dd.UserData = ud;
    end

    % ---- Update param button tooltip ----
    if isstruct(dd.UserData) ...
            && isfield(dd.UserData, 'ParamButton') ...
            && ~isempty(dd.UserData.ParamButton) ...
            && isvalid(dd.UserData.ParamButton)
        updateParamTooltip(dd.UserData.ParamButton, dd, dd.UserData.RootFolder);
    end

    % ---- Update red note label ----
    if isstruct(dd.UserData) ...
            && isfield(dd.UserData, 'ParamStatusLabel') ...
            && ~isempty(dd.UserData.ParamStatusLabel) ...
            && isvalid(dd.UserData.ParamStatusLabel)

        noteLabel = dd.UserData.ParamStatusLabel;
        note = computeParamMissingNote(dd.UserData.CompName, dd, dd.UserData.RootFolder);

        if strlength(note) ~= 0
            noteLabel.Text    = string(note);
            noteLabel.Visible = 'on';
        else
            if contains(string(noteLabel.Text), "No param script")
                noteLabel.Text    = "";
                noteLabel.Visible = 'off';
            end
        end
    end
end

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

    % ---- Re-discover default param file for new selection ----
    if isstruct(dd.UserData) && isfield(dd.UserData, 'CompName')
        computeParamMissingNote(dd.UserData.CompName, dd, dd.UserData.RootFolder);
    end

    % ---- Update param button tooltip (after ParamFile is re-set) ----
    if isstruct(dd.UserData) ...
            && isfield(dd.UserData, 'ParamButton') ...
            && ~isempty(dd.UserData.ParamButton) ...
            && isvalid(dd.UserData.ParamButton)
        updateParamTooltip(dd.UserData.ParamButton, dd);
    end

    % ---- Update red note label (param portion only) ----
    if isstruct(dd.UserData) ...
            && isfield(dd.UserData, 'ParamStatusLabel') ...
            && ~isempty(dd.UserData.ParamStatusLabel) ...
            && isvalid(dd.UserData.ParamStatusLabel)

        noteLabel = dd.UserData.ParamStatusLabel;
        hasParam = isfield(dd.UserData, 'ParamFile') ...
                   && strlength(string(dd.UserData.ParamFile)) > 0;

        currentText = string(noteLabel.Text);
        hasParamNote = contains(currentText, "No param script");

        if hasParam && hasParamNote
            % Param found — strip the param-missing portion, keep model notes
            parts = strsplit(currentText, '  |  ');
            parts = parts(~contains(parts, "No param script"));
            if isempty(parts)
                noteLabel.Text    = "";
                noteLabel.Visible = 'off';
            else
                noteLabel.Text = strjoin(parts, '  |  ');
            end
        elseif ~hasParam && ~hasParamNote
            % Param missing — append note without clobbering model notes
            paramNote = sprintf("No param script found: %sParams.m", ...
                regexprep(char(dd.Value), '\.slx$', '', 'ignorecase'));
            if strlength(currentText) > 0
                noteLabel.Text = currentText + "  |  " + paramNote;
            else
                noteLabel.Text = paramNote;
            end
            noteLabel.Visible = 'on';
        end
    end
end

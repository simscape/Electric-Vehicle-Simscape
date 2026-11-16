function resetFidMode(app)
% RESETFIDMODE Reset fidelity panel to idle state with no mode selected.

    app.FidMode = "";
    app.FidComponentDropDown.Enable = 'off';
    app.FidModelDropDown.Enable = 'off';
    app.FidParamField.Enable = 'off';
    app.FidParamBrowseBtn.Enable = 'off';
    app.FidMakeDefaultCB.Enable = 'off';
    app.FidPreviewBtn.Enable = 'off';
    app.FidWriteBtn.Enable = 'off';
    if ~isempty(app.DefaultNavBg)
        app.FidAddBtn.BackgroundColor = app.DefaultNavBg;
        app.FidAddBtn.FontColor = app.DefaultNavFg;
        app.FidDeleteBtn.BackgroundColor = app.DefaultNavBg;
        app.FidDeleteBtn.FontColor = app.DefaultNavFg;
    end
end

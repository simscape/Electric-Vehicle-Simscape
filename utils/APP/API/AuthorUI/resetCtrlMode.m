function resetCtrlMode(app)
% RESETCTRLMODE Reset controller panel to idle state with no mode selected.

    app.CtrlMode = "";
    app.CtrlModelDropDown.Enable = 'off';
    app.CtrlParamField.Enable = 'off';
    app.CtrlParamBrowseBtn.Enable = 'off';
    app.CtrlMakeDefaultCB.Enable = 'off';
    app.CtrlPreviewBtn.Enable = 'off';
    app.CtrlWriteBtn.Enable = 'off';
    if ~isempty(app.DefaultNavBg)
        app.CtrlAddBtn.BackgroundColor = app.DefaultNavBg;
        app.CtrlAddBtn.FontColor = app.DefaultNavFg;
        app.CtrlDeleteBtn.BackgroundColor = app.DefaultNavBg;
        app.CtrlDeleteBtn.FontColor = app.DefaultNavFg;
    end
end

/**
CJ Callado
 */
StartTest (function (t) {

    var engine = new iRely.TestEngine();
    engine.start(t)

        /* 1. Open screen and check default control's state*/
        .login('AGADMIN','AGADMIN','AG').wait(1500)
        .addFunction(function(next){t.diag("1. Open screen and check default control's state"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .openScreen('Inventory Count Group').wait(200)
        .checkScreenShown ('iccountgroup').wait(100)
        .checkScreenWindow({alias: 'iccountgroup', title: 'Inventory Count Group', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: false, save: true, refresh: false, search: false, delete: false, undo: true, close: true})
        .checkControlVisible(['#btnDelete', '#btnInsertCriteria','#txtFilterGrid'], true)
        .checkControlVisible(['#colCountGroup'], true)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
        .checkStatusBar()
        .checkStatusMessage('Ready')

        /* 2. Add a new record.*/
        .addFunction(function (next) { t.diag("2. Add new record"); next(); }).wait(100)
        .enterGridData('#grdGridTemplate', 1, 'colCountGroup', 'ICG - 02').wait(100)
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('iccountgroup').wait(100)
        //Verify record added
        .openScreen('Inventory Count Group').wait(200)
        .checkScreenShown('iccountgroup').wait(100)
        .checkGridData('#grdGridTemplate', 1, 'colCountGroup', 'ICG - 02')
        .checkStatusMessage('Ready')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('iccountgroup').wait(100)

        /* 3. Add Multiple records*/
        .openScreen('Inventory Count Group').wait(200)
        .checkScreenShown ('iccountgroup').wait(100)
        .addFunction(function (next) { t.diag("3. Add multiple records."); next(); }).wait(100)
        .enterGridData('#grdGridTemplate', 2, 'colCountGroup', 'ICG - 03').wait(100)
        .enterGridData('#grdGridTemplate', 3, 'colCountGroup', 'ICG - 04').wait(100)
        .enterGridData('#grdGridTemplate', 4, 'colCountGroup', 'ICG - 05').wait(100)
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('iccountgroup').wait(100)
        //Verify record added
        .openScreen('Inventory Count Group').wait(200)
        .checkScreenShown('iccountgroup').wait(100)
        .checkGridData('#grdGridTemplate', 1, 'colCountGroup', 'ICG - 02')
        .checkStatusMessage('Ready')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('iccountgroup').wait(100)

        /* 4. Add another record, Click Close button, do NOT save the changes */
        .addFunction(function (next) { t.diag("4. Add another record, Click Close button, do NOT save the changes"); next(); }).wait(100)
        .openScreen('Inventory Count Group').wait(200)
        .checkScreenShown('iccountgroup').wait(100)
        .enterGridData('#grdGridTemplate', 5, 'colCountGroup', 'ICG - 06').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21', 'Do you want to save the changes you made?', 'yesnocancel', 'question')
        .clickMessageBoxButton('no').wait(10)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('iccountgroup').wait(100)


        /* 5. Add another record, click Close, Cancel*/
        .addFunction(function (next) { t.diag("5. Add another record, Click Close button, do NOT save the changes"); next(); }).wait(100)
        .openScreen('Inventory Count Group').wait(200)
        .checkScreenShown('iccountgroup').wait(100)
        .enterGridData('#grdGridTemplate', 5, 'colCountGroup', 'ICG - 06').wait(100)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21', 'Do you want to save the changes you made?', 'yesnocancel', 'question')
        .clickMessageBoxButton('cancel').wait(10)
        .checkScreenShown('iccountgroup').wait(100)
        .checkGridData('#grdGridTemplate', 5, 'colCountGroup', 'ICG - 06').wait(500)


        /* 6. Add another record, click Close, Save the record*/
        .addFunction(function (next) { t.diag("6. Add another record, Click Close button,save the changes"); next(); }).wait(100)
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21', 'Do you want to save the changes you made?', 'yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(10)
        .checkIfScreenClosed('iccountgroup').wait(100)
        .openScreen('Inventory Count Group').wait(200)
        .checkGridData('#grdGridTemplate', 5, 'colCountGroup', 'ICG - 06').wait(500)
        .clickButton('#btnClose').wait(100)

        /* 7. Add Duplicate record*/
        .addFunction(function (next) { t.diag("7. Add Duplicate Record"); next(); }).wait(100)
        .openScreen('Inventory Count Group').wait(200)
        .checkScreenShown('iccountgroup').wait(100)
        .enterGridData('#grdGridTemplate', 6, 'colCountGroup', 'ICG - 06').wait(100)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave')
        .checkMessageBox('iRely i21', 'Count Group must be uniqe!', 'ok', 'error')
        .clickMessageBoxButton('ok').wait(10)
        .checkScreenShown('iccountgroup').wait(100)
        .checkGridData('#grdGridTemplate', 6, 'colCountGroup', '').wait(500)
        .clickButton('#btnClose').wait(100)
        .openScreen('Inventory Count Group').wait(200)
        .checkGridData('#grdGridTemplate', 6, 'colCountGroup', '').wait(500)

        .done()
})


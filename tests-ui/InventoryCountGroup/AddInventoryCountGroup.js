/**
 * Created by RQuidato on 11/14/14.
 */
/**
 * Created by RQuidato on 10/24/14.
 */
StartTest (function (t) {

    var engine = new iRely.TestEngine();
    engine.start(t)

        /* 1. Open screen and check default control's state*/
        .login('ssiadmin','summit','ag').wait(1500)
        .addFunction(function(next){t.diag("1. Open screen and check default control's state"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Inventory Count Group').wait(200)
        .checkScreenShown ('countgroup').wait(100)
        .checkScreenWindow({alias: 'countgroup', title: 'Inventory Count Group', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: false, save: true, search: false, delete: false, undo: true, close: true})
        .checkControlVisible(['#btnDelete', '#btnInsertCriteria','#txtFilterGrid'], true)
        .checkControlVisible(['#colCountGroup'], true)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
        .checkStatusBar()
        .checkStatusMessage('Ready')


        /* 2. Add multiple data */
        .addFunction(function(next){t.diag("2. Add multiple data"); next();}).wait(100)
        .enterGridData('#grdGridTemplate', 0, 'colCountGroup', 'icg01').wait(100)
        .enterGridData('#grdGridTemplate', 1, 'colCountGroup', 'icg02').wait(100)
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('countgroup').wait(100)

//        Verify record added
        .openScreen('Inventory Count Group').wait(200)
        .checkScreenShown ('countgroup').wait(100)
        .checkGridData('#grdGridTemplate', 0, 'colCountGroup','icg01')
//        .checkGridData('#grdGridTemplate', 1, 'colCountGroup','icg02')
        .checkStatusMessage('Ready')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('countgroup').wait(100)

        /* 3. Add another record, Click Close button, do NOT save the changes */
       .addFunction(function(next){t.diag("3. Add another record, Click Close button, do NOT save the changes"); next();}).wait(100)
        .openScreen('Inventory Count Group').wait(200)
        .checkScreenShown ('countgroup').wait(100)
        .enterGridData('#grdGridTemplate', 2, 'colCountGroup', 'icg03').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('no').wait(10)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('countgroup').wait(100)


        /* 4. Add another record, click Close, Cancel*/
       .addFunction(function(next){t.diag("4. Add another record, click Close, Cancel"); next();}).wait(100)
        .openScreen('Inventory Count Group').wait(200)
        .checkScreenShown ('countgroup').wait(100)
        .enterGridData('#grdGridTemplate', 2, 'colCountGroup', 'icg03').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('cancel').wait(10)
        .clickButton('#btnClose').wait(100)


        /* 5. Add another record, Click Close button, SAVE the changes*/
        .addFunction(function(next){t.diag("5. Add another record, Click Close button, SAVE the changes"); next();}).wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(500)
        .checkIfScreenClosed('countgroup').wait(100) /*issue - FRM-1547 or TS-445 or FRM-1560*/

//        Verify record added
        .openScreen('Inventory Count Group').wait(200)
        .checkScreenShown ('countgroup').wait(100)
        .checkGridData('#grdGridTemplate', 0, 'colCountGroup','icg03')
        .checkStatusMessage('Ready')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('countgroup').wait(100)


        /*6. Add duplicate record*/
        .addFunction(function(next){t.diag("6. Add duplicate record"); next();}).wait(100)
        .openScreen('Inventory Count Group').wait(200)
        .checkScreenShown ('countgroup').wait(100)
        .enterGridData('#grdGridTemplate', 3, 'colCountGroup', 'icg03').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkMessageBox('iRely i21','Fuel Category already exists.','ok','error') /*issue - IC-84 */
        .clickMessageBoxButton('ok').wait(10)

//        Modify duplicate record to correct it
        .addFunction(function(next){t.diag("6. Add duplicate record > Modify duplicate record to correct it"); next();}).wait(100)
        .enterGridData('#grdGridTemplate', 3, 'colCountGroup', 'icg04').wait(100) /*issue - IC-81 */
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question').wait(100)
        .clickMessageBoxButton('yes').wait(10)
        .checkIfScreenClosed('countgroup').wait(100)

//        Verify record added
        .openScreen('Inventory Count Group').wait(200)
        .checkScreenShown ('countgroup').wait(100)
        .checkGridData('#grdGridTemplate', 0, 'colCountGroup','icg04')
        .checkStatusMessage('Ready')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('countgroup').wait(100)


        /*7. Add primary key only then SAVE*/
        .addFunction(function(next){t.diag("7. Add primary key only then SAVE"); next();}).wait(100)
        .openScreen('Inventory Count Group').wait(200)
        .checkScreenShown ('countgroup').wait(100)
        .enterGridData('#grdGridTemplate', 4, 'colCountGroup', 'icg05').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('countgroup').wait(100)
        .done()
})


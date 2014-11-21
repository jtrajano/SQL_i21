/**
 * Created by RQuidato on 10/30/14.
 */
StartTest (function (t) {

    var engine = new iRely.TestEngine();
    engine.start(t)


        /* 1. Open screen and check default control's state */
        .login('ssiadmin','summit','ag').wait(1500)
        .addFunction(function(next){t.diag("1. Open screen and check default control's state"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Feed Stock UOM').wait(200)
        .checkScreenShown ('feedstockuom').wait(100)
        .checkScreenWindow({alias: 'feedstockuom', title: 'Feed Stock UOM', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: false, save: true, search: false, delete: false, undo: true, close: true})
        .checkControlVisible(['#btnDelete', '#btnInsertCriteria','#txtFilterGrid'], true)
        .checkControlVisible(['#colUOM','#colRinFeedStockUOMCode'], true)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
        .checkStatusBar()
        .checkStatusMessage('Ready')



        /* 2. Add multiple data */
        .addFunction(function(next){t.diag("2. Add multiple data"); next();}).wait(100)
//        .selectComboRowByFilter('#colUOM','gram')
        .enterGridData('#grdGridTemplate', 0, 'colRinFeedStockUOMCode', 'g01').wait(100)
//        .selectComboRowByFilter('#colUOM','kilogram')
        .enterGridData('#grdGridTemplate', 1, 'colRinFeedStockUOMCode', 'kg02').wait(100)
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('feedstockuom').wait(100)

//        verify records added
        .openScreen('Feed Stock UOM').wait(200)
        .checkScreenShown ('feedstockuom').wait(100)
        .checkGridData('#grdGridTemplate', 0, 'colUOM','')
        .checkGridData('#grdGridTemplate', 0, 'colRinFeedStockUOMCode','g01')
        .checkGridData('#grdGridTemplate', 0, 'colUOM','')
        .checkGridData('#grdGridTemplate', 0, 'colRinFeedStockUOMCode','kg02')
        .checkStatusMessage('Ready')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('feedstockuom').wait(100)

        /* 3. Add another record, Click Close button, do NOT save the changes */
        .addFunction(function(next){t.diag("3. Add another record, Click Close button, do NOT save the changes"); next();}).wait(100)
        .openScreen('Feed Stock UOM').wait(200)
        .checkScreenShown ('feedstockuom').wait(100)
        .enterGridData('#grdGridTemplate', 2, 'colUOM', '').wait(100)
        .enterGridData('#grdGridTemplate', 2, 'colRinFeedStockUOMCode', 'g03').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('no').wait(10)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('feedstockuom').wait(100)


        /* 4. Add another record, click Close, Cancel*/
        .addFunction(function(next){t.diag("4. Add another record, click Close, Cancel"); next();}).wait(100)
        .openScreen('Feed Stock UOM').wait(200)
        .checkScreenShown ('feedstockuom').wait(100)
        .enterGridData('#grdGridTemplate', 2, 'colUOM', '').wait(100)
        .enterGridData('#grdGridTemplate', 2, 'colRinFeedStockUOMCode', 'g03').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('cancel').wait(10)
        .clickButton('#btnClose').wait(100)


        /* 5. Add another record, Click Close button, SAVE the changes*/
        .addFunction(function(next){t.diag("5. Add another record, Click Close button, SAVE the changes"); next();}).wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(500)
        .checkIfScreenClosed('feedstockuom').wait(100) /*issue - FRM-1547 or TS-445 or FRM-1560*/

//        Verify record added
        .openScreen('Feed Stock UOM').wait(200)
        .checkScreenShown ('feedstockuom').wait(100)
        .checkGridData('#grdGridTemplate', 0, 'colUOM','')
        .checkGridData('#grdGridTemplate', 0, 'colRinFeedStockUOMCode','g03')
        .checkStatusMessage('Ready')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('feedstockuom').wait(100)


        /* 6. Add duplicate record*/
        .addFunction(function(next){t.diag("6. Add duplicate record"); next();}).wait(100)
        .openScreen('Feed Stock UOM').wait(200)
        .checkScreenShown ('feedstockuom').wait(100)
        .enterGridData('#grdGridTemplate', 2, 'colUOM', '').wait(100)
        .enterGridData('#grdGridTemplate', 2, 'colRinFeedStockUOMCode', 'g04').wait(100)

        .clickButton('#btnSave').wait(100)
        .checkMessageBox('iRely i21','Fuel Category already exists.','ok','error') /*issue - IC-84 */
        .clickMessageBoxButton('ok').wait(10)

//        Modify duplicate record to correct it
        .addFunction(function(next){t.diag("6. Add duplicate record > Modify duplicate record to correct it"); next();}).wait(100)
        .checkGridData('#grdGridTemplate', 0, 'colUOM','')
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question').wait(100)
        .clickMessageBoxButton('yes').wait(10)
        .checkIfScreenClosed('feedstockuom').wait(100)

//        Verify record added
        .openScreen('Feed Stock UOM').wait(200)
        .checkScreenShown ('feedstockuom').wait(100)
        .checkGridData('#grdGridTemplate', 0, 'colUOM','')
        .checkGridData('#grdGridTemplate', 0, 'colRinFeedStockUOMCode','g04')
        .checkStatusMessage('Ready')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('feedstockuom').wait(100)


        /*7. Add primary key only then SAVE*/
        .addFunction(function(next){t.diag("7. Add primary key only then SAVE"); next();}).wait(100)
        .openScreen('Feed Stock UOM').wait(200)
        .checkScreenShown ('feedstockuom').wait(100)
        .checkGridData('#grdGridTemplate', 0, 'colUOM','')
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('feedstockuom').wait(100)

        .done()
})

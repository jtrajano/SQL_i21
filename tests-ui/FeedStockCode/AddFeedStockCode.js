/**
 * Created by RQuidato on 10/30/14.
 */
/**
 * Created by RQuidato on 10/30/14.
 */
/**
 * Created by RQuidato on 10/29/14.
 */
StartTest (function (t) {

    var engine = new iRely.TestEngine();
    engine.start(t)

        /*Scenario 1. Add new records */
        /* 1. Open screen and check default controls' state */
        .login('ssiadmin','summit','eo').wait(1500)
        .addFunction(function(next){t.diag("Scenario 1. Add new records > 1. Open screen and check default controls' state"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .expandMenu('RIN').wait(100)
        .openScreen('Feed Stock Code').wait(200)
        .checkScreenShown ('feedstockcode').wait(100)
        .checkScreenWindow({alias: 'feedstockcode', title: 'Feed Stock Code', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: false, save: true, search: false, delete: false, undo: true, close: true})
        .checkControlVisible(['#colFeedStockCode', '#colDescription' ], true)
        .checkControlVisible('#btnDeleteFeedStockCode', true)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
        .checkStatusBar()
        .checkStatusMessage('Ready')


        /* 2. Multiple Data entry */
        .addFunction(function(next){t.diag("Scenario 1. Add new records > 2. Multiple Data entry"); next();}).wait(100)
        .enterGridData('#grdFeedStockCode', 0, 'colFeedStockCode', 'fsc01').wait(100)
        .enterGridData('#grdFeedStockCode', 0, 'colDescription', 'feed stock code 01').wait(100)
        .enterGridData('#grdFeedStockCode', 1, 'colFeedStockCode', 'fsc02').wait(100)
        .enterGridData('#grdFeedStockCode', 1, 'colDescription', 'feed stock code 02').wait(100)
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(500)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(200)
        .checkIfScreenClosed('feedstockcode').wait(100)


//        /* 3. Verify record added*/
//        .addFunction(function(next){t.diag("Scenario 1. Add new records > 3. Verify record added"); next();}).wait(100)
//        .openScreen('Feed Stock Code').wait(200)
//        .checkScreenShown ('feedstockcode').wait(100)
//        .checkGridData('#grdFeedStockCode', 0, 'colFeedStockCode','fsc01').wait(100)
//        .checkGridData('#grdFeedStockCode', 0, 'colDescription','feed stock code 01').wait(100)
//        .checkGridData('#grdFeedStockCode', 1, 'colFeedStockCode','fsc02').wait(100)
//        .checkGridData('#grdFeedStockCode', 1, 'colDescription','feed stock code 02').wait(100)
//

        /* Scenario 2. Add another record, click Close button, do NOT save the changes */
        /* 1. Data entry. */
        .addFunction(function(next){t.diag("Scenario 2. Add another record, click Close button, do NOT save the changes"); next();}).wait(100)
        .openScreen('Feed Stock Code').wait(200)
        .checkScreenShown ('feedstockcode').wait(100)
        .enterGridData('#grdFeedStockCode', 2, 'colFeedStockCode', 'fsc03').wait(100)
        .enterGridData('#grdFeedStockCode', 2, 'colDescription', 'feed stock code 03').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
//        .checkControlVisible(['#colFeedStockCode', '#colDescription' ], true)
        .clickMessageBoxButton('no').wait(10)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('feedstockcode').wait(100)



        /* Scenario 3. Add another record, click Close button, Cancel*/
        /* 1. Data entry. */
        .addFunction(function(next){t.diag("Scenario 3. Add another record, click Close button, Cancel"); next();}).wait(100)
        .openScreen('Feed Stock Code').wait(200)
        .checkScreenShown ('feedstockcode').wait(100)
        .enterGridData('#grdFeedStockCode', 2, 'colFeedStockCode', 'fsc03').wait(100)
        .enterGridData('#grdFeedStockCode', 2, 'colDescription', 'feed stock code 03').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('cancel').wait(10)
        .clickButton('#btnClose').wait(100)


        /* Scenario 4. Add another record, click Close button, SAVE the changes*/
        .addFunction(function(next){t.diag("Scenario 4. Add another record, click Close button, SAVE the changes"); next();}).wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(500)
        .checkIfScreenClosed('feedstockcode').wait(100) /*issue - FRM-1547*/
//
//        /* 2. Verify record not added*/
//        .addFunction(function(next){t.diag("Scenario 2. Add another record, click Close button, do NOT save the changes > 2. Verify record added"); next();}).wait(100)
//        .openScreen('Feed Stock Category').wait(200)
//        .checkScreenShown ('feedstockcode').wait(100)
//        .checkGridData('#grdFeedStockCode', 2, 'colFeedStockCode','fsc03')
//        .checkGridData('#grdFeedStockCode', 2, 'colDescription','feed stock code 03')
//
//
//
        /*Scenario 5. Add duplicate record > FuelCode*/
        .addFunction(function(next){t.diag("Scenario 5. Add duplicate record > FuelTypeCode"); next();}).wait(100)
        .openScreen('Feed Stock Code').wait(200)
        .checkScreenShown ('feedstockcode').wait(100)
        .enterGridData('#grdFeedStockCode', 3, 'colFeedStockCode', 'fsc03').wait(100)
        .enterGridData('#grdFeedStockCode', 3, 'colDescription', 'feed stock code 04').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkMessageBox('iRely i21','Fuel Category already exists.','ok','error') /* IC-84 */
        .clickMessageBoxButton('ok').wait(10)

        /*Scenario 6. Modify duplicate ProcessCode to correct it*/
        .addFunction(function(next){t.diag("Scenario 6. Modify duplicate ProcessCode to correct it"); next();}).wait(100)
        .enterGridData('#grdFeedStockCode', 3, 'colFeedStockCode', 'fsc04').wait(100) /* IC-81 */
        .clickButton('#closeButton').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(500)
        .checkIfScreenClosed('feedstockcode').wait(100)


//        .enterDummyRowData('#grdFuelCategory', [{ column: 'strRinFuelTypeCode', data: '10Et'}, {column: 'strDescription', data: '10-Ethanol'}]) /*issue - FRM-1535*/



        .done()
})

/**
 * Created by RQuidato on 11/3/14.
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
        .openScreen('Contract Document').wait(500)
        .checkScreenShown ('contractdocument').wait(200)
        .checkScreenWindow({alias: 'contractdocument', title: 'Contract Document', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})

        .checkControlVisible([
            '#txtDocumentName',
            '#txtDescription',
            '#cboCommodity',
            '#chkStandard'
        ], true)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
        .checkStatusBar()
        .checkStatusMessage('Ready')
        .checkControlVisible(['#first','#prev','#inputItem','#next','#last','#refresh'],true)


        /* 2. Data entry */
        .addFunction(function(next){t.diag("Scenario 1. Add new records > 2. Data entry"); next();}).wait(100)
        .enterData('#txtDocumentName','Docu01').wait(100)
        .enterData('#txtDescription','Test Document 01').wait(100)
//        .selectComboRowByFilter('cboCommodity', '')
        .clickCheckBox('#chkStandard',true)
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(500)
        .checkStatusMessage('Saved').wait(100)/*issue: IC-115 */
        .clickButton('#btnClose').wait(200)
        .checkIfScreenClosed('manufacturer').wait(100)
//
//
//        /* 3. Verify record added*/
//        .addFunction(function(next){t.diag("Scenario 1. Add new records > 3. Verify record added"); next();}).wait(100)
//        .openScreen('Manufacturer').wait(500)
//        //search screen name
//        .checkScreenShown ('search').wait(200)
//        .checkScreenWindow({alias: 'search', title: 'Search Manufacturer', collapse: true, maximize: true, minimize: false, restore: false, close: true })
//        .checkToolbarButton({new: true, openSelected: true, refresh: true, close: true})
//        .checkControlVisible(['#btnInsertCriteria', '#txtFilterGrid','#lblTotalRecords'],true)
//        //item id for columns shown on Search screen
//        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
//        .checkStatusBar()
//        .checkStatusMessage('Ready')
//        .checkControlVisible(['#first','#prev','#inputItem','#next','#last','#refresh'],true)
//        .selectSearchRowByFilter('manu01')

//
//
//
//
//        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
//        .checkControlData('#cboZipCode','46815').wait(100)

//
//        /* Scenario 2. Add another record, click Close button, do NOT save the changes */
//        /* 1. Data entry. */
//        .addFunction(function(next){t.diag("Scenario 2. Add another record, click Close button, do NOT save the changes"); next();}).wait(100)
//        .openScreen('Feed Stock Code').wait(200)
//        .checkScreenShown ('feedstock').wait(100)
//        .enterGridData('#grdFeedStock', 2, 'colCode', 'fs03').wait(100)
//        .enterGridData('#grdFeedStock', 2, 'colDescription', 'feed stock 03').wait(100)
//        .clickButton('#btnClose').wait(100)
//        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
////        .checkControlVisible(['#colFeedStockCode', '#colDescription' ], true)
//        .clickMessageBoxButton('no').wait(10)
//        .clickButton('#btnClose').wait(100)
//        .checkIfScreenClosed('feedstock').wait(100)
//
//
//
//        /* Scenario 3. Add another record, click Close button, Cancel*/
//        /* 1. Data entry. */
//        .addFunction(function(next){t.diag("Scenario 3. Add another record, click Close button, Cancel"); next();}).wait(100)
//        .openScreen('Feed Stock Code').wait(200)
//        .checkScreenShown ('feedstock').wait(100)
//        .enterGridData('#grdFeedStock', 2, 'colCode', 'fs03').wait(100)
//        .enterGridData('#grdFeedStock', 2, 'colDescription', 'feed stock 03').wait(100)
//        .clickButton('#btnClose').wait(100)
//        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
//        .clickMessageBoxButton('cancel').wait(10)
//        .clickButton('#btnClose').wait(100)
//
//
//        /* Scenario 4. Add another record, click Close button, SAVE the changes*/
//        .addFunction(function(next){t.diag("Scenario 4. Add another record, click Close button, SAVE the changes"); next();}).wait(100)
//        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
//        .clickMessageBoxButton('yes').wait(500)
//        .checkIfScreenClosed('feedstock').wait(100) /*issue - FRM-1547*/
////
////        /* 2. Verify record not added*/
////        .addFunction(function(next){t.diag("Scenario 2. Add another record, click Close button, do NOT save the changes > 2. Verify record added"); next();}).wait(100)
////        .openScreen('Feed Stock').wait(200)
////        .checkScreenShown ('feedstock').wait(100)
////        .checkGridData('#grdFeedStock', 2, 'colCode','fs03')
////        .checkGridData('#grdFeedStock', 2, 'colDescription','feed stock 03')
////
////
////
//        /*Scenario 5. Add duplicate record > FuelCode*/
//        .addFunction(function(next){t.diag("Scenario 5. Add duplicate record > FuelTypeCode"); next();}).wait(100)
//        .openScreen('Feed Stock').wait(200)
//        .checkScreenShown ('feedstock').wait(100)
//        .enterGridData('#grdFeedStock', 3, 'colCode', 'fs03').wait(100)
//        .enterGridData('#grdFeedStock', 3, 'colDescription', 'feed stock 04').wait(100)
//        .clickButton('#btnSave').wait(100)
//        .checkMessageBox('iRely i21','Fuel Category already exists.','ok','error') /* IC-84 */
//        .clickMessageBoxButton('ok').wait(10)
//
//        /*Scenario 6. Modify duplicate ProcessCode to correct it*/
//        .addFunction(function(next){t.diag("Scenario 6. Modify duplicate ProcessCode to correct it"); next();}).wait(100)
//        .enterGridData('#grdFeedStock', 3, 'colCode', 'fs04').wait(100) /* IC-81 */
//        .clickButton('#closeButton').wait(100)
//        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
//        .clickMessageBoxButton('yes').wait(500)
//        .checkIfScreenClosed('feedstock').wait(100)


//        .enterDummyRowData('#grdFuelCategory', [{ column: 'strRinFuelTypeCode', data: '10Et'}, {column: 'strDescription', data: '10-Ethanol'}]) /*issue - FRM-1535*/



        .done()
})

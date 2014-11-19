/**
 * Created by RQuidato on 10/31/14.
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
        .openScreen('Inventory Tag').wait(200)
        .checkScreenShown ('inventorytag').wait(200)
        .checkScreenWindow({alias: 'inventorytag', title: 'Inventory Tag', collapse: true, maximize: true, minimize: false, restore: false, close: true }).wait(100)
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true}).wait(100)
        /*Control checking*/
        .checkControlVisible(['#txtTagNumber','#chkHAZMATMessage','#txtDescription','#txtMessage'], true)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
        .checkStatusBar()
        .checkStatusMessage('Ready')
        .checkControlVisible(['#first','#prev','#inputItem','#next','#last','#refresh'],true)
        //        /*label checking*/ not yet available. Liz asked for this method be done on test framework. will continue this once available.
//        .checkFieldLabel('#cboFuelType', 'Fuel Type')


//        /* 2. Data entry */
//        .addFunction(function(next){t.diag("Scenario 1. Add new records > 2. Data entry"); next();}).wait(100)
//        .selectGridComboRowByFilter()
//        .selectComboRowByFilter('#cboFuelType','fuel category 01').wait(500) /*issues - IC-108 and IC-109*/
//        .selectComboRowByFilter('#cboFeedStock','fs01').wait(500)
//        .enterData('#txtBatchNo','bch01').wait(100)
//        .enterData('txtEndingRinGallonsForBatch', '5')
//        .checkControlData('#txtEquivalenceValue','1.0 Test EV')
//        .selectComboRowByFilter('#cboFuelCode','f01')
//        .selectComboRowByFilter('#cboProcessCode','p01')
//        .selectComboRowByFilter('#cboFeedStockUom','p01')
//        .enterData('#txtFeedStockFactor','p01')
//        .clickCheckBox('#chkRenewableBiomass',true)
//        .enterData('#txtPercentOfDenaturant','75')
//        .clickCheckBox('#chkDeductDenaturantFromRin',true)

//        .enterGridData('#grdFeedStockUom', 0, 'colUOM', 'u01').wait(100)
//        .enterGridData('#grdFeedStockUom', 0, 'colUOMCode', 'uom code 01').wait(100)
//        .enterGridData('#grdFeedStockUom', 1, 'colUOM', 'u02').wait(100)
//        .enterGridData('#grdFeedStockUom', 1, 'colUOMCode', 'uom code 02').wait(100)
//        .checkStatusMessage('Edited')
//        .clickButton('#btnSave').wait(500)
//        .checkStatusMessage('Saved').wait(100)
//        .clickButton('#btnClose').wait(200)
//        .checkIfScreenClosed('feedstockuom').wait(100)

//
////        /* 3. Verify record added*/
////        .addFunction(function(next){t.diag("Scenario 1. Add new records > 3. Verify record added"); next();}).wait(100)
////        .openScreen('Feed Stock UOM').wait(200)
////        .checkScreenShown ('feedstockuom').wait(100)
////        .checkGridData('#grdFeedStockUom', 0, 'colUOM','u01').wait(100)
////        .checkGridData('#grdFeedStockUom', 0, 'colUOMCode','uom code 01').wait(100)
////        .checkGridData('#grdFeedStockUom', 1, 'colUOM','u02').wait(100)
////        .checkGridData('#grdFeedStockUom', 1, 'colUOMCode','uom code 02').wait(100)
////
//
//        /* Scenario 2. Add another record, click Close button, do NOT save the changes */
//        /* 1. Data entry. */
//        .addFunction(function(next){t.diag("Scenario 2. Add another record, click Close button, do NOT save the changes"); next();}).wait(100)
//        .openScreen('Feed Stock UOM').wait(200)
//        .checkScreenShown ('feedstockuom').wait(100)
//        .enterGridData('#grdFeedStockUom', 2, 'colUOM', 'u03').wait(100)
//        .enterGridData('#grdFeedStockUom', 2, 'colUOMCode', 'uom code 03').wait(100)
//        .clickButton('#btnClose').wait(100)
//        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
////        .checkControlVisible(['#colFeedStockCode', '#colDescription' ], true)
//        .clickMessageBoxButton('no').wait(10)
//        .clickButton('#btnClose').wait(100)
//        .checkIfScreenClosed('feedstockuom').wait(100)
//
//
//
//        /* Scenario 3. Add another record, click Close button, Cancel*/
//        /* 1. Data entry. */
//        .addFunction(function(next){t.diag("Scenario 3. Add another record, click Close button, Cancel"); next();}).wait(100)
//        .openScreen('Feed Stock UOM').wait(200)
//        .checkScreenShown ('feedstockuom').wait(100)
//        .enterGridData('#grdFeedStockUom', 2, 'colUOM', 'u03').wait(100)
//        .enterGridData('#grdFeedStockUom', 2, 'colUOMCode', 'uom code 03').wait(100)
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
//        .checkIfScreenClosed('feedstockuom').wait(100) /*issue - FRM-1547*/
////
////        /* 2. Verify record not added*/
////        .addFunction(function(next){t.diag("Scenario 2. Add another record, click Close button, do NOT save the changes > 2. Verify record added"); next();}).wait(100)
////        .openScreen('Feed Stock UOM').wait(200)
////        .checkScreenShown ('feedstockuom').wait(100)
////        .checkGridData('#grdFeedStockUom', 2, 'colUOM','u03')
////        .checkGridData('#grdFeedStockUom', 2, 'colUOMCode','uom code 03')
////
////
////
//        /*Scenario 5. Add duplicate record > FuelCode*/
//        .addFunction(function(next){t.diag("Scenario 5. Add duplicate record > FuelTypeCode"); next();}).wait(100)
//        .openScreen('Feed Stock UOM').wait(200)
//        .checkScreenShown ('feedstockuom').wait(100)
//        .enterGridData('#grdFeedStockUom', 3, 'colUOM', 'u03').wait(100)
//        .enterGridData('#grdFeedStockUom', 3, 'colUOMCode', 'uom code 04').wait(100)
//        .clickButton('#btnSave').wait(100)
//        .checkMessageBox('iRely i21','Fuel Category already exists.','ok','error') /* IC-84 */
//        .clickMessageBoxButton('ok').wait(10)
//
//        /*Scenario 6. Modify duplicate ProductionProcess to correct it*/
//        .addFunction(function(next){t.diag("Scenario 6. Modify duplicate ProductionProcess to correct it"); next();}).wait(100)
//        .enterGridData('#grdFeedStockUom', 3, 'colUOM', 'u04').wait(100) /* IC-81 */
//        .clickButton('#closeButton').wait(100)
//        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
//        .clickMessageBoxButton('yes').wait(500)
//        .checkIfScreenClosed('feedstockuom').wait(100)
//
//
////        .enterDummyRowData('#grdFeedStockUom', [{ column: 'strRinFuelTypeCode', data: '10Et'}, {column: 'strDescription', data: '10-Ethanol'}]) /*issue - FRM-1535*/



        .done()
})

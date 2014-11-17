/**
 * Created by RQuidato on 11/3/14.
 */
StartTest (function (t) {

    var engine = new iRely.TestEngine();
    engine.start(t)

        /*Scenario 1. Add new records */
        /* 1. Open screen and check default controls' state */
        .login('ssiadmin','summit','ag').wait(1500)
        .addFunction(function(next){t.diag("Scenario 1. Add new records > 1. Open screen and check default controls' state"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Brand').wait(200)
        .checkScreenShown ('brand').wait(100)
        .checkScreenWindow({alias: 'brand', title: 'Brand', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: false, save: true, search: false, delete: false, undo: true, close: true})
        .checkControlVisible(['#btnDelete','#btnInsertCriteria','#txtFilterGrid'], true)
        .checkControlVisible(['#colBrandCode', '#colBrandName', '#colManufacturer'], true)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
        .checkStatusBar()
        .checkStatusMessage('Ready')


        /* 2. Multiple Data entry */
        .addFunction(function(next){t.diag("Scenario 1. Add new records > 2. Multiple Data entry"); next();}).wait(100)
        .enterGridData('#grdGridTemplate', 0, 'colBrandCode', 'b01').wait(100)
        .enterGridData('#grdGridTemplate', 0, 'colBrandName', 'brand 01').wait(100)
//        .selectGridComboRowByFilter() --not working yet
        .enterGridData('#grdGridTemplate', 1, 'colBrandCode', 'b02').wait(100)
        .enterGridData('#grdGridTemplate', 1, 'colBrandName', 'brand 02').wait(100)
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('brand').wait(100)


        /* 3. Verify record added*/
        .addFunction(function(next){t.diag("Scenario 1. Add new records > 3. Verify records added"); next();}).wait(100)
        .openScreen('Brand').wait(200)
        .checkScreenShown ('brand').wait(100)
        .checkGridData('#grdGridTemplate', 0, 'colBrandCode','b02')
        .checkGridData('#grdGridTemplate', 0, 'colBrandName','brand 02')

        //        .checkGridData('#grdGridTemplate', 1, 'colRinFuelCategoryCode','fc01') /* NOT WORKING, NEEDS VERIFICATION* /
//        .checkGridData('#grdGridTemplate', 1, 'colDescription','fuel category 01')
//        .checkGridData('#grdGridTemplate', 1, 'colEquivalenceValue','1.0 Test EV')
        .checkStatusMessage('Ready')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('brand').wait(100)

        /* Scenario 2. Add another record, click Close button, do NOT save the changes */
        /* 1. Data entry. */
        .addFunction(function(next){t.diag("Scenario 2. Add another record, click Close button, do NOT save the changes"); next();}).wait(100)
        .openScreen('Brand').wait(200)
        .checkScreenShown ('brand').wait(100)
        .enterGridData('#grdGridTemplate', 2, 'colBrandCode', 'b03').wait(100)
        .enterGridData('#grdGridTemplate', 2, 'colBrandName', 'brand 03').wait(100)

        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('no').wait(10)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('brand').wait(100)


        /* Scenario 3. Add another record, click Close button, Cancel*/
        /* 1. Data entry. */
        .addFunction(function(next){t.diag("Scenario 3. Add another record, click Close button, Cancel"); next();}).wait(100)
        .openScreen('Brand').wait(200)
        .checkScreenShown ('brand').wait(100)
        .enterGridData('#grdGridTemplate', 2, 'colBrandCode', 'b03').wait(100)
        .enterGridData('#grdGridTemplate', 2, 'colBrandName', 'brand 03').wait(100)

        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('cancel').wait(10)
        .clickButton('#btnClose').wait(100)


        /* Scenario 4. Add another record, click Close button, SAVE the changes*/
        .addFunction(function(next){t.diag("Scenario 4. Add another record, click Close button, SAVE the changes"); next();}).wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(500)
        .checkIfScreenClosed('brand').wait(100) /*issue - FRM-1547 or TS-445 or FRM-1560*/

        /* 2. Verify record added*/
        .addFunction(function(next){t.diag("Scenario 4. Add another record, SAVE the changes > 2. Verify record added"); next();}).wait(100)
        .openScreen('Brand').wait(200)
        .checkScreenShown ('brand').wait(100)
        .checkGridData('#grdGridTemplate', 0, 'colBrandCode','b03')
        .checkGridData('#grdGridTemplate', 0, 'colBrandName','brand 03')

        .checkStatusMessage('Ready')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('brand').wait(100)


        /*Scenario 5. Add duplicate record */
        .addFunction(function(next){t.diag("Scenario 5. Add duplicate record "); next();}).wait(100)
        .openScreen('Brand').wait(200)
        .checkScreenShown ('brand').wait(100)
        .enterGridData('#grdGridTemplate', 3, 'colBrandCode', 'b03').wait(100)
        .enterGridData('#grdGridTemplate', 3, 'colBrandName', 'brand 04').wait(100)

        .clickButton('#btnSave').wait(100)
        .checkMessageBox('iRely i21','Fuel Category already exists.','ok','error') /*issue - IC-84 */
        .clickMessageBoxButton('ok').wait(10)

        /*Scenario 6. Modify duplicate record to correct it*/
        .addFunction(function(next){t.diag("Scenario 6. Modify duplicate record to correct it"); next();}).wait(100)
        .enterGridData('#grdGridTemplate', 3, 'colBrandCode', 'b04').wait(100) /*issue - IC-81 */
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question').wait(100)
        .clickMessageBoxButton('yes').wait(10)
        .checkIfScreenClosed('brand').wait(100)



        /* 2. Verify record added*/
        .addFunction(function(next){t.diag("Scenario 6. Modify duplicate record to correct it > 2. Verify record added"); next();}).wait(100)
        .openScreen('Brand').wait(200)
        .checkScreenShown ('brand').wait(100)
        .checkGridData('#grdGridTemplate', 0, 'colBrandCode','b04')
        .checkGridData('#grdGridTemplate', 0, 'colBrandName','brand 04')

        .checkStatusMessage('Ready')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('brand').wait(100)

//        .enterDummyRowData('#grdFuelCategory', [{ column: 'strRinFuelTypeCode', data: '10Et'}, {column: 'strDescription', data: '10-Ethanol'}]) /*issue - FRM-1535 or TS-446 or FRM-1559*/

//        /*Scenario 7. Add records > FuelCategory*/
//        .addFunction(function(next){t.diag("Scenario 7. Add records "); next();}).wait(100)
//        .openScreen('Fuel Category').wait(200)
//        .checkScreenShown ('fuelcategory').wait(100)
//        .enterGridData('#grdGridTemplate', 4, 'colRinFuelCategoryCode', 'fc05').wait(100)
//        .enterGridData('#grdGridTemplate', 4, 'colDescription', 'fuel category 05').wait(100)
//        .enterGridData('#grdGridTemplate', 4, 'colEquivalenceValue', '5 Test EV').wait(100)
//        .enterGridData('#grdGridTemplate', 5, 'colRinFuelCategoryCode', 'fc06').wait(100)
//        .enterGridData('#grdGridTemplate', 5, 'colDescription', 'fuel category 06').wait(100)
//        .enterGridData('#grdGridTemplate', 5, 'colEquivalenceValue', '6 Test EV').wait(100)
//        .enterGridData('#grdGridTemplate', 6, 'colRinFuelCategoryCode', 'fc07').wait(100)
//        .enterGridData('#grdGridTemplate', 6, 'colDescription', 'fuel category 07').wait(100)
//        .enterGridData('#grdGridTemplate', 6, 'colEquivalenceValue', '7 Test EV').wait(100)
//        .clickButton('#btnSave').wait(100)
//        .checkStatusMessage('Edited')
//        .clickButton('#btnClose').wait(100)
//        .checkIfScreenClosed('fuelcategory').wait(100)

        .done()
})



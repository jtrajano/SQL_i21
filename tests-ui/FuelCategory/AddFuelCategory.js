/**
 * Created by RQuidato on 10/24/14.
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
        .openScreen('Fuel Category').wait(200)
        .checkScreenShown ('fuelcategory').wait(100)
        .checkScreenWindow({alias: 'fuelcategory', title: 'Fuel Category', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: false, save: true, search: false, delete: false, undo: true, close: true})
        .checkControlVisible(['#colFuelTypeCode', '#colDescription', '#colEquivalanceValue'], true)/*change to #colFuelCategoryCode, #colEquivalenceValue*/
        .checkControlVisible('#btnDeleteFuelCategory', true)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
        .checkStatusBar()
        .checkStatusMessage('Ready')


            /* 2. Data entry */
        .addFunction(function(next){t.diag("Scenario 1. Add new records > 2. Data entry"); next();}).wait(100)
        .enterGridData('#grdFuelCategory', 0, 'colFuelTypeCode', 'fcc01').wait(100)
        .enterGridData('#grdFuelCategory', 0, 'colDescription', 'fuel category 01').wait(100)
        .enterGridData('#grdFuelCategory', 1, 'colFuelTypeCode', 'fcc02').wait(100)
        .enterGridData('#grdFuelCategory', 1, 'colDescription', 'fuel category 02').wait(100)
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('fuelcategory').wait(100)


            /* 3. Verify record added*/
        .addFunction(function(next){t.diag("Scenario 1. Add new records > 3. Verify record added"); next();}).wait(100)
        .openScreen('Fuel Category').wait(200)
        .checkScreenShown ('fuelcategory').wait(100)
        .checkGridData('#grdFuelCategory', 0, 'colFuelTypeCode','fcc01')
        .checkGridData('#grdFuelCategory', 0, 'colDescription','fuel category 01')
        .checkGridData('#grdFuelCategory', 1, 'colFuelTypeCode','fcc02')
        .checkGridData('#grdFuelCategory', 1, 'colDescription','fuel category 02')


        /* Scenario 2. Add another record, click Close button, do NOT save the changes */
            /* 1. Data entry. */
        .addFunction(function(next){t.diag("Scenario 2. Add another record, click Close button, do NOT save the changes"); next();}).wait(100)
        .openScreen('Fuel Category').wait(200)
        .checkScreenShown ('fuelcategory').wait(100)
        .enterGridData('#grdFuelCategory', 2, 'colFuelTypeCode', 'fcc03').wait(100)
        .enterGridData('#grdFuelCategory', 2, 'colDescription', 'fuel category 03').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('no').wait(10)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('fuelcategory').wait(100)



        /* Scenario 3. Add another record, click Close button, Cancel*/
            /* 1. Data entry. */
        .addFunction(function(next){t.diag("Scenario 3. Add another record, click Close button, Cancel"); next();}).wait(100)
        .openScreen('Fuel Category').wait(200)
        .checkScreenShown ('fuelcategory').wait(100)
        .enterGridData('#grdFuelCategory', 2, 'colFuelTypeCode', 'fcc03').wait(100)
        .enterGridData('#grdFuelCategory', 2, 'colDescription', 'fuel category 03').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('cancel').wait(10)
        .clickButton('#btnClose').wait(100)


        /* Scenario 4. Add another record, click Close button, SAVE the changes*/
        .addFunction(function(next){t.diag("Scenario 4. Add another record, click Close button, SAVE the changes"); next();}).wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(500)
        .checkIfScreenClosed('fuelcategory').wait(100) /*issue - FRM-1547*/

            /* 2. Verify record not added*/
        .addFunction(function(next){t.diag("Scenario 2. Add another record, click Close button, do NOT save the changes > 2. Verify record added"); next();}).wait(100)
        .openScreen('Fuel Category').wait(200)
        .checkScreenShown ('fuelcategory').wait(100)
        .checkGridData('#grdFuelCategory', 2, 'colFuelTypeCode','fcc03')
        .checkGridData('#grdFuelCategory', 2, 'colDescription','fuel category 03')



        /*Scenario 5. Add duplicate record > FuelTypeCode*/
        .addFunction(function(next){t.diag("Scenario 5. Add duplicate record > FuelTypeCode"); next();}).wait(100)
        .openScreen('Fuel Category').wait(200)
        .checkScreenShown ('fuelcategory').wait(100)
        .enterGridData('#grdFuelCategory', 3, 'colFuelTypeCode', 'fcc03').wait(100)
        .enterGridData('#grdFuelCategory', 3, 'colDescription', 'fuel category 04').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkMessageBox('iRely i21','Fuel Category already exists.','ok','error')
        .clickMessageBoxButton('ok').wait(10)

        /*Scenario 6. Modify duplicate FuelTypeCode to correct it*/
        .addFunction(function(next){t.diag("Scenario 6. Modify duplicate FuelTypeCode to correct it"); next();}).wait(100)
        .enterGridData('#grdFuelCategory', 3, 'colFuelTypeCode', 'fcc04').wait(100)
        .clickButton('#closeButton').wait(100)


//        .enterDummyRowData('#grdFuelCategory', [{ column: 'strRinFuelTypeCode', data: '10Et'}, {column: 'strDescription', data: '10-Ethanol'}]) /*issue - FRM-1535*/



        .done()
    })


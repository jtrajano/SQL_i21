/**
 * Created by RQuidato on 10/29/14.
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
        .expandMenu('RIN').wait(100)
        .openScreen('Fuel Code').wait(200)
        .checkScreenShown ('fuelcode').wait(100)
        .checkScreenWindow({alias: 'fuelcode', title: 'Fuel Code', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: false, save: true, search: false, delete: false, undo: true, close: true})
        .checkControlVisible(['#colRinFuelCode', '#colDescription'], true)
        .checkControlVisible('#btnDelete', true)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
        .checkStatusBar()
        .checkStatusMessage('Ready')


        /* 2. Multiple Data entry */
        .addFunction(function(next){t.diag("Scenario 1. Add new records > 2. Multiple Data entry"); next();}).wait(100)
        .enterGridData('#grdGridTemplate', 0, 'colRinFuelCode', 'f01').wait(100)
        .enterGridData('#grdGridTemplate', 0, 'colDescription', 'fuel 01').wait(100)
        .enterGridData('#grdGridTemplate', 1, 'colRinFuelCode', 'f02').wait(100)
        .enterGridData('#grdGridTemplate', 1, 'colDescription', 'fuel 02').wait(100)
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('fuelcode').wait(100)


        /* 3. Verify record added*/
        .addFunction(function(next){t.diag("Scenario 1. Add new records > 3. Verify records added"); next();}).wait(100)
        .openScreen('Fuel Code').wait(200)
        .checkScreenShown ('fuelcode').wait(100)
        .checkGridData('#grdGridTemplate', 0, 'colRinFuelCode','f02')
        .checkGridData('#grdGridTemplate', 0, 'colDescription','fuel 02')
//        .checkGridData('#grdGridTemplate', 1, 'colRinFuelCode','f01')
//        .checkGridData('#grdGridTemplate', 1, 'colDescription','fuel 01')
        .checkStatusMessage('Ready')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('fuelcode').wait(100)

        /* Scenario 2. Add another record, click Close button, do NOT save the changes */
        /* 1. Data entry. */
        .addFunction(function(next){t.diag("Scenario 2. Add another record, click Close button, do NOT save the changes"); next();}).wait(100)
        .openScreen('Fuel Code').wait(200)
        .checkScreenShown ('fuelcode').wait(100)
        .enterGridData('#grdGridTemplate', 2, 'colRinFuelCode', 'f03').wait(100)
        .enterGridData('#grdGridTemplate', 2, 'colDescription', 'fuel 03').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('no').wait(10)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('fuelcode').wait(100)


        /* Scenario 3. Add another record, click Close button, Cancel*/
        /* 1. Data entry. */
        .addFunction(function(next){t.diag("Scenario 3. Add another record, click Close button, Cancel"); next();}).wait(100)
        .openScreen('Fuel Code').wait(200)
        .checkScreenShown ('fuelcode').wait(100)
        .enterGridData('#grdGridTemplate', 2, 'colRinFuelCode', 'f03').wait(100)
        .enterGridData('#grdGridTemplate', 2, 'colDescription', 'fuel 03').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('cancel').wait(10)
        .clickButton('#btnClose').wait(100)


        /* Scenario 4. Add another record, click Close button, SAVE the changes*/
        .addFunction(function(next){t.diag("Scenario 4. Add another record, click Close button, SAVE the changes"); next();}).wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(500)
        .checkIfScreenClosed('fuelcode').wait(100) /*issue - FRM-1547 or TS-445 or FRM-1560*/

        /* 2. Verify record added*/
        .addFunction(function(next){t.diag("Scenario 4. Add another record, SAVE the changes > 2. Verify record added"); next();}).wait(100)
        .openScreen('Fuel Code').wait(200)
        .checkScreenShown ('fuelcode').wait(100)
        .checkGridData('#grdGridTemplate', 0, 'colRinFuelCode','f03')
        .checkGridData('#grdGridTemplate', 0, 'colDescription','fuel 03')
        .checkStatusMessage('Ready')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('fuelcode').wait(100)


        /*Scenario 5. Add duplicate record */
        .addFunction(function(next){t.diag("Scenario 5. Add duplicate record "); next();}).wait(100)
        .openScreen('Fuel Code').wait(200)
        .checkScreenShown ('fuelcode').wait(100)
        .enterGridData('#grdGridTemplate', 3, 'colRinFuelCode', 'f03').wait(100)
        .enterGridData('#grdGridTemplate', 3, 'colDescription', 'fuel 04').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkMessageBox('iRely i21','Fuel Code already exists.','ok','error') /*issue - IC-84 */
        .clickMessageBoxButton('ok').wait(10)

        /*Scenario 6. Modify duplicate record to correct it*/
        .addFunction(function(next){t.diag("Scenario 6. Modify duplicate record to correct it"); next();}).wait(100)
        .enterGridData('#grdGridTemplate', 3, 'colRinFuelCode', 'f04').wait(100) /*issue - IC-81 */
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question').wait(100)
        .clickMessageBoxButton('yes').wait(10)
        .checkIfScreenClosed('fuelcode').wait(100)



        /* 2. Verify record added*/
        .addFunction(function(next){t.diag("Scenario 6. Modify duplicate record to correct it > 2. Verify record added"); next();}).wait(100)
        .openScreen('Fuel Code').wait(200)
        .checkScreenShown ('fuelcode').wait(100)
        .checkGridData('#grdGridTemplate', 0, 'colRinFuelCode','f04')
        .checkGridData('#grdGridTemplate', 0, 'colDescription','fuel 04')
        .checkStatusMessage('Ready')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('fuelcode').wait(100)

//        .enterDummyRowData('#grdFuelCategory', [{ column: 'strRinFuelTypeCode', data: '10Et'}, {column: 'strDescription', data: '10-Ethanol'}]) /*issue - FRM-1535 or TS-446 or FRM-1559*/

//        /*Scenario 7. Add records > Fuel Code */
//        .addFunction(function(next){t.diag("Scenario 7. Add records "); next();}).wait(100)
//        .openScreen('Fuel Code').wait(200)
//        .checkScreenShown ('fuelcode').wait(100)
//        .enterGridData('#grdGridTemplate', 4, 'colRinFuelCode', 'f05').wait(100)
//        .enterGridData('#grdGridTemplate', 4, 'colDescription', 'fuel 05').wait(100)
//        .enterGridData('#grdGridTemplate', 5, 'colRinFuelCode', 'f06').wait(100)
//        .enterGridData('#grdGridTemplate', 5, 'colDescription', 'fuel 06').wait(100)
//        .enterGridData('#grdGridTemplate', 6, 'colRinFuelCode', 'f07').wait(100)
//        .enterGridData('#grdGridTemplate', 6, 'colDescription', 'fuel 07').wait(100)
//        .clickButton('#btnSave').wait(100)
//        .checkStatusMessage('Edited')
//        .clickButton('#btnClose').wait(100)
//        .checkIfScreenClosed('fuelcode').wait(100)

        .done()
})


/**
 * Created by RQuidato on 11/4/14.
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
        .openScreen('Lot Status').wait(200)
        .checkScreenShown ('lotstatus').wait(100)
        .checkScreenWindow({alias: 'lotstatus', title: 'Lot Status', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: false, save: true, search: false, delete: false, undo: true, close: true})
        .checkControlVisible(['#btnDelete','#btnInsertCriteria','#txtFilterGrid'], true)
        .checkControlVisible(['#colSecondaryStatus', '#colDescription', '#colPrimaryStatus'], true)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
        .checkStatusBar()
        .checkStatusMessage('Ready')


        /* 2. Multiple Data entry */
        .addFunction(function(next){t.diag("Scenario 1. Add new records > 2. Multiple Data entry"); next();}).wait(100)
        .enterGridData('#grdGridTemplate', 0, 'colSecondaryStatus', 'ls01').wait(100)
        .enterGridData('#grdGridTemplate', 0, 'colDescription', 'lot status 01').wait(100)
        .selectGridComboRowByFilter('#grdGridTemplate',0,'colPrimaryStatus','Active')
        .enterGridData('#grdGridTemplate', 1, 'colSecondaryStatus', 'ls02').wait(100)
        .enterGridData('#grdGridTemplate', 1, 'colDescription', 'lot status 02').wait(100)
        .selectGridComboRowByFilter('#grdGridTemplate',1,'colPrimaryStatus','On Hold')
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('lotstatus').wait(100)


        /* 3. Verify record added*/
        .addFunction(function(next){t.diag("Scenario 1. Add new records > 3. Verify record added"); next();}).wait(100)
        .openScreen('Lot Status').wait(200)
        .checkScreenShown ('lotstatus').wait(100)
        .checkGridData('#grdGridTemplate', 0, 'colSecondaryStatus','ls01')
        .checkGridData('#grdGridTemplate', 0, 'colDescription','lot status 01')
        .checkGridData('#grdGridTemplate', 0, 'colPrimaryStatus','Active')
        .checkGridData('#grdGridTemplate', 1, 'colSecondaryStatus','ls02')
        .checkGridData('#grdGridTemplate', 1, 'colDescription','lot status 02')
        .checkGridData('#grdGridTemplate', 1, 'colPrimaryStatus','On Hold')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('lotstatus').wait(100)


        /* Scenario 2. Add another record, click Close button, do NOT save the changes */
        /* 1. Data entry. */
        .addFunction(function(next){t.diag("Scenario 2. Add another record, click Close button, do NOT save the changes"); next();}).wait(100)
        .openScreen('Lot Status').wait(200)
        .checkScreenShown ('lotstatus').wait(100)
        .enterGridData('#grdGridTemplate', 2, 'colSecondaryStatus', 'ls03').wait(100)
        .enterGridData('#grdGridTemplate', 2, 'colDescription', 'lot status 03').wait(100)
        .selectGridComboRowByFilter('#grdGridTemplate',2,'colPrimaryStatus','Quarantine')
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('no').wait(10)
        .checkIfScreenClosed('lotstatus').wait(100)

        /* 2. Verify record not added*/
        .addFunction(function(next){t.diag("Scenario 2. Add another record, click Close button, do NOT save the changes > 2. Verify record added"); next();}).wait(100)
        .openScreen('Lot Status').wait(200)
        .checkScreenShown ('lotstatus').wait(100)
        .checkGridData('#grdGridTemplate', 2, 'colSecondaryStatus','ls03')/* need to have a method to show as false*/
        .checkGridData('#grdGridTemplate', 2, 'colDescription','lot status 03')
        .checkGridData('#grdGridTemplate', 2, 'colPrimaryStatus','Quarantine')


        /* Scenario 3. Add another record, click Close button, Cancel*/
        /* 1. Data entry. */
        .addFunction(function(next){t.diag("Scenario 3. Add another record, click Close button, Cancel"); next();}).wait(100)
        .openScreen('Lot Status').wait(200)
        .checkScreenShown ('lotstatus').wait(100)
        .enterGridData('#grdGridTemplate', 2, 'colSecondaryStatus', 'ls03').wait(100)
        .enterGridData('#grdGridTemplate', 2, 'colDescription', 'lot status 03').wait(100)
        .selectGridComboRowByFilter('#grdGridTemplate',2,'colPrimaryStatus','Quarantine')
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('cancel').wait(10)


        /* 2. Verify record is still there */
        .addFunction(function(next){t.diag("Scenario 2. Add another record, click Close button, do NOT save the changes > 2. Verify record added"); next();}).wait(100)
        .checkGridData('#grdGridTemplate', 2, 'colSecondaryStatus','ls03')
        .checkGridData('#grdGridTemplate', 2, 'colDescription','lot status 03')
        .checkGridData('#grdGridTemplate', 2, 'colPrimaryStatus','Quarantine')

        /* Scenario 4. Add another record, click Close button, SAVE the changes*/
        .addFunction(function(next){t.diag("Scenario 4. Add another record, click Close button, SAVE the changes"); next();}).wait(100)
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(500)
        .checkIfScreenClosed('lotstatus').wait(100) /*issue - FRM-1547 or TS-445 or FRM-1560*/

        /* 2. Verify record is added/saved */
        .addFunction(function(next){t.diag("Scenario 2. Add another record, click Close button, do NOT save the changes > 2. Verify record added"); next();}).wait(100)
        .checkGridData('#grdGridTemplate', 2, 'colSecondaryStatus','ls03')
        .checkGridData('#grdGridTemplate', 2, 'colDescription','lot status 03')
        .checkGridData('#grdGridTemplate', 2, 'colPrimaryStatus','Quarantine')

        /*Scenario 5. Add duplicate record > Secondary Status*/
        .addFunction(function(next){t.diag("Scenario 5. Add duplicate record > FuelTypeCode"); next();}).wait(100)
        .openScreen('Lot Status').wait(200)
        .checkScreenShown ('lotstatus').wait(100)
        .enterGridData('#grdGridTemplate', 3, 'colSecondaryStatus', 'ls03').wait(100)
        .enterGridData('#grdGridTemplate', 3, 'colDescription', 'lot status 04').wait(100)
        .selectGridComboRowByFilter('#grdGridTemplate',2,'colPrimaryStatus','Quarantine').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkMessageBox('iRely i21','Fuel Category already exists.','ok','error') /*issue - IC-84 */
        .clickMessageBoxButton('ok').wait(10)

        /*Scenario 6. Modify duplicate FuelTypeCode to correct it*/
        .addFunction(function(next){t.diag("Scenario 6. Modify duplicate FuelTypeCode to correct it"); next();}).wait(100)
        .enterGridData('#grdGridTemplate', 3, 'colSecondaryStatus', 'ls04').wait(100) /*issue - IC-81 */
        .clickButton('#closeButton').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(500) /*issue - FRM-1562 */
        .checkIfScreenClosed('lotstatus').wait(100)


//        .enterDummyRowData('#grdFuelCategory', [{ column: 'strRinFuelTypeCode', data: '10Et'}, {column: 'strDescription', data: '10-Ethanol'}]) /*issue - FRM-1535 or TS-446 or FRM-1559*/



        .done()
})


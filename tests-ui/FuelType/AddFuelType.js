/**
 * Created by RQuidato on 10/30/14.
 */

StartTest (function (t) {

    var engine = new iRely.TestEngine();
    engine.start(t)

        /*Scenario 1. Add new records */
        /* 1.1. Open screen and check default controls' state */
        .login('ssiadmin','summit','eo').wait(1500)
        .addFunction(function(next){t.diag("Scenario 1. Add new records > 1. Open screen and check default controls' state"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Fuel Type').wait(500)
        .checkScreenShown ('fueltype').wait(200)
        .checkScreenWindow({alias: 'fueltype', title: 'Fuel Types', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
        .checkControlVisible(['#cboFuel','#txtDescription','#cboCommodity','#chkStandard'], true)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
        .checkStatusBar()
        .checkStatusMessage('Ready')
        .checkControlVisible(['#first','#prev','#inputItem','#next','#last','#refresh'],true)


        /* 1.2. Data entry */
        .addFunction(function(next){t.diag("Scenario 1. Add new records > 2. Data entry"); next();}).wait(100)
        .enterData('#txtDocumentName','DocName01').wait(100)
        .enterData('#txtDescription','Document Description 01').wait(100)
//        .selectComboRowByFilter('cboCommodity','Commod01')
        .clickCheckBox('#chkStandard',true).wait(100)
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(500)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(200)
        .checkIfScreenClosed('contractdocument').wait(100)


        /* 1.3. Verify record added*/
        .addFunction(function(next){t.diag("Scenario 1. Add new records > 3. Verify record added"); next();}).wait(100)
        .openScreen('Contract Document').wait(500)
        //search screen name
        .checkScreenShown ('search').wait(200)
        .checkScreenWindow({alias: 'search', title: 'Search Contract Document', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: false, search: false, delete: false, undo: false, close: true})
        .checkControlVisible(['#btnOpenSelected', '#btnRefresh'], true)
//        no checking if correct icon is used
//        no checking if button label is correct
        .checkControlVisible(['#btnInsertCriteria', '#txtFilterGrid','#lblTotalRecords'],true)
        .selectSearchRowByFilter('DocName01')
        .clickButton('#btnOpenSelected').wait(100)
        .addFunction(function(next){t.diag("3.a Opens selected record = Passed"); next();}).wait(100)
        .checkControlData('#txtDocumentName','DocName01')
        .checkControlData('#txtDescription','Document Description 01')
//        .checkControlData('#cboCommodity','Commod01')
        .checkControlData('#chkStandard',true)
        .checkStatusMessage('Ready')
        .addFunction(function(next){t.diag("3.b Correct record is selected and data entered is intact = Passed"); next();}).wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('contractdocument').wait(100)



        /* Scenario 2. Add another record, click Close button, do NOT save the changes */
        .addFunction(function(next){t.diag("Scenario 2. Add another record, click Close button, do NOT save the changes"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Contract Document').wait(500)
        .checkScreenShown ('search').wait(200)
        .checkScreenWindow({alias: 'search', title: 'Search Contract Document', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .clickButton('#btnNew')
        .checkScreenShown ('contractdocument').wait(200)
        .checkScreenWindow({alias: 'contractdocument', title: 'Contract Document', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
        .addFunction(function(next){t.diag("Scenario 1. Add new records > 2. Data entry"); next();}).wait(100)
        .enterData('#txtDocumentName','DocName02').wait(100)
        .enterData('#txtDescription','Document Description 02').wait(100)
//        .selectComboRowByFilter('cboCommodity','Commod01')
        .checkStatusMessage('Edited')
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('no').wait(10)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('contractdocument').wait(100)
        .addFunction(function(next){t.diag("Scenario 2. Added record not saved = Passed"); next();}).wait(100)


        /* Scenario 3. Add another record, click Close button, Cancel*/
        .addFunction(function(next){t.diag("Scenario 3. Add another record, click Close button, Cancel"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Contract Document').wait(500)
        .checkScreenShown ('search').wait(200)
        .checkScreenWindow({alias: 'search', title: 'Search Contract Document', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .clickButton('#btnNew')
        .checkScreenShown ('contractdocument').wait(200)
        .checkScreenWindow({alias: 'contractdocument', title: 'Contract Document', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
        .addFunction(function(next){t.diag("Scenario 1. Add new records > 2. Data entry"); next();}).wait(100)
        .enterData('#txtDocumentName','DocName02').wait(100)
        .enterData('#txtDescription','Document Description 02').wait(100)
//        .selectComboRowByFilter('cboCommodity','Commod02')
        .checkStatusMessage('Edited')
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('cancel').wait(10)
        .clickButton('#btnClose').wait(100)
        .addFunction(function(next){t.diag("Scenario 2. Click Cancel, back to screen = Passed"); next();}).wait(100)
        .clickButton('#btnClose').wait(100)


        /* Scenario 4. Add another record, click Close button, SAVE the changes*/
        .addFunction(function(next){t.diag("Scenario 4. Add another record, click Close button, SAVE the changes"); next();}).wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(500)
        .checkIfScreenClosed('contractdocument').wait(100) /*issue - FRM-1547*/

        /* 4.1. Verify record added*/
        .addFunction(function(next){t.diag("Scenario 1. Add new records > 3. Verify record added"); next();}).wait(100)
        .openScreen('Contract Document').wait(500)
        //search screen name
        .checkScreenShown ('search').wait(200)
        .checkScreenWindow({alias: 'search', title: 'Search Contract Document', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: false, search: false, delete: false, undo: false, close: true})
        .checkControlVisible(['#btnOpenSelected', '#btnRefresh'], true)
//        no checking if correct icon is used
//        no checking if button label is correct
        .checkControlVisible(['#btnInsertCriteria', '#txtFilterGrid','#lblTotalRecords'],true)
        .selectSearchRowByFilter('DocName02')
        .clickButton('#btnOpenSelected').wait(100)
        .addFunction(function(next){t.diag("3.a Opens selected record = Passed"); next();}).wait(100)
        .checkControlData('#txtDocumentName','DocName02')
        .checkControlData('#txtDescription','Document Description 02')
//        .checkControlData('#cboCommodity','Commod02')
        .checkControlData('#chkStandard',false)
        .checkStatusMessage('Ready')
        .addFunction(function(next){t.diag("3.b Correct record is selected and data entered is intact = Passed"); next();}).wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('contractdocument').wait(100)

        /*Scenario 5. Add duplicate record*/
        .addFunction(function(next){t.diag("Scenario 3. Add another record, click Close button, Cancel"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Contract Document').wait(500)
        .checkScreenShown ('search').wait(200)
        .checkScreenWindow({alias: 'search', title: 'Search Contract Document', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .clickButton('#btnNew')
        .checkScreenShown ('contractdocument').wait(200)
        .checkScreenWindow({alias: 'contractdocument', title: 'Contract Document', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
        .addFunction(function(next){t.diag("Scenario 1. Add new records > 2. Data entry"); next();}).wait(100)
        .enterData('#txtDocumentName','DocName02').wait(100)
        .enterData('#txtDescription','Document Description 03').wait(100)
//        .selectComboRowByFilter('cboCommodity','Commod03')
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(100)
        .checkMessageBox('iRely i21','Contract Document already exists.','ok','error') /* IC-84 */
        .clickMessageBoxButton('ok').wait(10)
        .addFunction(function(next){t.diag("Scenario 5. Duplicate record not saved = Passed"); next();}).wait(100)

        /*Scenario 6. Modify duplicate record to correct it*/
        .addFunction(function(next){t.diag("Scenario 6. Modify duplicate record to correct it"); next();}).wait(100)
        .enterData('#txtDocumentName','DocName03').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(500)
        .checkIfScreenClosed('contractdocument').wait(100)
        .addFunction(function(next){t.diag("Scenario 6. Record modified = Passed"); next();}).wait(100)

        /* 6.1. Verify record added*/
        .addFunction(function(next){t.diag("6.1 Verify record added"); next();}).wait(100)
        .openScreen('Contract Document').wait(500)
        //search screen name
        .checkScreenShown ('search').wait(200)
        .checkScreenWindow({alias: 'search', title: 'Search Contract Document', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: false, search: false, delete: false, undo: false, close: true})
        .checkControlVisible(['#btnOpenSelected', '#btnRefresh'], true)
//        no checking if correct icon is used
//        no checking if button label is correct
        .checkControlVisible(['#btnInsertCriteria', '#txtFilterGrid','#lblTotalRecords'],true)
        .selectSearchRowByFilter('DocName03')
        .clickButton('#btnOpenSelected').wait(100)
        .addFunction(function(next){t.diag("6.a Opens selected record = Passed"); next();}).wait(100)
        .checkControlData('#txtDocumentName','DocName03')
        .checkControlData('#txtDescription','Document Description 03')
//        .checkControlData('#cboCommodity','Commod03')
        .checkControlData('#chkStandard',false)
        .checkStatusMessage('Ready')
        .addFunction(function(next){t.diag("6.b Correct record is selected and data entered is intact = Passed"); next();}).wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('contractdocument').wait(100)


        .done()
})

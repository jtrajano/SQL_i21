/**
 * Created by RQuidato on 11/3/14.
 */


StartTest (function (t) {

    var engine = new iRely.TestEngine();
    engine.start(t)

        /*Scenario 1. Add new records */
        /* 1.1. Open screen and check default controls' state */
        .login('ssiadmin','summit','ag').wait(1500)
        .addFunction(function(next){t.diag("Scenario 1. Add new records > 1. Open screen and check default controls' state"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Manufacturer').wait(500)
        .checkScreenShown ('manufacturer').wait(200)
        .checkScreenWindow({alias: 'manufacturer', title: 'Manufacturer', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})

        .checkControlVisible([
            '#txtManufacturer',
            '#txtContact',
            '#btnAddressMap',
            '#txtAddress',
            '#cboZipCode',
            '#txtCity',
            '#txtState',
            '#cboCountry',
            '#txtPhone',
            '#txtFax',
            '#btnWebsite',
            '#txtWebsite',
            '#btnEmail',
            '#txtEmail',
            '#txtNotes'
        ], true)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
        .checkStatusBar()
        .checkStatusMessage('Ready')
        .checkControlVisible(['#first','#prev','#inputItem','#next','#last','#refresh'],true)


        /* 1.2. Data entry */
        .addFunction(function(next){t.diag("Scenario 1. Add new records > 2. Data entry"); next();}).wait(100)
        .enterData('#txtManufacturer','Manu01').wait(100)
        .enterData('#txtContact','Test Contact 01').wait(100)
        .enterData('#txtAddress','4242 Flagstaff Cove').wait(100)
//        .selectComboRowByFilter('#cboZipCode','46815').wait(700) /*issue - IC-6*/
//        .checkControlData('#cboZipCode','46815').wait(100)
//        .checkControlData('#txtCity','Fort Wayne').wait(100)
//        .checkControlData('#txtState','IN').wait(100)
//        .checkControlData('#cboCountry','United States').wait(100)
        .enterData('#txtPhone','800.433.5724').wait(100)
        .enterData('#txtFax','260.486.5187').wait(100)
        .enterData('#txtWebsite','http://www.irely.com/').wait(100)
        .enterData('#txtEmail','info@iRely.com').wait(100)
        .enterData('#txtNotes','This is a note. This is a note. This is a note. This is a note.').wait(100)
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(500)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(200)
        .checkIfScreenClosed('manufacturer').wait(100)


        /* 1.3. Verify record added*/
        .addFunction(function(next){t.diag("Scenario 1. Add new records > 3. Verify record added"); next();}).wait(100)
        .openScreen('Manufacturer').wait(500)
        //search screen name
        .checkScreenShown ('search').wait(200)
        .checkScreenWindow({alias: 'search', title: 'Search Manufacturer', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: false, search: false, delete: false, undo: false, close: true})
        .checkControlVisible(['#btnOpenSelected', '#btnRefresh'], true)
//        no checking if correct icon is used
//        no checking if button label is correct
        .checkControlVisible(['#btnInsertCriteria', '#txtFilterGrid','#lblTotalRecords'],true)
        .selectSearchRowByIndex(0)
        .selectSearchRowByFilter('Manu01')
        .clickButton('#btnOpenSelected').wait(100)
        .addFunction(function(next){t.diag("3.a Opens selected record = Passed"); next();}).wait(100)
        .checkControlData('#txtManufacturer','Manu01')
        .checkControlData('#txtContact','Test Contact 01')
        .checkControlData('#txtAddress','4242 Flagstaff Cove')
        .checkControlData('#txtPhone','800.433.5724')
        .checkControlData('#txtFax','260.486.5187')
        .checkControlData('#txtWebsite','http://www.irely.com/')
        .checkControlData('#txtEmail','info@iRely.com')
        .checkControlData('#txtNotes','This is a note. This is a note. This is a note. This is a note.')
        .checkStatusMessage('Ready')
        .addFunction(function(next){t.diag("3.b Correct record is selected and data entered is intact = Passed"); next();}).wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('manufacturer').wait(100)



        /* Scenario 2. Add another record, click Close button, do NOT save the changes */
        .addFunction(function(next){t.diag("Scenario 2. Add another record, click Close button, do NOT save the changes"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Manufacturer').wait(500)
        .checkScreenShown ('search').wait(200)
        .checkScreenWindow({alias: 'search', title: 'Search Manufacturer', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .clickButton('#btnNew')
        .checkScreenShown ('manufacturer').wait(200)
        .checkScreenWindow({alias: 'manufacturer', title: 'Manufacturer', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
        .addFunction(function(next){t.diag("Scenario 1. Add new records > 2. Data entry"); next();}).wait(100)
        .enterData('#txtManufacturer','Manu02').wait(100)
        .enterData('#txtContact','Test Contact 02').wait(100)
        .enterData('#txtAddress','4242 Flagstaff Cove').wait(100)
//        .selectComboRowByFilter('#cboZipCode','46815').wait(700) /*issue - IC-6*/
//        .checkControlData('#cboZipCode','46815').wait(100)
//        .checkControlData('#txtCity','Fort Wayne').wait(100)
//        .checkControlData('#txtState','IN').wait(100)
//        .checkControlData('#cboCountry','United States').wait(100)
        .enterData('#txtPhone','800.433.5724').wait(100)
        .enterData('#txtFax','260.486.5187').wait(100)
        .enterData('#txtWebsite','http://www.irely.com/').wait(100)
        .enterData('#txtEmail','info@iRely.com').wait(100)
        .enterData('#txtNotes','This is a note. This is a note. This is a note. This is a note.').wait(100)
        .checkStatusMessage('Edited')
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('no').wait(10)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('manufacturer').wait(100)
        .addFunction(function(next){t.diag("Scenario 2. Added record not saved = Passed"); next();}).wait(100)


        /* Scenario 3. Add another record, click Close button, Cancel*/
        .addFunction(function(next){t.diag("Scenario 3. Add another record, click Close button, Cancel"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Manufacturer').wait(500)
        .checkScreenShown ('search').wait(200)
        .checkScreenWindow({alias: 'search', title: 'Search Manufacturer', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .clickButton('#btnNew')
        .checkScreenShown ('manufacturer').wait(200)
        .checkScreenWindow({alias: 'manufacturer', title: 'Manufacturer', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
        .addFunction(function(next){t.diag("Scenario 1. Add new records > 2. Data entry"); next();}).wait(100)
        .enterData('#txtManufacturer','Manu02').wait(100)
        .enterData('#txtContact','Test Contact 01').wait(100)
        .enterData('#txtAddress','4242 Flagstaff Cove').wait(100)
//        .selectComboRowByFilter('#cboZipCode','46815').wait(700) /*issue - IC-6*/
//        .checkControlData('#cboZipCode','46815').wait(100)
//        .checkControlData('#txtCity','Fort Wayne').wait(100)
//        .checkControlData('#txtState','IN').wait(100)
//        .checkControlData('#cboCountry','United States').wait(100)
        .enterData('#txtPhone','800.433.5724').wait(100)
        .enterData('#txtFax','260.486.5187').wait(100)
        .enterData('#txtWebsite','http://www.irely.com/').wait(100)
        .enterData('#txtEmail','info@iRely.com').wait(100)
        .enterData('#txtNotes','This is a note. This is a note. This is a note. This is a note.').wait(100)
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
        .checkIfScreenClosed('manufacturer').wait(100) /*issue - FRM-1547*/

        /* 4.1. Verify record added*/
        .addFunction(function(next){t.diag("Scenario 1. Add new records > 3. Verify record added"); next();}).wait(100)
        .openScreen('Manufacturer').wait(500)
        //search screen name
        .checkScreenShown ('search').wait(200)
        .checkScreenWindow({alias: 'search', title: 'Search Manufacturer', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: false, search: false, delete: false, undo: false, close: true})
        .checkControlVisible(['#btnOpenSelected', '#btnRefresh'], true)
//        no checking if correct icon is used
//        no checking if button label is correct
        .checkControlVisible(['#btnInsertCriteria', '#txtFilterGrid','#lblTotalRecords'],true)
        .selectSearchRowByIndex(0)
        .selectSearchRowByFilter('Manu02')
        .clickButton('#btnOpenSelected').wait(100)
        .addFunction(function(next){t.diag("3.a Opens selected record = Passed"); next();}).wait(100)
        .checkControlData('#txtManufacturer','Manu02')
        .checkControlData('#txtContact','Test Contact 01')
        .checkControlData('#txtAddress','4242 Flagstaff Cove')
        .checkControlData('#txtPhone','800.433.5724')
        .checkControlData('#txtFax','260.486.5187')
        .checkControlData('#txtWebsite','http://www.irely.com/')
        .checkControlData('#txtEmail','info@iRely.com')
        .checkControlData('#txtNotes','This is a note. This is a note. This is a note. This is a note.')
        .checkStatusMessage('Ready')
        .addFunction(function(next){t.diag("3.b Correct record is selected and data entered is intact = Passed"); next();}).wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('manufacturer').wait(100)

          /*Scenario 5. Add duplicate record*/
        .addFunction(function(next){t.diag("Scenario 3. Add another record, click Close button, Cancel"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Manufacturer').wait(500)
        .checkScreenShown ('search').wait(200)
        .checkScreenWindow({alias: 'search', title: 'Search Manufacturer', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .clickButton('#btnNew')
        .checkScreenShown ('manufacturer').wait(200)
        .checkScreenWindow({alias: 'manufacturer', title: 'Manufacturer', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
        .addFunction(function(next){t.diag("Scenario 1. Add new records > 2. Data entry"); next();}).wait(100)
        .enterData('#txtManufacturer','Manu02').wait(100)
        .enterData('#txtContact','Test Contact 01').wait(100)
        .enterData('#txtAddress','4242 Flagstaff Cove').wait(100)
//        .selectComboRowByFilter('#cboZipCode','46815').wait(700) /*issue - IC-6*/
//        .checkControlData('#cboZipCode','46815').wait(100)
//        .checkControlData('#txtCity','Fort Wayne').wait(100)
//        .checkControlData('#txtState','IN').wait(100)
//        .checkControlData('#cboCountry','United States').wait(100)
        .enterData('#txtPhone','800.433.5724').wait(100)
        .enterData('#txtFax','260.486.5187').wait(100)
        .enterData('#txtWebsite','http://www.irely.com/').wait(100)
        .enterData('#txtEmail','info@iRely.com').wait(100)
        .enterData('#txtNotes','This is a note. This is a note. This is a note. This is a note.').wait(100)
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(100)
        .checkMessageBox('iRely i21','Manufacturer already exists.','ok','error') /* IC-84 */
        .clickMessageBoxButton('ok').wait(10)
        .addFunction(function(next){t.diag("Scenario 5. Duplicate record not saved = Passed"); next();}).wait(100)

        /*Scenario 6. Modify duplicate record to correct it*/
        .addFunction(function(next){t.diag("Scenario 6. Modify duplicate record to correct it"); next();}).wait(100)
        .enterData('#txtManufacturer','Manu03').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(500)
        .checkIfScreenClosed('manufacturer').wait(100)
        .addFunction(function(next){t.diag("Scenario 6. Record modified = Passed"); next();}).wait(100)

        /* 6.1. Verify record added*/
        .addFunction(function(next){t.diag("6.1 Verify record added"); next();}).wait(100)
        .openScreen('Manufacturer').wait(500)
        //search screen name
        .checkScreenShown ('search').wait(200)
        .checkScreenWindow({alias: 'search', title: 'Search Manufacturer', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: false, search: false, delete: false, undo: false, close: true})
        .checkControlVisible(['#btnOpenSelected', '#btnRefresh'], true)
//        no checking if correct icon is used
//        no checking if button label is correct
        .checkControlVisible(['#btnInsertCriteria', '#txtFilterGrid','#lblTotalRecords'],true)
        .selectSearchRowByIndex(0)
        .selectSearchRowByFilter('Manu03')
        .clickButton('#btnOpenSelected').wait(100)
        .addFunction(function(next){t.diag("6.a Opens selected record = Passed"); next();}).wait(100)
        .checkControlData('#txtManufacturer','Manu03')
        .checkControlData('#txtContact','Test Contact 01')
        .checkControlData('#txtAddress','4242 Flagstaff Cove')
        .checkControlData('#txtPhone','800.433.5724')
        .checkControlData('#txtFax','260.486.5187')
        .checkControlData('#txtWebsite','http://www.irely.com/')
        .checkControlData('#txtEmail','info@iRely.com')
        .checkControlData('#txtNotes','This is a note. This is a note. This is a note. This is a note.')
        .checkStatusMessage('Ready')
        .addFunction(function(next){t.diag("6.b Correct record is selected and data entered is intact = Passed"); next();}).wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('manufacturer').wait(100)


        .done()
})

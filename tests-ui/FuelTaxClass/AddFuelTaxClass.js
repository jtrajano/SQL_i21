/**  * Created by RQuidato on 10/31/14.  */


StartTest (function (t) {

    var engine = new iRely.TestEngine();
    engine.start(t)

        /*1. Open screen and check default control's state*/
        .login('ssiadmin','summit','ag').wait(1500)
        .addFunction(function(next){t.diag("1. Open screen and check default control's state"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Fuel Tax Class').wait(500)
        .checkScreenShown ('fueltaxclass').wait(200)
        .checkScreenWindow({alias: 'fueltaxclass', title: 'Fuel Tax Class', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
        .checkControlVisible([
            '#txtTaxClassCode',
            '#txtIrsTaxCode',
            '#txtDescription',
            '#grdProductCode'
        ], true)
        .checkFieldLabel([
            {
                itemId : '#txtTaxClassCode',
                label: 'Tax Class Code'
            },
            {
                itemId : '#txtIrsTaxCode',
                label: 'IRS Tax Code'
            },
            {
                itemId : '#txtDescription',
                label: 'Description'
            }
        ])
        .checkControlVisible(['#btnDelete', '#btnInsertCriteria','#txtFilterGrid'], true)
        .checkControlVisible(['#colState','#colProductCode'], true)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
        .checkStatusBar()
        .checkStatusMessage('Ready')
        .checkControlVisible(['#first','#prev','#inputItem','#next','#last','#refresh'],true)


        /*2. Add data*/
        .addFunction(function(next){t.diag("2. Add data"); next();}).wait(100)
        .enterData('#txtTaxClassCode','tcc01').wait(100)
        .enterData('#txtIrsTaxCode','itc01').wait(100)
        .enterData('#txtDescription','tax class code 01').wait(100)
        .selectGridComboRowByFilter('#colState','Colorado')
        .enterData('#colProductCode','prodcode01')
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(500)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(200)
        .checkIfScreenClosed('fueltaxclass').wait(100)


//        Verify record added
        .openScreen('Fuel Tax Class').wait(500)
//        search screen name
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Fuel Tax Class', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: false, search: false, delete: false, undo: false, close: true})
        .checkControlVisible(['#btnOpenSelected', '#btnRefresh'], true)
//        no checking if correct icon is used
//        no checking if button label is correct
//        check columns shown
//        check column headers
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
        .checkStatusBar()
        .checkStatusMessage('Ready')
        .selectSearchRowByFilter('tcc01')
        .clickButton('#btnOpenSelected').wait(100)
        .checkScreenShown ('Fuel Tax Class').wait(200)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkControlData('#txtTaxClassCode','tcc01')
        .checkControlData('#txtIrsTaxCode','itc01').wait(100)
        .checkControlData('#txtDescription','tax class code 01')
        .checkControlData('#colState','Colorado')
        .checkControlData('#colProductCode','prodcode01')
        .checkStatusMessage('Ready')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('fueltaxclass').wait(100)



        /*3. Add another record, Click Close button, do NOT save the changes > New on Search*/
        .addFunction(function(next){t.diag("3. Add another record, Click Close button, do NOT save the changes > New on Search"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Fuel Tax Class').wait(500)
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Fuel Tax Class', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .clickButton('#btnNew')
        .checkScreenShown ('Fuel Tax Class').wait(300)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'fueltaxclass', title: 'Fuel Tax Class', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
        .enterData('#txtTaxClassCode','tcc02').wait(100)
        .enterData('#txtIrsTaxCode','itc02').wait(100)
        .enterData('#txtDescription','tax class code 02').wait(100)
        .selectGridComboRowByFilter('#colState','Florida')
        .enterData('#colProductCode','prodcode02')
        .checkStatusMessage('Edited')
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('no').wait(10)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('fueltaxclass').wait(100)


        /*4. Add another record, click Close, Cancel > New on Search*/
        .addFunction(function(next){t.diag("4. Add another record, click Close, Cancel > New on Search"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Fuel Tax Class').wait(500)
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Fuel Tax Class', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .clickButton('#btnNew')
        .checkScreenShown ('fueltaxclass').wait(200)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'fueltaxclass', title: 'Pack Type', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
        .enterData('#txtTaxClassCode','tcc02').wait(100)
        .enterData('#txtIrsTaxCode','itc02').wait(100)
        .enterData('#txtDescription','tax class code 02').wait(100)
        .selectGridComboRowByFilter('#colState','Florida')
        .enterData('#colProductCode','prodcode02')
        .checkStatusMessage('Edited')
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('cancel').wait(10)
        .clickButton('#btnClose').wait(100)



        /*5. Add another record, Click Close button, SAVE the changes > New on Search */
        .addFunction(function(next){t.diag("5. Add another record, Click Close button, SAVE the changes > New on Search"); next();}).wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(500)
        .checkIfScreenClosed('fueltaxclass').wait(100) /*issue - FRM-1547*/

//        Verify record added
        .openScreen('Fuel Tax Class').wait(500)
//        search screen name
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Fuel Tax Class', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: false, search: false, delete: false, undo: false, close: true})
        .checkControlVisible(['#btnOpenSelected', '#btnRefresh'], true)
//        no checking if correct icon is used
//        no checking if button label is correct
//        check columns shown
//        check column headers
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
        .checkStatusBar()
        .checkStatusMessage('Ready')
        .selectSearchRowByFilter('tcc02')
        .clickButton('#btnOpenSelected').wait(100)
        .checkScreenShown ('Fuel Tax Class').wait(200)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkControlData('#txtTaxClassCode','tcc02').wait(100)
        .checkControlData('#txtIrsTaxCode','itc02').wait(100)
        .checkControlData('#txtDescription','tax class code 02').wait(100)
        .checkControlData('#colState','Florida')
        .checkControlData('#colProductCode','prodcode02')
        .checkStatusMessage('Ready')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('fueltaxclass').wait(100)

        /*6. Add duplicate record > New on existing record */
        .addFunction(function(next){t.diag("6. Add duplicate record > New on existing record "); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Fuel Tax Class').wait(500)
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Fuel Tax Class', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .selectSearchRowByFilter('tcc01')
        .clickButton('#btnOpenSelected').wait(100)
        .checkScreenShown ('fueltaxclass').wait(200)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'packtype', title: 'Fuel Tax Class', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
        .clickButton('#btnNew')
        .checkControlData('#txtTaxClassCode','').wait(100)
        .checkControlData('#txtIrsTaxCode','').wait(100)
        .checkControlData('#txtDescription','').wait(100)
        .checkControlData('#colState','')
        .checkControlData('#colProductCode','')
        .enterData('#txtTaxClassCode','tcc02').wait(100)
        .enterData('#txtIrsTaxCode','itc03').wait(100)
        .enterData('#txtDescription','tax class code 03').wait(100)
        .enterData('#colState','Maryland')
        .enterData('#colProductCode','prodcode03')
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(100)
        .checkMessageBox('iRely i21','Manufacturer already exists.','ok','error') /* IC-84 */
        .clickMessageBoxButton('ok').wait(10)

//        Modify duplicate record to correct it
        .addFunction(function(next){t.diag("6. Add duplicate record > New on existing record > Modify duplicate record to correct it "); next();}).wait(100)
        .enterData('#txtTaxClassCode','tcc03').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(500)
        .checkIfScreenClosed('fueltaxclass').wait(100)

        /*7. Add primary key only then SAVE > New from existing record then Search*/
        .addFunction(function(next){t.diag("7. Add primary key only then SAVE > New from existing record then Search"); next();}).wait(100)
        .openScreen('Fuel Tax Class').wait(500)
        //search screen name
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Fuel Tax Class', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .selectSearchRowByFilter('tcc02')
        .clickButton('#btnOpenSelected').wait(100)
        .checkScreenShown ('fueltaxclass').wait(200)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'fueltaxclass', title: 'Fuel Tax Class', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
        .clickButton('#btnSearch')
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Fuel Tax Class', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .clickButton('#btnNew')
        .checkScreenShown ('fueltaxclass').wait(200)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'fueltaxclass', title: 'Fuel Tax Class', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .enterData('#txtTaxClassCode','tcc04').wait(100)
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(100)
        .checkIfScreenClosed('fueltaxclass').wait(100)


        .done()
})

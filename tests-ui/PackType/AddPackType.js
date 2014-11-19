/**
 * Created by RQuidato on 11/19/14.
 */
StartTest (function (t) {

    var engine = new iRely.TestEngine();
    engine.start(t)

        /*1. Open screen and check default control's state*/
        .login('ssiadmin','summit','ag').wait(1500)
        .addFunction(function(next){t.diag("1. Open screen and check default control's state"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Pack Type').wait(500)
        .checkScreenShown ('packtype').wait(200)
        .checkScreenWindow({alias: 'packtype', title: 'Pack Type', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
        .checkControlVisible([
            '#txtPackTypeName',
            '#txtDescription',
            ], true)
        .checkFieldLabel([
            {
                itemId : '#txtPackTypeName',
                label: 'Pack Type Name'
            },
            {
                itemId : '#txtDescription',
                label: 'Description'
            }
        ])
        .checkControlVisible(['#btnDelete', '#btnInsertCriteria','#txtFilterGrid'], true)
        .checkControlVisible(['#colSourceUOM','#colTargetUOM','#colConversionFactor'], true)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
        .checkStatusBar()
        .checkStatusMessage('Ready')
        .checkControlVisible(['#first','#prev','#inputItem','#next','#last','#refresh'],true)


        /*2. Add data*/
        .addFunction(function(next){t.diag("2. Add data"); next();}).wait(100)
        .enterData('#txtPackTypeName','ptn01').wait(100)
        .enterData('#txtDescription','pack type name 01').wait(100)
//        .selectComboRowByFilter('#colSourceUOM','grams').wait(700) /*issue - IC-6*/
//        .selectComboRowByFilter('#colTargetUOM','kilograms').wait(700)
//        .selectComboRowByFilter('#colConversionFactor','20').wait(700)
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(500)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(200)
        .checkIfScreenClosed('packtype').wait(100)


//        Verify record added
        .openScreen('Pack Type').wait(500)
//        search screen name
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Pack Types', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: false, search: false, delete: false, undo: false, close: true})
        .checkControlVisible(['#btnOpenSelected', '#btnRefresh'], true)
//        no checking if correct icon is used
//        no checking if button label is correct
//        check columns shown
//        check column headers
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
        .checkStatusBar()
        .checkStatusMessage('Ready')
        .selectSearchRowByFilter('ptn01')
        .clickButton('#btnOpenSelected').wait(100)
        .checkScreenShown ('Pack Type').wait(200)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkControlData('#txtPackTypeName','ptn01')
        .checkControlData('#txtDescription','pack type name 01')
        .checkStatusMessage('Ready')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('packtype').wait(100)



        /*3. Add another record, Click Close button, do NOT save the changes > New on Search*/
        .addFunction(function(next){t.diag("3. Add another record, Click Close button, do NOT save the changes > New on Search"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Pack Type').wait(500)
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Pack Types', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .clickButton('#btnNew')
        .checkScreenShown ('Pack Type').wait(300)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'packtype', title: 'Pack Type', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
        .enterData('#txtPackTypeName','ptn02').wait(100)
        .enterData('#txtDescription','pack type name 02').wait(100)
//        .selectComboRowByFilter('#colSourceUOM','grams').wait(700) /*issue - IC-6*/
//        .selectComboRowByFilter('#colTargetUOM','kilograms').wait(700)
//        .selectComboRowByFilter('#colConversionFactor','20').wait(700)
        .checkStatusMessage('Edited')
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('no').wait(10)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('packtype').wait(100)


        /*4. Add another record, click Close, Cancel > New on Search*/
        .addFunction(function(next){t.diag("4. Add another record, click Close, Cancel > New on Search"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Manufacturer').wait(500)
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Pack Types', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .clickButton('#btnNew')
        .checkScreenShown ('packtype').wait(200)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'packtype', title: 'Pack Type', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
        .enterData('#txtPackTypeName','ptn02').wait(100)
        .enterData('#txtDescription','pack type name 02').wait(100)
//        .selectComboRowByFilter('#colSourceUOM','grams').wait(700) /*issue - IC-6*/
//        .selectComboRowByFilter('#colTargetUOM','kilograms').wait(700)
//        .selectComboRowByFilter('#colConversionFactor','20').wait(700)
        .checkStatusMessage('Edited')
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('cancel').wait(10)
        .clickButton('#btnClose').wait(100)
        .clickButton('#btnClose').wait(100)


        /*5. Add another record, Click Close button, SAVE the changes > New on Search */
        .addFunction(function(next){t.diag("5. Add another record, Click Close button, SAVE the changes > New on Search"); next();}).wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(500)
        .checkIfScreenClosed('packtype').wait(100) /*issue - FRM-1547*/

//        Verify record added
        .openScreen('Pack Type').wait(500)
//        search screen name
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Pack Types', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: false, search: false, delete: false, undo: false, close: true})
        .checkControlVisible(['#btnOpenSelected', '#btnRefresh'], true)
//        no checking if correct icon is used
//        no checking if button label is correct
//        check columns shown
//        check column headers
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
        .checkStatusBar()
        .checkStatusMessage('Ready')
        .selectSearchRowByFilter('ptn01')
        .clickButton('#btnOpenSelected').wait(100)
        .checkScreenShown ('Pack Type').wait(200)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkControlData('#txtPackTypeName','ptn02')
        .checkControlData('#txtDescription','pack type name 02')
        .checkStatusMessage('Ready')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('packtype').wait(100)

        /*6. Add duplicate record > New on existing record */
        .addFunction(function(next){t.diag("6. Add duplicate record > New on existing record "); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Pack Type').wait(500)
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Pack Types', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .selectSearchRowByFilter('ptn01')
        .clickButton('#btnOpenSelected').wait(100)
        .checkScreenShown ('packtype').wait(200)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'packtype', title: 'Pack Type', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
        .clickButton('#btnNew')
        .checkControlData('#txtPackTypeName','')
        .checkControlData('#txtDescription','')
        .enterData('#txtPackTypeName','ptn02').wait(100)
        .enterData('#txtDescription','pack type name 03').wait(100)
//        .selectComboRowByFilter('#colSourceUOM','grams').wait(700) /*issue - IC-6*/
//        .selectComboRowByFilter('#colTargetUOM','kilograms').wait(700)
//        .selectComboRowByFilter('#colConversionFactor','20').wait(700)
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(100)
        .checkMessageBox('iRely i21','Manufacturer already exists.','ok','error') /* IC-84 */
        .clickMessageBoxButton('ok').wait(10)

//        Modify duplicate record to correct it
        .addFunction(function(next){t.diag("6. Add duplicate record > New on existing record > Modify duplicate record to correct it "); next();}).wait(100)
        .enterData('#txtPackTypeName','ptn03').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(500)
        .checkIfScreenClosed('packtype').wait(100)

        /*7. Add primary key only then SAVE > New from existing record then Search*/
        .addFunction(function(next){t.diag("7. Add primary key only then SAVE > New from existing record then Search"); next();}).wait(100)
        .openScreen('Pack Type').wait(500)
        //search screen name
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Pack Types', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .selectSearchRowByFilter('ptn01')
        .clickButton('#btnOpenSelected').wait(100)
        .checkScreenShown ('packtype').wait(200)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'packtype', title: 'Pack Type', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
        .clickButton('#btnSearch')
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Pack Types', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .clickButton('#btnNew')
        .checkScreenShown ('packtype').wait(200)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'packtype', title: 'Pack Type', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkControlData('#txtPackTypeName','')
        .checkControlData('#txtDescription','')
        .enterData('#txtPackTypeName','ptn04').wait(100)
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(100)
        .checkIfScreenClosed('packtype').wait(100)


        .done()
})

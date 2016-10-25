/**
 * Created by RQuidato on 10/31/14.
 */

StartTest (function (t) {

    var engine = new iRely.TestEngine();
    engine.start(t)

       /*1. Open screen and check default control's state*/
        .login('ssiadmin','summit','ag').wait(1500)
        .addFunction(function(next){t.diag("1. Open screen and check default control's state"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Inventory Tag').wait(200)
        .checkScreenShown ('inventorytag').wait(200)
        .checkScreenWindow({alias: 'inventorytag', title: 'Inventory Tag', collapse: true, maximize: true, minimize: false, restore: false, close: true }).wait(100)
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true}).wait(100)
        .checkControlVisible(['#txtTagNumber','#chkHAZMATMessage','#txtDescription','#txtMessage'], true)
        .checkFieldLabel([
            {
                itemId : '#txtTagNumber',
                label: 'Tag Number'
            },
            {
                itemId : '#chkHAZMATMessage',
                label: 'HAZMAT Message'
            },
            {
                itemId : '#txtDescription',
                label: 'Description'
            },
            {
                itemId : '#txtMessage',
                label: 'Message'
            }
        ])
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
        .checkStatusBar()
        .checkStatusMessage('Ready')
        .checkControlVisible(['#first','#prev','#inputItem','#next','#last','#refresh'],true)


        /*2. Add data*/
        .addFunction(function(next){t.diag("2. Add data"); next();}).wait(100)
        .enterData('#txtTagNumber','itn01').wait(100)
        .clickCheckBox('#chkHAZMATMessage', true)
        .enterData('#txtDescription', 'inventory tag number 01')
        .enterData('#txtMessage','This is an Inventory Tag message 01. !@#123 - This is an Inventory Tag message 01. !@#123 - This is an Inventory Tag message 01. !@#123 - This is an Inventory Tag message 01. !@#123 - This is an Inventory Tag message 01. !@#123 - ')
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(500)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(200)
        .checkIfScreenClosed('inventorytag').wait(100)


//        Verify record added
        .openScreen('Inventory Tag').wait(200)
//        search screen name
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Inventory Tag', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: false, search: false, delete: false, undo: false, close: true})
        .checkControlVisible(['#btnOpenSelected', '#btnRefresh'], true)
//        no checking if correct icon is used
//        no checking if button label is correct
//        check columns shown
//        check column headers
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
        .checkStatusBar()
        .checkStatusMessage('Ready')
        .selectSearchRowByFilter('itn01')
        .clickButton('#btnOpenSelected').wait(100)
        .checkScreenShown ('inventorytag').wait(200)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkControlData('#txtTagNumber','itn01')
        .checkControlData('#chkHAZMATMessage',true)
        .checkControlData('#txtDescription','inventory tag number 01')
        .checkControlData('#txtMessage','This is an Inventory Tag message 01. !@#123 - This is an Inventory Tag message 01. !@#123 - This is an Inventory Tag message 01. !@#123 - This is an Inventory Tag message 01. !@#123 - This is an Inventory Tag message 01. !@#123 - ')
        .checkStatusMessage('Ready')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('inventorytag').wait(100)



        /*3. Add another record, Click Close button, do NOT save the changes > New on Search*/
        .addFunction(function(next){t.diag("3. Add another record, Click Close button, do NOT save the changes > New on Search"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Inventory Tag').wait(500)
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Inventory Tag', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .clickButton('#btnNew')
        .checkScreenShown ('inventorytag').wait(300)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'inventorytag', title: 'Inventory Tag', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
        .enterData('#txtTagNumber','itn02').wait(100)
        .clickCheckBox('#chkHAZMATMessage', false)
        .enterData('#txtDescription', 'inventory tag number 02')
        .enterData('#txtMessage','This is an Inventory Tag message 02.')
        .checkStatusMessage('Edited')
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('no').wait(10)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('inventorytag').wait(100)


        /*4. Add another record, click Close, Cancel > New on Search*/
        .addFunction(function(next){t.diag("4. Add another record, click Close, Cancel > New on Search"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Inventory Tag').wait(500)
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Inventory Tag', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .clickButton('#btnNew')
        .checkScreenShown ('inventorytag').wait(200)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'inventorytag', title: 'Inventory Tag', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
        .enterData('#txtTagNumber','itn02').wait(100)
        .clickCheckBox('#chkHAZMATMessage', false)
        .enterData('#txtDescription', 'inventory tag number 02')
        .enterData('#txtMessage','This is an Inventory Tag message 02.')
        .checkStatusMessage('Edited')
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('cancel').wait(10)
        .clickButton('#btnClose').wait(100)



        /*5. Add another record, Click Close button, SAVE the changes > New on Search */
        .addFunction(function(next){t.diag("5. Add another record, Click Close button, SAVE the changes > New on Search"); next();}).wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(500)
        .checkIfScreenClosed('inventorytag').wait(100) /*issue - FRM-1547*/

//        Verify record added
        .openScreen('Inventory Tag').wait(500)
//        search screen name
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Inventory Tag', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: false, search: false, delete: false, undo: false, close: true})
        .checkControlVisible(['#btnOpenSelected', '#btnRefresh'], true)
//        no checking if correct icon is used
//        no checking if button label is correct
//        check columns shown
//        check column headers
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
        .checkStatusBar()
        .checkStatusMessage('Ready')
        .selectSearchRowByFilter('itn02')
        .clickButton('#btnOpenSelected').wait(100)
        .checkScreenShown ('inventorytag').wait(200)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkControlData('#txtTagNumber','itn02')
        .checkControlData('#chkHAZMATMessage',false)
        .checkControlData('#txtDescription','inventory tag number 02')
        .checkControlData('#txtMessage','This is an Inventory Tag message 02.')
        .checkStatusMessage('Ready')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('inventorytag').wait(100)

        /*6. Add duplicate record > New on existing record */
        .addFunction(function(next){t.diag("6. Add duplicate record > New on existing record "); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Inventory Tag').wait(500)
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Inventory Tag', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .selectSearchRowByFilter('itn01')
        .clickButton('#btnOpenSelected').wait(100)
        .checkScreenShown ('inventorytag').wait(200)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'inventorytag', title: 'Inventory Tag', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
        .clickButton('#btnNew')
        .checkControlData('#txtTagNumber','')
        .checkControlData('#chkHAZMATMessage',false)
        .checkControlData('#txtDescription','')
        .checkControlData('#txtMessage','')
        .enterData('#txtTagNumber','itn02').wait(100)
        .clickCheckBox('#chkHAZMATMessage', false)
        .enterData('#txtDescription', 'inventory tag number 03')
        .enterData('#txtMessage','This is an Inventory Tag message 03.')
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(100)
        .checkMessageBox('iRely i21','Manufacturer already exists.','ok','error') /* IC-84 */
        .clickMessageBoxButton('ok').wait(10)

//        Modify duplicate record to correct it
        .addFunction(function(next){t.diag("6. Add duplicate record > New on existing record > Modify duplicate record to correct it "); next();}).wait(100)
        .enterData('#txtTagNumber','itn03').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(500)
        .checkIfScreenClosed('inventorytag').wait(100)

        /*7. Add primary key only then SAVE > New from existing record then Search*/
        .addFunction(function(next){t.diag("7. Add primary key only then SAVE > New from existing record then Search"); next();}).wait(100)
        .openScreen('Inventory Tag').wait(500)
        //search screen name
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Inventory Tag', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .selectSearchRowByFilter('itn01')
        .clickButton('#btnOpenSelected').wait(100)
        .checkScreenShown ('inventorytag').wait(200)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'inventorytag', title: 'Inventory Tag', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
        .clickButton('#btnSearch')
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Inventory Tag', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .clickButton('#btnNew')
        .checkScreenShown ('inventorytag').wait(200)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'inventorytag', title: 'Inventory Tag', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkControlData('#txtTagNumber','')
        .checkControlData('#chkHAZMATMessage',false)
        .checkControlData('#txtDescription','')
        .checkControlData('#txtMessage','')
        .enterData('#txtTagNumber','itn04').wait(100)
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('inventorytag').wait(100)

        .done()
})

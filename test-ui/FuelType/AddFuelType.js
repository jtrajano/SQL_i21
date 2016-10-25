/**
 * Created by RQuidato on 10/30/14.
 */
StartTest (function (t) {

    var engine = new iRely.TestEngine();
    engine.start(t)

        /*1. Open screen and check default control's state*/
        .login('ssiadmin','summit','ag').wait(1500)
        .addFunction(function(next){t.diag("1. Open screen and check default control's state"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Fuel Type').wait(500)
        .checkScreenShown ('fueltype').wait(200)
        .checkScreenWindow({alias: 'fueltype', title: 'Fuel Types', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
        .checkControlVisible([
            '#cboFuelCategory',
            '#cboFeedStock',
            '#txtBatchNo',
            '#txtEndingRinGallonsForBatch',
            '#txtEquivalenceValue',
            '#cboFuelCode',
            '#cboProductionProcess',
            '#cboFeedStockUom',
            '#txtFeedStockFactor',
            '#chkRenewableBiomass',
            '#txtPercentOfDenaturant',
            '#chkDeductDenaturantFromRin',

        ], true)
        .checkFieldLabel([
            {
                itemId : '#cboFuelCategory',
                label: 'Fuel Category'
            },
            {
                itemId : '#cboFeedStock',
                label: 'Feed Stock'
            },
            {
                itemId : '#txtBatchNo',
                label: 'Batch No'
            },
            {
                itemId : '#txtEndingRinGallonsForBatch',
                label: 'Ending RIN Gallons for Batch'
            },
            {
                itemId : '#txtEquivalenceValue',
                label: 'Equivalence Value'
            },
            {
                itemId : '#cboFuelCode',
                label: 'Fuel Code'
            },
            {
                itemId : '#cboProductionProcess',
                label: 'Production Process'
            },
            {
                itemId : '#cboFeedStockUom',
                label: 'Feed Stock UOM'
            },
            {
                itemId : '#txtFeedStockFactor',
                label: 'Feed Stock Factor'
            },
            {
                itemId : '#chkRenewableBiomass',
                label: 'Renewable Biomass'
            },
            {
                itemId : '#txtPercentOfDenaturant',
                label: 'Percent of Denaturant'
            },
            {
                itemId : '#chkDeductDenaturantFromRin',
                label: 'Deduct Denaturant from RIN'
            }
        ])
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
        .checkStatusBar()
        .checkStatusMessage('Ready')
        .checkControlVisible(['#first','#prev','#inputItem','#next','#last','#refresh'],true)


        /*2. Add data*/
        .addFunction(function(next){t.diag("2. Add data"); next();}).wait(100)
        .selectComboRowByFilter('#cboFuelCategory','fc01') //check with Lawrence what is the primary field of this screen
        .selectComboRowByFilter('#cboFeedStock','fs01')
        .enterData('#txtBatchNo','10001').wait(100)
        .enterData('#txtEndingRinGallonsForBatch','25').wait(100)
        .checkControlData('#txtEquivalenceValue','1.0 Test EV')
        .enterData('#txtEquivalenceValue','1.0 Test EVa')
        .selectComboRowByFilter('#cboFuelCode','f01')
        .selectComboRowByFilter('#cboProductionProcess','pp01')
        .selectComboRowByFilter('#cboFeedStockUom','liter')
        .enterData('#txtFeedStockFactor','10')
        .clickCheckBox('#chkRenewableBiomass')
        .enterData('#txtPercentOfDenaturant','15')
        .clickCheckBox('#chkDeductDenaturantFromRin')
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(500)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(200)
        .checkIfScreenClosed('fueltype').wait(100)


//        Verify record added
        .openScreen('Fuel Type').wait(500)
//        search screen name
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Fuel Type', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: false, search: false, delete: false, undo: false, close: true})
        .checkControlVisible(['#btnOpenSelected', '#btnRefresh'], true)
//        no checking if correct icon is used
//        no checking if button label is correct
//        check columns shown
//        check column headers
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
        .checkStatusBar()
        .checkStatusMessage('Ready')
        .selectSearchRowByFilter('fc01')
        .clickButton('#btnOpenSelected').wait(100)
        .checkScreenShown ('Fuel Type').wait(200)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkControlData('#txtPackTypeName','ptn01')
        .checkControlData('#txtDescription','pack type name 01')
        .checkControlData('#txtBatchNo','10001')
        .checkControlData('#txtEndingRinGallonsForBatch','25')
        .checkControlData('#txtEquivalenceValue','1.0 Test EVa')
        .checkControlData('#cboFuelCode','f01')
        .checkControlData('#cboProductionProcess','pp01')
        .checkControlData('#cboFeedStockUom','liter')
        .checkControlData('#txtFeedStockFactor','10')
        .checkCheckboxValue('#chkRenewableBiomass',true)
        .checkControlData('#txtPercentOfDenaturant','15')
        .checkCheckboxValue('#chkDeductDenaturantFromRin',true)
        .checkStatusMessage('Ready')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('fueltype').wait(100)



        /*3. Add another record, Click Close button, do NOT save the changes > New on Search*/
        .addFunction(function(next){t.diag("3. Add another record, Click Close button, do NOT save the changes > New on Search"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Fuel Type').wait(500)
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Fuel Type', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .clickButton('#btnNew')
        .checkScreenShown ('Fuel Type').wait(300)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'fueltype', title: 'Fuel Type', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
        .selectComboRowByFilter('#cboFuelCategory','fc02')
        .selectComboRowByFilter('#cboFeedStock','fs02')
        .enterData('#txtBatchNo','10002').wait(100)
        .enterData('#txtEndingRinGallonsForBatch','30').wait(100)
        .checkControlData('#txtEquivalenceValue','2.25 Test EV')
        .enterData('#txtEquivalenceValue','2.25 Test EVa')
        .selectComboRowByFilter('#cboFuelCode','f02')
        .selectComboRowByFilter('#cboProductionProcess','pp02')
        .selectComboRowByFilter('#cboFeedStockUom','liter')
        .enterData('#txtFeedStockFactor','15.35')
        .enterData('#txtPercentOfDenaturant','15.25')
        .checkStatusMessage('Edited')
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('no').wait(10)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('fueltype').wait(100)


        /*4. Add another record, click Close, Cancel > New on Search*/
        .addFunction(function(next){t.diag("4. Add another record, click Close, Cancel > New on Search"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Fuel Type').wait(500)
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Fuel Type', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .clickButton('#btnNew')
        .checkScreenShown ('fueltype').wait(200)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'fueltype', title: 'Fuel Type', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
        .selectComboRowByFilter('#cboFuelCategory','fc02')
        .selectComboRowByFilter('#cboFeedStock','fs02')
        .enterData('#txtBatchNo','10002').wait(100)
        .enterData('#txtEndingRinGallonsForBatch','30').wait(100)
        .checkControlData('#txtEquivalenceValue','2.25 Test EV')
        .enterData('#txtEquivalenceValue','2.25 Test EVa')
        .selectComboRowByFilter('#cboFuelCode','f02')
        .selectComboRowByFilter('#cboProductionProcess','pp02')
        .selectComboRowByFilter('#cboFeedStockUom','liter')
        .enterData('#txtFeedStockFactor','15.35')
        .enterData('#txtPercentOfDenaturant','15.25')
        .checkStatusMessage('Edited')
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('cancel').wait(10)
        .clickButton('#btnClose').wait(100)



        /*5. Add another record, Click Close button, SAVE the changes > New on Search */
        .addFunction(function(next){t.diag("5. Add another record, Click Close button, SAVE the changes > New on Search"); next();}).wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(500)
        .checkIfScreenClosed('fueltype').wait(100) /*issue - FRM-1547*/

//        Verify record added
        .openScreen('Fuel Type').wait(500)
//        search screen name
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Fuel Type', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: false, search: false, delete: false, undo: false, close: true})
        .checkControlVisible(['#btnOpenSelected', '#btnRefresh'], true)
//        no checking if correct icon is used
//        no checking if button label is correct
//        check columns shown
//        check column headers
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
        .checkStatusBar()
        .checkStatusMessage('Ready')
        .selectSearchRowByFilter('fc02')
        .clickButton('#btnOpenSelected').wait(100)
        .checkScreenShown ('Fuel Type').wait(200)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkControlData('#cboFuelCategory','fc02')
        .checkControlData('#cboFeedStock','fs02')
        .checkControlData('#txtBatchNo','10002').wait(100)
        .checkControlData('#txtEndingRinGallonsForBatch','30').wait(100)
        .checkControlData('#txtEquivalenceValue','2.25 Test EVa')
        .checkControlData('#cboFuelCode','f02')
        .checkControlData('#cboProductionProcess','pp02')
        .checkControlData('#cboFeedStockUom','liter')
        .checkControlData('#txtFeedStockFactor','15.35')
        .checkCheckboxValue('#chkRenewableBiomass',false)
        .checkControlData('#txtPercentOfDenaturant','15.25')
        .checkCheckboxValue('#chkDeductDenaturantFromRin',false)
        .checkStatusMessage('Ready')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('fueltype').wait(100)

        /*6. Add duplicate record > New on existing record */
        .addFunction(function(next){t.diag("6. Add duplicate record > New on existing record "); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Fuel Type').wait(500)
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Fuel Type', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .selectSearchRowByFilter('fc01')
        .clickButton('#btnOpenSelected').wait(100)
        .checkScreenShown ('fueltype').wait(200)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'fueltype', title: 'Fuel Type', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
        .clickButton('#btnNew')
        .checkControlData('#cboFuelCategory','')
        .checkControlData('#cboFeedStock','')
        .checkControlData('#txtBatchNo','').wait(100)
        .checkControlData('#txtEndingRinGallonsForBatch','').wait(100)
        .checkControlData('#txtEquivalenceValue','')
        .checkControlData('#txtEquivalenceValue','')
        .checkControlData('#cboFuelCode','')
        .checkControlData('#cboProductionProcess','')
        .checkControlData('#cboFeedStockUom','')
        .checkControlData('#txtFeedStockFactor','')
        .checkCheckboxValue('#chkRenewableBiomass',false)
        .checkControlData('#txtPercentOfDenaturant','')
        .checkCheckboxValue('#chkDeductDenaturantFromRin',false)
        .selectComboRowByFilter('#cboFuelCategory','fc02')
        .selectComboRowByFilter('#cboFeedStock','fs03')
        .enterData('#txtBatchNo','10003').wait(100)
        .enterData('#txtEndingRinGallonsForBatch','28').wait(100)
        .checkControlData('#txtEquivalenceValue','2.25 Test EV')
        .enterData('#txtEquivalenceValue','2.25 Test EVb')
        .selectComboRowByFilter('#cboFuelCode','f03')
        .selectComboRowByFilter('#cboProductionProcess','pp03')
        .selectComboRowByFilter('#cboFeedStockUom','liter')
        .enterData('#txtFeedStockFactor','18.0')
        .enterData('#txtPercentOfDenaturant','5')
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(100)
        .checkMessageBox('iRely i21','Manufacturer already exists.','ok','error') /* IC-84 */
        .clickMessageBoxButton('ok').wait(10)

//        Modify duplicate record to correct it
        .addFunction(function(next){t.diag("6. Add duplicate record > New on existing record > Modify duplicate record to correct it "); next();}).wait(100)
        .enterData('#cboFuelCategory','fc03').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(500)
        .checkIfScreenClosed('fueltype').wait(100)

        /*7. Add primary key only then SAVE > New from existing record then Search*/
        .addFunction(function(next){t.diag("7. Add primary key only then SAVE > New from existing record then Search"); next();}).wait(100)
        .openScreen('Fuel Type').wait(500)
        //search screen name
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Fuel Type', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .selectSearchRowByFilter('ptn01')
        .clickButton('#btnOpenSelected').wait(100)
        .checkScreenShown ('fueltype').wait(200)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'fueltype', title: 'Fuel Type', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
        .clickButton('#btnSearch')
        .checkScreenShown ('search').wait(200)
        .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'search', title: 'Search Fuel Type', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .clickButton('#btnNew')
        .checkScreenShown ('fueltype').wait(200)
        .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
        .checkScreenWindow({alias: 'fueltype', title: 'Fuel Type', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkControlData('#cboFuelCategory','fc03')
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(100)
        .checkIfScreenClosed('fueltype').wait(100)


        .done()
})

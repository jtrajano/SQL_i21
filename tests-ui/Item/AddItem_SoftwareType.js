
StartTest (function (t) {

    var engine = new iRely.TestEngine(),
        commonSM = Ext.create('SystemManager.CommonSM');
    engine.start(t)

        /*Add Item - Software Type Lot Tracked Yes Serial Number)*/
        .addFunction(function (next) { commonSM.commonLogin(t, next); })
        .addFunction(function(next){t.diag("Scenario 1. Open screen and check default controls' state"); next();}).wait(100)
        .expandMenu('Inventory').wait(200)
        .openScreen('Items').wait(5000)
        .checkScreenWindow({alias: 'icitems',title: 'Inventory UOMs',collapse: true,maximize: true,minimize: false,restore: false,close: true}).wait(1000)
        .checkSearchToolbarButton({new: true, view: true, openselected: false, openall: false, refresh: true, export: true, close: true}).wait(100)
        .clickButton('#btnNew').wait(200)
        .checkScreenShown('icitem').wait(200)
        .checkToolbarButton({ new: true, save: true, search: true,refresh: false, delete: true, undo: true,duplicate: true, close: true })
        .checkControlVisible(['#btnInsertUom','#btnDeleteUom', '#btnLoadUOM', '#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid'], true)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName', '#btnEmailUrl'], true)
        .checkStatusMessage('Ready')

        .addFunction(function(next){t.diag("Scenario 2. Add Software Item Type"); next();}).wait(100)
        .enterData('#txtItemNo','IItem-010').wait(200)
        .selectComboRowByIndex('#cboType',8).wait(200)
        .enterData('#txtShortName','Test Software Item').wait(200)
        .enterData('#txtDescription','Software Type Item').wait(200)
        .addFunction(function(next){t.diag("Setup Item Category"); next();}).wait(100)
        .selectComboRowByFilter('#cboCategory', 'Software',300, 'strCategoryCode').wait(300)
        .checkControlReadOnly('#cboLotTracking', true).wait(100)
        .checkControlData('#cboLotTracking', 'No').wait(100)
        .checkControlReadOnly('#cboTracking', true).wait(100)
        .checkControlData('#cboTracking', 'Item Level').wait(100)


        .addFunction(function(next){t.diag("Setup Item GL Accounts"); next();}).wait(100)
        .clickTab('#cfgSetup').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 0,'strAccountCategory','General', 300,'strAccountCategory').wait(100)

        .selectGridComboRowByFilter('#grdGlAccounts', 0,'strAccountId','10003-0000-000', 400,'strAccountId').wait(100)
        /*Account ID's for Maintenance Sales not yet set for Demo db, will uncomment this after demo db is updated*/
        /*.selectGridComboRowByFilter('#grdGlAccounts', 1,'strAccountId','50000-0000-000', 400,'strAccountId').wait(100)*/


        .addFunction(function(next){t.diag("Setup Item Location"); next();}).wait(100)
        .clickTab('#cfgLocation').wait(100)
        .checkControlVisible(['#btnAddLocation','#btnAddMultipleLocation','#btnEditLocation','#btnDeleteLocation', '#cboCopyLocation', '#btnGridLayout','#btnInsertCriteria','#txtFilterGrid'], true).wait(100)
        .clickButton('#btnAddLocation').wait(100)
        .checkToolbarButton({ new: true, save: true, search: true,refresh: false, delete: true, undo: true, close: true }).wait(1000)
        .enterData('#txtDescription','Test Pos Description').wait(200)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave')
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)

        .addFunction(function(next){t.diag("Setup Item Pricing"); next();}).wait(100)
        .clickTab('#cfgPricing').wait(100)
        .checkControlVisible(['#btnInsertPricing','#btnDeletePricing','#btnGridLayout','#btnInsertCriteria','#txtFilterGrid'], true).wait(100)
        .checkGridData('#grdPricing', 0, 'strLocationName', '0001 - Fort Wayne').wait(100)
        .enterGridData('#grdPricing', 0, 'dblLastCost', '15.6').wait(300)
        .enterGridData('#grdPricing', 0, 'dblStandardCost', '18.2').wait(300)
        .enterGridData('#grdPricing', 0, 'dblAverageCost', '15.5').wait(300)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave')
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)
        .done()
});
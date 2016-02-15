StartTest (function (t) {

    var engine = new iRely.TestEngine(),
        commonSM = Ext.create('SystemManager.CommonSM');
    engine.start(t)

        /*Add Item - Raw Material Type Lot Tracked Yes Serial Number)*/
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

        .addFunction(function(next){t.diag("Scenario 2. Add Inventory Item Lot tracked Yes-Serial Number"); next();}).wait(100)
        .enterData('#txtItemNo','IItem-004').wait(200)
        .selectComboRowByIndex('#cboType',6).wait(200)
        .enterData('#txtShortName','Test Raw Material Item').wait(200)
        .enterData('#txtDescription','Raw Material Item - 004 Lot Yes Serial').wait(200)
        .addFunction(function(next){t.diag("Setup Item Category"); next();}).wait(100)
        .selectComboRowByFilter('#cboCategory', 'RM',300, 'strCategoryCode').wait(300)
        .selectComboRowByIndex('#cboLotTracking',1).wait(200)
        .checkControlReadOnly('#cboTracking', true).wait(100)
        .checkControlData('#cboTracking', 'Lot Level').wait(100)


        .addFunction(function(next){t.diag(" Setup Item UOM"); next();}).wait(100)
        .clickButton('#btnLoadUOM').wait(100)
        .clickGridCheckBox('#grdUnitOfMeasure', 'strUnitMeasure', 'LB', 'ysnStockUnit', true).wait(100)

        .addFunction(function(next){t.diag("Setup Item GL Accounts"); next();}).wait(100)
        .clickTab('#cfgSetup').wait(100)
        .clickButton('#btnAddRequiredAccounts').wait(100)
        .checkGridData('#grdGlAccounts', 0, 'colGLAccountCategory', 'AP Clearing').wait(100)
        .checkGridData('#grdGlAccounts', 1, 'colGLAccountCategory', 'Inventory').wait(100)
        .checkGridData('#grdGlAccounts', 2, 'colGLAccountCategory', 'Cost of Goods').wait(100)
        .checkGridData('#grdGlAccounts', 3, 'colGLAccountCategory', 'Sales Account').wait(100)
        .checkGridData('#grdGlAccounts', 4, 'colGLAccountCategory', 'Inventory In-Transit').wait(100)
        .checkGridData('#grdGlAccounts', 5, 'colGLAccountCategory', 'Inventory Adjustment').wait(100)
        .checkGridData('#grdGlAccounts', 6, 'colGLAccountCategory', 'Work In Progress').wait(100)
        .checkGridData('#grdGlAccounts', 7, 'colGLAccountCategory', 'Auto-Negative').wait(100)
        .checkGridData('#grdGlAccounts', 8, 'colGLAccountCategory', 'Revalue Sold').wait(100)
        .checkGridData('#grdGlAccounts', 9, 'colGLAccountCategory', 'Write-Off Sold').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 0,'strAccountId','21000-0000-000', 400,'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 1,'strAccountId','16000-0000-000', 400,'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 2,'strAccountId','50000-0000-000', 400,'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 3,'strAccountId','40010-0001-006', 400,'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 4,'strAccountId','16050-0000-000', 400,'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 5,'strAccountId','16040-0000-000', 400,'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 6,'strAccountId','16060-0000-000', 400,'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 7,'strAccountId','16010-0000-000', 400,'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 8,'strAccountId','16030-0000-000', 400,'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 9,'strAccountId','16020-0000-000', 400,'strAccountId').wait(100)

        .addFunction(function(next){t.diag("Setup Item Manufacturing Tab"); next();}).wait(100)
        .clickTab('#cfgManufacturing').wait(100)
        .enterData('#txtLifeTime','300').wait(100)
        .selectComboRowByIndex('#cboLifetimeType',0).wait(200)
        .enterData('#txtReceiveLife','50').wait(100)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave')
        .checkStatusMessage('Saved').wait(100)

        .addFunction(function(next){t.diag("Setup Item Location"); next();}).wait(100)
        .clickTab('#cfgLocation').wait(100)
        .checkControlVisible(['#btnAddLocation','#btnAddMultipleLocation','#btnEditLocation','#btnDeleteLocation', '#cboCopyLocation', '#btnGridLayout','#btnInsertCriteria','#txtFilterGrid'], true).wait(100)
        .clickButton('#btnAddLocation').wait(100)
        .checkToolbarButton({ new: true, save: true, search: true,refresh: false, delete: true, undo: true, close: true }).wait(1000)
        .selectComboRowByFilter('#cboDefaultVendor', '0001005057', 600, 'intVendorId').wait(100)
        .enterData('#txtDescription','Test Pos Description').wait(200)
        .selectComboRowByFilter('#cboSubLocation','Processing Plant',600, 'intSubLocationId').wait(100)
        .selectComboRowByFilter('#cboStorageLocation','RM Storage',600, 'intStorageLocationId').wait(100)
        .selectComboRowByFilter('#cboIssueUom','LB',600, 'strUnitMeasure').wait(100)
        .selectComboRowByFilter('#cboReceiveUom','LB',600, 'strUnitMeasure').wait(100)
        .selectComboRowByIndex('#cboNegativeInventory',1).wait(200)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave')
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)


        .addFunction(function(next){t.diag("Setup Item Pricing"); next();}).wait(100)
        .clickTab('#cfgPricing').wait(100)
        .checkControlVisible(['#btnInsertPricing','#btnDeletePricing','#btnGridLayout','#btnInsertCriteria','#txtFilterGrid'], true).wait(100)
        .checkGridData('#grdPricing', 0, 'strLocationName', '0001 - Fort Wayne').wait(100)
        .enterGridData('#grdPricing', 0, 'dblLastCost', '8.5').wait(300)
        .enterGridData('#grdPricing', 0, 'dblStandardCost', '8.2').wait(300)
        .enterGridData('#grdPricing', 0, 'dblAverageCost', '8.5').wait(300)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave')
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)


        /*Add Item - Raw Material Type Lot Tracked Yes Manual)*/
        .addFunction(function(next){t.diag("Scenario 3. Add Inventory Item Lot tracked Yes Manual"); next();}).wait(100)
        .clickButton('#btnNew').wait(100)
        .enterData('#txtItemNo','IItem-005').wait(200)
        .selectComboRowByIndex('#cboType',6).wait(200)
        .enterData('#txtShortName','Test Raw Material Item').wait(200)
        .enterData('#txtDescription','Raw Material Item - 005 Lot Yes Manual').wait(200)
        .addFunction(function(next){t.diag("Setup Item Category"); next();}).wait(100)
        .selectComboRowByFilter('#cboCategory', 'RM',300, 'strCategoryCode').wait(300)
        .selectComboRowByIndex('#cboLotTracking',1).wait(200)
        .checkControlReadOnly('#cboTracking', true).wait(100)
        .checkControlData('#cboTracking', 'Lot Level').wait(100)


        .addFunction(function(next){t.diag(" Setup Item UOM"); next();}).wait(100)
        .clickButton('#btnLoadUOM').wait(100)
        .clickGridCheckBox('#grdUnitOfMeasure', 'strUnitMeasure', 'LB', 'ysnStockUnit', true).wait(100)

        .addFunction(function(next){t.diag("Setup Item GL Accounts"); next();}).wait(100)
        .clickTab('#cfgSetup').wait(100)
        .clickButton('#btnAddRequiredAccounts').wait(100)
        .checkGridData('#grdGlAccounts', 0, 'colGLAccountCategory', 'AP Clearing').wait(100)
        .checkGridData('#grdGlAccounts', 1, 'colGLAccountCategory', 'Inventory').wait(100)
        .checkGridData('#grdGlAccounts', 2, 'colGLAccountCategory', 'Cost of Goods').wait(100)
        .checkGridData('#grdGlAccounts', 3, 'colGLAccountCategory', 'Sales Account').wait(100)
        .checkGridData('#grdGlAccounts', 4, 'colGLAccountCategory', 'Inventory In-Transit').wait(100)
        .checkGridData('#grdGlAccounts', 5, 'colGLAccountCategory', 'Inventory Adjustment').wait(100)
        .checkGridData('#grdGlAccounts', 6, 'colGLAccountCategory', 'Work In Progress').wait(100)
        .checkGridData('#grdGlAccounts', 7, 'colGLAccountCategory', 'Auto-Negative').wait(100)
        .checkGridData('#grdGlAccounts', 8, 'colGLAccountCategory', 'Revalue Sold').wait(100)
        .checkGridData('#grdGlAccounts', 9, 'colGLAccountCategory', 'Write-Off Sold').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 0,'strAccountId','21000-0000-000', 400,'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 1,'strAccountId','16000-0000-000', 400,'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 2,'strAccountId','50000-0000-000', 400,'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 3,'strAccountId','40010-0001-006', 400,'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 4,'strAccountId','16050-0000-000', 400,'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 5,'strAccountId','16040-0000-000', 400,'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 6,'strAccountId','16060-0000-000', 400,'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 7,'strAccountId','16010-0000-000', 400,'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 8,'strAccountId','16030-0000-000', 400,'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 9,'strAccountId','16020-0000-000', 400,'strAccountId').wait(100)

        .addFunction(function(next){t.diag("Setup Item Manufacturing Tab"); next();}).wait(100)
        .clickTab('#cfgManufacturing').wait(100)
        .enterData('#txtLifeTime','60').wait(100)
        .selectComboRowByIndex('#cboLifetimeType',1).wait(200)
        .enterData('#txtReceiveLife','5').wait(100)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave')
        .checkStatusMessage('Saved').wait(100)

        .addFunction(function(next){t.diag("Setup Item Location"); next();}).wait(100)
        .clickTab('#cfgLocation').wait(100)
        .checkControlVisible(['#btnAddLocation','#btnAddMultipleLocation','#btnEditLocation','#btnDeleteLocation', '#cboCopyLocation', '#btnGridLayout','#btnInsertCriteria','#txtFilterGrid'], true).wait(100)
        .clickButton('#btnAddLocation').wait(100)
        .checkToolbarButton({ new: true, save: true, search: true,refresh: false, delete: true, undo: true, close: true }).wait(1000)
        .selectComboRowByFilter('#cboDefaultVendor', '0001005057', 600, 'intVendorId').wait(100)
        .enterData('#txtDescription','Test Pos Description').wait(200)
        .selectComboRowByFilter('#cboSubLocation','Processing Plant',600, 'intSubLocationId').wait(100)
        .selectComboRowByFilter('#cboStorageLocation','RM Storage',600, 'intStorageLocationId').wait(100)
        .selectComboRowByFilter('#cboIssueUom','LB',600, 'strUnitMeasure').wait(100)
        .selectComboRowByFilter('#cboReceiveUom','LB',600, 'strUnitMeasure').wait(100)
        .selectComboRowByIndex('#cboNegativeInventory',1).wait(200)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave')
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)


        .addFunction(function(next){t.diag("Setup Item Pricing"); next();}).wait(100)
        .clickTab('#cfgPricing').wait(100)
        .checkControlVisible(['#btnInsertPricing','#btnDeletePricing','#btnGridLayout','#btnInsertCriteria','#txtFilterGrid'], true).wait(100)
        .checkGridData('#grdPricing', 0, 'strLocationName', '0001 - Fort Wayne').wait(100)
        .enterGridData('#grdPricing', 0, 'dblLastCost', '8.5').wait(300)
        .enterGridData('#grdPricing', 0, 'dblStandardCost', '8.2').wait(300)
        .enterGridData('#grdPricing', 0, 'dblAverageCost', '8.5').wait(300)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave')
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)

        /*Add Item - Raw Material Type Non Lotted)*/
        .addFunction(function(next){t.diag("Scenario 3. Add Inventory Item Lot tracked Yes Manual"); next();}).wait(100)
        .clickButton('#btnNew').wait(100)
        .enterData('#txtItemNo','IItem-006').wait(200)
        .selectComboRowByIndex('#cboType',6).wait(200)
        .enterData('#txtShortName','Test Raw Material Item').wait(200)
        .enterData('#txtDescription','Raw Material Item - 006 Lot Yes Manual').wait(200)
        .addFunction(function(next){t.diag("Setup Item Category"); next();}).wait(100)
        .selectComboRowByFilter('#cboCategory', 'RM',300, 'strCategoryCode').wait(300)
        .selectComboRowByIndex('#cboLotTracking',2).wait(200)
        .checkControlReadOnly('#cboTracking', true).wait(100)
        .checkControlData('#cboTracking', 'Item Level').wait(100)


        .addFunction(function(next){t.diag(" Setup Item UOM"); next();}).wait(100)
        .clickButton('#btnLoadUOM').wait(100)
        .clickGridCheckBox('#grdUnitOfMeasure', 'strUnitMeasure', 'LB', 'ysnStockUnit', true).wait(100)

        .addFunction(function(next){t.diag("Setup Item GL Accounts"); next();}).wait(100)
        .clickTab('#cfgSetup').wait(100)
        .clickButton('#btnAddRequiredAccounts').wait(100)
        .checkGridData('#grdGlAccounts', 0, 'colGLAccountCategory', 'AP Clearing').wait(100)
        .checkGridData('#grdGlAccounts', 1, 'colGLAccountCategory', 'Inventory').wait(100)
        .checkGridData('#grdGlAccounts', 2, 'colGLAccountCategory', 'Cost of Goods').wait(100)
        .checkGridData('#grdGlAccounts', 3, 'colGLAccountCategory', 'Sales Account').wait(100)
        .checkGridData('#grdGlAccounts', 4, 'colGLAccountCategory', 'Inventory In-Transit').wait(100)
        .checkGridData('#grdGlAccounts', 5, 'colGLAccountCategory', 'Inventory Adjustment').wait(100)
        .checkGridData('#grdGlAccounts', 6, 'colGLAccountCategory', 'Work In Progress').wait(100)
        .checkGridData('#grdGlAccounts', 7, 'colGLAccountCategory', 'Auto-Negative').wait(100)
        .checkGridData('#grdGlAccounts', 8, 'colGLAccountCategory', 'Revalue Sold').wait(100)
        .checkGridData('#grdGlAccounts', 9, 'colGLAccountCategory', 'Write-Off Sold').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 0,'strAccountId','21000-0000-000', 400,'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 1,'strAccountId','16000-0000-000', 400,'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 2,'strAccountId','50000-0000-000', 400,'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 3,'strAccountId','40010-0001-006', 400,'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 4,'strAccountId','16050-0000-000', 400,'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 5,'strAccountId','16040-0000-000', 400,'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 6,'strAccountId','16060-0000-000', 400,'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 7,'strAccountId','16010-0000-000', 400,'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 8,'strAccountId','16030-0000-000', 400,'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 9,'strAccountId','16020-0000-000', 400,'strAccountId').wait(100)

        .addFunction(function(next){t.diag("Setup Item Manufacturing Tab"); next();}).wait(100)
        .clickTab('#cfgManufacturing').wait(100)
        .enterData('#txtLifeTime','30').wait(100)
        .selectComboRowByIndex('#cboLifetimeType',2).wait(200)
        .enterData('#txtReceiveLife','5').wait(100)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave')
        .checkStatusMessage('Saved').wait(100)

        .addFunction(function(next){t.diag("Setup Item Location"); next();}).wait(100)
        .clickTab('#cfgLocation').wait(100)
        .checkControlVisible(['#btnAddLocation','#btnAddMultipleLocation','#btnEditLocation','#btnDeleteLocation', '#cboCopyLocation', '#btnGridLayout','#btnInsertCriteria','#txtFilterGrid'], true).wait(100)
        .clickButton('#btnAddLocation').wait(100)
        .checkToolbarButton({ new: true, save: true, search: true,refresh: false, delete: true, undo: true, close: true }).wait(1000)
        .selectComboRowByFilter('#cboDefaultVendor', '0001005057', 600, 'intVendorId').wait(100)
        .enterData('#txtDescription','Test Pos Description').wait(200)
        .selectComboRowByFilter('#cboSubLocation','Processing Plant',600, 'intSubLocationId').wait(100)
        .selectComboRowByFilter('#cboStorageLocation','RM Storage',600, 'intStorageLocationId').wait(100)
        .selectComboRowByFilter('#cboIssueUom','LB',600, 'strUnitMeasure').wait(100)
        .selectComboRowByFilter('#cboReceiveUom','LB',600, 'strUnitMeasure').wait(100)
        .selectComboRowByIndex('#cboNegativeInventory',1).wait(200)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave')
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)


        .addFunction(function(next){t.diag("Setup Item Pricing"); next();}).wait(100)
        .clickTab('#cfgPricing').wait(100)
        .checkControlVisible(['#btnInsertPricing','#btnDeletePricing','#btnGridLayout','#btnInsertCriteria','#txtFilterGrid'], true).wait(100)
        .checkGridData('#grdPricing', 0, 'strLocationName', '0001 - Fort Wayne').wait(100)
        .enterGridData('#grdPricing', 0, 'dblLastCost', '8.5').wait(300)
        .enterGridData('#grdPricing', 0, 'dblStandardCost', '8.2').wait(300)
        .enterGridData('#grdPricing', 0, 'dblAverageCost', '8.5').wait(300)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave')
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)



        .done()
});


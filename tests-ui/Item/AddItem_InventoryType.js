StartTest(function (t) {

    var engine = new iRely.TestEngine(),
        commonSM = Ext.create('SystemManager.CommonSM');

    engine.start(t)

        /*Add Item - Inventory Type Lot Tracked Yes Serial Number)*/
        .addFunction(function (next) { commonSM.commonLogin(t, next); })
        .addFunction(function (next) { t.diag("Scenario 1. Open screen and check default controls' state"); next(); }).wait(100)
        .expandMenu('Inventory').wait(5000)
        .openScreen('Items').wait(5000)
        .checkScreenWindow({ alias: 'icitems', title: 'Inventory UOMs', collapse: true, maximize: true, minimize: false, restore: false, close: true }).wait(1000)
        .checkSearchToolbarButton({ new: true, view: true, openselected: false, openall: false, refresh: true, export: true, close: true }).wait(100)
        .clickButton('#btnNew').wait(200)
        .checkScreenShown('icitem').wait(200)
        .checkToolbarButton({ new: true, save: true, search: true, refresh: false, delete: true, undo: true, duplicate: true, close: true })
        .checkControlVisible(['#btnInsertUom', '#btnDeleteUom', '#btnLoadUOM', '#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid'], true)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName', '#btnEmailUrl'], true)
        .checkStatusMessage('Ready')

        .addFunction(function (next) { t.diag("Scenario 2. Add Inventory Item Lot tracked Yes-Serial Number"); next(); }).wait(100)
        // JavaScript source code
        .enterData('#txtItemNo', 'IItem-001').wait(200)
        /*.selectComboRowByIndex('#cboType',0).wait(200)*/
        .enterData('#txtShortName', 'Test Inventory Item').wait(200)
        .enterData('#txtDescription', 'Inventory Item - 001 Lot Yes Serial').wait(200)
        .addFunction(function (next) { t.diag("Setup Item Commodity and Category"); next(); }).wait(100)
        .selectComboRowByFilter('#cboCommodity', 'C', 300, 'strCommodityCode').wait(300)
        .selectComboRowByIndex('#cboLotTracking', 1).wait(200)
        .checkControlReadOnly('#cboTracking', true).wait(100)
        .checkControlData('#cboTracking', 'Lot Level').wait(100)
        .selectComboRowByFilter('#cboCategory', 'Grains', 300, 'strCategoryCode').wait(300)

        .addFunction(function (next) { t.diag(" Setup Item UOM"); next(); }).wait(100)
        .selectGridComboRowByFilter('#grdUnitOfMeasure', 0, 'strUnitMeasure', 'LB', 300, 'strUnitMeasure').wait(100)
        .clickButton('#btnInsertUom').wait(100)
        .selectGridComboRowByFilter('#grdUnitOfMeasure', 1, 'strUnitMeasure', '50 lb bag', 300, 'strUnitMeasure').wait(100)
        .clickButton('#btnInsertUom').wait(100)
        .selectGridComboRowByFilter('#grdUnitOfMeasure', 2, 'strUnitMeasure', 'Bushels', 300, 'strUnitMeasure').wait(100)
        .clickGridCheckBox('#grdUnitOfMeasure', 'strUnitMeasure', 'LB', 'ysnStockUnit', true).wait(100)

        .addFunction(function (next) { t.diag("Setup Item GL Accounts"); next(); }).wait(100)
        .clickTab('#cfgSetup').wait(100)
        .clickButton('#btnAddRequiredAccounts').wait(100)
        .checkGridData('#grdGlAccounts', 0, 'colGLAccountCategory', 'AP Clearing').wait(100)
        .checkGridData('#grdGlAccounts', 1, 'colGLAccountCategory', 'Inventory').wait(100)
        .checkGridData('#grdGlAccounts', 2, 'colGLAccountCategory', 'Cost of Goods').wait(100)
        .checkGridData('#grdGlAccounts', 3, 'colGLAccountCategory', 'Sales Account').wait(100)
        .checkGridData('#grdGlAccounts', 4, 'colGLAccountCategory', 'Inventory In-Transit').wait(100)
        .checkGridData('#grdGlAccounts', 5, 'colGLAccountCategory', 'Inventory Adjustment').wait(100)
        .checkGridData('#grdGlAccounts', 6, 'colGLAccountCategory', 'Auto-Negative').wait(100)
        .checkGridData('#grdGlAccounts', 7, 'colGLAccountCategory', 'Revalue Sold').wait(100)
        .checkGridData('#grdGlAccounts', 8, 'colGLAccountCategory', 'Write-Off Sold').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 0, 'strAccountId', '21000-0000-000', 400, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 1, 'strAccountId', '16000-0000-000', 400, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 2, 'strAccountId', '50000-0000-000', 400, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 3, 'strAccountId', '40010-0001-006', 400, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 4, 'strAccountId', '16050-0000-000', 400, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 5, 'strAccountId', '16040-0000-000', 400, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 6, 'strAccountId', '16010-0000-000', 400, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 7, 'strAccountId', '16030-0000-000', 400, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 8, 'strAccountId', '16020-0000-000', 400, 'strAccountId').wait(100)

        .addFunction(function (next) { t.diag("Setup Item Location"); next(); }).wait(100)
        .clickTab('#cfgLocation').wait(100)
        .checkControlVisible(['#btnAddLocation', '#btnAddMultipleLocation', '#btnEditLocation', '#btnDeleteLocation', '#cboCopyLocation', '#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid'], true).wait(100)
        .clickButton('#btnAddLocation').wait(100)
        .checkToolbarButton({ new: true, save: true, search: true, refresh: false, delete: true, undo: true, close: true }).wait(1000)
        .selectComboRowByFilter('#cboDefaultVendor', '0001005057', 600, 'intVendorId').wait(100)
        .enterData('#txtDescription', 'Test Pos Description').wait(200)
        .selectComboRowByFilter('#cboSubLocation', 'Processing Plant', 600, 'intSubLocationId').wait(100)
        .selectComboRowByFilter('#cboStorageLocation', 'RM Storage', 600, 'intStorageLocationId').wait(100)
        .selectComboRowByFilter('#cboIssueUom', 'LB', 600, 'strUnitMeasure').wait(100)
        .selectComboRowByFilter('#cboReceiveUom', 'LB', 600, 'strUnitMeasure').wait(100)
        .selectComboRowByIndex('#cboNegativeInventory', 1).wait(200)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave')
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)

        .addFunction(function (next) { t.diag("Setup Item Pricing"); next(); }).wait(100)
        .clickTab('#cfgPricing').wait(100)
        .checkControlVisible(['#btnInsertPricing', '#btnDeletePricing', '#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid'], true).wait(100)
        .checkGridData('#grdPricing', 0, 'strLocationName', '0001 - Fort Wayne').wait(100)
        .enterGridData('#grdPricing', 0, 'dblLastCost', '8.5').wait(300)
        .enterGridData('#grdPricing', 0, 'dblStandardCost', '8.2').wait(300)
        .enterGridData('#grdPricing', 0, 'dblAverageCost', '8.5').wait(300)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave')
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)


        /*Add Item - Inventory Type Lot Tracked Yes Manual)*/
        .clickButton('#btnNew')
        .addFunction(function (next) { t.diag("Scenario 3. Add Inventory Item Lot Tracked Yes Manua"); next(); }).wait(100)
        .enterData('#txtItemNo', 'IItem-002').wait(200)
        /*.selectComboRowByIndex('#cboType',0).wait(200)*/
        .enterData('#txtShortName', 'Test Inventory Item - 02').wait(200)
        .enterData('#txtDescription', 'Inventory Item - 002 Lot Yes Manual').wait(200)
        .addFunction(function (next) { t.diag("Setup Item Commodity and Category"); next(); }).wait(100)
        .selectComboRowByFilter('#cboCommodity', 'C', 300, 'strCommodityCode').wait(300)
        .selectComboRowByIndex('#cboLotTracking', 0).wait(200)
        .checkControlReadOnly('#cboTracking', true).wait(100)
        .checkControlData('#cboTracking', 'Lot Level').wait(100)
        .selectComboRowByFilter('#cboCategory', 'Grains', 300, 'strCategoryCode').wait(300)

        .addFunction(function (next) { t.diag("Setup Item UOM"); next(); }).wait(100)
        .selectGridComboRowByFilter('#grdUnitOfMeasure', 0, 'strUnitMeasure', 'LB', 300, 'strUnitMeasure').wait(100)
        .clickButton('#btnInsertUom').wait(100)
        .selectGridComboRowByFilter('#grdUnitOfMeasure', 1, 'strUnitMeasure', '50 lb bag', 300, 'strUnitMeasure').wait(100)
        .clickButton('#btnInsertUom').wait(100)
        .selectGridComboRowByFilter('#grdUnitOfMeasure', 2, 'strUnitMeasure', 'Bushels', 300, 'strUnitMeasure').wait(100)
        .clickGridCheckBox('#grdUnitOfMeasure', 'strUnitMeasure', 'LB', 'ysnStockUnit', true).wait(100)

        .addFunction(function (next) { t.diag("Setup Item GL Accounts"); next(); }).wait(100)
        .clickTab('#cfgSetup').wait(100)
        .clickButton('#btnAddRequiredAccounts').wait(100)
        .checkGridData('#grdGlAccounts', 0, 'colGLAccountCategory', 'AP Clearing').wait(100)
        .checkGridData('#grdGlAccounts', 1, 'colGLAccountCategory', 'Inventory').wait(100)
        .checkGridData('#grdGlAccounts', 2, 'colGLAccountCategory', 'Cost of Goods').wait(100)
        .checkGridData('#grdGlAccounts', 3, 'colGLAccountCategory', 'Sales Account').wait(100)
        .checkGridData('#grdGlAccounts', 4, 'colGLAccountCategory', 'Inventory In-Transit').wait(100)
        .checkGridData('#grdGlAccounts', 5, 'colGLAccountCategory', 'Inventory Adjustment').wait(100)
        .checkGridData('#grdGlAccounts', 6, 'colGLAccountCategory', 'Auto-Negative').wait(100)
        .checkGridData('#grdGlAccounts', 7, 'colGLAccountCategory', 'Revalue Sold').wait(100)
        .checkGridData('#grdGlAccounts', 8, 'colGLAccountCategory', 'Write-Off Sold').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 0, 'strAccountId', '21000-0000-000', 300, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 1, 'strAccountId', '16000-0000-000', 300, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 2, 'strAccountId', '50000-0000-000', 300, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 3, 'strAccountId', '40010-0001-006', 300, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 4, 'strAccountId', '16050-0000-000', 300, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 5, 'strAccountId', '16040-0000-000', 300, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 6, 'strAccountId', '16010-0000-000', 300, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 7, 'strAccountId', '16030-0000-000', 300, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 8, 'strAccountId', '16020-0000-000', 300, 'strAccountId').wait(100)

        .addFunction(function (next) { t.diag("Setup Item Location"); next(); }).wait(100)
        .clickTab('#cfgLocation').wait(100)
        .checkControlVisible(['#btnAddLocation', '#btnAddMultipleLocation', '#btnEditLocation', '#btnDeleteLocation', '#cboCopyLocation', '#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid'], true).wait(100)
        .clickButton('#btnAddLocation').wait(100)
        .checkToolbarButton({ new: true, save: true, search: true, refresh: false, delete: true, undo: true, close: true }).wait(100)
        .selectComboRowByFilter('#cboDefaultVendor', '0001005057', 300, 'intVendorId').wait(100)
        .enterData('#txtDescription', 'Test Pos Description').wait(200)
        .selectComboRowByFilter('#cboSubLocation', 'Processing Plant', 300, 'intSubLocationId').wait(100)
        .selectComboRowByFilter('#cboStorageLocation', 'RM Storage', 300, 'intStorageLocationId').wait(100)
        .selectComboRowByFilter('#cboIssueUom', 'LB', 400, 'strUnitMeasure').wait(100)
        .selectComboRowByFilter('#cboReceiveUom', 'LB', 400, 'strUnitMeasure').wait(100)
        .selectComboRowByIndex('#cboNegativeInventory', 1).wait(200)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave')
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)

        .addFunction(function (next) { t.diag("Setup Item Pricing"); next(); }).wait(100)
        .clickTab('#cfgPricing').wait(100)
        .checkControlVisible(['#btnInsertPricing', '#btnDeletePricing', '#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid'], true).wait(100)
        .checkGridData('#grdPricing', 0, 'strLocationName', '0001 - Fort Wayne').wait(100)
        .enterGridData('#grdPricing', 0, 'dblLastCost', '8.5').wait(300)
        .enterGridData('#grdPricing', 0, 'dblStandardCost', '8.2').wait(300)
        .enterGridData('#grdPricing', 0, 'dblAverageCost', '8.5').wait(300)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave')
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)



        /*Add Item - Inventory Type Non Lotted Item)*/
        .clickButton('#btnNew')
        .addFunction(function (next) { t.diag("Scenario 4. Add Inventory Item Non Lotted Item"); next(); }).wait(100)
        .enterData('#txtItemNo', 'IItem-003').wait(200)
        /*.selectComboRowByIndex('#cboType',0).wait(200)*/
        .enterData('#txtShortName', 'Test Inventory Item - 03').wait(200)
        .enterData('#txtDescription', 'Inventory Item - 003 Non Lotted Item').wait(200)
        .addFunction(function (next) { t.diag("Setup Item Commodity and Category"); next(); }).wait(100)
        .selectComboRowByFilter('#cboCommodity', 'C', 300, 'strCommodityCode').wait(300)
        .selectComboRowByIndex('#cboLotTracking', 2).wait(200)
        .checkControlReadOnly('#cboTracking', true).wait(100)
        .checkControlData('#cboTracking', 'Item Level').wait(100)
        .selectComboRowByFilter('#cboCategory', 'Grains', 300, 'strCategoryCode').wait(300)

        .addFunction(function (next) { t.diag("Setup Item UOM"); next(); }).wait(100)
        .selectGridComboRowByFilter('#grdUnitOfMeasure', 0, 'strUnitMeasure', 'LB', 300, 'strUnitMeasure').wait(100)
        .clickButton('#btnInsertUom').wait(100)
        .selectGridComboRowByFilter('#grdUnitOfMeasure', 1, 'strUnitMeasure', '50 lb bag', 300, 'strUnitMeasure').wait(100)
        .clickButton('#btnInsertUom').wait(100)
        .selectGridComboRowByFilter('#grdUnitOfMeasure', 2, 'strUnitMeasure', 'Bushels', 300, 'strUnitMeasure').wait(100)
        .clickGridCheckBox('#grdUnitOfMeasure', 'strUnitMeasure', 'LB', 'ysnStockUnit', true).wait(100)

        .addFunction(function (next) { t.diag("Setup Item GL Accounts"); next(); }).wait(100)
        .clickTab('#cfgSetup').wait(100)
        .clickButton('#btnAddRequiredAccounts').wait(100)
        .checkGridData('#grdGlAccounts', 0, 'colGLAccountCategory', 'AP Clearing').wait(100)
        .checkGridData('#grdGlAccounts', 1, 'colGLAccountCategory', 'Inventory').wait(100)
        .checkGridData('#grdGlAccounts', 2, 'colGLAccountCategory', 'Cost of Goods').wait(100)
        .checkGridData('#grdGlAccounts', 3, 'colGLAccountCategory', 'Sales Account').wait(100)
        .checkGridData('#grdGlAccounts', 4, 'colGLAccountCategory', 'Inventory In-Transit').wait(100)
        .checkGridData('#grdGlAccounts', 5, 'colGLAccountCategory', 'Inventory Adjustment').wait(100)
        .checkGridData('#grdGlAccounts', 6, 'colGLAccountCategory', 'Auto-Negative').wait(100)
        .checkGridData('#grdGlAccounts', 7, 'colGLAccountCategory', 'Revalue Sold').wait(100)
        .checkGridData('#grdGlAccounts', 8, 'colGLAccountCategory', 'Write-Off Sold').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 0, 'strAccountId', '21000-0000-000', 300, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 1, 'strAccountId', '16000-0000-000', 300, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 2, 'strAccountId', '50000-0000-000', 300, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 3, 'strAccountId', '40010-0001-006', 300, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 4, 'strAccountId', '16050-0000-000', 300, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 5, 'strAccountId', '16040-0000-000', 300, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 6, 'strAccountId', '16010-0000-000', 300, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 7, 'strAccountId', '16030-0000-000', 300, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 8, 'strAccountId', '16020-0000-000', 300, 'strAccountId').wait(100)

        .addFunction(function (next) { t.diag("Setup Item Location"); next(); }).wait(100)
        .clickTab('#cfgLocation').wait(100)
        .checkControlVisible(['#btnAddLocation', '#btnAddMultipleLocation', '#btnEditLocation', '#btnDeleteLocation', '#cboCopyLocation', '#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid'], true).wait(100)
        .clickButton('#btnAddLocation').wait(100)
        .checkToolbarButton({ new: true, save: true, search: true, refresh: false, delete: true, undo: true, close: true }).wait(100)
        .selectComboRowByFilter('#cboDefaultVendor', '0001005057', 300, 'intVendorId').wait(100)
        .enterData('#txtDescription', 'Test Pos Description').wait(200)
        .selectComboRowByFilter('#cboSubLocation', 'Processing Plant', 300, 'intSubLocationId').wait(100)
        .selectComboRowByFilter('#cboStorageLocation', 'RM Storage', 300, 'intStorageLocationId').wait(100)
        .selectComboRowByFilter('#cboIssueUom', 'LB', 400, 'strUnitMeasure').wait(100)
        .selectComboRowByFilter('#cboReceiveUom', 'LB', 400, 'strUnitMeasure').wait(100)
        .selectComboRowByIndex('#cboNegativeInventory', 1).wait(200)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave')
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)

        .addFunction(function (next) { t.diag("Setup Item Pricing"); next(); }).wait(100)
        .clickTab('#cfgPricing').wait(100)
        .checkControlVisible(['#btnInsertPricing', '#btnDeletePricing', '#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid'], true).wait(100)
        .checkGridData('#grdPricing', 0, 'strLocationName', '0001 - Fort Wayne').wait(100)
        .enterGridData('#grdPricing', 0, 'dblLastCost', '8.5').wait(300)
        .enterGridData('#grdPricing', 0, 'dblStandardCost', '8.2').wait(300)
        .enterGridData('#grdPricing', 0, 'dblAverageCost', '8.5').wait(300)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave')
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)
        .clickButton('#btnClose').wait(100)

        .done()
});


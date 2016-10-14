StartTest(function (t) {

    var engine = new iRely.TestEngine();
       var commonSM = Ext.create('SystemManager.CommonSM');
       var commonIC = Ext.create('i21.test.Inventory.CommonIC');

    engine.start(t)

        // LOG IN
        .displayText('Log In').wait(500)
        .addFunction(function (next) {
            commonSM.commonLogin(t, next); }).wait(100)
        .waitTillMainMenuLoaded('Login Successful').wait(500)

        .expandMenu('Inventory').wait(100)
        .waitTillLoaded()


        // IC Add Maintenance Records Scenarios
        //#Scenario 1: Add Item
        .displayText('====== Scenario 1. Add Item ======').wait(300)
        //#1.1 Add Non Lotted Inventory Item
        .addFunction(function(next){
            commonIC.addInventoryItem(t,next,'NLTI - 01','NLTI - 01',2,'Corn','Grains','Bushels','Bushels','10','10','10')
        })

        //#1.2 Add Non Lotted Inventory Item
        .addFunction(function(next){
            commonIC.addInventoryItem(t,next,'LTI - 01','LTI - 01',0,'Corn','Grains','Bushels','Bushels','10','10','10')
        })


        //Add Items Complete Code
        /* //START OF TEST CASE Scenario 1: Add Inventory Item - Non Lotted

         .displayText('======== Scenario 1: Add Inventory Item - Non Lotted ========"').wait(1000)
         .expandMenu('Inventory').wait(500)
         .waitTillLoaded('Open Inventory Menu Successfull').wait(500)
         .openScreen('Items').wait(500)
         .waitTillLoaded('Open Items Search Screen Successful')
         .markSuccess('======== Open Items Search Screen Successful ========').wait(500)

         //#1
         .displayText('======== 1. Open New Item Screen. ========').wait(500)
         .clickButton('#btnNew').wait(500)
         .waitTillVisible('icitem','Open New Item Screen Successful').wait(500)
         .checkScreenShown('icitem').wait(200)
         .checkStatusMessage('Ready')
         .markSuccess('======== Open New Items Screen Successful ========').wait(500)


         //#2
         .displayText('======== 2. Setup Details Tab ========').wait(500)
         .enterData('#txtItemNo', '01 - NLTI').wait(200)
         //.selectComboRowByIndex('#cboType',0).wait(200)
         .enterData('#txtShortName', 'Test Inventory Item').wait(200)
         .enterData('#txtDescription', 'Non-Lotted Item 01').wait(200)
         .selectComboRowByFilter('#cboCommodity', 'Corn', 500, 'strCommodityCode').wait(500)
         .selectComboRowByIndex('#cboLotTracking', 2).wait(200)
         .checkControlReadOnly('#cboTracking', true).wait(100)
         .checkControlData('#cboTracking', 'Item Level').wait(100)
         .selectComboRowByFilter('#cboCategory', 'Grains', 500, 'strCategoryCode').wait(500)
         .markSuccess('======== Setup Details Tab Successful ========').wait(500)


         //#3
         .displayText('======== 3. Setup Unit of Measure ========').wait(500)
         .clickButton('#btnLoadUOM').wait(300)
         .waitTillLoaded('Add UOM Successful')
         //.selectGridComboRowByFilter('#grdUnitOfMeasure', 0, 'strUnitMeasure', 'LB', 300, 'strUnitMeasure').wait(100)
         //.clickButton('#btnInsertUom').wait(100)
         //.selectGridComboRowByFilter('#grdUnitOfMeasure', 1, 'strUnitMeasure', '50 lb bag', 300, 'strUnitMeasure').wait(100)
         //.clickButton('#btnInsertUom').wait(100)
         //.selectGridComboRowByFilter('#grdUnitOfMeasure', 2, 'strUnitMeasure', 'Bushels', 300, 'strUnitMeasure').wait(100)
         //.clickGridCheckBox('#grdUnitOfMeasure', 'strUnitMeasure', 'LB', 'ysnStockUnit', true).wait(100)
         .markSuccess('======== Setup UOM Successful ========').wait(500)

         //#4
         .displayText('======== 3. Setup GL Accounts ========').wait(500)
         .clickTab('#cfgSetup').wait(100)
         .clickButton('#btnAddRequiredAccounts').wait(100)
         .checkGridData('#grdGlAccounts', 0, 'colGLAccountCategory', 'AP Clearing').wait(100)
         .checkGridData('#grdGlAccounts', 1, 'colGLAccountCategory', 'Inventory').wait(100)
         .checkGridData('#grdGlAccounts', 2, 'colGLAccountCategory', 'Cost of Goods').wait(100)
         .checkGridData('#grdGlAccounts', 3, 'colGLAccountCategory', 'Sales Account').wait(100)
         .checkGridData('#grdGlAccounts', 4, 'colGLAccountCategory', 'Inventory In-Transit').wait(100)
         .checkGridData('#grdGlAccounts', 5, 'colGLAccountCategory', 'Inventory Adjustment').wait(100)
         .checkGridData('#grdGlAccounts', 6, 'colGLAccountCategory', 'Auto-Variance').wait(100)

         .selectGridComboRowByFilter('#grdGlAccounts', 0, 'strAccountId', '21000-0000-000', 400, 'strAccountId').wait(100)
         .addFunction(function (next) {
         var t = this,
         win = Ext.WindowManager.getActive();
         if (win) {
         var grdGlAccounts = win.down('#grdGlAccounts');
         grdGlAccounts.editingPlugin.completeEdit();
         }
         next();
         }).wait(1000)
         .selectGridComboRowByFilter('#grdGlAccounts', 1, 'strAccountId', '16000-0000-000', 400, 'strAccountId').wait(100)
         .selectGridComboRowByFilter('#grdGlAccounts', 2, 'strAccountId', '50000-0000-000', 400, 'strAccountId').wait(100)
         .selectGridComboRowByFilter('#grdGlAccounts', 3, 'strAccountId', '40010-0001-006', 400, 'strAccountId').wait(100)
         .selectGridComboRowByFilter('#grdGlAccounts', 4, 'strAccountId', '16050-0000-000', 400, 'strAccountId').wait(100)
         .selectGridComboRowByFilter('#grdGlAccounts', 5, 'strAccountId', '16040-0000-000', 400, 'strAccountId').wait(100)
         .selectGridComboRowByFilter('#grdGlAccounts', 6, 'strAccountId', '16010-0000-000', 400, 'strAccountId').wait(100)
         .markSuccess('======== Setup GL Accounts Successful ========').wait(500)

         //#5
         .displayText('======== 5. Setup Location ========').wait(500)
         .clickTab('#cfgLocation').wait(100)
         .clickButton('#btnAddLocation').wait(100)
         .waitTillVisible('icitemlocation','Add Item Location Screen Displayed',60000).wait(500)
         //.selectComboRowByFilter('#cboDefaultVendor', '0001005057', 1000, 'intVendorId').wait(1000)
         .enterData('#txtDescription', 'Test Pos Description').wait(500)
         .selectComboRowByFilter('#cboSubLocation', 'Raw Station', 1000, 'intSubLocationId').wait(500)
         .selectComboRowByFilter('#cboStorageLocation', 'RM Storage', 1000, 'intStorageLocationId').wait(500)
         .selectComboRowByFilter('#cboIssueUom', 'LB', 1000, 'strUnitMeasure').wait(500)
         .selectComboRowByFilter('#cboReceiveUom', 'LB', 1000, 'strUnitMeasure').wait(500)
         .selectComboRowByIndex('#cboNegativeInventory', 1).wait(500)
         .checkStatusMessage('Edited').wait(300)
         .clickButton('#btnSave')
         .checkStatusMessage('Saved').wait(300)
         .clickButton('#btnClose').wait(300)
         .markSuccess('======== 5. Setup Location Successful ========').wait(500)

         //#6
         .displayText('======== 6. Setup Item Pricing ========').wait(500)
         .clickTab('#cfgPricing').wait(100)
         .checkGridData('#grdPricing', 0, 'strLocationName', '0001 - Fort Wayne').wait(100)
         .enterGridData('#grdPricing', 0, 'dblLastCost', '10').wait(300)
         .enterGridData('#grdPricing', 0, 'dblStandardCost', '10').wait(300)
         .enterGridData('#grdPricing', 0, 'dblAverageCost', '10').wait(300)
         //.selectGridComboRowByIndex('#grdPricing', 0, 'strPricingMethod','2', 'strPricingMethod').wait(100)
         //.enterGridData('#grdPricing', 0, 'dblAmountPercent', '40').wait(300)
         .checkStatusMessage('Edited').wait(200)
         .clickButton('#btnSave').wait(200)
         .checkStatusMessage('Saved').wait(200)
         .displayText('Setup Item Pricing Successful').wait(500)
         .markSuccess('======== Create non-lotted Item Successful ========').wait(500)
         .clickButton('#btnClose').wait(500)



         //Scenario 2. Add Inventory Item - Lotted Yes Serial
         .displayText('======== Scenario 2: Add Inventory Item - Lotted Yes Serial========"').wait(1000)
         .expandMenu('Inventory').wait(500)
         .waitTillLoaded('Open Inventory Menu Successfull').wait(200)
         .openScreen('Items').wait(500)
         .waitTillLoaded('Open Items Search Screen Successful').wait(500)


         //#1
         .displayText('======== 1. Open New Item Screen. ========').wait(500)
         .clickButton('#btnNew').wait(200)
         .waitTillVisible('icitem','Open New Item Screen Successful').wait(500)
         .checkScreenShown('icitem').wait(200)
         .checkStatusMessage('Ready')
         .markSuccess('======== Open New Item Screen Successful ========').wait(500)


         //#2
         .displayText('======== 2. Setup Details Tab ========').wait(500)
         .enterData('#txtItemNo', '01 - LTI').wait(200)
         //.selectComboRowByIndex('#cboType',0).wait(200)
         .enterData('#txtShortName', 'Test Inventory Item').wait(200)
         .enterData('#txtDescription', 'Lotted Item 01').wait(200)
         .selectComboRowByFilter('#cboCommodity', 'Corn', 600, 'strCommodityCode').wait(300)
         .selectComboRowByIndex('#cboLotTracking', 1).wait(200)
         .checkControlReadOnly('#cboTracking', true).wait(100)
         .checkControlData('#cboTracking', 'Lot Level').wait(100)
         .selectComboRowByFilter('#cboCategory', 'Grains', 600, 'strCategoryCode').wait(300)
         .markSuccess('======== Setup Details Tab Successful ========').wait(500)


         //#3
         .displayText('======== 3. Setup Unit of Measure ========').wait(500)
         .clickButton('#btnLoadUOM').wait(300)
         .waitTillLoaded('Add UOM Successful')
         .selectGridComboRowByFilter('#grdUnitOfMeasure', 0, 'strUnitMeasure', 'LB', 300, 'strUnitMeasure').wait(100)
         .clickButton('#btnInsertUom').wait(100)
         .selectGridComboRowByFilter('#grdUnitOfMeasure', 1, 'strUnitMeasure', '50 lb bag', 300, 'strUnitMeasure').wait(100)
         .clickButton('#btnInsertUom').wait(100)
         .selectGridComboRowByFilter('#grdUnitOfMeasure', 2, 'strUnitMeasure', 'Bushels', 300, 'strUnitMeasure').wait(100)
         .clickGridCheckBox('#grdUnitOfMeasure', 'strUnitMeasure', 'LB', 'ysnStockUnit', true).wait(100)
         .markSuccess('======== Setup UOM Successful ========').wait(500)

         //#4
         .displayText('======== 3. Setup GL Accounts ========').wait(500)
         .clickTab('#cfgSetup').wait(100)
         .clickButton('#btnAddRequiredAccounts').wait(100)
         .checkGridData('#grdGlAccounts', 0, 'colGLAccountCategory', 'AP Clearing').wait(100)
         .checkGridData('#grdGlAccounts', 1, 'colGLAccountCategory', 'Inventory').wait(100)
         .checkGridData('#grdGlAccounts', 2, 'colGLAccountCategory', 'Cost of Goods').wait(100)
         .checkGridData('#grdGlAccounts', 3, 'colGLAccountCategory', 'Sales Account').wait(100)
         .checkGridData('#grdGlAccounts', 4, 'colGLAccountCategory', 'Inventory In-Transit').wait(100)
         .checkGridData('#grdGlAccounts', 5, 'colGLAccountCategory', 'Inventory Adjustment').wait(100)
         .checkGridData('#grdGlAccounts', 6, 'colGLAccountCategory', 'Auto-Variance').wait(100)

         .selectGridComboRowByFilter('#grdGlAccounts', 0, 'strAccountId', '21000-0000-000', 400, 'strAccountId').wait(100)
         .addFunction(function (next) {
         var t = this,
         win = Ext.WindowManager.getActive();
         if (win) {
         var grdGlAccounts = win.down('#grdGlAccounts');
         grdGlAccounts.editingPlugin.completeEdit();
         }
         next();
         }).wait(1000)
         .selectGridComboRowByFilter('#grdGlAccounts', 1, 'strAccountId', '16000-0000-000', 400, 'strAccountId').wait(100)
         .selectGridComboRowByFilter('#grdGlAccounts', 2, 'strAccountId', '50000-0000-000', 400, 'strAccountId').wait(100)
         .selectGridComboRowByFilter('#grdGlAccounts', 3, 'strAccountId', '40010-0001-006', 400, 'strAccountId').wait(100)
         .selectGridComboRowByFilter('#grdGlAccounts', 4, 'strAccountId', '16050-0000-000', 400, 'strAccountId').wait(100)
         .selectGridComboRowByFilter('#grdGlAccounts', 5, 'strAccountId', '16040-0000-000', 400, 'strAccountId').wait(100)
         .selectGridComboRowByFilter('#grdGlAccounts', 6, 'strAccountId', '16010-0000-000', 400, 'strAccountId').wait(100)
         .markSuccess('Setup GL Accounts Successful').wait(500)

         //#5
         .displayText('======== 5. Setup Location ========').wait(500)
         .clickTab('#cfgLocation').wait(100)
         .clickButton('#btnAddLocation').wait(100)
         .waitTillVisible('icitemlocation','Add Item Location Screen Displayed',60000).wait(500)
         //.selectComboRowByFilter('#cboDefaultVendor', '0001005057', 1000, 'intVendorId').wait(500)
         .enterData('#txtDescription', 'Test Pos Description').wait(500)
         .selectComboRowByFilter('#cboSubLocation', 'Raw Station', 600, 'intSubLocationId').wait(500)
         .selectComboRowByFilter('#cboStorageLocation', 'RM Storage', 600, 'intStorageLocationId').wait(500)
         .selectComboRowByFilter('#cboIssueUom', 'LB', 600, 'strUnitMeasure').wait(500)
         .selectComboRowByFilter('#cboReceiveUom', 'LB', 600, 'strUnitMeasure').wait(500)
         .selectComboRowByIndex('#cboNegativeInventory', 1).wait(500)
         .checkStatusMessage('Edited').wait(300)
         .clickButton('#btnSave')
         .checkStatusMessage('Saved').wait(300)
         .clickButton('#btnClose').wait(300)
         .markSuccess('======== Setup Location Successful ========').wait(500)

         //#6
         .displayText('======== 6. Setup Item Pricing ========').wait(500)
         .clickTab('#cfgPricing').wait(100)
         .checkGridData('#grdPricing', 0, 'strLocationName', '0001 - Fort Wayne').wait(100)
         .enterGridData('#grdPricing', 0, 'dblLastCost', '10').wait(300)
         .enterGridData('#grdPricing', 0, 'dblStandardCost', '10').wait(300)
         .enterGridData('#grdPricing', 0, 'dblAverageCost', '10').wait(300)

         //.enterGridData('#grdPricing', 0, 'dblAmountPercent', '40').wait(300)
         .checkStatusMessage('Edited').wait(200)
         .clickButton('#btnSave').wait(200)
         .checkStatusMessage('Saved').wait(200)
         .displayText('Setup Item Pricing Successful').wait(500)
         .markSuccess('======== Create non-lotted Item Successful ========').wait(500)
         .clickButton('#btnClose').wait(500)



         //Scenario 3. Add Inventory Item - Lotted Yes Serial
         .displayText('======== Scenario 3: Add Inventory Item - Lotted Yes Manual========"').wait(1000)
         .expandMenu('Inventory').wait(500)
         .waitTillLoaded('Open Inventory Menu Successfull').wait(200)
         .openScreen('Items').wait(500)
         .waitTillLoaded('Open Items Search Screen Successful').wait(500)

         //#1
         .displayText('======== 1. Open New Item Screen. ========').wait(500)
         .clickButton('#btnNew').wait(200)
         .waitTillVisible('icitem','Open New Item Screen Successful').wait(500)
         .checkScreenShown('icitem').wait(200)
         .checkStatusMessage('Ready')
         .markSuccess('======== Open New Item Screen Successful ========')


         //#2
         .displayText('======== 2. Setup Details Tab ========').wait(500)
         .enterData('#txtItemNo', '02 - LTI').wait(200)
         //.selectComboRowByIndex('#cboType',0).wait(200)
         .enterData('#txtShortName', 'Test Inventory Item').wait(200)
         .enterData('#txtDescription', 'Lotted Item 02').wait(200)
         .selectComboRowByFilter('#cboCommodity', 'Corn', 600, 'strCommodityCode').wait(300)
         .selectComboRowByIndex('#cboLotTracking', 0).wait(200)
         .checkControlReadOnly('#cboTracking', true).wait(100)
         .checkControlData('#cboTracking', 'Lot Level').wait(100)
         .selectComboRowByFilter('#cboCategory', 'Grains', 600, 'strCategoryCode').wait(300)
         .markSuccess('======== Setup Details Tab Successful ========').wait(500)


         //#3
         .displayText('======== 3. Setup Unit of Measure ========').wait(500)
         .clickButton('#btnLoadUOM').wait(300)
         .waitTillLoaded('Add UOM Successful')
         .selectGridComboRowByFilter('#grdUnitOfMeasure', 0, 'strUnitMeasure', 'LB', 300, 'strUnitMeasure').wait(100)
         .clickButton('#btnInsertUom').wait(100)
         .selectGridComboRowByFilter('#grdUnitOfMeasure', 1, 'strUnitMeasure', '50 lb bag', 300, 'strUnitMeasure').wait(100)
         .clickButton('#btnInsertUom').wait(100)
         .selectGridComboRowByFilter('#grdUnitOfMeasure', 2, 'strUnitMeasure', 'Bushels', 300, 'strUnitMeasure').wait(100)
         .clickGridCheckBox('#grdUnitOfMeasure', 'strUnitMeasure', 'LB', 'ysnStockUnit', true).wait(100)
         .markSuccess('======== Setup UOM Successful ========').wait(500)


         //#4
         .displayText('======== 3. Setup GL Accounts ========').wait(500)
         .clickTab('#cfgSetup').wait(100)
         .clickButton('#btnAddRequiredAccounts').wait(100)
         .checkGridData('#grdGlAccounts', 0, 'colGLAccountCategory', 'AP Clearing').wait(100)
         .checkGridData('#grdGlAccounts', 1, 'colGLAccountCategory', 'Inventory').wait(100)
         .checkGridData('#grdGlAccounts', 2, 'colGLAccountCategory', 'Cost of Goods').wait(100)
         .checkGridData('#grdGlAccounts', 3, 'colGLAccountCategory', 'Sales Account').wait(100)
         .checkGridData('#grdGlAccounts', 4, 'colGLAccountCategory', 'Inventory In-Transit').wait(100)
         .checkGridData('#grdGlAccounts', 5, 'colGLAccountCategory', 'Inventory Adjustment').wait(100)
         .checkGridData('#grdGlAccounts', 6, 'colGLAccountCategory', 'Auto-Variance').wait(100)

         .selectGridComboRowByFilter('#grdGlAccounts', 0, 'strAccountId', '21000-0000-000', 400, 'strAccountId').wait(100)
         .addFunction(function (next) {
         var t = this,
         win = Ext.WindowManager.getActive();
         if (win) {
         var grdGlAccounts = win.down('#grdGlAccounts');
         grdGlAccounts.editingPlugin.completeEdit();
         }
         next();
         }).wait(1000)
         .selectGridComboRowByFilter('#grdGlAccounts', 1, 'strAccountId', '16000-0000-000', 400, 'strAccountId').wait(100)
         .selectGridComboRowByFilter('#grdGlAccounts', 2, 'strAccountId', '50000-0000-000', 400, 'strAccountId').wait(100)
         .selectGridComboRowByFilter('#grdGlAccounts', 3, 'strAccountId', '40010-0001-006', 400, 'strAccountId').wait(100)
         .selectGridComboRowByFilter('#grdGlAccounts', 4, 'strAccountId', '16050-0000-000', 400, 'strAccountId').wait(100)
         .selectGridComboRowByFilter('#grdGlAccounts', 5, 'strAccountId', '16040-0000-000', 400, 'strAccountId').wait(100)
         .selectGridComboRowByFilter('#grdGlAccounts', 6, 'strAccountId', '16010-0000-000', 400, 'strAccountId').wait(100)
         .markSuccess('======== Setup GL Accounts Successful ========').wait(500)

         //#5
         .displayText('======== 5. Setup Location ========').wait(500)
         .clickTab('#cfgLocation').wait(100)
         .clickButton('#btnAddLocation').wait(100)
         .waitTillVisible('icitemlocation','Add Item Location Screen Displayed',60000).wait(500)
         //.selectComboRowByFilter('#cboDefaultVendor', '0001005057', 1000, 'intVendorId').wait(500)
         .enterData('#txtDescription', 'Test Pos Description').wait(500)
         .selectComboRowByFilter('#cboSubLocation', 'Raw Station', 600, 'intSubLocationId').wait(500)
         .selectComboRowByFilter('#cboStorageLocation', 'RM Storage', 600, 'intStorageLocationId').wait(500)
         .selectComboRowByFilter('#cboIssueUom', 'LB', 600, 'strUnitMeasure').wait(500)
         .selectComboRowByFilter('#cboReceiveUom', 'LB', 600, 'strUnitMeasure').wait(500)
         .selectComboRowByIndex('#cboNegativeInventory', 1).wait(500)
         .checkStatusMessage('Edited').wait(300)
         .clickButton('#btnSave')
         .checkStatusMessage('Saved').wait(300)
         .clickButton('#btnClose').wait(300)
         .markSuccess('======== Setup Location Successful ========').wait(500)

         //#6
         .displayText('======== 6. Setup Item Pricing ========').wait(500)
         .clickTab('#cfgPricing').wait(100)
         .checkGridData('#grdPricing', 0, 'strLocationName', '0001 - Fort Wayne').wait(100)
         .enterGridData('#grdPricing', 0, 'dblLastCost', '10').wait(300)
         .enterGridData('#grdPricing', 0, 'dblStandardCost', '10').wait(300)
         .enterGridData('#grdPricing', 0, 'dblAverageCost', '10').wait(300)

         //.enterGridData('#grdPricing', 0, 'dblAmountPercent', '40').wait(300)
         .checkStatusMessage('Edited').wait(200)
         .clickButton('#btnSave').wait(200)
         .checkStatusMessage('Saved').wait(200)
         .markSuccess('======== Setup Item Pricing Successful ========').wait(500)
         .markSuccess('======== Create non-lotted Item Successful ========').wait(500)
         .clickButton('#btnClose').wait(500)


         //Scenario 4. Duplicate Item
         .displayText('======== Scenario 4. Duplicate Item========"').wait(1000)
         .expandMenu('Inventory').wait(500)
         .waitTillLoaded('Open Inventory Menu Successfull').wait(200)
         .openScreen('Items').wait(500)
         .waitTillLoaded('Open Items Search Screen Successful').wait(500)

         //#1
         .displayText('======== 1. Open New Item Screen. ========').wait(500)
         .clickButton('#btnNew').wait(200)
         .waitTillVisible('icitem','Open New Item Screen Successful').wait(500)
         .checkScreenShown('icitem').wait(200)
         .checkStatusMessage('Ready')


         //#2
         .displayText('======== 2. Setup Details Tab ========').wait(500)
         .enterData('#txtItemNo', '01 - LTI').wait(200)
         //.selectComboRowByIndex('#cboType',0).wait(200)
         .enterData('#txtShortName', 'Test Inventory Item').wait(200)
         .enterData('#txtDescription', 'Lotted Item 01').wait(200)
         .selectComboRowByFilter('#cboCommodity', 'Corn', 600, 'strCommodityCode').wait(300)
         .selectComboRowByIndex('#cboLotTracking', 1).wait(200)
         .checkControlReadOnly('#cboTracking', true).wait(100)
         .checkControlData('#cboTracking', 'Lot Level').wait(100)
         .selectComboRowByFilter('#cboCategory', 'Grains', 600, 'strCategoryCode').wait(300)
         .markSuccess(' ======== Setup Details Tab Successful======== ').wait(500)


         //#3
         .displayText('======== 3. Setup Unit of Measure ========').wait(500)
         .clickButton('#btnLoadUOM').wait(300)
         .waitTillLoaded('Add UOM Successful')
         .selectGridComboRowByFilter('#grdUnitOfMeasure', 0, 'strUnitMeasure', 'LB', 300, 'strUnitMeasure').wait(100)
         .clickButton('#btnInsertUom').wait(100)
         .selectGridComboRowByFilter('#grdUnitOfMeasure', 1, 'strUnitMeasure', '50 lb bag', 300, 'strUnitMeasure').wait(100)
         .clickButton('#btnInsertUom').wait(100)
         .selectGridComboRowByFilter('#grdUnitOfMeasure', 2, 'strUnitMeasure', 'Bushels', 300, 'strUnitMeasure').wait(100)
         .clickGridCheckBox('#grdUnitOfMeasure', 'strUnitMeasure', 'LB', 'ysnStockUnit', true).wait(100)
         .markSuccess('======== Setup UOM Successful======== ').wait(500)

         //#4
         .displayText('======== 3. Save Duplicate item ========').wait(500)
         .clickButton('#btnSave').wait(300)
         .checkMessageBox('iRely i21','Item No must be unique.','ok','error').wait(1000)
         .clickMessageBoxButton('ok').wait(300)
         .clickButton('#btnClose').wait(500)
         .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question').wait(1000)
         .clickMessageBoxButton('no').wait(300)
         .markSuccess('======== Was not able to save duplicate item. ========').wait(500)


         //Scenario 5. Duplicate Button
         .displayText('======== Scenario 5. Duplicate Button========"').wait(1000)
         .expandMenu('Inventory').wait(500)
         .waitTillLoaded('Open Inventory Menu Successfull').wait(200)
         //#1
         .displayText('======== 1. Open Items Screen ========').wait(500)
         .openScreen('Items').wait(500)
         .waitTillLoaded('Open Items Search Screen Successful').wait(500)

         //#2
         .displayText('========2. Select Any Item ========').wait(500)
         .selectSearchRowByIndex(3).wait(500)
         .waitTillLoaded('======== Search Item Successful ========')

         //#3
         .displayText('======== 3. Open Item ========').wait(500)
         .clickButton('#btnOpenSelected').wait(500)
         .waitTillVisible('icitem','Open New Item Screen Successful').wait(500)
         .markSuccess('======== Open Item Succesful ========').wait(500)

         //#4
         .displayText('======== Click Duplicate Button ========').wait(500)
         .clickButton('#btnDuplicate').wait(500)
         .waitTillLoaded('Duplicate Item Successful')
         .checkControlData('#txtItemNo', 'LTI - 01-copy').wait(100)
         .markSuccess('======== Duplicate Item Successful ========').wait(500)

         //#5
         .displayText('======== 5. Update Item No. ========').wait(500)
         .enterData('#txtItemNo', 'NLTI - 03').wait(200)
         .enterData('#txtShortName', 'Test Inventory Item').wait(200)
         .enterData('#txtDescription', 'Lotted Item 03').wait(200)
         .markSuccess('======== Update Item No. Successful ========').wait(500)

         //#6
         .displayText('========6. Save and Close item screen. ========').wait(500)
         .clickButton('#btnSave').wait(500)
         .checkStatusMessage('Saved').wait(200)
         .clickButton('#btnClose').wait(500)
         .markSuccess('======== Item Save Successful ========').wait(500)
         */
        .markSuccess('======== Add Item Scenarios Done and Successful! ========')



        //#Scenario 2: Add Commodity
                .displayText('====== Scenario 2. Add Cmmodity ======').wait(300)
        .openScreen('Commodities').wait(500)
        .waitTillLoaded('Open Commodity  Search Screen Successful').wait(200)
        //#1 Add Commodity with no UOM Setup and Attributes
        .displayText('====== Scenario 2.1. Add Commodity with no UOM Setup and Attributes ======').wait(300)
        .clickButton('#btnNew').wait(300)
        .waitTillVisible('iccommodity','Open Commodity Screen Successful').wait(300)
        .enterData('#txtCommodityCode','Test Commodity 1').wait(100)
        .enterData('#txtDescription','Test Commodity 1').wait(100)
        .clickCheckBox('#chkExchangeTraded',true).wait(100)
        .enterData('#txtDecimalsOnDpr','6.00').wait(100)
        .enterData('#txtConsolidateFactor','6.00').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .markSuccess('Add Commodity with no UOM Setup and Attributes Successful')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('iccommodity').wait(300)

        //#2 Add Commodity with UOM
        .displayText('====== Scenario 2.2 Add Commodity with no UOM Setup and Attributes ======').wait(300)
        .clickButton('#btnNew').wait(300)
        .waitTillVisible('iccommodity','Open Commodity Screen Successful').wait(300)
        .enterData('#txtCommodityCode','Test Commodity 2').wait(100)
        .enterData('#txtDescription','Test Commodity 2').wait(100)
        .clickCheckBox('#chkExchangeTraded',true).wait(100)
        .enterData('#txtDecimalsOnDpr','6.00').wait(100)
        .enterData('#txtConsolidateFactor','6.00').wait(100)
        .selectGridComboRowByFilter('#grdUom', 0,'strUnitMeasure','LB', 300,'strUnitMeasure').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .selectGridComboRowByFilter('#grdUom', 1,'strUnitMeasure','50 lb bag', 300,'strUnitMeasure').wait(100)
        .clickGridCheckBox('#grdUom', 'strUnitMeasure', 'LB', 'ysnStockUnit', true).wait(100)
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .markSuccess('Add Commodity with no UOM Setup and Attributes Successful')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('iccommodity').wait(300)



        //#Scenario 3: Add Category
                        .displayText('====== Scenario 3. Add Category ======').wait(300)
                .openScreen('Categories').wait(500)
                .waitTillLoaded('Open Category Search Screen Successful').wait(200)


                //#3.1 Add Category - Inventory
                .displayText('====== Scenario 3.1. Create Inventory Type Category ======').wait(300)
                .clickButton('#btnNew').wait(200)
                .waitTillVisible('iccategory','Open Category Screen Successful').wait(300)
                .enterData('#txtCategoryCode','Test Inventory Category').wait(300)
                .enterData('#txtDescription','Test Description').wait(300)
                .selectComboRowByIndex('#cboInventoryType',1).wait(200)
                .selectComboRowByIndex('#cboCostingMethod',0,100).wait(300)
                .selectGridComboRowByFilter('#grdUnitOfMeasure', 0,'strUnitMeasure','LB', 300,'strUnitMeasure').wait(100)
                .clickButton('#btnSave').wait(300)
                .checkStatusMessage('Saved').wait(300)
                .selectGridComboRowByFilter('#grdUnitOfMeasure', 1,'strUnitMeasure','50 lb bag', 300,'strUnitMeasure').wait(100)
                .clickGridCheckBox('#grdUnitOfMeasure', 'strUnitMeasure', 'LB', 'ysnStockUnit', true).wait(100)
                .enterData('#txtStandardQty','100000').wait(300)
                //.selectComboRowByFilter('#cboStandardUOM','LB',500, 'intUOMId',0).wait(100)
                .selectGridComboRowByFilter('#grdTax', 0,'strTaxClass','State Sales Tax (SST)', 300,'strTaxClass').wait(100)
                .clickButton('#btnSave').wait(300)
                .markSuccess('Create Inventory Type Category Successful').wait(500)
                .clickButton('#btnClose').wait(300)



        //Scenarios 4-9 Fuel Types Screen
        //#Scenario 4: Add Fuel Category
          .displayText('====== Scenario 4. Add Fuel Category ======').wait(300)
        .openScreen('Fuel Types').wait(500)
        .waitTillLoaded()
        .clickButton('#btnClose').wait(500)
        .clickButton('#btnFuelCategory').wait(300)
        .enterGridData('#grdGridTemplate', 0, 'colRinFuelCategoryCode', 'Test Fuel Category 1').wait(150)
        .enterGridData('#grdGridTemplate', 0, 'colDescription', 'Test Description 1').wait(150)
        .enterGridData('#grdGridTemplate', 0, 'colEquivalenceValue', 'Test Equivalence Value 1').wait(150)
        .enterGridData('#grdGridTemplate', 1, 'colRinFuelCategoryCode', 'Test Fuel Category 2').wait(150)
        .enterGridData('#grdGridTemplate', 1, 'colDescription', 'Test Description 2').wait(150)
        .enterGridData('#grdGridTemplate', 1, 'colEquivalenceValue', 'Test Equivalence Value 2').wait(150)
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(1000)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)
        .markSuccess('====== Add Fuel Category Successful ======').wait(300)


        //#Scenario 5: Add Feed Stock
        .displayText('====== Scenario 5. Add Feed Stock ======').wait(300)
        .clickButton('#btnFeedStock').wait(300)
        .enterGridData('#grdGridTemplate', 0, 'colRinFeedStockCode', 'FS01').wait(100)
        .enterGridData('#grdGridTemplate', 0, 'colDescription', 'Feed Stock 01').wait(100)
        .enterGridData('#grdGridTemplate', 1, 'colRinFeedStockCode', 'FS02').wait(100)
        .enterGridData('#grdGridTemplate', 1, 'colDescription', 'Feed Stock 02').wait(100)
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('feedstockcode').wait(100)
        .markSuccess('====== Add Feed Stock Successful ======').wait(300)


        //#Scenario 6: Add Fuel Code
        .displayText('====== Scenario 6. Add Fuel Code ======').wait(300)
        .clickButton('#btnFuelCode').wait(300)
        .enterGridData('#grdGridTemplate', 0, 'colRinFuelCode', 'F01').wait(100)
        .enterGridData('#grdGridTemplate', 0, 'colDescription', 'Fuel 01').wait(100)
        .enterGridData('#grdGridTemplate', 1, 'colRinFuelCode', 'F02').wait(100)
        .enterGridData('#grdGridTemplate', 1, 'colDescription', 'Fuel 02').wait(100)
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('fuelcode').wait(100)
        .markSuccess('====== Add Fuel Code Successful ======').wait(300)


        //#Scenario 7: Add Production Process
        .displayText('====== Scenario 7. Add Production Process ======').wait(300)
        .clickButton('#btnProductionProcess').wait(300)
        .enterGridData('#grdGridTemplate', 0, 'colRinProcessCode', 'PP01').wait(100)
        .enterGridData('#grdGridTemplate', 0, 'colDescription', 'Production Process 01').wait(100)
        .enterGridData('#grdGridTemplate', 1, 'colRinProcessCode', 'PP02').wait(100)
        .enterGridData('#grdGridTemplate', 1, 'colDescription', 'Production Process 02').wait(100)
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(100)
        .clickButton('#btnClose').wait(100)
        .markSuccess('====== Add Production Process Successful ======').wait(300)


        //#Scenario 8: Add Feed Stock UOM
        .displayText('====== Scenario 8. Add Feed Stock UOM ======').wait(300)
        .clickButton('#btnFeedStockUOM').wait(300)
        .selectGridComboRowByFilter('#grdGridTemplate', 0, 'strUnitMeasure', 'LB', 300, 'strUnitMeasure').wait(1000)
        .enterGridData('#grdGridTemplate', 0, 'colRinFeedStockUOMCode', 'LB').wait(100)
        .selectGridComboRowByFilter('#grdGridTemplate', 1, 'strUnitMeasure', 'KG', 300, 'strUnitMeasure').wait(1000)
        .enterGridData('#grdGridTemplate', 1, 'colRinFeedStockUOMCode', 'KG').wait(100)
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('feedstockuom').wait(100)
        .markSuccess('====== Add Add Feed Stock UOM Successful ======').wait(300)


        //#Scenario 9: Add Fuel Type
        .displayText('====== Scenario 9. Add Fuel Type ======').wait(300)
        .clickButton('#btnNew').wait(300)
        .selectComboRowByFilter('#cboFuelCategory', 'Test Fuel Category 1', 300, 'intRinFuelCategoryId', 0).wait(200)
        .selectComboRowByFilter('#cboFeedStock', 'FS01', 300, 'intRinFeedStockId', 0).wait(200)
        .enterData('#txtBatchNo','10001').wait(100)
        .enterData('#txtEndingRinGallonsForBatch','25').wait(100)
        .checkControlData('#txtEquivalenceValue','Test Equivalence Value 1')
        .selectComboRowByFilter('#cboFuelCode', 'F01', 300, 'intRinFuelId', 0).wait(200)
        .selectComboRowByFilter('#cboProductionProcess', 'PP01', 300, 'intRinProcessId', 0).wait(200)
        .selectComboRowByFilter('#cboFeedStockUom', 'LB', 300, 'intRinFeedStockUOMId', 0).wait(200)
        .enterData('#txtFeedStockFactor','10').wait(200)
        .clickButton('#btnSave').wait(500)
        .clickButton('#btnClose').wait(200)
        .markSuccess('====== Add Add Fuel Type Successful ======').wait(300)



        //#Scenario 10: Inventory UOM
        // 10.1 Add stock UOM first
               .displayText('====== #1 Add Stock UOM ======').wait(300)
        .clickButton('#btnNew').wait(100)
        .waitTillVisible('icinventoryuom','Open Inventory UOM  Successful').wait(200)
        .checkScreenShown('icinventoryuom').wait(100)
        .enterData('#txtUnitMeasure', 'Pound_1').wait(300)
        .enterData('#txtSymbol', 'Lb_1').wait(300)
        .selectComboRowByIndex('#cboUnitType', 5).wait(300)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave').wait(100)
        .displayText('====== Verify Record Added ======').wait(300)
        .clickButton('#btnSearch').wait(500)
        .waitTillLoaded('').wait(500)
        .checkGridData('#grdSearch', 40, 'strUnitMeasure', 'Pound_1').wait(100)
        .checkGridData('#grdSearch', 40, 'strSymbol', 'Lb_1').wait(100)
        .markSuccess('====== Add Stock UOM Successful ======').wait(200)
        .clickButton('#btnClose').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('icinventoryuom').wait(100)

        // 10.2. Add conversion UOMs on each stock UOM
        .displayText('====== Scenario #2 Add Conversion UOM> 5 Lb Bag======').wait(300)
        .clickButton('#btnNew').wait(100).wait(100)
        .enterData('#txtUnitMeasure', '5 Lb Bag_1').wait(100)
        .enterData('#txtSymbol', '5 Lb Bag_1').wait(100)
        .selectComboRowByIndex('#cboUnitType', 5).wait(100)
        .selectGridComboRowByFilter('#grdConversion', 0, 'strUnitMeasure', 'Pound_1', 1000).wait(100)
        .enterGridData('#grdConversion', 0, 'colConversionToStockUOM', '5').wait(500)
        .clickButton('#btnSave').wait(100)
        .displayText('====== Verify Record Added ======').wait(300)
        .clickButton('#btnSearch').wait(500)
        .waitTillLoaded('').wait(500)
        .checkGridData('#grdSearch', 41, 'strUnitMeasure', '5 Lb Bag_1').wait(100)
        .checkGridData('#grdSearch', 41, 'strSymbol', '5 Lb Bag_1').wait(100)
        .markSuccess('====== Add Conversion UOM> 5 Lb Bag ======').wait(200)
        .clickButton('#btnClose').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('icinventoryuom').wait(100)


        .displayText('====== Scenario #3 Add Conversion UOM> 10 Lb Bag======').wait(300)
        .clickButton('#btnNew').wait(100)
        .enterData('#txtUnitMeasure', '10 Lb Bag_1').wait(100)
        .enterData('#txtSymbol', '10 Lb Bag_1').wait(100)
        .selectComboRowByIndex('#cboUnitType', 5).wait(100)
        .selectGridComboRowByFilter('#grdConversion', 0, 'strUnitMeasure', 'Pound_1', 1000).wait(100)
        .enterGridData('#grdConversion', 0, 'colConversionToStockUOM', '10').wait(500)
        .clickButton('#btnSave').wait(100)
        .addFunction(function (next) { t.diag("Verify Record Added"); next(); }).wait(100)
        .clickButton('#btnSearch').wait(500)
        .waitTillLoaded('').wait(500)
        .checkGridData('#grdSearch', 42, 'strUnitMeasure', '10 Lb Bag_1').wait(100)
        .checkGridData('#grdSearch', 42, 'strSymbol', '10 Lb Bag_1').wait(100)
        .markSuccess('====== Add Conversion UOM> 10 Lb Bag Successful ======').wait(200)
        .clickButton('#btnClose').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('icinventoryuom').wait(100)



        //#Scenario 11: Add Storage Location
          .displayText('====== Scenario 1. Allow bin of the same name to be used in a different Sub Location ======').wait(300)
        .clickButton('#btnNew').wait(200)
        .waitTillVisible('icstorageunit','Open Inventory UOM  Successful').wait(200)
        .checkScreenShown('icstorageunit').wait(200)
        .enterData('#txtName','Test SL - SH - 001').wait(100)
        .enterData('#txtDescription','Test SL - SH - 001').wait(100)
        .selectComboRowByFilter('#cboUnitType','Bin',300, 'strStorageUnitType').wait(100)
        .selectComboRowByFilter('#cboLocation','0001 - Fort Wayne',300, 'intLocationId').wait(100)
        .selectComboRowByFilter('#cboSubLocation','Stellhorn',300, 'intSubLocationId').wait(100)
        .selectComboRowByFilter('#cboParentUnit','RM Storage',300, 'intParentStorageLocationId').wait(100)
        .enterData('#txtAisle','Test Aisle').wait(100)
        .clickCheckBox('#chkAllowConsume',true).wait(100)
        .clickCheckBox('#chkAllowMultipleItems',true).wait(100)
        .clickCheckBox('#chkAllowMultipleLots',true).wait(100)
        .clickCheckBox('#chkMergeOnMove',true).wait(100)
        .clickCheckBox('#chkCycleCounted',true).wait(100)
        .clickCheckBox('#chkDefaultWarehouseStagingUnit',true).wait(100)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('icstorageunit').wait(100)
        .markSuccess('====== Allow bin of the same name to be used in a different Sub Location Successful ======').wait(200)

        .markSuccess('====== Add IC Maintenance Records Successful! Ole! ======')

        .done();
});



/**
 * Created by CCallado on 10/4/2016.
 */

StartTest(function (t) {

    var engine = new iRely.TestEngine(),
        commonSM = Ext.create('SystemManager.CommonSM');

    engine.start(t)

        // LOG IN
        .displayText('Log In').wait(500)
        .addFunction(function (next) { commonSM.commonLogin(t, next); }).wait(100)
        .waitTillMainMenuLoaded('Login Successful').wait(500)


        //START OF TEST CASE
        //Scenario 1: Add Inventory Item - Non Lotted
        .displayText('======== Scenario 1: Add Inventory Item - Non Lotted ========"').wait(1000)
        .expandMenu('Inventory').wait(500)
        .waitTillLoaded('Open Inventory Menu Successfull').wait(200)
        .openScreen('Items').wait(500)
        .waitTillLoaded('Open Items Search Screen Successful').wait(500)
        //#1
        .displayText('1. Open New Item Screen.').wait(500)
        .clickButton('#btnNew').wait(200)
        .waitTillVisible('icitem','Open New Item Screen Successful').wait(500)
        .checkScreenShown('icitem').wait(200)
        .checkStatusMessage('Ready')


        //#2
        .displayText('2. Setup Details Tab').wait(500)
        .enterData('#txtItemNo', 'NLTI - 01').wait(200)
        //.selectComboRowByIndex('#cboType',0).wait(200)
        .enterData('#txtShortName', 'Test Inventory Item').wait(200)
        .enterData('#txtDescription', 'Non-Lotted Item 01').wait(200)
        .selectComboRowByFilter('#cboCommodity', 'Corn', 600, 'strCommodityCode').wait(300)
        .selectComboRowByIndex('#cboLotTracking', 2).wait(200)
        .checkControlReadOnly('#cboTracking', true).wait(100)
        .checkControlData('#cboTracking', 'Item Level').wait(100)
        .selectComboRowByFilter('#cboCategory', 'Grains', 600, 'strCategoryCode').wait(300)
        .displayText(' Setup Details Tab Successful').wait(500)


        //#3
        .displayText('3. Setup Unit of Measure').wait(500)
        .clickButton('#btnLoadUOM').wait(300)
        .waitTillLoaded('Add UOM Successful')
        /*.selectGridComboRowByFilter('#grdUnitOfMeasure', 0, 'strUnitMeasure', 'LB', 300, 'strUnitMeasure').wait(100)
        .clickButton('#btnInsertUom').wait(100)
        .selectGridComboRowByFilter('#grdUnitOfMeasure', 1, 'strUnitMeasure', '50 lb bag', 300, 'strUnitMeasure').wait(100)
        .clickButton('#btnInsertUom').wait(100)
        .selectGridComboRowByFilter('#grdUnitOfMeasure', 2, 'strUnitMeasure', 'Bushels', 300, 'strUnitMeasure').wait(100)
        .clickGridCheckBox('#grdUnitOfMeasure', 'strUnitMeasure', 'LB', 'ysnStockUnit', true).wait(100)*/

       //#4
        .displayText('3. Setup GL Accounts').wait(500)
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
        .displayText('Setup GL Accounts Successful').wait(500)

        //#5
        .displayText('5. Setup Location').wait(500)
        .clickTab('#cfgLocation').wait(100)
        .clickButton('#btnAddLocation').wait(100)
        .waitTillVisible('icitemlocation','Add Item Location Screen Displayed',60000).wait(500)
        .selectComboRowByFilter('#cboDefaultVendor', '0001005057', 1000, 'intVendorId').wait(500)
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
        .displayText('5. Setup Location Successful').wait(500)

        //#6
        .displayText('5. Setup Item Pricing').wait(500)
        .clickTab('#cfgPricing').wait(100)
        .checkGridData('#grdPricing', 0, 'strLocationName', '0001 - Fort Wayne').wait(100)
        .enterGridData('#grdPricing', 0, 'dblLastCost', '8.5').wait(300)
        .enterGridData('#grdPricing', 0, 'dblStandardCost', '8.2').wait(300)
        .enterGridData('#grdPricing', 0, 'dblAverageCost', '8.5').wait(300)
        .checkStatusMessage('Edited').wait(200)
        .clickButton('#btnSave').wait(200)
        .checkStatusMessage('Saved').wait(200)
        .displayText('Setup Item Pricing Successful').wait(500)
        .displayText('Create non-lotted Item Successful').wait(500)
        .clickButton('#btnClose').wait(500)



        //Scenario 2. Add Inventory Item - Lotted Yes Serial
        .displayText('======== Scenario 2: Add Inventory Item - Lotted Yes Serial========"').wait(1000)
        .expandMenu('Inventory').wait(500)
        .waitTillLoaded('Open Inventory Menu Successfull').wait(200)
        .openScreen('Items').wait(500)
        .waitTillLoaded('Open Items Search Screen Successful').wait(500)

        //#1
        .displayText('1. Open New Item Screen.').wait(500)
        .clickButton('#btnNew').wait(200)
        .waitTillVisible('icitem','Open New Item Screen Successful').wait(500)
        .checkScreenShown('icitem').wait(200)
        .checkStatusMessage('Ready')


        //#2
        .displayText('2. Setup Details Tab').wait(500)
        .enterData('#txtItemNo', 'LTI - 01').wait(200)
        //.selectComboRowByIndex('#cboType',0).wait(200)
        .enterData('#txtShortName', 'Test Inventory Item').wait(200)
        .enterData('#txtDescription', 'Lotted Item 01').wait(200)
        .selectComboRowByFilter('#cboCommodity', 'Corn', 600, 'strCommodityCode').wait(300)
        .selectComboRowByIndex('#cboLotTracking', 1).wait(200)
        .checkControlReadOnly('#cboTracking', true).wait(100)
        .checkControlData('#cboTracking', 'Lot Level').wait(100)
        .selectComboRowByFilter('#cboCategory', 'Grains', 600, 'strCategoryCode').wait(300)
        .displayText(' Setup Details Tab Successful').wait(500)


        //#3
        .displayText('3. Setup Unit of Measure').wait(500)
        .clickButton('#btnLoadUOM').wait(300)
        .waitTillLoaded('Add UOM Successful')
        /*.selectGridComboRowByFilter('#grdUnitOfMeasure', 0, 'strUnitMeasure', 'LB', 300, 'strUnitMeasure').wait(100)
         .clickButton('#btnInsertUom').wait(100)
         .selectGridComboRowByFilter('#grdUnitOfMeasure', 1, 'strUnitMeasure', '50 lb bag', 300, 'strUnitMeasure').wait(100)
         .clickButton('#btnInsertUom').wait(100)
         .selectGridComboRowByFilter('#grdUnitOfMeasure', 2, 'strUnitMeasure', 'Bushels', 300, 'strUnitMeasure').wait(100)
         .clickGridCheckBox('#grdUnitOfMeasure', 'strUnitMeasure', 'LB', 'ysnStockUnit', true).wait(100)*/

        //#4
        .displayText('3. Setup GL Accounts').wait(500)
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
        .displayText('Setup GL Accounts Successful').wait(500)

        //#5
        .displayText('5. Setup Location').wait(500)
        .clickTab('#cfgLocation').wait(100)
        .clickButton('#btnAddLocation').wait(100)
        .waitTillVisible('icitemlocation','Add Item Location Screen Displayed',60000).wait(500)
        .selectComboRowByFilter('#cboDefaultVendor', '0001005057', 1000, 'intVendorId').wait(500)
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
        .displayText('5. Setup Location Successful').wait(500)

        //#6
        .displayText('5. Setup Item Pricing').wait(500)
        .clickTab('#cfgPricing').wait(100)
        .checkGridData('#grdPricing', 0, 'strLocationName', '0001 - Fort Wayne').wait(100)
        .enterGridData('#grdPricing', 0, 'dblLastCost', '8.5').wait(300)
        .enterGridData('#grdPricing', 0, 'dblStandardCost', '8.2').wait(300)
        .enterGridData('#grdPricing', 0, 'dblAverageCost', '8.5').wait(300)
        .checkStatusMessage('Edited').wait(200)
        .clickButton('#btnSave').wait(200)
        .checkStatusMessage('Saved').wait(200)
        .displayText('Setup Item Pricing Successful').wait(500)
        .displayText('Create non-lotted Item Successful').wait(500)
        .clickButton('#btnClose').wait(500)



        //Scenario 3. Add Inventory Item - Lotted Yes Serial
        .displayText('======== Scenario 3: Add Inventory Item - Lotted Yes Manual========"').wait(1000)
        .expandMenu('Inventory').wait(500)
        .waitTillLoaded('Open Inventory Menu Successfull').wait(200)
        .openScreen('Items').wait(500)
        .waitTillLoaded('Open Items Search Screen Successful').wait(500)

        //#1
        .displayText('1. Open New Item Screen.').wait(500)
        .clickButton('#btnNew').wait(200)
        .waitTillVisible('icitem','Open New Item Screen Successful').wait(500)
        .checkScreenShown('icitem').wait(200)
        .checkStatusMessage('Ready')


        //#2
        .displayText('2. Setup Details Tab').wait(500)
        .enterData('#txtItemNo', 'LTI - 02').wait(200)
        //.selectComboRowByIndex('#cboType',0).wait(200)
        .enterData('#txtShortName', 'Test Inventory Item').wait(200)
        .enterData('#txtDescription', 'Lotted Item 02').wait(200)
        .selectComboRowByFilter('#cboCommodity', 'Corn', 600, 'strCommodityCode').wait(300)
        .selectComboRowByIndex('#cboLotTracking', 0).wait(200)
        .checkControlReadOnly('#cboTracking', true).wait(100)
        .checkControlData('#cboTracking', 'Lot Level').wait(100)
        .selectComboRowByFilter('#cboCategory', 'Grains', 600, 'strCategoryCode').wait(300)
        .displayText(' Setup Details Tab Successful').wait(500)


        //#3
        .displayText('3. Setup Unit of Measure').wait(500)
        .clickButton('#btnLoadUOM').wait(300)
        .waitTillLoaded('Add UOM Successful')
        /*.selectGridComboRowByFilter('#grdUnitOfMeasure', 0, 'strUnitMeasure', 'LB', 300, 'strUnitMeasure').wait(100)
         .clickButton('#btnInsertUom').wait(100)
         .selectGridComboRowByFilter('#grdUnitOfMeasure', 1, 'strUnitMeasure', '50 lb bag', 300, 'strUnitMeasure').wait(100)
         .clickButton('#btnInsertUom').wait(100)
         .selectGridComboRowByFilter('#grdUnitOfMeasure', 2, 'strUnitMeasure', 'Bushels', 300, 'strUnitMeasure').wait(100)
         .clickGridCheckBox('#grdUnitOfMeasure', 'strUnitMeasure', 'LB', 'ysnStockUnit', true).wait(100)*/

        //#4
        .displayText('3. Setup GL Accounts').wait(500)
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
        .displayText('Setup GL Accounts Successful').wait(500)

        //#5
        .displayText('5. Setup Location').wait(500)
        .clickTab('#cfgLocation').wait(100)
        .clickButton('#btnAddLocation').wait(100)
        .waitTillVisible('icitemlocation','Add Item Location Screen Displayed',60000).wait(500)
        .selectComboRowByFilter('#cboDefaultVendor', '0001005057', 1000, 'intVendorId').wait(500)
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
        .displayText('5. Setup Location Successful').wait(500)

        //#6
        .displayText('5. Setup Item Pricing').wait(500)
        .clickTab('#cfgPricing').wait(100)
        .checkGridData('#grdPricing', 0, 'strLocationName', '0001 - Fort Wayne').wait(100)
        .enterGridData('#grdPricing', 0, 'dblLastCost', '8.5').wait(300)
        .enterGridData('#grdPricing', 0, 'dblStandardCost', '8.2').wait(300)
        .enterGridData('#grdPricing', 0, 'dblAverageCost', '8.5').wait(300)
        .checkStatusMessage('Edited').wait(200)
        .clickButton('#btnSave').wait(200)
        .checkStatusMessage('Saved').wait(200)
        .displayText('Setup Item Pricing Successful').wait(500)
        .displayText('Create non-lotted Item Successful').wait(500)
        .clickButton('#btnClose').wait(500)


        //Scenario 4. Duplicate Item
        .displayText('======== Scenario 4. Duplicate Item========"').wait(1000)
        .expandMenu('Inventory').wait(500)
        .waitTillLoaded('Open Inventory Menu Successfull').wait(200)
        .openScreen('Items').wait(500)
        .waitTillLoaded('Open Items Search Screen Successful').wait(500)

        //#1
        .displayText('1. Open New Item Screen.').wait(500)
        .clickButton('#btnNew').wait(200)
        .waitTillVisible('icitem','Open New Item Screen Successful').wait(500)
        .checkScreenShown('icitem').wait(200)
        .checkStatusMessage('Ready')


        //#2
        .displayText('2. Setup Details Tab').wait(500)
        .enterData('#txtItemNo', 'LTI - 01').wait(200)
        //.selectComboRowByIndex('#cboType',0).wait(200)
        .enterData('#txtShortName', 'Test Inventory Item').wait(200)
        .enterData('#txtDescription', 'Lotted Item 01').wait(200)
        .selectComboRowByFilter('#cboCommodity', 'Corn', 600, 'strCommodityCode').wait(300)
        .selectComboRowByIndex('#cboLotTracking', 1).wait(200)
        .checkControlReadOnly('#cboTracking', true).wait(100)
        .checkControlData('#cboTracking', 'Lot Level').wait(100)
        .selectComboRowByFilter('#cboCategory', 'Grains', 600, 'strCategoryCode').wait(300)
        .displayText(' Setup Details Tab Successful').wait(500)


        //#3
        .displayText('3. Setup Unit of Measure').wait(500)
        .clickButton('#btnLoadUOM').wait(300)
        .waitTillLoaded('Add UOM Successful')
        /*.selectGridComboRowByFilter('#grdUnitOfMeasure', 0, 'strUnitMeasure', 'LB', 300, 'strUnitMeasure').wait(100)
         .clickButton('#btnInsertUom').wait(100)
         .selectGridComboRowByFilter('#grdUnitOfMeasure', 1, 'strUnitMeasure', '50 lb bag', 300, 'strUnitMeasure').wait(100)
         .clickButton('#btnInsertUom').wait(100)
         .selectGridComboRowByFilter('#grdUnitOfMeasure', 2, 'strUnitMeasure', 'Bushels', 300, 'strUnitMeasure').wait(100)
         .clickGridCheckBox('#grdUnitOfMeasure', 'strUnitMeasure', 'LB', 'ysnStockUnit', true).wait(100)*/

        //#4
        .displayText('3. Save Duplicate item').wait(500)
        .clickButton('#btnSave').wait(300)
        .checkMessageBox('iRely i21','Item No must be unique.','ok','error').wait(1000)
        .clickMessageBoxButton('ok').wait(300)
        .clickButton('#btnClose').wait(500)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question').wait(1000)
        .clickMessageBoxButton('no').wait(300)
        .displayText('Was not able to save duplicate item.').wait(500)


        //Scenario 5. Duplicate Buton
        .displayText('======== Scenario 5. Duplicate Button========"').wait(1000)
        .expandMenu('Inventory').wait(500)
        .waitTillLoaded('Open Inventory Menu Successfull').wait(200)
        //#1
        .displayText('1. Open Items Screen').wait(500)
        .openScreen('Items').wait(500)
        .waitTillLoaded('Open Items Search Screen Successful').wait(500)

        //#2
        .displayText('2. Select Any Item').wait(500)
        .selectSearchRowByFilter('LTI - 01').wait(500)
        .waitTillLoaded('Search Item Successful')

        //#3
        .displayText('3. Open Item').wait(500)
        .clickButton('#btnOpenSelected').wait(500)
        .waitTillVisible('icitem','Open New Item Screen Successful').wait(500)

        //#4
        .displayText('4. Click Duplicate Button').wait(500)
        .clickButton('#btnDuplicate').wait(500)
        .waitTillLoaded('Duplicate Item Successful')
        .checkControlData('#txtItemNo', 'LTI - 01-copy').wait(100)
        .displayText('Duplicate Item Successfu').wait(500)

        //#5
        .displayText('5. Update Item No.').wait(500)
        .enterData('#txtItemNo', 'NLTI - 03').wait(200)
        .enterData('#txtShortName', 'Test Inventory Item').wait(200)
        .enterData('#txtDescription', 'Lotted Item 03').wait(200)
        .displayText('Update Item No. Successful').wait(500)

        //#6
        .displayText('6. Save and Close item screen.').wait(500)
        .clickButton('#btnSave').wait(500)
        .checkStatusMessage('Saved').wait(200)
        .clickButton('#btnClose').wait(500)
        .displayText('Item Save Successful').wait(500)


        .done();
});



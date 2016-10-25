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


        .markSuccess('======== Add Item Scenarios Done and Successful! ========')


        //#Scenario 2: Add Commodity
         .displayText('====== Scenario 2. Add Cmmodity ======').wait(300)
        .openScreen('Commodities').wait(500)
        .waitTillLoaded('Open Commodity  Search Screen Successful').wait(200)
        .displayText('====== Scenario 2.1. Add Commodity with no UOM Setup ======').wait(300)
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

        //#2.1 Add Commodity with UOM
        .displayText('====== Scenario 2.1 Add Commodity with UOM Setup ======').wait(300)
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
        .markSuccess('Add Commodity with no UOM Setup Successful')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('iccommodity').wait(300)


        //#Scenario 3: Add Category
        .displayText('====== Scenario 3. Add Category ======').wait(300)
        .openScreen('Categories').wait(500)
        .waitTillLoaded('Open Category Search Screen Successful').wait(200)


        //#3. Add Category - Inventory
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
        .displayText('====== Scenario 10: Inventory UOM ======').wait(300)
        .openScreen('Inventory UOM').wait(500)
        .waitTillLoaded()
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
        .displayText('====== Scenario #10.1 Add Conversion UOM> 5 Lb Bag======').wait(300)
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


        .displayText('====== Scenario #10.2 Add Conversion UOM> 10 Lb Bag======').wait(300)
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

        .displayText('====== Scenario 11. Add Storage Location: Allow bin of the same name to be used in a different Sub Location ======').wait(300)
        .openScreen('Storage Locations').wait(500)
        .waitTillLoaded()
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



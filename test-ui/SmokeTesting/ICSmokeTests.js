StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)



//
//        //region Scenario 2. Add Maintenance Screens
//        .displayText('=====   Scenario 2. Add Maintenance Screens ====')
//        //region Scenario 2.1: Add Storage Locations
//        .displayText('===== Scenario 2.1: Add Storage Locations =====')
        .clickMenuFolder('Inventory','Folder')
//        .clickMenuScreen('Storage Locations','Screen')
//        .clickButton('New')
//        .waitUntilLoaded('icstorageunit')
//        .enterData('Text Field','Name','ICSmoke - SL')
//        .enterData('Text Field','Description','ICSmoke - SL')
//        .selectComboBoxRowNumber('UnitType',7,0)
//        .selectComboBoxRowNumber('Location',1,0)
//        .selectComboBoxRowNumber('SubLocation',6,0)
//        .selectComboBoxRowNumber('ParentUnit',1,0)
//        .enterData('Text Field','Aisle','Test Aisle - 01')
//        .clickCheckBox('AllowConsume', true)
//        .clickCheckBox('AllowMultipleItems', true)
//        .clickCheckBox('AllowMultipleLots', true)
//        .clickCheckBox('CycleCounted', true)
//        .verifyStatusMessage('Edited')
//        .clickButton('Save')
//        .verifyStatusMessage('Saved')
//        .clickButton('Close')
//        .displayText('===== Scenario 2.1: Add Storage Locations Done=====')
//
//
//        //region Scenario 2.2. Add Inventory UOM
//        .displayText('===== Scenario 2.2. Add Inventory UOM =====')
//        .clickMenuScreen('Inventory UOM','Screen')
//        .clickButton('New')
//        .waitUntilLoaded('icinventoryuom')
//        .enterData('Text Field','UnitMeasure','Smoke_LB')
//        .enterData('Text Field','Symbol','Test_LB')
//        .selectComboBoxRowNumber('UnitType',6,0)
//        .verifyStatusMessage('Edited')
//        .clickButton('Save')
//        .verifyStatusMessage('Saved')
//        .clickButton('Close')
//
//        .clickButton('New')
//        .waitUntilLoaded('icinventoryuom')
//        .enterData('Text Field','UnitMeasure','Smoke 5 LB bag')
//        .enterData('Text Field','Symbol','Smoke 5 LB bag')
//        .selectComboBoxRowNumber('UnitType',7,0)
//        .selectGridComboBoxRowValue('Conversion',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
//        .enterGridData('Conversion', 1, 'dblConversionToStock', '5')
//        .verifyStatusMessage('Edited')
//        .clickButton('Save')
//        .verifyStatusMessage('Saved')
//        .clickButton('Close')
//
//        .clickButton('New')
//        .waitUntilLoaded('icinventoryuom')
//        .enterData('Text Field','UnitMeasure','Smoke 10 LB bag')
//        .enterData('Text Field','Symbol','Smoke 10 LB bag')
//        .selectComboBoxRowNumber('UnitType',7,0)
//        .selectGridComboBoxRowValue('Conversion',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
//        .enterGridData('Conversion', 1, 'dblConversionToStock', '10')
//        .verifyStatusMessage('Edited')
//        .clickButton('Save')
//        .verifyStatusMessage('Saved')
//        .clickButton('Close')
        //endregion

//        .clickButton('New')
//        .waitUntilLoaded('icinventoryuom')
//        .enterData('Text Field','UnitMeasure','Smoke KG')
//        .enterData('Text Field','Symbol','Smoke KG')
//        .selectComboBoxRowNumber('UnitType',6,0)
//        .selectGridComboBoxRowValue('Conversion',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
//        .enterGridData('Conversion', 1, 'dblConversionToStock', '2.20462')
//        .verifyStatusMessage('Edited')
//        .clickButton('Save')
//        .verifyStatusMessage('Saved')
//        .clickButton('Close')
//        .displayText('===== Scenario 2.2. Add Inventory UOM Done=====')
        //endregion
//
        //region Scenario 2.3: Add New Fuel Type, Fuel Category, Feed Stock, Fuel Code, Production Process, Feed Stock UOM
        //Fuel Category
//        .displayText('===== Scenario 2.3: Add New Fuel Type, Fuel Category, Feed Stock, Fuel Code, Production Process, Feed Stock UOM =====')
//        .clickMenuScreen('Fuel Types','Screen')
//        .clickButton('Close')
//        .clickButton('FuelCategory')
//        .waitUntilLoaded('icfuelcategory')
//        .enterGridData('GridTemplate', 1, 'colRinFuelCategoryCode', 'ICSmokeFuelCategory')
//        .enterGridData('GridTemplate', 1, 'colDescription', 'ICSmokeFuelCategoryDesc')
//        .enterGridData('GridTemplate', 1, 'colEquivalenceValue', 'ICSmokeFuelCategory_EV')
//        .verifyStatusMessage('Edited')
//        .clickButton('Save')
//        .verifyStatusMessage('Saved')
//        .clickButton('Close')
//
//        //Feed Stock
//        .clickButton('FeedStock')
//        .waitUntilLoaded('')
//        .enterGridData('GridTemplate', 1, 'colRinFeedStockCode', 'ICSmokeFeedStock')
//        .enterGridData('GridTemplate', 1, 'colDescription', 'ICSmokeFeedStockDesc')
//        .verifyStatusMessage('Edited')
//        .clickButton('Save')
//        .verifyStatusMessage('Saved')
//        .clickButton('Close')
//
//        //FuelCode
//        .clickButton('FuelCode')
//        .waitUntilLoaded('icfuelcode')
//        .enterGridData('GridTemplate', 1, 'colRinFuelCode', 'ICSmokeFuelCode')
//        .enterGridData('GridTemplate', 1, 'colDescription', 'ICSmokeFuelCodeDesc')
//        .verifyStatusMessage('Edited')
//        .clickButton('Save')
//        .verifyStatusMessage('Saved')
//        .clickButton('Close')
//
//        //Production Process
//        .clickButton('ProductionProcess')
//        .waitUntilLoaded('icprocesscode')
//        .enterGridData('GridTemplate', 1, 'colRinProcessCode', 'ICSmokeProductionProcess')
//        .enterGridData('GridTemplate', 1, 'colDescription', 'ICSmokeProductionProcessDesc')
//        .verifyStatusMessage('Edited')
//        .clickButton('Save')
//        .verifyStatusMessage('Saved')
//        .clickButton('Close')
//
//        //Feed Stock UOM
//        .clickButton('FeedStockUOM')
//        .waitUntilLoaded('icfeedstockuom')
//        .selectGridComboBoxRowValue('GridTemplate',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
//        .enterGridData('GridTemplate', 1, 'colRinFeedStockUOMCode', 'Test UOM Code 1')
//        .verifyStatusMessage('Edited')
//        .clickButton('Save')
//        .verifyStatusMessage('Saved')
//        .clickButton('Close')
//
//        //Fuel Type
//        .clickButton('New')
//        .selectComboBoxRowValue('FuelCategory', 'ICSmokeFuelCategory', 'FuelCategory',0)
//        .selectComboBoxRowValue('FeedStock', 'ICSmokeFeedStock', 'FeedStock',0)
//        .enterData('Text Field','BatchNo','1')
//        .verifyData('Text Field','EquivalenceValue','ICSmokeFuelCategory_EV')
//        .selectComboBoxRowValue('FuelCode', 'ICSmokeFuelCode', 'FuelCode',0)
//        .selectComboBoxRowValue('ProductionProcess', 'ICSmokeProductionProcess', 'ProductionProcess',0)
//        .selectComboBoxRowValue('FeedStockUom', 'Smoke_LB', 'FeedStockUom',0)
//        .enterData('Text Field','FeedStockFactor','10')
//        .clickCheckBox('RenewableBiomass', true)
//        .enterData('Text Field','PercentOfDenaturant','25')
//        .clickCheckBox('DeductDenaturantFromRin', true)
//        .clickButton('Save')
//        .verifyStatusMessage('Saved')
//        .clickButton('Close')
//        //endregion
//
//
        //region Scenario 2.4: Add Category
        .displayText('===== Scenario 2.4: Add Category =====')
        .clickMenuScreen('Categories','Screen')
        .clickButton('New')
        .waitUntilLoaded('iccategory')
        .enterData('Text Field','CategoryCode','Smoke Inventory Category')
        .enterData('Text Field','Description','Test Inventory Category')
        .selectComboBoxRowNumber('InventoryType',2,0)
        .selectComboBoxRowNumber('CostingMethod',1,0)
        .selectGridComboBoxRowValue('Tax',1,'strTaxClass','State Sales Tax (SST)','strTaxClass')


        .displayText('===== Setup GL Accounts=====')
        .clickTab('GL Accounts')
        .clickButton('AddRequired')
        .waitUntilLoaded()
        .verifyGridData('GlAccounts', 1, 'colAccountCategory', 'AP Clearing')
        .verifyGridData('GlAccounts', 2, 'colAccountCategory', 'Inventory')
        .verifyGridData('GlAccounts', 3, 'colAccountCategory', 'Cost of Goods')
        .verifyGridData('GlAccounts', 4, 'colAccountCategory', 'Sales Account')
        .verifyGridData('GlAccounts', 5, 'colAccountCategory', 'Inventory In-Transit')
        .verifyGridData('GlAccounts', 6, 'colAccountCategory', 'Inventory Adjustment')

        .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', '21000-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 2, 'strAccountId', '16000-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 3, 'strAccountId', '50000-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 4, 'strAccountId', '40010-0102-005', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 5, 'strAccountId', '16050-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 6, 'strAccountId', '16040-0000-000', 'strAccountId')


        .clickButton('Save')
        .waitUntilLoaded()
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .displayText('===== Scenario 2.4: Add Category Done =====')
       //endregion

        //region Scenario 2.5: Add Commodity
        .displayText('===== Scenario 2.5: Add Commodity =====')
        .clickMenuScreen('Commodities','Screen')
        .clickButton('New')
        .waitUntilLoaded('iccommodity')
        .enterData('Text Field','CommodityCode','Smoke Commodity')
        .enterData('Text Field','Description','Test Smoke Commodity')


        .selectGridComboBoxRowValue('Uom',1,'strUnitMeasure','LB','strUnitMeasure')
        .clickGridCheckBox('Uom', 1,'strUnitMeasure', 'LB', 'ysnStockUnit', true)
        .selectGridComboBoxRowValue('Uom',2,'strUnitMeasure','KG','strUnitMeasure')
        .selectGridComboBoxRowValue('Uom',3,'strUnitMeasure','50 LB Bag','strUnitMeasure')

        .verifyGridData('Uom', 1, 'colUOMUnitQty', '1')
        .verifyGridData('Uom', 2, 'colUOMUnitQty', '2.20462')
        .verifyGridData('Uom', 3, 'colUOMUnitQty', '50')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .displayText('===== Scenario 2.5: Add Commodity Done =====')
        //endregion

        //region Scenario 2.6: Add Lotted Item
        .displayText('===== Scenario 2.6: Add Lotted Item =====')
        .clickMenuScreen('Items','Screen')
        .clickButton('New')
        .waitUntilLoaded('icitem')
        .enterData('Text Field','ItemNo','Smoke - LTI - 01')
        .enterData('Text Field','Description','Smoke - LTI - 01 Lotted Item Manual')
        .selectComboBoxRowValue('Category', 'Smoke Inventory Category', 'Category',0)
        .selectComboBoxRowValue('Commodity', 'Smoke Commodity', 'Commodity',0)
        .selectComboBoxRowNumber('LotTracking',1,0)
        .verifyData('Combo Box','Tracking','Lot Level')

//        .displayText('===== Setup Item UOM=====')
//        .selectGridComboBoxRowValue('UnitOfMeasure',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
//        .selectGridComboBoxRowValue('UnitOfMeasure',2,'strUnitMeasure','Smoke 5 LB bag','strUnitMeasure')
//        .selectGridComboBoxRowValue('UnitOfMeasure',3,'strUnitMeasure','Smoke 10 LB bag','strUnitMeasure')
//        .selectGridComboBoxRowValue('UnitOfMeasure',4,'strUnitMeasure','Smoke KG','strUnitMeasure')
//        .clickGridCheckBox('UnitOfMeasure', 0,'strUnitMeasure', 'Smoke_LB', 'ysnStockUnit', true)
//        .waitUntilLoaded('')
//
//        .verifyGridData('UnitOfMeasure', 1, 'colDetailUnitQty', '1')
//        .verifyGridData('UnitOfMeasure', 2, 'colDetailUnitQty', '5')
//        .verifyGridData('UnitOfMeasure', 3, 'colDetailUnitQty', '10')
//        .verifyGridData('UnitOfMeasure', 4, 'colDetailUnitQty', '2.20462')


        .displayText('===== Setup Item GL Accounts=====')
        .clickTab('Setup')
//        .clickButton('AddRequiredAccounts')
//        .verifyGridData('GlAccounts', 1, 'colGLAccountCategory', 'AP Clearing')
//        .verifyGridData('GlAccounts', 2, 'colGLAccountCategory', 'Inventory')
//        .verifyGridData('GlAccounts', 3, 'colGLAccountCategory', 'Cost of Goods')
//        .verifyGridData('GlAccounts', 4, 'colGLAccountCategory', 'Sales Account')
//        .verifyGridData('GlAccounts', 5, 'colGLAccountCategory', 'Inventory In-Transit')
//        .verifyGridData('GlAccounts', 6, 'colGLAccountCategory', 'Inventory Adjustment')
//        .verifyGridData('GlAccounts', 7, 'colGLAccountCategory', 'Auto-Variance')
//        .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', '21000-0000-000', 'strAccountId')
//        .selectGridComboBoxRowValue('GlAccounts', 2, 'strAccountId', '16000-0000-000', 'strAccountId')
//        .selectGridComboBoxRowValue('GlAccounts', 3, 'strAccountId', '50000-0000-000', 'strAccountId')
//        .selectGridComboBoxRowValue('GlAccounts', 4, 'strAccountId', '40010-0001-006', 'strAccountId')
//        .selectGridComboBoxRowValue('GlAccounts', 5, 'strAccountId', '16050-0000-000', 'strAccountId')
//        .selectGridComboBoxRowValue('GlAccounts', 6, 'strAccountId', '16040-0000-000', 'strAccountId')
//        .selectGridComboBoxRowValue('GlAccounts', 7, 'strAccountId', '16010-0000-000', 'strAccountId')

        .displayText('===== Setup Item Location=====')
        .clickTab('Location')
        .clickButton('AddLocation')
        .waitUntilLoaded('')
        .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',0)
        .selectComboBoxRowValue('StorageLocation', 'ICSmoke - SL', 'StorageLocation',0)
        .selectComboBoxRowValue('IssueUom', 'Smoke_LB', 'IssueUom',0)
        .selectComboBoxRowValue('ReceiveUom', 'Smoke_LB', 'ReceiveUom',0)
        .clickButton('Save')
        .clickButton('Close')

        .clickButton('AddLocation')
        .waitUntilLoaded('')
        .selectComboBoxRowValue('Location', '0002 - Indianapolis', 'Location',0)
        .selectComboBoxRowValue('SubLocation', 'Indy', 'SubLocation',0)
        .selectComboBoxRowValue('StorageLocation', 'Indy Storage', 'StorageLocation',0)
        .selectComboBoxRowValue('IssueUom', 'LB', 'IssueUom',0)
        .selectComboBoxRowValue('ReceiveUom', 'LB', 'ReceiveUom',0)
        .clickButton('Save')
        .clickButton('Close')

        .displayText('===== Setup Item Pricing=====')
        .clickTab('Pricing')
        .waitUntilLoaded('')
        .verifyGridData('Pricing', 1, 'strLocationName', '0001 - Fort Wayne')
        .enterGridData('Pricing', 1, 'dblLastCost', '10')
        .enterGridData('Pricing', 1, 'dblStandardCost', '10')
        .selectGridComboBoxRowNumber('Pricing', 1, 'strPricingMethod',3)
        .enterGridData('Pricing', 1, 'dblAmountPercent', '40')

        .verifyGridData('Pricing', 2, 'strLocationName', '0002 - Indianapolis')
        .enterGridData('Pricing', 2, 'dblLastCost', '10')
        .enterGridData('Pricing', 2, 'dblStandardCost', '10')
        .selectGridComboBoxRowNumber('Pricing', 2, 'strPricingMethod',3)
        .enterGridData('Pricing', 2, 'dblAmountPercent', '40')
        .clickButton('Save')
        .clickButton('Close')
        .displayText('===== Scenario 2.6: Add Lotted Item Done=====')
        //endregion



        //region Scenario 2.7: Add Non Lotted Item -
        .displayText('===== Scenario 2.7: Add Non Lotted Item - =====')
        .clickButton('New')
        .waitUntilLoaded('icitem')
        .enterData('Text Field','ItemNo','Smoke - NLTI - 01')
        .enterData('Text Field','Description','Smoke - NLTI - 01 Non Lotted Item')
        .selectComboBoxRowValue('Category', 'Smoke Inventory Category', 'Category',0)
        .selectComboBoxRowValue('Commodity', 'Smoke Commodity', 'Commodity',0)
        .selectComboBoxRowNumber('LotTracking',4,0)
        .verifyData('Combo Box','Tracking','Item Level')

//        .displayText('===== Setup Item UOM=====')
//        .selectGridComboBoxRowValue('UnitOfMeasure',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
//        .selectGridComboBoxRowValue('UnitOfMeasure',2,'strUnitMeasure','Smoke 5 LB bag','strUnitMeasure')
//        .selectGridComboBoxRowValue('UnitOfMeasure',3,'strUnitMeasure','Smoke 10 LB bag','strUnitMeasure')
//        .selectGridComboBoxRowValue('UnitOfMeasure',4,'strUnitMeasure','Smoke KG','strUnitMeasure')
//        .clickGridCheckBox('UnitOfMeasure', 0,'strUnitMeasure', 'Smoke_LB', 'ysnStockUnit', true)
//        .waitUntilLoaded('')
//
//        .verifyGridData('UnitOfMeasure', 1, 'colDetailUnitQty', '1')
//        .verifyGridData('UnitOfMeasure', 2, 'colDetailUnitQty', '5')
//        .verifyGridData('UnitOfMeasure', 3, 'colDetailUnitQty', '10')
//        .verifyGridData('UnitOfMeasure', 4, 'colDetailUnitQty', '2.20462')


        .displayText('===== Setup Item GL Accounts=====')
        .clickTab('Setup')
//        .clickButton('AddRequiredAccounts')
//        .verifyGridData('GlAccounts', 1, 'colGLAccountCategory', 'AP Clearing')
//        .verifyGridData('GlAccounts', 2, 'colGLAccountCategory', 'Inventory')
//        .verifyGridData('GlAccounts', 3, 'colGLAccountCategory', 'Cost of Goods')
//        .verifyGridData('GlAccounts', 4, 'colGLAccountCategory', 'Sales Account')
//        .verifyGridData('GlAccounts', 5, 'colGLAccountCategory', 'Inventory In-Transit')
//        .verifyGridData('GlAccounts', 6, 'colGLAccountCategory', 'Inventory Adjustment')
//        .verifyGridData('GlAccounts', 7, 'colGLAccountCategory', 'Auto-Variance')
//        .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', '21000-0000-000', 'strAccountId')
//        .selectGridComboBoxRowValue('GlAccounts', 2, 'strAccountId', '16000-0000-000', 'strAccountId')
//        .selectGridComboBoxRowValue('GlAccounts', 3, 'strAccountId', '50000-0000-000', 'strAccountId')
//        .selectGridComboBoxRowValue('GlAccounts', 4, 'strAccountId', '40010-0001-006', 'strAccountId')
//        .selectGridComboBoxRowValue('GlAccounts', 5, 'strAccountId', '16050-0000-000', 'strAccountId')
//        .selectGridComboBoxRowValue('GlAccounts', 6, 'strAccountId', '16040-0000-000', 'strAccountId')
//        .selectGridComboBoxRowValue('GlAccounts', 7, 'strAccountId', '16010-0000-000', 'strAccountId')

        .displayText('===== Setup Item Location=====')
        .clickTab('Location')
        .clickButton('AddLocation')
        .waitUntilLoaded('')
        .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',0)
        .selectComboBoxRowValue('StorageLocation', 'ICSmoke - SL', 'StorageLocation',0)
        .selectComboBoxRowValue('IssueUom', 'Smoke_LB', 'IssueUom',0)
        .selectComboBoxRowValue('ReceiveUom', 'Smoke_LB', 'ReceiveUom',0)
        .clickButton('Save')
        .clickButton('Close')

        .clickButton('AddLocation')
        .waitUntilLoaded('')
        .selectComboBoxRowValue('Location', '0002 - Indianapolis', 'Location',0)
        .selectComboBoxRowValue('SubLocation', 'Indy', 'SubLocation',0)
        .selectComboBoxRowValue('StorageLocation', 'Indy Storage', 'StorageLocation',0)
        .selectComboBoxRowValue('IssueUom', 'LB', 'IssueUom',0)
        .selectComboBoxRowValue('ReceiveUom', 'LB', 'ReceiveUom',0)
        .clickButton('Save')
        .clickButton('Close')

        .displayText('===== Setup Item Pricing=====')
        .clickTab('Pricing')
        .waitUntilLoaded('')
        .verifyGridData('Pricing', 1, 'strLocationName', '0001 - Fort Wayne')
        .enterGridData('Pricing', 1, 'dblLastCost', '10')
        .enterGridData('Pricing', 1, 'dblStandardCost', '10')
        .selectGridComboBoxRowNumber('Pricing', 1, 'strPricingMethod',3)
        .enterGridData('Pricing', 1, 'dblAmountPercent', '40')

        .verifyGridData('Pricing', 2, 'strLocationName', '0002 - Indianapolis')
        .enterGridData('Pricing', 2, 'dblLastCost', '10')
        .enterGridData('Pricing', 2, 'dblStandardCost', '10')
        .selectGridComboBoxRowNumber('Pricing', 2, 'strPricingMethod',3)
        .enterGridData('Pricing', 2, 'dblAmountPercent', '40')
        .clickButton('Save')
        .clickButton('Close')
        .displayText('===== Scenario 2.7: Add Non Lotted Item Done =====')
        .displayText('=====   Add Maintenance Screens Done ====')
        //endregion


        //region Scenario 3. Add IC Transactions
        .displayText('=====   Scenario 3. Add IC Transactions ====')

        //region Scenario 3.1: Add Direct IR for Non Lotted Item
        .displayText('=====  Scenario 3.1: Add Direct IR for Non Lotted Item =====')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','Smoke - NLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
        .enterGridData('InventoryReceipt', 1, 'colQtyToReceive', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'Smoke_LB')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'Smoke_LB')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000000')

        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblGrossWgt').text;
            if (total == 'Gross: 100,000.00') {
                t.ok(true, 'Gross is correct.');
            }
            else {
                t.ok(false, 'Gross is incorrect.');
            }
            next();
        })
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblNetWgt').text;
            if (total == 'Net: 100,000.00') {
                t.ok(true, 'Net is correct.');
            }
            else {
                t.ok(false, 'Net is incorrect.');
            }
            next();
        })
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblTotal').text;
            if (total == 'Total: 1,000,000.00') {
                t.ok(true, 'Total is correct.');
            }
            else {
                t.ok(false, 'Total is incorrect.');
            }
            next();
        })

        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000000')
        .clickButton('Post')
        .addResult('Successfully Posted',3000)
        .waitUntilLoaded('')
        .addResult('Successfully Posted',3000)
        .waitUntilLoaded('')
        .addResult('Successfully Posted',3000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Direct Inventory Receipt for Non Lotted Item Done=====')

        //region Scenario 3.2. Create Direct Inventory Receipt for Lotted Item
        .displayText('=====  Scenario 3.2. Create Direct IR for Lotted Item  =====')
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','Smoke - LTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
        .enterGridData('InventoryReceipt', 1, 'colQtyToReceive', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'Smoke_LB')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'Smoke_LB')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000000')
        .verifyGridData('InventoryReceipt', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryReceipt', 1, 'colStorageLocation', 'ICSmoke - SL')

        .enterGridData('LotTracking', 1, 'colLotId', 'LOT-01')
        .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
        .enterGridData('LotTracking', 1, 'colLotQuantity', '100000')
        .verifyGridData('LotTracking', 1, 'colLotGrossWeight', '100000')
        .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colLotNetWeight', '100000')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM', 'Smoke_LB')
        .verifyGridData('LotTracking', 1, 'colLotStorageLocation', 'ICSmoke - SL')

        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblGrossWgt').text;
            if (total == 'Gross: 100,000.00') {
                t.ok(true, 'Gross is correct.');
            }
            else {
                t.ok(false, 'Gross is incorrect.');
            }
            next();
        })
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblNetWgt').text;
            if (total == 'Net: 100,000.00') {
                t.ok(true, 'Net is correct.');
            }
            else {
                t.ok(false, 'Net is incorrect.');
            }
            next();
        })
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblTotal').text;
            if (total == 'Total: 1,000,000.00') {
                t.ok(true, 'Total is correct.');
            }
            else {
                t.ok(false, 'Total is incorrect.');
            }
            next();
        })

        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000000')
        .clickButton('Post')
        .addResult('Successfully Posted',3000)
        .waitUntilLoaded('')
        .addResult('Successfully Posted',3000)
        .waitUntilLoaded('')
        .addResult('Successfully Posted',3000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Direct Inventory Receipt for Lotted Item=====')


        //region Scenario 3.3. Create Direct Inventory Shipment for Non Lotted Item
        .displayText('=====  Scenario 3.3. Create Direct Inventory Shipment for Non Lotted Item  =====')
        .clickMenuScreen('Inventory Shipments','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryshipment')
        .selectComboBoxRowNumber('OrderType',4,0)
        .selectComboBoxRowValue('Customer', 'ABC Trucking', 'Customer',1)
        .selectComboBoxRowValue('FreightTerms', 'Truck', 'FreightTerms',1)
        .selectComboBoxRowValue('ShipFromAddress', '0001 - Fort Wayne', 'ShipFromAddress',1)
        .selectComboBoxRowNumber('ShipToAddress',1,0)

        .selectGridComboBoxRowValue('InventoryShipment',1,'strItemNo','Smoke - NLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryShipment',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
        .enterGridData('InventoryShipment', 1, 'colQuantity', '100')


        .verifyGridData('InventoryShipment', 1, 'colUnitPrice', '14')
        .verifyGridData('InventoryShipment', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryShipment', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryShipment', 1, 'colStorageLocation', 'ICSmoke - SL')
        .verifyGridData('InventoryShipment', 1, 'colLineTotal', '1400')


        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapCredit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '16050-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapDebit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1500)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Direct Inventory Shipment for Non Lotted Item Done=====')
        //endregion

        //region Scenario 3.4. Create Direct Inventory Shipment for Lotted Item
        .displayText('=====  Scenario 3.4. Create Direct Inventory Shipment for Lotted Item  =====')
        .clickButton('New')
        .waitUntilLoaded('icinventoryshipment')
        .selectComboBoxRowNumber('OrderType',4,0)
        .selectComboBoxRowValue('Customer', 'ABC Trucking', 'Customer',1)
        .selectComboBoxRowValue('FreightTerms', 'Truck', 'FreightTerms',1)
        .selectComboBoxRowValue('ShipFromAddress', '0001 - Fort Wayne', 'ShipFromAddress',1)
        .selectComboBoxRowNumber('ShipToAddress',1,0)

        .selectGridComboBoxRowValue('InventoryShipment',1,'strItemNo','Smoke - LTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryShipment',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
        .enterGridData('InventoryShipment', 1, 'colQuantity', '100')
        .verifyGridData('InventoryShipment', 1, 'colUnitPrice', '14')
        .verifyGridData('InventoryShipment', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryShipment', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryShipment', 1, 'colStorageLocation', 'ICSmoke - SL')
        .verifyGridData('InventoryShipment', 1, 'colLineTotal', '1400')

        .selectGridComboBoxRowValue('LotTracking',1,'strLotId','LOT-01','strLotId')
        .enterGridData('LotTracking', 1, 'colShipQty', '100')
        .verifyGridData('LotTracking', 1, 'colLotUOM', 'Smoke_LB')
        .verifyGridData('LotTracking', 1, 'colGrossWeight', '100')
        .verifyGridData('LotTracking', 1, 'colTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colNetWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM', 'Smoke_LB')

        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapCredit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '16050-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapDebit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1500)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Direct Inventory Shipment for Non Lotted Item Done=====')
        //endregion


        //region Scenario 3.5. Create Inventory Transfer for Non Lotted Item Shipment Not Required Location to Location
        .displayText('===== Scenario 3.5. Create Inventory Transfer for Non Lotted Item Shipment Not Required Location to Location =====')
        .clickMenuScreen('Inventory Transfers','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventorytransfer')
        .verifyData('Combo Box','TransferType','Location to Location')
        .verifyData('Combo Box','FromLocation','0001 - Fort Wayne')
        .verifyData('Combo Box','SourceType','None')
        .selectComboBoxRowValue('ToLocation', '0002 - Indianapolis', 'ToLocation',1)
        .enterData('Text Field','Description','Test Transfer')

        .selectGridComboBoxRowValue('InventoryTransfer',1,'strItemNo','Smoke - NLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromSubLocationName','Raw Station','strFromSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromStorageLocationName','ICSmoke - SL','strFromStorageLocationName')
        .verifyGridData('InventoryTransfer', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryTransfer', 1, 'colAvailableUOM', 'Smoke_LB')
        .enterGridData('InventoryTransfer', 1, 'colTransferQty', '100')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToSubLocationName','Indy','strToSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToStorageLocationName','Indy Storage','strToStorageLocationName')

        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapCredit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '16000-0002-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapDebit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1500)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Inventory Transfer for Non Lotted Item Shipment Not Required Done =====')
        //endregion

//        //region Scenario 3.6. Create Inventory Transfer for Lotted Item Shipment Not Required Location to Location
//        .displayText('===== Scenario 3.6. Create Inventory Transfer for Lotted Item Shipment Not Required Location to Location=====')
//        .clickMenuScreen('Inventory Transfers','Screen')
//        .waitUntilLoaded()
//        .clickButton('New')
//        .waitUntilLoaded('icinventorytransfer')
//        .verifyData('Combo Box','TransferType','Location to Location')
//        .verifyData('Combo Box','FromLocation','0001 - Fort Wayne')
//        .verifyData('Combo Box','SourceType','None')
//        .selectComboBoxRowValue('ToLocation', '0002 - Indianapolis', 'ToLocation',1)
//        .enterData('Text Field','Description','Test Transfer')
//
//        .selectGridComboBoxRowValue('InventoryTransfer',1,'strItemNo','Smoke - LTI - 01','strItemNo')
//        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromSubLocationName','Raw Station','strFromSubLocationName')
//        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromStorageLocationName','ICSmoke - SL','strFromStorageLocationName')
//        .verifyGridData('InventoryTransfer', 1, 'colOwnershipType', 'Own')
//        .verifyGridData('InventoryTransfer', 1, 'colAvailableUOM', 'Smoke_LB')
//        .selectGridComboBoxRowValue('InventoryTransfer',1,'strLotNumber','LOT-01','strLotNumber')
//        .enterGridData('InventoryTransfer', 1, 'colTransferQty', '100')
//        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToSubLocationName','Indy','strToSubLocationName')
//        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToStorageLocationName','Indy Storage','strToStorageLocationName')
//
//        .clickButton('PostPreview')
//        .waitUntilLoaded('cmcmrecaptransaction')
//        .waitUntilLoaded('')
//        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
//        .verifyGridData('RecapTransaction', 1, 'colRecapCredit', '1000')
//        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '16000-0002-000')
//        .verifyGridData('RecapTransaction', 2, 'colRecapDebit', '1000')
//        .clickButton('Post')
//        .waitUntilLoaded('')
//        .addResult('Successfully Posted',1500)
//        .waitUntilLoaded('')
//        .clickButton('Close')
//        .waitUntilLoaded('')
//        .displayText('===== Create Inventory Transfer for Lotted Item Shipment Not Required Done =====')
//        //endregion



        //region Scenario 3.7. Inventory Adjustment Quantity Change Non Lotted Item
        .displayText('===== Scenario 3.7. Inventory Adjustment Quantity Change Non Lotted Item=====')
        .clickMenuScreen('Inventory Adjustments','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryadjustment')
        .verifyData('Combo Box','Location','0001 - Fort Wayne')
        .selectComboBoxRowNumber('AdjustmentType',1,0)
        .enterData('Text Field','Description','Test Quantity Change')

        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strItemNo','Smoke - NLTI - 01','strItemNo')
        .enterGridData('InventoryAdjustment', 1, 'colAdjustByQuantity', '100')
        .verifyGridData('InventoryAdjustment', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryAdjustment', 1, 'colNewUnitCost', '10')

        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '16040-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Inventory Transfer for Non Lotted Item Shipment Not Required Done =====')
        //endregion

        //region Scenario 3.8. Inventory Adjustment Quantity Change Lotted Item
        .displayText('===== Scenario 3.8. Inventory Adjustment Quantity Change Lotted Item=====')
        .clickMenuScreen('Inventory Adjustments','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryadjustment')
        .verifyData('Combo Box','Location','0001 - Fort Wayne')
        .selectComboBoxRowNumber('AdjustmentType',1,0)
        .enterData('Text Field','Description','Test Quantity Change')

        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strItemNo','Smoke - LTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strSubLocation','Raw Station','strSubLocation')
        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strStorageLocation','ICSmoke - SL','strStorageLocation')
        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strLotNumber','LOT-01','strLotNumber')
        .enterGridData('InventoryAdjustment', 1, 'colAdjustByQuantity', '100')
        .verifyGridData('InventoryAdjustment', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryAdjustment', 1, 'colNewUnitCost', '10')

        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '16040-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Inventory Transfer for Non Lotted Item Shipment Not Required Done =====')
        //endregion




        //region Scenario 9. Inventory Count - Lock Inventory
        .displayText('===== Scenario  9. Inventory Count - Lock Inventory =====')
        .clickMenuScreen('Inventory Count','Screen')
        .clickButton('New')
        .waitUntilLoaded()
        .selectComboBoxRowValue('Category', 'Gas', 'Category',1)
        .selectComboBoxRowValue('Commodity', 'Gasoline', 'Commodity',1)
        .clickButton('Fetch')
        .waitUntilLoaded()
        .verifyGridData('PhysicalCount', 1, 'colItem', '87G')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('PrintCountSheets')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .clickButton('LockInventory')
        .waitUntilLoaded()
        .isControlVisible('tlb',
        [
            'PrintVariance'
            , 'LockInventory'
            , 'Post'
            , 'PostPreview'
        ], true)
        .clickButton('Close')
        .waitUntilLoaded()

        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','87G','strItemNo')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strUnitMeasure','Gallon','strUnitMeasure')
        .enterGridData('InventoryReceipt', 1, 'colQtyToReceive', '100')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'Gallon')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblTotal').text;
            if (total == 'Total: 1,000.00') {
                t.ok(true, 'Total is correct.');
            }
            else {
                t.ok(false, 'Total is incorrect.');
            }
            next();
        })

        .clickButton('PostPreview')
        .waitUntilLoaded('')
        .addResult('Clicking Recap',5000)
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .verifyMessageBox('iRely i21','Inventory Count is ongoing for Item 87G and is locked under Location 0001 - Fort Wayne.','ok','error')
        .clickMessageBoxButton('ok')
        .waitUntilLoaded('')
        .clickButton('Close')
        .displayText('===== Scenario 8. Inventory Count - Lock Inventory Done =====')
//        //endregion

        //region Scenario 9. Add new Storage Measurement Reading with 1 item only.
        .displayText('===== Scenario 1. Add new Storage Measurement Reading with 1 item only. ====')
        .clickMenuScreen('Storage Measurement Reading','Screen')
        .waitUntilLoaded()
        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded()
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',1)
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strCommodity','Smoke Commodity','strCommodity')
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strItemNo','Smoke - LTI - 01','strItemNo')
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strStorageLocationName','ICSmoke - SL','strStorageLocationName')
        .waitUntilLoaded()
        .verifyGridData('StorageMeasurementReading', 1, 'colSubLocation', 'Raw Station')
        .enterGridData('StorageMeasurementReading', 1, 'dblAirSpaceReading', '20')
        .enterGridData('StorageMeasurementReading', 1, 'dblCashPrice', '14')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== Add new Storage Measurement Reading with 1 item only Done. ====')


        .displayText('=====  Add IC Transactions Done====')
        .done();

})

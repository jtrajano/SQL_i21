StartTest (function (t) {
    var commonICST = Ext.create('Inventory.CommonICSmokeTest');
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)


        /*====================================== Add Another Company Location for Irelyadmin User and setup default decimals ======================================*/
        //region
        .displayText('===== 1. Add Indianapolis for Company Location for irelyadmin User =====')
        .clickMenuFolder('System Manager','Folder')
        .clickMenuScreen('Users','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('irelyadmin', 'strUsername', 1)
        .waitUntilLoaded('')
        .waitUntilLoaded()
        .selectComboBoxRowValue('Timezone', '(UTC+08:00) Beijing, Chongqing, Hong Kong, Urumqi', 'Timezone',0)
        .clickTab('User')
        .waitUntilLoaded()
        .clickTab('User Roles')

        .waitUntilLoaded()
        .filterGridRecords('UserRoleCompanyLocationRolePermission', 'FilterGrid', '0002 - Indianapolis')
        .waitUntilLoaded()

        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Location already exists.')
                return win.down('#grdUserRoleCompanyLocationRolePermission').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)

                    .displayText('Location is not yet existing.')
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .clickMessageBoxButton('no')
                    .waitUntilLoaded()
                    .doubleClickSearchRowValue('irelyadmin', 'strUsername', 1)
                    .waitUntilLoaded('')
                    .clickTab('User')
                    .waitUntilLoaded()
                    .clickTab('User Roles')
                    .waitUntilLoaded()
                    .selectGridComboBoxRowValue('UserRoleCompanyLocationRolePermission', 'Dummy','strLocationName', '0002 - Indianapolis','strLocationName', 1)
                    .selectGridComboBoxBottomRowValue('UserRoleCompanyLocationRolePermission', 'strUserRole', 'ADMIN', 'strUserRole', 1)
                    .clickTab('Detail')
                    .waitUntilLoaded()
                    .selectComboBoxRowValue('UserNumberFormat', '1,234,567.89', 'UserNumberFormat',1)
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .doubleClickSearchRowValue('irelyadmin', 'strUsername', 1)
                    .waitUntilLoaded('')
                    .clickTab('User')
                    .waitUntilLoaded()
                    .clickTab('User Roles')
                    .waitUntilLoaded()
                    .filterGridRecords('UserRoleCompanyLocationRolePermission', 'FilterGrid', '0002 - Indianapolis')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Location already exists.')
                return win.down('#grdUserRoleCompanyLocationRolePermission').store.getCount() != 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .clickMessageBoxButton('no')
                    .waitUntilLoaded()
                    .clickMenuFolder('System Manager','Folder')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })

        //endregion


        /*====================================== Add Storage Location for Indianapolis======================================*/
        //region
        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded()
        .clickMenuScreen('Storage Units','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'Indy Storage')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                return win.down('#grdSearch').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .displayText('===== Scenario 1: Add New Storage Location. =====')
                    .clickMenuScreen('Storage Units','Screen')
                    .clickButton('New')
                    .waitUntilLoaded('')
                    .enterData('Text Field','Name','Indy Storage')
                    .enterData('Text Field','Description','Indy Storage')
                    .selectComboBoxRowNumber('UnitType',6,0)
                    .selectComboBoxRowNumber('Location',2,0)
                    .selectComboBoxRowNumber('SubLocation',1,0)
                    .selectComboBoxRowNumber('ParentUnit',1,0)
                    .enterData('Text Field','Aisle','Test Aisle - 01')
                    .clickCheckBox('AllowConsume', true)
                    .clickCheckBox('AllowMultipleItems', true)
                    .clickCheckBox('AllowMultipleLots', true)
                    .clickCheckBox('CycleCounted', true)
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })
        //endregion


        /*====================================== Add Storage Location ======================================*/
        //region
        .waitUntilLoaded()
        .clickMenuScreen('Storage Units','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'Smoke Storage')
        .waitUntilLoaded()

        .continueIf({
            expected: true,
            actual: function (win,next) {
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Storage Location does not yet exists.')
                    .displayText('===== Scenario 1: Adding New Storage Location. =====')
                    .clickMenuScreen('Storage Units','Screen')
                    .clickButton('New')
                    .waitUntilLoaded('')
                    .enterData('Text Field','Name','Smoke Storage')
                    .enterData('Text Field','Description','Test Smoke Storage')
                    .selectComboBoxRowNumber('UnitType',6,0)
                    .selectComboBoxRowNumber('Location',1,0)
                    .selectComboBoxRowNumber('SubLocation',6,0)
                    .selectComboBoxRowNumber('ParentUnit',1,0)
                    .enterData('Text Field','Aisle','Test Aisle - 01')
                    .clickCheckBox('AllowConsume', true)
                    .clickCheckBox('AllowMultipleItems', true)
                    .clickCheckBox('AllowMultipleLots', true)
                    .clickCheckBox('CycleCounted', true)
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')
                    .waitUntilLoaded('')
                    .displayText('===== Storage Location Created =====')
                    .done();
            },
            continueOnFail: true
        })
        //endregion

        /*====================================== Add Inventory UOM ======================================*/
        //region
        .clickMenuScreen('Inventory UOM','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'Smoke')
        .waitUntilLoaded()

        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Inventory UOM Location already exists.')
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    //region Scenario 2. Add Inventory UOM
                    .displayText('===== Scenario 2. Add Inventory UOM =====')
                    .clickMenuScreen('Inventory UOM','Screen')
                    .clickButton('New')
                    .waitUntilLoaded('')
                    .enterData('Text Field','UnitMeasure','Smoke_LB')
                    .enterData('Text Field','Symbol','Test_LB')
                    .selectComboBoxRowNumber('UnitType',6,0)
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')


                    //Add Inventory UOM with Conversion 5 lb bag
                    .clickButton('New')
                    .waitUntilLoaded('')
                    .enterData('Text Field','UnitMeasure','Smoke 5 LB bag')
                    .enterData('Text Field','Symbol','Smoke 5 LB bag')
                    .selectComboBoxRowNumber('UnitType',7,0)
                    .selectGridComboBoxRowNumber('Conversion',1,'colOtherUOM',7)
                    //.selectGridComboBoxRowValue('Conversion',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
                    .enterGridData('Conversion', 1, 'dblConversionToStock', '5')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')


                    //Add Inventory UOM with Conversion 10 lb bag
                    .clickButton('New')
                    .waitUntilLoaded('')
                    .enterData('Text Field','UnitMeasure','Smoke 10 LB bag')
                    .enterData('Text Field','Symbol','Smoke 10 LB bag')
                    .selectComboBoxRowNumber('UnitType',7,0)
                    .selectGridComboBoxRowNumber('Conversion',1,'colOtherUOM',7)
                    //.selectGridComboBoxRowValue('Conversion',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
                    .enterGridData('Conversion', 1, 'dblConversionToStock', '10')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')
                    .waitUntilLoaded('')
                    .displayText('===== Inventory UOM Created =====')
                    .done();
            },
            continueOnFail: true
        })
        //endregion



        /*====================================== Add Fuel Types ======================================*/
        //region

        .displayText('===== Scenario 3: Add New Fuel Type, Fuel Category, Feed Stock, Fuel Code, Production Process, Feed Stock UOM =====')
        .clickMenuScreen('Fuel Types','Screen')
        .waitUntilLoaded()
        .continueIf({
            expected: 'icfueltype',
            actual: function(win){
                return win.alias[0].replace('widget.', '');
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .clickButton('FuelCategory')
                    .waitUntilLoaded('')
                    .enterGridData('GridTemplate', 1, 'colRinFuelCategoryCode', 'ICSmokeFuelCategory')
                    .enterGridData('GridTemplate', 1, 'colDescription', 'ICSmokeFuelCategoryDesc')
                    .enterGridData('GridTemplate', 1, 'colEquivalenceValue', 'ICSmokeFuelCategory_EV')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')

                    //Feed Stock
                    .clickButton('FeedStock')
                    .waitUntilLoaded('')
                    .enterGridData('GridTemplate', 1, 'colRinFeedStockCode', 'ICSmokeFeedStock')
                    .enterGridData('GridTemplate', 1, 'colDescription', 'ICSmokeFeedStockDesc')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')

                    //FuelCode
                    .clickButton('FuelCode')
                    .waitUntilLoaded('')
                    .enterGridData('GridTemplate', 1, 'colRinFuelCode', 'ICSmokeFuelCode')
                    .enterGridData('GridTemplate', 1, 'colDescription', 'ICSmokeFuelCodeDesc')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')

                    //Production Process
                    .clickButton('ProductionProcess')
                    .waitUntilLoaded('')
                    .enterGridData('GridTemplate', 1, 'colRinProcessCode', 'ICSmokeProductionProcess')
                    .enterGridData('GridTemplate', 1, 'colDescription', 'ICSmokeProductionProcessDesc')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')

                    //Feed Stock UOM
                    .clickButton('FeedStockUOM')
                    .waitUntilLoaded('')
                    .selectGridComboBoxRowValue('GridTemplate',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
                    .enterGridData('GridTemplate', 1, 'colRinFeedStockUOMCode', 'Test UOM Code 1')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')

                    //Fuel Type
                    .clickButton('New')
                    .selectComboBoxRowNumber('FuelCategory',1,0)
                    .selectComboBoxRowNumber('FeedStock',1,0)
                    .enterData('Text Field','BatchNo','1')
                    .verifyData('Text Field','EquivalenceValue','ICSmokeFuelCategory_EV')
                    .selectComboBoxRowNumber('FuelCode',1,0)
                    .selectComboBoxRowNumber('ProductionProcess',1,0)
                    .selectComboBoxRowNumber('FeedStockUom',1,0)
                    .enterData('Text Field','FeedStockFactor','10')
                    .clickCheckBox('RenewableBiomass', true)
                    .enterData('Text Field','PercentOfDenaturant','25')
                    .clickCheckBox('DeductDenaturantFromRin', true)
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')
                    .waitUntilLoaded('')
                    .displayText('===== Add Fuel Type Done =====')

                    .done();
                         },
                        continueOnFail: true
                    })

        //endregion


        /*====================================== Add Category ======================================*/
        //region

        .clickMenuScreen('Categories','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'SC - Category - 01')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Category already exists.')
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    //Add Category
                    .displayText('===== Scenario 4: Add Category =====')
                    .clickMenuFolder('Inventory','Folder')
                    .addFunction(function(next){
                        commonIC.addCategory (t,next, 'SC - Category - 01', 'Test Smoke Category Description', 2)
                    })
                    .clickMenuFolder('Inventory','Folder')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })
        //endregion


        /*====================================== Add Commodity ======================================*/
        //region

        .clickMenuScreen('Commodities','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'SC - Commodity - 01')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Commodity already exists.')
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clickMenuFolder('Inventory','Folder')
                    //Add Commodity
                    .displayText('===== Scenario 6: Add Commodity =====')
                    .addFunction(function(next){
                        commonIC.addCommodity (t,next, 'SC - Commodity - 01', 'Test Smoke Commodity Description')
                    })
                    .clickMenuFolder('Inventory','Folder')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })
        //endregion


        /*====================================== Add Lotted Item ======================================*/
        //region
        .clickMenuScreen('Items','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'Smoke - LTI - 01')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Item already exists.')
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clickMenuFolder('Inventory','Folder')
                    .displayText('===== Scenario 5: Add Lotted Item =====')
                    .addFunction(function(next){
                        commonIC.addInventoryItem
                        (t,next,
                            'Smoke - LTI - 01'
                            , 'Test Lotted Item For Other Smoke Testing'
                            , 'SC - Category - 01'
                            , 'SC - Commodity - 01'
                            , 3
                            , 'Pounds'
                            , 'Pounds'
                            , 10
                            , 10
                            , 40
                        )
                    })
                    .clickMenuFolder('Inventory','Folder')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })
        //endregion


        /*====================================== Add Non Lotted Item ======================================*/
        //region
        .clickMenuScreen('Items','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'Smoke - NLTI - 01')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Item already exists.')
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clickMenuFolder('Inventory','Folder')
                    .displayText('===== Scenario 6: Add Non Lotted Item =====')
                    .addFunction(function(next){
                        commonIC.addInventoryItem
                        (t,next,
                            'Smoke - NLTI - 01'
                            , 'Test Non Lotted Item Smoke Testing'
                            , 'SC - Category - 01'
                            , 'SC - Commodity - 01'
                            , 4
                            , 'Pounds'
                            , 'Pounds'
                            , 10
                            , 10
                            , 40
                        )
                    })
                    .clickMenuFolder('Inventory','Folder')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })
        //endregion


        /*====================================== Add Other Charge Item ======================================*/
        //region
        .clickMenuScreen('Items','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'Smoke - Other Charge Item - 01')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Item already exists.')
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clickMenuFolder('Inventory','Folder')
                    //Add Other Charge Item
                    .displayText('===== Scenario 7: Add Other Charge Item =====')
                    .addFunction(function(next){
                        commonIC.addOtherChargeItem
                        (t,next,
                            'Smoke - Other Charge Item - 01'
                            , 'Test Other Charge Item Smoke Testing'
                            , '0001 - Fort Wayne'
                        )
                    })
                    .displayText('===== Add Maintenance Screens Done =====')
                    .clickMenuFolder('Inventory','Folder')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })
        //endregion



//        /*====================================== Create CT to IR for  Non Lotted Item Process Button ======================================*/
//        //region
//        .displayText('===== Scenario 1: Create CT to IR for  Non Lotted Item Process Button =====')
//        .addFunction(function(next){
//            commonIC.addCTtoIRProcessButtonNonLotted (t,next, 'ABC Trucking','SC - Commodity - 01','0001 - Fort Wayne', 'Smoke - NLTI - 01','Pounds', 1000, 10)
//        })
//        .waitUntilLoaded('')
//        //endregion
//
//
//        /*====================================== Create CT to IR for  Lotted Item Process Button ======================================*/
//        //region
//        .displayText('===== Scenario 2:  CT to IR for Non Lotted Item Process Button =====')
//        .addFunction(function(next){
//            commonIC.addCTtoIRProcessButtonLotted (t,next, 'ABC Trucking', 'SC - Commodity - 01' ,'0001 - Fort Wayne', 'Smoke - LTI - 01','Pounds', 1000, 10, 'Raw Station', 'RM Storage', 'LOT-01', 'Pounds')
//        })
//        .waitUntilLoaded('')
        //endregion


        /*====================================== Create PO to IR for Non Lotted Item Add Orders Screen ======================================*/
        //region
        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded('')
        .displayText('===== Scenario 3: Create PO to IR for Non Lotted Item Add Orders Screen =====')
        .addFunction(function(next){
            commonIC.addPOtoIRAddOrdersButtonNonLotted (t,next, 'ABC Trucking', '0001 - Fort Wayne', 'Smoke - NLTI - 01','Pounds', 1000, 10)
        })
        .waitUntilLoaded('')
        //endregion


        /*====================================== Create PO to IR for Lotted Item  Add Orders Screen ======================================*/
        //region
        .displayText('===== Scenario 4: Create PO to IR for Lotted Item  Add Orders Screen =====')
        .addFunction(function(next){
            commonIC.addPOtoIRAddOrdersButtonLotted (t,next, 'ABC Trucking', '0001 - Fort Wayne', 'Smoke - LTI - 01','Pounds', 1000, 10, 'Raw Station', 'RM Storage', 'LOT-01', 'Pounds')
        })
        .waitUntilLoaded('')
        //endregion


        /*====================================== Create Direct IR for Lotted Item with other charges ======================================*/
        //region
        .displayText('===== Scenario 5: Direct IR for Lotted Item with other charges  =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Receipts','Screen')
        .clickButton('New')
        .waitUntilLoaded('')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowNumber('Vendor',1,0)
        .selectComboBoxRowNumber('Location',1,0)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','Smoke - LTI - 01','strItemNo')
        .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure', 100, 'Pounds')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'Pounds')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'Pounds')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '100')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '100')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryReceipt', 1, 'colStorageLocation', 'RM Storage')

        .enterGridData('LotTracking', 1, 'colLotId', 'LOT-01')
        .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure','Pounds','strUnitMeasure')
        .enterGridData('LotTracking', 1, 'colLotQuantity', '100')
        .verifyGridData('LotTracking', 1, 'colLotGrossWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colLotNetWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM', 'Pounds')
        .verifyGridData('LotTracking', 1, 'colLotStorageLocation', 'RM Storage')

        //Calculate Charge Amount
        .clickTab('FreightInvoice')
        .selectGridComboBoxRowValue('Charges',1,'strItemNo','Smoke - Other Charge Item - 01','strItemNo')
        .selectGridComboBoxRowNumber('Charges',1,'colCostMethod',2)
        .selectGridComboBoxRowValue('Charges',1,'strCurrency','USD','strCurrency')
        .enterGridData('Charges', 1, 'colRate', '10')
        .clickGridCheckBox('Charges',0, 'strItemNo', 'Smoke - Other Charge Item - 01', 'ysnAccrue', true)

        .clickButton('CalculateCharges')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .addResult('Successfully Calculated',2000)
        .waitUntilLoaded()
        .waitUntilLoaded()
        .addResult('Successfully Calculated',2000)

        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .clickTab('Details')
        .waitUntilLoaded('')
        .clickTab('FreightInvoice')
        .waitUntilLoaded('')
        .verifyGridData('Charges', 1, 'colChargeAmount', '100')
        .clickButton('Save')
        .waitUntilLoaded()

        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickTab('FreightInvoice')
        .waitUntilLoaded('')
        .verifyGridData('Charges', 1, 'colChargeAmount', '100')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Inventory','Folder')
        .displayText('=====  Scenario 1: Done: IR with Charges  =====')
        //endregion


        /*====================================== Create Direct IR for Non Lotted Item ======================================*/
        //region
        .displayText('===== Scenario 6: Create Direct IR for Non Lotted Item =====')
        .addFunction(function(next){
            commonIC.addDirectIRNonLotted (t,next, 'ABC Trucking', 1, 'Smoke - NLTI - 01','Pounds', 1000, 10)
        })
        //endregion


        /*====================================== Create Direct IR for Lotted Item ======================================*/
        //region
        .displayText('===== Scenario 7: Create Direct IR for Lotted Item =====')
        .addFunction(function(next){
            commonIC.addDirectIRLotted (t,next, 'ABC Trucking', 1, 'Smoke - LTI - 01','Pounds', 1000, 10, 'Raw Station', 'RM Storage', 'LOT-01', 'Pounds')
        })
        //endregion


//        /*====================================== Create SC for Non Lotted Item ======================================*/
//        //region
//        .displayText('===== Scenario 8: Create Sales Contract to Inventory Shipment Non Lotted =====')
//        .addFunction(function(next){
//            commonIC.addSCtoISAddORdersNonLotted (t,next, 'Apple Spice Sales','Smoke - NLTI - 01','SC - Commodity - 01', 100,'Pounds','0001 - Fort Wayne', 'USD', 14, 'Truck')
//        })
//        //endregion
//
//
//        /*====================================== Create SC for Lotted Item ======================================*/
//        .displayText('===== Scenario 9: Create Sales Contract to Inventory Shipment Lotted=====')
//        .addFunction(function(next){
//            commonIC.addSCtoISAddORdersLotted (t,next, 'Apple Spice Sales','Smoke - LTI - 01','SC - Commodity - 01', 100,'Pounds','0001 - Fort Wayne', 'USD', 14,'Truck', 'Raw Station', 'RM Storage','LOT-01')
//        })
//        //endregion


        /*====================================== Create SO for Non Lotted Item ======================================*/
        .displayText('===== Scenario 10: Create SO IS for NON Lotted Item =====')
        .addFunction(function(next){
            commonIC.addSOtoISAddORdersNonLotted (t,next, 'Apple Spice Sales',  'USD', '0001 - Fort Wayne', 'Truck','Smoke - NLTI - 01','Pounds', 100)
        })
        //endregion


        /*====================================== Create Direct IS for Non Lotted Item ======================================*/
        .displayText('===== Scenario 11: Create Direct IS for Non Lotted Item =====')
        .addFunction(function(next){
            commonIC.addDirectISNonLotted (t,next, 'Apple Spice Sales', 'Truck', 'USD', '0001 - Fort Wayne','Smoke - NLTI - 01','Pounds', 100)
        })
        //endregion


        /*====================================== Create Direct IS for Lotted Item ======================================*/
        .displayText('===== Scenario 12: Create Direct IS for Lotted Item =====')
        .addFunction(function(next){
            commonIC.addDirectISLotted (t,next, 'Apple Spice Sales', 'Truck', 'USD', '0001 - Fort Wayne', 'Smoke - LTI - 01','Pounds', 100, 'LOT-01')
        })
        //endregion


        /*====================================== Create Inventory Transfer for Lotted Item Shipment Required Different Location ======================================*/
        //region
        .displayText('===== Scenario 13. Create Inventory Transfer for Lotted Item Shipment Required Location to Location =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Transfers','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('')
        .verifyData('Combo Box','TransferType','Location to Location')
        .verifyData('Combo Box','FromLocation','0001 - Fort Wayne')
        .verifyData('Combo Box','SourceType','None')
        .selectComboBoxRowNumber('ToLocation',2,0)
        .clickCheckBox('ShipmentRequired', true)
        .enterData('Text Field','Description','Test Transfer')

        .selectGridComboBoxRowValue('InventoryTransfer',1,'strItemNo','Smoke - LTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromSubLocationName','Raw Station','strFromSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromStorageLocationName','RM Storage','strFromStorageLocationName')
        .verifyGridData('InventoryTransfer', 1, 'colOwnershipType', 'Own')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strLotNumber','LOT-01','strLotNumber')
        .verifyGridData('InventoryTransfer', 1, 'colAvailableUOM', 'Pounds')
        .enterGridData('InventoryTransfer', 1, 'colTransferQty', '100')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToSubLocationName','Indy','strToSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToStorageLocationName','Indy Storage','strToStorageLocationName')

        .clickButton('PostPreview')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1500)
        .addResult('Successfully Posted',1500)
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1500)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')

        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('')
        .selectComboBoxRowNumber('ReceiptType',3,0)
        .selectComboBoxRowNumber('Transferor',1,0)
        .doubleClickSearchRowValue('Smoke - LTI - 01', 'strItemNo', 1)
        .waitUntilLoaded('')
        .verifyData('Combo Box','ReceiptType','Transfer Order')
        .verifyData('Combo Box','Transferor','0001 - Fort Wayne')
        .verifyData('Combo Box','Location','0002 - Indianapolis')
        .verifyData('Combo Box','Currency','USD')
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'Smoke - LTI - 01')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'Pounds')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colSubLocation', 'Indy')
        .verifyGridData('InventoryReceipt', 1, 'colStorageLocation', 'Indy Storage')

        .selectGridRowNumber('InventoryReceipt', [1])

        .waitTillLoaded()
        .enterGridData('LotTracking', 1, 'colLotId', 'LOT-01')
        .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure','Pounds','strUnitMeasure')
        .enterGridData('LotTracking', 1, 'colLotQuantity', '100')
        .verifyGridData('LotTracking', 1, 'colLotGrossWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colLotNetWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM', 'Pounds')
        .verifyGridData('LotTracking', 1, 'colLotStorageLocation', 'Indy Storage')

        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .clickTab('Details')
        .waitUntilLoaded('')
        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Scenario 13: Create Inventory Transfer for Non Lotted Item Shipment Required Location to Location Done =====')
        //endregion


        /*====================================== Create Inventory Transfer for Non Lotted Item Shipment Not Required Location to Location ======================================*/
        //region
        .displayText('===== Scenario 14. Create Inventory Transfer for Non Lotted Item Shipment Not Required Location to Location =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Transfers','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('')
        .verifyData('Combo Box','TransferType','Location to Location')
        .verifyData('Combo Box','FromLocation','0001 - Fort Wayne')
        .verifyData('Combo Box','SourceType','None')
        .selectComboBoxRowNumber('ToLocation',2,0)
        .enterData('Text Field','Description','Test Transfer')

        .selectGridComboBoxRowValue('InventoryTransfer',1,'strItemNo','Smoke - NLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromSubLocationName','Raw Station','strFromSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromStorageLocationName','RM Storage','strFromStorageLocationName')
        .verifyGridData('InventoryTransfer', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryTransfer', 1, 'colAvailableUOM', 'Pounds')
        .enterGridData('InventoryTransfer', 1, 'colTransferQty', '100')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToSubLocationName','Indy','strToSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToStorageLocationName','Indy Storage','strToStorageLocationName')

        .clickButton('PostPreview')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1500)
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1500)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Scenario 14. Create Inventory Transfer for Non Lotted Item Shipment Not Required Location to Location Done=====')
        //endregion


        /*====================================== Create Inventory Transfer for Lotted Item Shipment Not Required Location to Location ======================================*/
        //region
        .displayText('===== Scenario 15. Create Inventory Transfer for Lotted Item Shipment Not Required Location to Location=====')
        .clickMenuScreen('Inventory Transfers','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('')
        .verifyData('Combo Box','TransferType','Location to Location')
        .verifyData('Combo Box','FromLocation','0001 - Fort Wayne')
        .verifyData('Combo Box','SourceType','None')
        .selectComboBoxRowNumber('ToLocation',2,0)
        .enterData('Text Field','Description','Test Transfer')

        .selectGridComboBoxRowValue('InventoryTransfer',1,'strItemNo','Smoke - LTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromSubLocationName','Raw Station','strFromSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromStorageLocationName','RM Storage','strFromStorageLocationName')
        .verifyGridData('InventoryTransfer', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryTransfer', 1, 'colAvailableUOM', 'Pounds')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strLotNumber','LOT-01','strLotNumber')
        .enterGridData('InventoryTransfer', 1, 'colTransferQty', '100')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToSubLocationName','Indy','strToSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToStorageLocationName','Indy Storage','strToStorageLocationName')

        .clickButton('PostPreview')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1500)
        .addResult('Successfully Posted',1500)
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
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Scenario 15. Create Inventory Transfer for Lotted Item Shipment Not Required Location to Location Done =====')
        //endregion


        /*====================================== Inventory Adjustment Quantity Change Non Lotted Item ======================================*/
        //region
        .displayText('===== Scenario 16. Inventory Adjustment Quantity Change Non Lotted Item=====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Adjustments','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('')
        .verifyData('Combo Box','Location','0001 - Fort Wayne')
        .selectComboBoxRowNumber('AdjustmentType',1,0)
        .enterData('Text Field','Description','Test Quantity Change')

        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strItemNo','Smoke - NLTI - 01','strItemNo')
        .enterGridData('InventoryAdjustment', 1, 'colAdjustByQuantity', '100')
        .verifyGridData('InventoryAdjustment', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryAdjustment', 1, 'colNewUnitCost', '10')

        .clickButton('PostPreview')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Scenario 16. Inventory Adjustment Quantity Change Non Lotted Item Done =====')
        //endregion


        /*====================================== Inventory Adjustment Quantity Change Lotted Item ======================================*/
        //region
        .displayText('===== Scenario 17. Inventory Adjustment Quantity Change Lotted Item =====')
        .clickMenuScreen('Inventory Adjustments','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('')
        .verifyData('Combo Box','Location','0001 - Fort Wayne')
        .selectComboBoxRowNumber('AdjustmentType',1,0)
        .enterData('Text Field','Description','Test Quantity Change')

        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strItemNo','Smoke - LTI - 01','strItemNo')
        .selectGridComboBoxRowNumber('InventoryAdjustment',1,'colLotNumber',1)
        .enterGridData('InventoryAdjustment', 1, 'colAdjustByQuantity', '100')
        .verifyGridData('InventoryAdjustment', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryAdjustment', 1, 'colStorageLocation', 'RM Storage')
        .verifyGridData('InventoryAdjustment', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryAdjustment', 1, 'colNewUnitCost', '10')

        .clickButton('PostPreview')
        .waitUntilLoaded('')
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
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Scenario 17. Inventory Adjustment Quantity Change Lotted Item =====')
        //endregion


        /*====================================== Inventory Adjustment Lot Move Lotted Item ======================================*/
        //region
        .displayText('===== Scenario 18. Inventory Adjustment Quantity Change Lotted Item =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Adjustments','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('')
        .verifyData('Combo Box','Location','0001 - Fort Wayne')
        .selectComboBoxRowNumber('AdjustmentType',8,0)
        .enterData('Text Field','Description','Test Lot Move')

        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strItemNo','Smoke - LTI - 01','strItemNo')
        .selectGridComboBoxRowNumber('InventoryAdjustment',1,'colLotNumber',1)
        .enterGridData('InventoryAdjustment', 1, 'colNewLotNumber', 'LOT-01')
        .enterGridData('InventoryAdjustment', 1, 'colAdjustByQuantity', '-100')
        .verifyGridData('InventoryAdjustment', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryAdjustment', 1, 'colStorageLocation', 'RM Storage')
        .verifyGridData('InventoryAdjustment', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryAdjustment', 1, 'colNewUnitCost', '10')
        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strNewLocation','0002 - Indianapolis','strNewLocation')
        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strNewSubLocation','Indy','strNewSubLocation')
        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strNewStorageLocation','Indy Storage','strNewStorageLocation')

        .clickButton('PostPreview')
        .waitUntilLoaded('')

        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapCredit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '16000-0002-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 3, 'colRecapAccountId', '16040-0001-000')
        .verifyGridData('RecapTransaction', 3, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 4, 'colRecapAccountId', '16040-0002-000')
        .verifyGridData('RecapTransaction', 4, 'colRecapCredit', '1000')

        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Scenario 18. Inventory Adjustment Quantity Change Lotted Item Done =====')
        //endregion


        /*====================================== Inventory Count - Lock Inventory ======================================*/
        //region
        .displayText('===== Scenario  19. Inventory Count - Lock Inventory =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Count','Screen')
        .clickButton('New')
        .waitUntilLoaded()
        .selectComboBoxRowNumber('Category',1,0)
        .selectComboBoxRowNumber('Commodity',3,0)
        .clickButton('Fetch')
        .waitUntilLoaded()
        .verifyGridData('PhysicalCount', 1, 'colItem', '87G')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('PrintCountSheets')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .isControlVisible('tlb',
        [
            'PrintVariance'
            , 'LockInventory'
            , 'Post'
            , 'Recap'
        ], true)
        .waitUntilLoaded()
        .clickButton('LockInventory')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()

        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowNumber('Vendor',1,0)
        .selectComboBoxRowNumber('Location',1,0)

        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','87G','strItemNo')
        .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure', 100, 'Gallon')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'Gallon')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')

        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Clicking Recap',3000)
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .clickMessageBoxButton('ok')
        .waitUntilLoaded('')
        .clickButton('Close')
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Scenario  19. Inventory Count - Lock Inventory =====')
        // endregion


        /*====================================== Add new Storage Measurement Reading with 1 item only. ======================================*/
        //region
        .displayText('===== Scenario 20. Add new Storage Measurement Reading with 1 item only. ====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Storage Measurement Reading','Screen')
        .waitUntilLoaded()
        .continueIf({
            expected: 'storagemeasurementreading',
            actual: function(win){
                return win.alias[0].replace('widget.', '');
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                    .clickMessageBoxButton('no')
                    .waitUntilLoaded()
                    .clickButton('New')
                    .waitUntilLoaded()
                    .selectComboBoxRowNumber('Location',1,0)
                    .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strCommodity','SC - Commodity - 01','strCommodity')
                    .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strItemNo','Smoke - LTI - 01','strItemNo')
                    .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strStorageLocationName','RM Storage','strStorageLocationName')
                    .waitUntilLoaded()
                    .verifyGridData('StorageMeasurementReading', 1, 'colSubLocation', 'Raw Station')
                    .enterGridData('StorageMeasurementReading', 1, 'dblAirSpaceReading', '20')
                    .enterGridData('StorageMeasurementReading', 1, 'dblCashPrice', '14')
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .clickMenuFolder('Inventory','Folder')
                    .displayText('===== Scenario 20. Add new Storage Measurement Reading with 1 item only. Done ====')
                    .done();
            },
            continueOnFail: true
        })
        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded()
        // endregion

        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded()
        .displayText('===== Scenario 21. Opening IC Screens ====')
        /*====================================== Add Another Company Location for Irelyadmin User and setup default decimals ======================================*/
        .addFunction(function(next){
            commonICST.openICScreens (t,next)
        })


        .done();

})
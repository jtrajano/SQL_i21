StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)

        //region
        .displayText('===== Pre-setup =====')
        /*====================================== Add Another Company Location for Irelyadmin User and setup default decimals ======================================*/
        .displayText('===== 1. Add Indianapolis for Company Location for irelyadmin User =====')
        .clickMenuFolder('System Manager','Folder')
        .clickMenuScreen('Users','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('irelyadmin', 'strUsername', 1)
        .waitUntilLoaded('ementity')
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
                    .waitUntilLoaded('ementity')
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
                    .waitUntilLoaded('ementity')
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


        /*====================================== Add Storage Location for Indianapolis======================================*/
        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded()
        .clickMenuScreen('Storage Locations','Screen')
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
                    .clickMenuScreen('Storage Locations','Screen')
                    .clickButton('New')
                    .waitUntilLoaded('icstorageunit')
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
        .clickMenuFolder('Inventory','Folder')
        /*====================================== Add Category ======================================*/
        //region
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Categories','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'IS - Category - 01')
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
                        commonIC.addCategory (t,next, 'IS - Category - 01', 'Test Category Description', 2)
                    })
                    .clickMenuFolder('Inventory','Folder')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })


        /*====================================== Add Commodity ======================================*/

        .clickMenuScreen('Commodities','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'IS - Commodity - 01')
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
                        commonIC.addCommodity (t,next, 'IS - Commodity - 01', 'Test Commodity Description')
                    })
                    .clickMenuFolder('Inventory','Folder')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })


        /*====================================== Add Lotted Item ======================================*/
        .clickMenuScreen('Items','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'DISLTI - 02')
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
                            'DISLTI - 02'
                            , 'Test Lotted Item Description'
                            , 'IS - Category - 01'
                            , 'IS - Commodity - 01'
                            , 3
                            , 'LB'
                            , 'LB'
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


        /*====================================== Add Non Lotted Item ======================================*/
        .clickMenuScreen('Items','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'DISNLTI - 02')
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
                            'DISNLTI - 02'
                            , 'Test Non Lotted Item Description'
                            , 'IS - Category - 01'
                            , 'IS - Commodity - 01'
                            , 4
                            , 'LB'
                            , 'LB'
                            , 10
                            , 10
                            , 40
                        )
                    })
                    .waitUntilLoaded('')
                    .clickMenuFolder('Inventory','Folder')
                    .done();
            },
            continueOnFail: true
        })
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Pre-setup done =====')
        //endregion


        //Adding Stock to Items
        .displayText('===== Adding Stocks to Created items =====')
        .addFunction(function(next){
            commonIC.addDirectIRNonLotted (t,next, 'ABC Trucking', 1, 'DISNLTI - 02','LB', 1000, 10)
        })

        .addFunction(function(next){
            commonIC.addDirectIRLotted (t,next, 'ABC Trucking', 1, 'DISLTI - 02','LB', 1000, 10, 'Raw Station', 'RM Storage', 'LOT-01', 'LB')
        })
        .waitUntilLoaded()
        .displayText('===== Adding Stocks to Created Done =====')
        .displayText('===== Pre-setup done =====')
        
        
        
        

        .displayText('=====  Scenario 1. Create Direct Inventory Shipment  for Non Lotted Item then Delete IS =====')
        .displayText('===== Creating Non Lotted Item =====')
        .clickMenuFolder('Inventory','Folder')
        // Create Inventory Shipment
        .displayText('=====   Creeate Direct IS for Non Lotted Item  =====')
        .clickMenuScreen('Inventory Shipments','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryshipment')
        .selectComboBoxRowNumber('OrderType',4,0)
        .selectComboBoxRowValue('Customer', 'ABC Trucking', 'Customer',1)
        .selectComboBoxRowValue('FreightTerms', 'Truck', 'FreightTerms',1)
        .selectComboBoxRowValue('ShipFromAddress', '0001 - Fort Wayne', 'ShipFromAddress',1)
        .selectComboBoxRowNumber('ShipToAddress',1,0)

        .selectGridComboBoxRowValue('InventoryShipment',1,'strItemNo','DISNLTI - 02','strItemNo')
        .enterUOMGridData('InventoryShipment', 1, 'colGumQuantity', 'strUnitMeasure', 100, 'LB')
        .verifyGridData('InventoryShipment', 1, 'colUnitPrice', '14')
        .verifyGridData('InventoryShipment', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryShipment', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryShipment', 1, 'colStorageLocation', 'RM Storage')
        .verifyGridData('InventoryShipment', 1, 'colLineTotal', '1400')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()


        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DISNLTI - 02', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '1000')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '0')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '100')
        .verifyGridData('Stock', 1, 'colStockAvailable', '900')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()

        //Post Inventory Shipment
        .clickMenuScreen('Inventory Shipments','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('Direct', 'strOrderType', 1)
        .waitUntilLoaded()
        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .clickTab('Details')
        .waitUntilLoaded('')
        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colCredit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colAccountId', '16050-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colDebit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1500)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Direct Inventory Shipment for Non Lotted Item Done=====')
        //endregion


        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DISNLTI - 02', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '900')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '100')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '0')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '0')
        .verifyGridData('Stock', 1, 'colStockAvailable', '900')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()

        //UnPost Inventory Shipment
        .clickMenuScreen('Inventory Shipments','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('Direct', 'strOrderType', 1)
        .waitUntilLoaded()
        .clickButton('Unpost')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()

        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DISNLTI - 02', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '1000')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '0')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '100')
        .verifyGridData('Stock', 1, 'colStockAvailable', '900')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()


        //Delete Inventory Shipment
        .clickMenuScreen('Inventory Shipments','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('Direct', 'strOrderType', 1)
        .waitUntilLoaded()
        .clickButton('Delete')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()

        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DISNLTI - 02', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '1000')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '0')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '0')
        .verifyGridData('Stock', 1, 'colStockAvailable', '1000')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Create Direct Inventory Shipment  for Non Lotted Item then Delete IS Done=====')
        //endregion



        //region Scenario 2. Create Direct Inventory Shipment for Lotted Item then Delete IS
        .displayText('=====  Scenario 2. Create Direct Inventory Shipment for Lotted Item then Delete IS =====')
        .clickMenuFolder('Inventory','Folder')
        // Create Inventory Shipment
        .displayText('=====   Creeate Direct IS for Non Lotted Item  =====')
        .clickMenuScreen('Inventory Shipments','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryshipment')
        .selectComboBoxRowNumber('OrderType',4,0)
        .selectComboBoxRowValue('Customer', 'ABC Trucking', 'Customer',1)
        .selectComboBoxRowValue('FreightTerms', 'Truck', 'FreightTerms',1)
        .selectComboBoxRowValue('ShipFromAddress', '0001 - Fort Wayne', 'ShipFromAddress',1)
        .selectComboBoxRowNumber('ShipToAddress',1,0)

        .selectGridComboBoxRowValue('InventoryShipment',1,'strItemNo','DISLTI - 02','strItemNo')
        .enterUOMGridData('InventoryShipment', 1, 'colGumQuantity', 'strUnitMeasure', 100, 'LB')

        .verifyGridData('InventoryShipment', 1, 'colUnitPrice', '14')
        .verifyGridData('InventoryShipment', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryShipment', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryShipment', 1, 'colStorageLocation', 'RM Storage')
        .verifyGridData('InventoryShipment', 1, 'colLineTotal', '1400')

        .selectGridComboBoxRowValue('LotTracking',1,'strLotId','LOT-01','strLotId')
        .enterGridData('LotTracking', 1, 'colShipQty', '100')
        .verifyGridData('LotTracking', 1, 'colLotUOM', 'LB')
        .verifyGridData('LotTracking', 1, 'colGrossWeight', '100')
        .verifyGridData('LotTracking', 1, 'colTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colNetWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM', 'LB')

        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()


        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DISLTI - 02', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '1000')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '0')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '100')
        .verifyGridData('Stock', 1, 'colStockAvailable', '900')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()

        //Post Inventory Shipment
        .clickMenuScreen('Inventory Shipments','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('Direct', 'strOrderType', 1)
        .waitUntilLoaded()
        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .clickTab('Details')
        .waitUntilLoaded('')
        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colCredit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colAccountId', '16050-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colDebit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1500)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Direct Inventory Shipment for Non Lotted Item Done=====')
        //endregion


        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DISLTI - 02', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '900')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '100')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '0')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '0')
        .verifyGridData('Stock', 1, 'colStockAvailable', '900')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()

        //UnPost Inventory Shipment
        .clickMenuScreen('Inventory Shipments','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('Direct', 'strOrderType', 1)
        .waitUntilLoaded()
        .clickButton('Unpost')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .waitUntilLoaded()

        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DISLTI - 02', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '1000')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '0')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '100')
        .verifyGridData('Stock', 1, 'colStockAvailable', '900')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()


        //Delete Inventory Shipment
        .clickMenuScreen('Inventory Shipments','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('Direct', 'strOrderType', 1)
        .waitUntilLoaded()
        .clickButton('Delete')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()

        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DISLTI - 02', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '1000')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '0')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '0')
        .verifyGridData('Stock', 1, 'colStockAvailable', '1000')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded()
        .displayText('===== Create Direct Inventory Shipment  for Non Lotted Item then Delete IS Done=====')
        //endregion


        //region Scenario 3. Create Sales Order IR for Non Lotted Item "Ship Button" then Delete IS
        .displayText('===== Scenario 3. Create Sales Order IR for Non Lotted Item then Delete the IR."Ship Button" then Delete IS =====')
        .clickMenuFolder('Sales (Accounts Receivable)','Folder')
        .clickMenuScreen('Sales Orders','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('arsalesorder')
        .selectComboBoxRowValue('Customer', 'ABC Trucking', 'Customer',1)
        .enterData('Text Field','BOLNo','Test BOL - 01')
        .selectComboBoxRowValue('FreightTerm', 'Truck', 'FreightTerm',1)
        .selectGridComboBoxRowValue('SalesOrder',1,'strItemNo','DISNLTI - 02','strItemNo')
        .addResult('Item Selected',1500)
        .enterGridData('SalesOrder', 1, 'colOrdered', '100')
        .verifyGridData('SalesOrder', 1, 'colPrice', '14')
        .clickButton('Save')
        .waitUntilLoaded('')
        .verifyMessageBox('iRely i21','WARNING: Customer may exceed credit limit!','ok','information')
        .clickMessageBoxButton('ok')
        .waitUntilLoaded('')
        .addResult('Sales Order Saved',1500)
        .clickButton('Close')
        .clickMenuFolder('Sales (Accounts Receivable)','Folder')
        .waitUntilLoaded('')

        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DISNLTI - 02', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '1000')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '100')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '0')
        .verifyGridData('Stock', 1, 'colStockAvailable', '1000')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded()

        //Ship SO to IS
        .clickMenuFolder('Sales (Accounts Receivable)','Folder')
        .clickMenuScreen('Sales Orders','Screen')
        .waitUntilLoaded()
        .clickMenuScreen('Sales Orders','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('ABC Trucking', 'strCustomerName', 1)
        .waitUntilLoaded()
        .waitUntilLoaded()
        .clickButton('Ship')
        .addResult('Clicked Ship Button',3000)
        .waitUntilLoaded('')
        .verifyMessageBox('iRely i21','WARNING: Customer may exceed credit limit!','ok','information')
        .clickMessageBoxButton('ok')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .addResult('Open Inventory Shipment Screen',3000)
        .waitUntilLoaded('')
        .waitUntilLoaded('')

        .verifyData('Combo Box','OrderType','Sales Order')
        .verifyData('Combo Box','Customer','ABC Trucking')
        .verifyData('Combo Box','FreightTerms','Truck')
        .selectGridComboBoxRowValue('InventoryShipment',1,'strSubLocationName','Raw Station','strSubLocationName')
        .selectGridComboBoxRowValue('InventoryShipment',1,'strStorageLocationName','RM Storage','strStorageLocationName')
        .verifyGridData('InventoryShipment', 1, 'colItemNumber', 'DISNLTI - 02')
        .verifyGridData('InventoryShipment', 1, 'colUnitPrice', '14')
        .verifyGridData('InventoryShipment', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryShipment', 1, 'colLineTotal', '1400')
        .clickButton('Save')
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Sales (Accounts Receivable)','Folder')
        .waitUntilLoaded()

        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DISNLTI - 02', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '1000')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '100')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '100')
        .verifyGridData('Stock', 1, 'colStockAvailable', '900')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()

        //Post Inventory Shipment
        .clickMenuScreen('Inventory Shipments','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('Sales Order', 'strOrderType', 1)
        .waitUntilLoaded()
        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .clickTab('Details')
        .waitUntilLoaded('')
        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colCredit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colAccountId', '16050-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colDebit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1500)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')

        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DISNLTI - 02', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '900')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '100')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '0')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '0')
        .verifyGridData('Stock', 1, 'colStockAvailable', '900')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()

        //UnPost Inventory Shipment
        .clickMenuScreen('Inventory Shipments','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('Sales Order', 'strOrderType', 1)
        .waitUntilLoaded()
        .clickButton('Unpost')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()

        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DISNLTI - 02', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '1000')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '100')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '100')
        .verifyGridData('Stock', 1, 'colStockAvailable', '900')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()

        //Delete Inventory Shipment
        .clickMenuScreen('Inventory Shipments','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('Sales Order', 'strOrderType', 1)
        .waitUntilLoaded()
        .clickButton('Delete')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()

        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DISNLTI - 02', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '1000')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '100')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '0')
        .verifyGridData('Stock', 1, 'colStockAvailable', '1000')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Create Sales Order IR for Non Lotted Item "Ship Button" then Delete IS Done=====')


        //region Scenario 4: Create Sales Order IR for Non Lotted Item "Add Orders Button" then Delete IS
        .displayText('===== Scenario 4: Create Sales Order IR for Non Lotted Item "Add Orders Button" then Delete IS =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Shipments','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryshipment')
        .selectComboBoxRowNumber('OrderType',2,0)
        .selectComboBoxRowValue('Customer', 'ABC Trucking', 'Customer',1)
        .waitUntilLoaded()
        .selectSearchRowNumber(1)
        .clickButton('OpenSelected')
        .waitUntilLoaded('icinventoryshipment')
        .selectComboBoxRowValue('FreightTerms', 'Truck', 'FreightTerms',1)
        .selectComboBoxRowValue('ShipFromAddress', '0001 - Fort Wayne', 'ShipFromAddress',1)
        .selectComboBoxRowNumber('ShipToAddress',1,0)

        .verifyGridData('InventoryShipment', 1, 'colItemNumber', 'DISNLTI - 02')
        .verifyGridData('InventoryShipment', 1, 'colUnitPrice', '14')
        .verifyGridData('InventoryShipment', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryShipment', 1, 'colLineTotal', '1400')
        .selectGridComboBoxRowValue('InventoryShipment',1,'strSubLocationName','Raw Station','strSubLocationName')
        .selectGridComboBoxRowValue('InventoryShipment',1,'strStorageLocationName','RM Storage','strStorageLocationName')
        .waitUntilLoaded()
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()

        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DISNLTI - 02', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '1000')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '100')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '100')
        .verifyGridData('Stock', 1, 'colStockAvailable', '900')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()

        //Post Inventory Shipment
        .clickMenuScreen('Inventory Shipments','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('Sales Order', 'strOrderType', 1)
        .waitUntilLoaded()
        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .clickTab('Details')
        .waitUntilLoaded('')
        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colCredit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colAccountId', '16050-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colDebit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1500)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')

        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DISNLTI - 02', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '900')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '100')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '0')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '0')
        .verifyGridData('Stock', 1, 'colStockAvailable', '900')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()

        //UnPost Inventory Shipment
        .clickMenuScreen('Inventory Shipments','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('Sales Order', 'strOrderType', 1)
        .waitUntilLoaded()
        .clickButton('Unpost')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()

        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DISNLTI - 02', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '1000')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '100')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '100')
        .verifyGridData('Stock', 1, 'colStockAvailable', '900')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()

        //Delete Inventory Shipment
        .clickMenuScreen('Inventory Shipments','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('Sales Order', 'strOrderType', 1)
        .waitUntilLoaded()
        .clickButton('Delete')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()

        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DISNLTI - 02', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '1000')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '100')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '0')
        .verifyGridData('Stock', 1, 'colStockAvailable', '1000')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .clickMenuFolder('Inventory','Folder')
        //endregion



        .done();

})
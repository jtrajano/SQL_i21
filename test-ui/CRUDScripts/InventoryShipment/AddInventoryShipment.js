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
        .filterGridRecords('Search', 'FilterGrid', 'ISLTI - 01')
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
                            'ISLTI - 01'
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
        .filterGridRecords('Search', 'FilterGrid', 'ISNLTI - 01')
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
                            'ISNLTI - 01'
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
            commonIC.addDirectIRNonLotted (t,next, 'ABC Trucking', 1, 'ISNLTI - 01','LB', 10000, 10)
        })

        .addFunction(function(next){
            commonIC.addDirectIRLotted (t,next, 'ABC Trucking', 1, 'ISLTI - 01','LB', 10000, 10, 'Raw Station', 'RM Storage', 'LOT-01', 'LB')
        })
        .displayText('===== Adding Stocks to Created Done =====')
        .displayText('===== Pre-setup done =====')


        
        //region Scenario 1. Create Direct Inventory Shipment for Non Lotted Item
        .displayText('=====  Scenario 1. Creeate Direct IS for Non Lotted Item  =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Shipments','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryshipment')
        .selectComboBoxRowNumber('OrderType',4,0)
        .selectComboBoxRowValue('Customer', 'ABC Trucking', 'Customer',1)
        .selectComboBoxRowValue('FreightTerms', 'Truck', 'FreightTerms',1)
        .selectComboBoxRowValue('Currency', 'USD', 'Currency',1)
        .selectComboBoxRowValue('ShipFromAddress', '0001 - Fort Wayne', 'ShipFromAddress',1)
        .selectComboBoxRowNumber('ShipToAddress',1,0)

        .selectGridComboBoxRowValue('InventoryShipment',1,'strItemNo','ISNLTI - 01','strItemNo')
        .enterUOMGridData('InventoryShipment', 1, 'colGumQuantity', 'strUnitMeasure', 100, 'LB')
        .verifyGridData('InventoryShipment', 1, 'colUnitPrice', '14')
        .verifyGridData('InventoryShipment', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryShipment', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryShipment', 1, 'colStorageLocation', 'RM Storage')
        .verifyGridData('InventoryShipment', 1, 'colLineTotal', '1400')


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

        //region Scenario 2. Create Direct Inventory Shipment for Lotted Item
        .displayText('=====  Scenario 2. Creeate Direct IS for Lotted Item  =====')
        .clickButton('New')
        .waitUntilLoaded('icinventoryshipment')
        .selectComboBoxRowNumber('OrderType',4,0)
        .selectComboBoxRowValue('Customer', 'ABC Trucking', 'Customer',1)
        .selectComboBoxRowValue('FreightTerms', 'Truck', 'FreightTerms',1)
        .selectComboBoxRowValue('Currency', 'USD', 'FreightTerms',1)
        .selectComboBoxRowValue('ShipFromAddress', '0001 - Fort Wayne', 'ShipFromAddress',1)
        .selectComboBoxRowNumber('ShipToAddress',1,0)

        .selectGridComboBoxRowValue('InventoryShipment',1,'strItemNo','ISLTI - 01','strItemNo')
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
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Create Direct Inventory Shipment for Non Lotted Item Done=====')
        //endregion


        //region Scenario 3. Create Sales Order Inventory Shipment for Non Lotted Item Ship Button
        .displayText('=====  Scenario 3. Ship Button SO to IS for Non Lotted =====')
        .clickMenuFolder('Sales (Accounts Receivable)','Folder')
        .clickMenuScreen('Sales Orders','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('arsalesorder')
        .selectComboBoxRowValue('Customer', 'ABC Trucking', 'Customer',1)
        .enterData('Text Field','BOLNo','Test BOL - 01')
        .selectComboBoxRowValue('FreightTerm', 'Truck', 'FreightTerm',1)
        .selectGridComboBoxRowValue('SalesOrder',1,'strItemNo','ISNLTI - 01','strItemNo')
        .addResult('Item Selected',1500)
        .enterGridData('SalesOrder', 1, 'colOrdered', '100')
        .verifyGridData('SalesOrder', 1, 'colPrice', '14')
//        .verifyGridData('SalesOrder', 1, 'colTotal', '1400')
        .clickButton('Save')
        .waitUntilLoaded('')
        .verifyMessageBox('iRely i21','WARNING: Customer may exceed credit limit!','ok','information')
        .clickMessageBoxButton('ok')
        .waitUntilLoaded('')
        .clickButton('Ship')
        .waitUntilLoaded('')
        .addResult('Clicked Ship Button',3000)
        .waitUntilLoaded('')
        .verifyMessageBox('iRely i21','WARNING: Customer may exceed credit limit!','ok','information')
        .clickMessageBoxButton('ok')
        .waitUntilLoaded('')
        .addResult('Open Inventory Shipment Screen',3000)
        .waitUntilLoaded('')
        .waitUntilLoaded('')

        .selectComboBoxRowValue('Currency', 'USD', 'Currency',1)
        .verifyData('Combo Box','OrderType','Sales Order')
        .verifyData('Combo Box','Customer','ABC Trucking')
        .verifyData('Combo Box','FreightTerms','Truck')
        .selectGridComboBoxRowValue('InventoryShipment',1,'strSubLocationName','Raw Station','strSubLocationName')
        .selectGridComboBoxRowValue('InventoryShipment',1,'strStorageLocationName','RM Storage','strStorageLocationName')
        .verifyGridData('InventoryShipment', 1, 'colItemNumber', 'ISNLTI - 01')
        .verifyGridData('InventoryShipment', 1, 'colUnitPrice', '14')
        .verifyGridData('InventoryShipment', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryShipment', 1, 'colLineTotal', '1400')

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
        .displayText('===== Ship Button SO to IS for Non Lotted Done=====')
        //endregion


        //region Scenario 4. Create Sales Order Inventory Shipment for Lotted Item Ship Button
        .displayText('=====  Scenario 4. Ship Button SO to IS for Lotted =====')
        .clickButton('New')
        .waitUntilLoaded('')
        .selectComboBoxRowValue('Customer', 'ABC Trucking', 'Customer',1)
        .enterData('Text Field','BOLNo','Test BOL - 01')
        .selectComboBoxRowValue('FreightTerm', 'Truck', 'FreightTerm',1)
        .selectGridComboBoxRowValue('SalesOrder',1,'strItemNo','ISLTI - 01','strItemNo')
        .addResult('Item Selected',1500)
        .enterGridData('SalesOrder', 1, 'colOrdered', '100')
        .verifyGridData('SalesOrder', 1, 'colPrice', '14')
        //.verifyGridData('SalesOrder', 1, 'colTotal', '1400')
        .clickButton('Save')
        .waitUntilLoaded('')
        .verifyMessageBox('iRely i21','WARNING: Customer may exceed credit limit!','ok','information')
        .clickMessageBoxButton('ok')
        .waitUntilLoaded('')
        .clickButton('Ship')
        .addResult('Clicked Ship Button',3000)
        .waitUntilLoaded('')
        .verifyMessageBox('iRely i21','WARNING: Customer may exceed credit limit!','ok','information')
        .clickMessageBoxButton('ok')
        .waitUntilLoaded('')
        .addResult('Open Inventory Shipment Screen',3000)
        .waitUntilLoaded('')
        .waitUntilLoaded('')

        .verifyData('Combo Box','OrderType','Sales Order')
        .verifyData('Combo Box','Customer','ABC Trucking')
        .verifyData('Combo Box','FreightTerms','Truck')
        .selectComboBoxRowValue('Currency', 'USD', 'Currency',1)
        .verifyGridData('InventoryShipment', 1, 'colItemNumber', 'ISLTI - 01')
        .verifyGridData('InventoryShipment', 1, 'colUnitPrice', '14')
        .verifyGridData('InventoryShipment', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryShipment', 1, 'colLineTotal', '1400')
        .selectGridComboBoxRowValue('InventoryShipment',1,'strSubLocationName','Raw Station','strSubLocationName')
        .selectGridComboBoxRowValue('InventoryShipment',1,'strStorageLocationName','RM Storage','strStorageLocationName')

        .selectGridComboBoxRowValue('LotTracking',1,'strLotId','LOT-01','strLotId')
        .enterGridData('LotTracking', 1, 'colShipQty', '100')
        .verifyGridData('LotTracking', 1, 'colLotUOM', 'LB')
        .verifyGridData('LotTracking', 1, 'colGrossWeight', '100')
        .verifyGridData('LotTracking', 1, 'colTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colNetWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM', 'LB')


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
        .clickMenuFolder('Sales (Accounts Receivable)','Folder')
        .displayText('===== Ship Button SO to IS for Lotted Done=====')
        //endregion

        //region Scenario 5. Create Sales Order Inventory Shipment for Non Lotted Item Add Orders Screen
        .displayText('=====  Scenario 5. Add Orders Screen SO to IS for Non Lotted =====')
        .clickMenuFolder('Sales (Accounts Receivable)','Folder')
        .clickMenuScreen('Sales Orders','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('arsalesorder')
        .selectComboBoxRowValue('Customer', 'ABC Trucking', 'Customer',1)
        .enterData('Text Field','BOLNo','Test BOL - 01')
        .selectComboBoxRowValue('FreightTerm', 'Truck', 'FreightTerm',1)
        .selectGridComboBoxRowValue('SalesOrder',1,'strItemNo','ISNLTI - 01','strItemNo')
        .addResult('Item Selected',1500)
        .enterGridData('SalesOrder', 1, 'colOrdered', '100')
        .verifyGridData('SalesOrder', 1, 'colPrice', '14')
       // .verifyGridData('SalesOrder', 1, 'colTotal', '1400')
        .clickButton('Save')
        .waitUntilLoaded('')
        .verifyMessageBox('iRely i21','WARNING: Customer may exceed credit limit!','ok','information')
        .clickMessageBoxButton('ok')
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Sales (Accounts Receivable)','Folder')

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
        .selectComboBoxRowValue('Currency', 'USD', 'Currency',1)
        .selectComboBoxRowValue('ShipFromAddress', '0001 - Fort Wayne', 'ShipFromAddress',1)
        .selectComboBoxRowNumber('ShipToAddress',1,0)

        .verifyGridData('InventoryShipment', 1, 'colItemNumber', 'ISNLTI - 01')
        .verifyGridData('InventoryShipment', 1, 'colUnitPrice', '14')
        .verifyGridData('InventoryShipment', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryShipment', 1, 'colLineTotal', '1400')
        .selectGridComboBoxRowValue('InventoryShipment',1,'strSubLocationName','Raw Station','strSubLocationName')
        .selectGridComboBoxRowValue('InventoryShipment',1,'strStorageLocationName','RM Storage','strStorageLocationName')


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
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Ship Button SO to IS for Non Lotted Done=====')
        //endregion

        //region Scenario 6. Create Sales Order Inventory Shipment for Lotted Item Add Orders Screen
        .displayText('=====  Scenario 6. Add Orders Screen SO to IS for Lotted =====')
        .clickMenuFolder('Sales (Accounts Receivable)','Folder')
        .clickMenuScreen('Sales Orders','Screen')
        .clickMenuScreen('Sales Orders','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('')
        .selectComboBoxRowValue('Customer', 'ABC Trucking', 'Customer',1)
        .enterData('Text Field','BOLNo','Test BOL - 01')
        .selectComboBoxRowValue('FreightTerm', 'Truck', 'FreightTerm',1)
        .selectGridComboBoxRowValue('SalesOrder',1,'strItemNo','ISLTI - 01','strItemNo')
        .addResult('Item Selected',1500)
        .enterGridData('SalesOrder', 1, 'colOrdered', '100')
        .verifyGridData('SalesOrder', 1, 'colPrice', '14')
        //.verifyGridData('SalesOrder', 1, 'colTotal', '1400')
        .clickButton('Save')
        .waitUntilLoaded('')
        .verifyMessageBox('iRely i21','WARNING: Customer may exceed credit limit!','ok','information')
        .clickMessageBoxButton('ok')
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Sales (Accounts Receivable)','Folder')

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
        .selectComboBoxRowValue('Currency', 'USD', 'Currency',1)
        .selectComboBoxRowValue('ShipFromAddress', '0001 - Fort Wayne', 'ShipFromAddress',1)
        .selectComboBoxRowNumber('ShipToAddress',1,0)

        .verifyGridData('InventoryShipment', 1, 'colItemNumber', 'ISLTI - 01')
        .verifyGridData('InventoryShipment', 1, 'colUnitPrice', '14')
        .verifyGridData('InventoryShipment', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryShipment', 1, 'colLineTotal', '1400')
        .selectGridComboBoxRowValue('InventoryShipment',1,'strSubLocationName','Raw Station','strSubLocationName')
        .selectGridComboBoxRowValue('InventoryShipment',1,'strStorageLocationName','RM Storage','strStorageLocationName')

        .selectGridComboBoxRowValue('LotTracking',1,'strLotId','LOT-01','strLotId')
        .enterGridData('LotTracking', 1, 'colShipQty', '100')
        .verifyGridData('LotTracking', 1, 'colLotUOM', 'LB')
        .verifyGridData('LotTracking', 1, 'colGrossWeight', '100')
        .verifyGridData('LotTracking', 1, 'colTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colNetWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM', 'LB')

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
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Ship Button SO to IS for Lotted Done=====')
        //endregion

        .done();

})
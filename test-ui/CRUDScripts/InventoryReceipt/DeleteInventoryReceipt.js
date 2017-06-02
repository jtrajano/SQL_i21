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
            .filterGridRecords('Search', 'FilterGrid', 'IR - Category')
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
                            commonIC.addCategory (t,next, 'IR - Category', 'Test Category', 2)
                        })
                        .clickMenuFolder('Inventory','Folder')
                        .waitUntilLoaded('')
                        .done();
                },
                continueOnFail: true
            })


            /*====================================== Add Commodity ======================================*/

            .clickMenuScreen('Commodities','Screen')
            .filterGridRecords('Search', 'FilterGrid', 'IR - Commodity')
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
                            commonIC.addCommodity (t,next, 'IR - Commodity', 'Test Commodity')
                        })
                        .clickMenuFolder('Inventory','Folder')
                        .waitUntilLoaded('')
                        .done();
                },
                continueOnFail: true
            })


            /*====================================== Add Lotted Item ======================================*/
            .clickMenuScreen('Items','Screen')
            .filterGridRecords('Search', 'FilterGrid', 'DIR - LTI - 02')
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
                                'DIR - LTI - 02'
                                , 'Test Lotted Item'
                                , 'IR - Category'
                                , 'IR - Commodity'
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
            .filterGridRecords('Search', 'FilterGrid', 'DIR - NLTI - 02')
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
                                'DIR - NLTI - 02'
                                , 'Test Non Lotted Item'
                                , 'IR - Category'
                                , 'IR - Commodity'
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
        
        

        //region Scenario 1. Create Direct Inventory Receipt for Non Lotted Item then Delete IR
        .displayText('=====  Scenario 1. Create Direct Inventory Receipt for Non Lotted Item then Delete IR =====')
        .displayText('=====  Creating Direct Inventory Receipt=====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .selectComboBoxRowNumber('Location', 1,0)
        //.selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','DIR - NLTI - 02','strItemNo')
        .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure', 100, 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '100')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '100')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')


        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .clickTab('Details')
        .waitUntilLoaded('')
        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('=====  Creating Direct Inventory Receipt for DNLTI - 02 Done=====')

        //Check On Hand Stock of the Item
        .displayText('=====  Checking ON Hand Stock of the item =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DIR - NLTI - 02', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        //.verifyGridData('Stock', 1, 'colStockUOM', 'LB')
        .verifyGridData('Stock', 1, 'colStockOnHand', '100')
        .displayText('=====  On Hand Stock is Correct! =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()


        //Delete IR
        .displayText('===== Delete Non Lotted Inventory Receipt  =====')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
//        .doubleClickSearchRowValue('Direct', 'strOrderType', 1)
        .waitUntilLoaded()
        .waitUntilLoaded('')
        .addResult('Successfully Opened',4000)
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'DIR - NLTI - 02')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .clickButton('Unpost')
        .waitUntilLoaded('')
        .addResult('Successfully Unposted',2000)
        .waitUntilLoaded('')
        .clickButton('Delete')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()
        .displayText('===== Non Lotted Item Successfully Deleted=====')
        .clearTextFilter('FilterGrid')

        //Check ON hand stock of the item
        .displayText('=====  Checking ON Hand Stock of the item =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DIR - NLTI - 02', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        //.verifyGridData('Stock', 1, 'colStockUOM', 'LB')
        .verifyGridData('Stock', 1, 'colStockOnHand', '0')
        .displayText('=====  On Hand Stock is Correct! =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        //endregion


        //region Scenario 2. Create Direct Inventory Receipt for Lotted Item then Delete IR
        .displayText('=====  Scenario Scenario 2. Create Direct Inventory Receipt for Lotted Item then Delete IR =====')
        .displayText('=====  Creating Direct Inventory Receipt  =====')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .selectComboBoxRowNumber('Location', 1,0)
//        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','DIR - LTI - 02','strItemNo')
        .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure', 100000, 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000000')
        .verifyGridData('InventoryReceipt', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryReceipt', 1, 'colStorageLocation', 'RM Storage')

        .enterGridData('LotTracking', 1, 'colLotId', 'LOT-01')
        .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure','LB','strUnitMeasure')
        .enterGridData('LotTracking', 1, 'colLotQuantity', '100000')
        .verifyGridData('LotTracking', 1, 'colLotGrossWeight', '100000')
        .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colLotNetWeight', '100000')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM', 'LB')
        .verifyGridData('LotTracking', 1, 'colLotStorageLocation', 'RM Storage')


        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .clickTab('Details')
        .waitUntilLoaded('')
        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colDebit', '1000000')
        .verifyGridData('RecapTransaction', 2, 'colAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colCredit', '1000000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Direct Inventory Receipt for Lotted Item=====')

        //Check On Hand Stock of the Item
        .displayText('=====  Checking ON Hand Stock of the item =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DIR - LTI - 02', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        //.verifyGridData('Stock', 1, 'colStockUOM', 'LB')
        .verifyGridData('Stock', 1, 'colStockOnHand', '100000')
        .displayText('=====  On Hand Stock is Correct! =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()


        //Delete IR
        .displayText('===== Delete Non Lotted Inventory Receipt  =====')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
//        .doubleClickSearchRowValue('Direct', 'strOrderType', 1)
        .waitUntilLoaded()
        .waitUntilLoaded('icinventoryreceipt')
        .addResult('Successfully Opened',4000)
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'DIR - LTI - 02')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000000')
        .clickButton('Unpost')
        .waitUntilLoaded('icinventoryreceipt')
        .addResult('Successfully Unposted',2000)
        .clickButton('Delete')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()
        .displayText('===== Non Lotted Item Successfully Deleted=====')
        .clearTextFilter('FilterGrid')

        //Check ON hand stock of the item
        .displayText('=====  Checking ON Hand Stock of the item =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DIR - LTI - 02', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        //.verifyGridData('Stock', 1, 'colStockUOM', 'LB')
        .verifyGridData('Stock', 1, 'colStockOnHand', '0')
        .displayText('=====  On Hand Stock is Correct! =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .clickMenuFolder('Inventory','Folder')
        //endregion


        //region Scenario 3. Create Purchase Order Inventory Receipt for Non Lotted Item "Add Orders Button" then Delete the IR.
        .displayText('=====  Scenario 3. Create Purchase Order Inventory Receipt for Non Lotted Item "Add Orders Button" then Delete the IR. =====')

        .clickMenuFolder('Purchasing (Accounts Payable)','Folder')
        .clickMenuScreen('Purchase Orders','Screen')
        .clickButton('New')
        .waitUntilLoaded('appurchaseorder')
        .selectComboBoxRowValue('VendorId', 'ABC Trucking', 'VendorId',1)
        .waitUntilLoaded('')
        .selectGridComboBoxRowValue('Items',1,'strItemNo','DIR - NLTI - 02','strItemNo')
        .selectGridComboBoxRowValue('Items',1,'strUOM','LB','strUOM')
        .enterGridData('Items', 1, 'colQtyOrdered', '100')
        .verifyGridData('Items', 1, 'colTotal', '1000')
        .clickButton('Save')
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Purchasing (Accounts Payable)','Folder')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Receipts','Screen')
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',2,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .waitUntilLoaded('')
        .selectSearchRowNumber(1)
        .clickButton('OpenSelected')
        .waitUntilLoaded('icinventoryreceipt')
        .waitUntilLoaded('')
        .verifyData('Combo Box','ReceiptType','Purchase Order')
        .verifyData('Combo Box','Vendor','ABC Trucking')
        .verifyData('Combo Box','Currency','USD')
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'DIR - NLTI - 02')
        .verifyGridData('InventoryReceipt', 1, 'colOrderUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colQtyOrdered', '100')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryReceipt', 1, 'colStorageLocation', 'RM Storage')

        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .clickTab('Details')
        .waitUntilLoaded('')
        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Purchase Order Inventory Receipt for Non Lotted Item "Process Button" Done=====')

        //Check On Hand Stock of the Item
        .displayText('=====  Checking ON Hand Stock of the item =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DIR - NLTI - 02', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        //.verifyGridData('Stock', 1, 'colStockUOM', 'LB')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '100')
        .displayText('=====  On Hand Stock is Correct! =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()


        //Delete IR
        .displayText('===== Delete Non Lotted Inventory Receipt  =====')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
//        .doubleClickSearchRowValue('Purchase Order', 'strOrderType', 1)
        .waitUntilLoaded()
        .waitUntilLoaded('icinventoryreceipt')
        .addResult('Successfully Opened',4000)
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'DIR - NLTI - 02')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .clickButton('Unpost')
        .waitUntilLoaded('')
        .addResult('Successfully Unposted',2000)
        .clickButton('Delete')
        .waitUntilLoaded()
        .addResult('',2000)
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()
        .displayText('===== Non Lotted Item Successfully Deleted=====')
        .clearTextFilter('FilterGrid')

        //Check ON hand stock of the item
        .displayText('=====  Checking ON Hand Stock of the item =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DIR - NLTI - 02', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        //.verifyGridData('Stock', 1, 'colStockUOM', 'LB')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '100')
        .verifyGridData('Stock', 1, 'colStockOnHand', '0')
        .displayText('=====  On Hand Stock is Correct! =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .clickMenuFolder('Inventory','Folder')
        .displayText('=====  Create Purchase Order Inventory Receipt for Non Lotted Item "Add Orders Button" then Delete the IR. Done =====')
        //endregion


        //region Scenario 5. Create Purchase Contract Inventory Receipt for Non Lotted Item "Process Button" then Delete the IR
        .displayText('=====  Scenario 5. Create Purchase Contract Inventory Receipt for Non Lotted Item "Process Button" then Delete the IR  =====')
        .clickMenuFolder('Contract Management','Folder')
        .clickMenuScreen('Contracts','Screen')
        .clickButton('New')
        .waitUntilLoaded('ctcontract')
        .selectComboBoxRowValue('Type', 'Purchase', 'Type',1)
        .selectComboBoxRowValue('Customer', 'ABC Trucking', 'Customer',1)
        .selectComboBoxRowValue('Commodity', 'IR - Commodity', 'Commodity',1)
        .enterData('Text Field','Quantity','100')
        .selectComboBoxRowValue('CommodityUOM', 'LB', 'CommodityUOM',1)
        .selectComboBoxRowValue('Position', 'Arrival', 'Position',1)
        .selectComboBoxRowValue('PricingType', 'Cash', 'PricingType',1)
        .selectComboBoxRowValue('Salesperson', 'Bob Smith', 'Salesperson',1)
        .clickButton('AddDetail')
        .waitUntilLoaded('ctcontractsequence')
        .addFunction (function (next){
        var date = new Date().toLocaleDateString();
        new iRely.FunctionalTest().start(t, next)
            .enterData('Date Field','EndDate', date, 0, 10)
            .done();
        })
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',1)
        .selectComboBoxRowValue('Item', 'DIR - NLTI - 02', 'Item',1)
        .selectComboBoxRowValue('PriceCurrency', 'USD', 'NetWeightUOM',1)
        .selectComboBoxRowValue('NetWeightUOM', 'LB', 'NetWeightUOM',1)
        .verifyData('Combo Box','PricingType','Cash')
        .verifyData('Combo Box','PriceCurrency','USD')
        .verifyData('Combo Box','CashPriceUOM','LB')
        .enterData('Text Field','CashPrice','10')
        .clickButton('Save')
        .waitUntilLoaded('ctcontract')
        .waitUntilLoaded('')
        .clickButton('Save')
        .waitUntilLoaded('')
        .clickButton('Process')
        .clickButton('IR')
        .waitUntilLoaded('')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .addResult('Successfully Processed',2000)
        .waitUntilLoaded('')
        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .clickTab('Details')
        .waitUntilLoaded('')

        .verifyData('Combo Box','ReceiptType','Purchase Contract')
        .verifyData('Combo Box','Vendor','ABC Trucking')
        .verifyData('Combo Box','Currency','USD')
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'DIR - NLTI - 02')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')


        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .clickTab('Details')
        .waitUntilLoaded('')
        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',3000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('ctcontract')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Contract Management','Folder')
        .displayText('===== Create Purchase Contract Inventory Receipt for Non Lotted Item "Process Button" Done =====')

        //Check ON hand stock of the item
        .displayText('=====  Checking ON Hand Stock of the item =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DIR - NLTI - 02', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        //.verifyGridData('Stock', 1, 'colStockUOM', 'LB')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '100')
        .verifyGridData('Stock', 1, 'colStockOnHand', '100')
        .displayText('=====  On Hand Stock is Correct! =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()


        //Delete IR
        .displayText('===== Delete Non Lotted Inventory Receipt  =====')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
         .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
        .waitUntilLoaded()
        .waitUntilLoaded('icinventoryreceipt')
        .addResult('Successfully Opened',4000)
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'DIR - NLTI - 02')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .clickButton('Unpost')
        .waitUntilLoaded('')
        .addResult('Successfully Unposted',2000)
        .clickButton('Delete')
        .waitUntilLoaded()
        .addResult('',2000)
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()
        .displayText('===== Non Lotted Item Successfully Deleted=====')
        .clearTextFilter('FilterGrid')

        //Check ON hand stock of the item
        .displayText('=====  Checking ON Hand Stock of the item =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DIR - NLTI - 02', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        //.verifyGridData('Stock', 1, 'colStockUOM', 'LB')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '100')
        .verifyGridData('Stock', 1, 'colStockOnHand', '0')
        .displayText('=====  On Hand Stock is Correct! =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Create Purchase Contract Inventory Receipt for Non Lotted Item "Process Button" then Delete the IR Done =====')


        //region Scenario 6. Create Purchase Contract Inventory Receipt for Non Lotted Item "Add Orders Button" then Delete the IR
        .displayText('===== 6. Create Purchase Contract Inventory Receipt for Non Lotted Item "Add Orders Button" then Delete the IR =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Receipts','Screen')
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',1,0)
        .selectComboBoxRowNumber('SourceType',1,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .waitUntilLoaded('')
        .addResult('Successfully ',2000)
        .addResult('Successfully ',2000)
        .waitUntilLoaded('')
        .selectSearchRowNumber(1)
        .clickButton('OpenSelected')
        .waitUntilLoaded('')


        .verifyData('Combo Box','ReceiptType','Purchase Contract')
        .verifyData('Combo Box','Vendor','ABC Trucking')
        .verifyData('Combo Box','Currency','USD')
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'DIR - NLTI - 02')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strWeightUOM','LB','strWeightUOM')

        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .clickTab('Details')
        .waitUntilLoaded('')
        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Inventory','Folder')

        //Check ON hand stock of the item
        .displayText('=====  Checking ON Hand Stock of the item =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DIR - NLTI - 02', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        //.verifyGridData('Stock', 1, 'colStockUOM', 'LB')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '100')
        .verifyGridData('Stock', 1, 'colStockOnHand', '100')
        .displayText('=====  On Hand Stock is Correct! =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()


        //Delete IR
        .displayText('===== Delete Non Lotted Inventory Receipt  =====')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
        .waitUntilLoaded()
        .waitUntilLoaded('icinventoryreceipt')
        .addResult('Successfully Opened',4000)
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'DIR - NLTI - 02')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .clickButton('Unpost')
        .waitUntilLoaded('')
        .addResult('Successfully Unposted',2000)
        .clickButton('Delete')
        .waitUntilLoaded()
        .addResult('',2000)
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()
        .displayText('===== Non Lotted Item Successfully Deleted=====')
        .clearTextFilter('FilterGrid')

        //Check ON hand stock of the item
        .displayText('=====  Checking ON Hand Stock of the item =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DIR - NLTI - 02', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        //.verifyGridData('Stock', 1, 'colStockUOM', 'LB')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '100')
        .verifyGridData('Stock', 1, 'colStockOnHand', '0')
        .displayText('=====  On Hand Stock is Correct! =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Create Purchase Contract Inventory Receipt for Non Lotted Item "Add Orders Button" then Delete the IR Done =====')

        .done();

})
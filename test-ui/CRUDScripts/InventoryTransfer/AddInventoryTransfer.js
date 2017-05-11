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
        .filterGridRecords('Search', 'FilterGrid', 'IT - Category - 01')
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
                        commonIC.addCategory (t,next, 'IT - Category - 01', 'Test Category Description', 2)
                    })
                    .clickMenuFolder('Inventory','Folder')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })


        /*====================================== Add Commodity ======================================*/

        .clickMenuScreen('Commodities','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'IT - Commodity - 01')
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
                        commonIC.addCommodity (t,next, 'IT - Commodity - 01', 'Test Commodity Description')
                    })
                    .clickMenuFolder('Inventory','Folder')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })


        /*====================================== Add Lotted Item ======================================*/
        .clickMenuScreen('Items','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'ITLTI - 01')
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
                            'ITLTI - 01'
                            , 'Test Lotted Item Description'
                            , 'IT - Category - 01'
                            , 'IT - Commodity - 01'
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
        .filterGridRecords('Search', 'FilterGrid', 'ITNLTI - 01')
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
                            'ITNLTI - 01'
                            , 'Test Non Lotted Item Description'
                            , 'IT - Category - 01'
                            , 'IT - Commodity - 01'
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


        /*====================================== Add Non Lotted Item ======================================*/
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Items','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'ITNLTI - 03')
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
                    //region Add Non Lotted Item - Negative Inventory Yes
                    .displayText('===== Add Non Lotted Item Negative Inventory Yes =====')
                    .clickMenuScreen('Items','Screen')
                    .waitUntilLoaded()
                    .clickButton('New')
                    .waitUntilLoaded('icitem')
                    .enterData('Text Field','ItemNo','ITNLTI - 03')
                    .enterData('Text Field','Description','001 - CRUD Non Lotted Item')
                    .selectComboBoxRowValue('Category', 'IT - Category - 01', 'Category',0)
                    .selectComboBoxRowValue('Commodity', 'IT - Commodity - 01', 'Commodity',0)
                    .selectComboBoxRowNumber('LotTracking',4,0)
                    .verifyData('Combo Box','Tracking','Item Level')

                    .displayText('===== Setup Item GL Accounts=====')
                    .clickTab('Setup')
                    .clickButton('AddRequiredAccounts')
                    .verifyGridData('GlAccounts', 1, 'colGLAccountCategory', 'AP Clearing')
                    .verifyGridData('GlAccounts', 2, 'colGLAccountCategory', 'Inventory')
                    .verifyGridData('GlAccounts', 3, 'colGLAccountCategory', 'Cost of Goods')
                    .verifyGridData('GlAccounts', 4, 'colGLAccountCategory', 'Sales Account')
                    .verifyGridData('GlAccounts', 5, 'colGLAccountCategory', 'Inventory In-Transit')
                    .verifyGridData('GlAccounts', 6, 'colGLAccountCategory', 'Inventory Adjustment')

                    .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', '21000-0000-000', 'strAccountId')
                    .selectGridComboBoxRowValue('GlAccounts', 2, 'strAccountId', '16000-0000-000', 'strAccountId')
                    .selectGridComboBoxRowValue('GlAccounts', 3, 'strAccountId', '50000-0000-000', 'strAccountId')
                    .selectGridComboBoxRowValue('GlAccounts', 4, 'strAccountId', '40010-0001-006', 'strAccountId')
                    .selectGridComboBoxRowValue('GlAccounts', 5, 'strAccountId', '16050-0000-000', 'strAccountId')
                    .selectGridComboBoxRowValue('GlAccounts', 6, 'strAccountId', '16040-0000-000', 'strAccountId')

                    .displayText('===== Setup Item Location=====')
                    .clickTab('Location')
                    .clickButton('AddLocation')
                    .waitUntilLoaded('')
                    .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',0)
                    .selectComboBoxRowValue('StorageLocation', 'RM Storage', 'StorageLocation',0)
                    .selectComboBoxRowValue('IssueUom', 'LB', 'IssueUom',0)
                    .selectComboBoxRowValue('ReceiveUom', 'LB', 'ReceiveUom',0)
                    .selectComboBoxRowNumber('NegativeInventory',1,0)
                    .clickButton('Save')
                    .clickButton('Close')

                    .clickButton('AddLocation')
                    .waitUntilLoaded('')
                    .selectComboBoxRowValue('Location', '0002 - Indianapolis', 'Location',0)
                    .selectComboBoxRowValue('SubLocation', 'Indy', 'SubLocation',0)
                    .selectComboBoxRowValue('StorageLocation', 'Indy Storage', 'StorageLocation',0)
                    .selectComboBoxRowValue('IssueUom', 'LB', 'IssueUom',0)
                    .selectComboBoxRowValue('ReceiveUom', 'LB', 'ReceiveUom',0)
                    .selectComboBoxRowNumber('NegativeInventory',1,0)
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
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .displayText('===== Add Non Lotted Item - Negative Inventory Yes Done=====')
                    .done();
            },
            continueOnFail: true
        })
        .clickMenuFolder('Inventory','Folder')


        //Adding Stock to Items
        .displayText('===== Adding Stocks to Created items =====')
        .addFunction(function(next){
            commonIC.addDirectIRNonLotted (t,next, 'ABC Trucking', 1, 'ITNLTI - 01','LB', 10000, 10)
        })

        .addFunction(function(next){
            commonIC.addDirectIRLotted (t,next, 'ABC Trucking', 1, 'ITLTI - 01','LB', 10000, 10, 'Raw Station', 'RM Storage', 'LOT-01', 'LB')
        })
        .displayText('===== Adding Stocks to Created Done =====')
        .displayText('===== Pre-setup done =====')


        //region Scenario 1. Create Inventory Transfer for Non Lotted Item Shipment Not Required Location to Location
        .displayText('===== Scenario 1. Create Inventory Transfer for Non Lotted Item Shipment Not Required Location to Location=====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Transfers','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventorytransfer')
        .verifyData('Combo Box','TransferType','Location to Location')
        .verifyData('Combo Box','FromLocation','0001 - Fort Wayne')
        .verifyData('Combo Box','SourceType','None')
        .selectComboBoxRowValue('ToLocation', '0002 - Indianapolis', 'ToLocation',1)
        .enterData('Text Field','Description','Test Transfer')

        .selectGridComboBoxRowValue('InventoryTransfer',1,'strItemNo','ITNLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromSubLocationName','Raw Station','strFromSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromStorageLocationName','RM Storage','strFromStorageLocationName')
        .verifyGridData('InventoryTransfer', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryTransfer', 1, 'colAvailableUOM', 'LB')
        .enterGridData('InventoryTransfer', 1, 'colTransferQty', '100')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToSubLocationName','Indy','strToSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToStorageLocationName','Indy Storage','strToStorageLocationName')

        .clickButton('PostPreview')
        .waitUntilLoaded('')
        .addResult('Successfully Opened',2000)
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


        //region Scenario 2. Create Inventory Transfer for Lotted Item Shipment Not Required Location to Location
        .displayText('===== Scenario 2. Create Inventory Transfer for Lotted Item Shipment Not Required Location to Location=====')
        .clickMenuScreen('Inventory Transfers','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventorytransfer')
        .verifyData('Combo Box','TransferType','Location to Location')
        .verifyData('Combo Box','FromLocation','0001 - Fort Wayne')
        .verifyData('Combo Box','SourceType','None')
        .selectComboBoxRowValue('ToLocation', '0002 - Indianapolis', 'ToLocation',1)
        .enterData('Text Field','Description','Test Transfer')

        .selectGridComboBoxRowValue('InventoryTransfer',1,'strItemNo','ITLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromSubLocationName','Raw Station','strFromSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromStorageLocationName','RM Storage','strFromStorageLocationName')
        .verifyGridData('InventoryTransfer', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryTransfer', 1, 'colAvailableUOM', 'LB')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strLotNumber','LOT-01','strLotNumber')
        .enterGridData('InventoryTransfer', 1, 'colTransferQty', '100')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToSubLocationName','Indy','strToSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToStorageLocationName','Indy Storage','strToStorageLocationName')

        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .addResult('Successfully Opened',2000)
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
        .displayText('===== Create Inventory Transfer for Lotted Item Shipment Not Required Done =====')
        //endregion


        //region Scenario 3. Create Inventory Transfer for Non Lotted Item Shipment Not Required Storage to Storage
        .displayText('===== Scenario 3. Create Inventory Transfer for Non Lotted Item Shipment Not Required Storage to Storage=====')
        .clickMenuScreen('Inventory Transfers','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventorytransfer')
        .selectComboBoxRowValue('TransferType', 'Storage to Storage', 'TransferType',1)
        .verifyData('Combo Box','FromLocation','0001 - Fort Wayne')
        .verifyData('Combo Box','SourceType','None')
        .selectComboBoxRowValue('ToLocation', '0002 - Indianapolis', 'ToLocation',1)
        .enterData('Text Field','Description','Test Transfer')

        .selectGridComboBoxRowValue('InventoryTransfer',1,'strItemNo','ITNLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromSubLocationName','Raw Station','strFromSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromStorageLocationName','RM Storage','strFromStorageLocationName')
        .verifyGridData('InventoryTransfer', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryTransfer', 1, 'colAvailableUOM', 'LB')
        .enterGridData('InventoryTransfer', 1, 'colTransferQty', '100')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToSubLocationName','Indy','strToSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToStorageLocationName','Indy Storage','strToStorageLocationName')

        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .addResult('Successfully Opened',2000)
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


        //region Scenario 4. Create Inventory Transfer for Lotted Item Shipment Not Required Storage to Storage
        .displayText('===== Scenario 4. Create Inventory Transfer for Lotted Item Shipment Not Required Storage to Storage =====')
        .clickMenuScreen('Inventory Transfers','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventorytransfer')
        .selectComboBoxRowValue('TransferType', 'Storage to Storage', 'TransferType',1)
        .verifyData('Combo Box','FromLocation','0001 - Fort Wayne')
        .verifyData('Combo Box','SourceType','None')
        .selectComboBoxRowValue('ToLocation', '0002 - Indianapolis', 'ToLocation',1)
        .enterData('Text Field','Description','Test Transfer')

        .selectGridComboBoxRowValue('InventoryTransfer',1,'strItemNo','ITLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromSubLocationName','Raw Station','strFromSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromStorageLocationName','RM Storage','strFromStorageLocationName')
        .verifyGridData('InventoryTransfer', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryTransfer', 1, 'colAvailableUOM', 'LB')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strLotNumber','LOT-01','strLotNumber')
        .enterGridData('InventoryTransfer', 1, 'colTransferQty', '100')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToSubLocationName','Indy','strToSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToStorageLocationName','Indy Storage','strToStorageLocationName')

        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .addResult('Successfully Opened',2000)
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
        .displayText('===== Create Inventory Transfer for Lotted Item Shipment Not Required Done =====')
        //endregion

        //region Scenario 5. Qty entered is more than the Available qty Negative Inventory field for the item location selected is NO - Non Lotted Item,
        .displayText('===== Scenario 5. Qty entered is more than the Available qty Negative Inventory field for the item location selected is NO Non Lotted Item,=====')
        .clickMenuScreen('Inventory Transfers','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventorytransfer')
        .verifyData('Combo Box','TransferType','Location to Location')
        .verifyData('Combo Box','FromLocation','0001 - Fort Wayne')
        .verifyData('Combo Box','SourceType','None')
        .selectComboBoxRowValue('ToLocation', '0002 - Indianapolis', 'ToLocation',1)
        .enterData('Text Field','Description','Test Transfer')

        .selectGridComboBoxRowValue('InventoryTransfer',1,'strItemNo','ITNLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromSubLocationName','Raw Station','strFromSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromStorageLocationName','RM Storage','strFromStorageLocationName')
        .verifyGridData('InventoryTransfer', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryTransfer', 1, 'colAvailableUOM', 'LB')
        .enterGridData('InventoryTransfer', 1, 'colTransferQty', '100000000')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToSubLocationName','Indy','strToSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToStorageLocationName','Indy Storage','strToStorageLocationName')

        .clickButton('PostPreview')
        .waitUntilLoaded()
//        .verifyMessageBox('iRely i21','Negative stock quantity is not allowed for ITNLTI - 01 on 0001 - Fort Wayne, Raw Station, and RM Storage.','ok','error')
        .clickMessageBoxButton('ok')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== Qty entered is more than the Available qty Negative Inventory field for the item location selected is NO Non Lotted Item Done =====')
        //endregion

        //region Scenario 6. Qty entered is more than the Available qty Negative Inventory field for the item location selected is Yes - Non Lotted Item,
        .displayText('===== Scenario 6. Qty entered is more than the Available qty Negative Inventory field for the item location selected is Yes Non Lotted Item,=====')
        .clickMenuScreen('Inventory Transfers','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventorytransfer')
        .verifyData('Combo Box','TransferType','Location to Location')
        .verifyData('Combo Box','FromLocation','0001 - Fort Wayne')
        .verifyData('Combo Box','SourceType','None')
        .selectComboBoxRowValue('ToLocation', '0002 - Indianapolis', 'ToLocation',1)
        .enterData('Text Field','Description','Test Transfer')

        .selectGridComboBoxRowValue('InventoryTransfer',1,'strItemNo','ITNLTI - 03','strItemNo')
        .verifyGridData('InventoryTransfer', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryTransfer', 1, 'colAvailableUOM', 'LB')
        .enterGridData('InventoryTransfer', 1, 'colTransferQty', '500000')

        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .addResult('Successfully Opened',2000)
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapCredit', '0')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '16000-0002-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapDebit', '0')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1500)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Qty entered is more than the Available qty Negative Inventory field for the item location selected is Yes Non Lotted Item Done =====')
        //endregion




        //region Scenario 7. Create Inventory Transfer for Non Lotted Item Shipment Required Different Location
        .displayText('===== Scenario 7. Create Inventory Transfer for Non Lotted Item Shipment Required Location to Location =====')
        .clickMenuScreen('Inventory Transfers','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventorytransfer')
        .verifyData('Combo Box','TransferType','Location to Location')
        .verifyData('Combo Box','FromLocation','0001 - Fort Wayne')
        .verifyData('Combo Box','SourceType','None')
        .selectComboBoxRowValue('ToLocation', '0002 - Indianapolis', 'ToLocation',1)
        .clickCheckBox('ShipmentRequired', true)
        .enterData('Text Field','Description','Test Transfer')

        .selectGridComboBoxRowValue('InventoryTransfer',1,'strItemNo','ITNLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromSubLocationName','Raw Station','strFromSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromStorageLocationName','RM Storage','strFromStorageLocationName')
        .verifyGridData('InventoryTransfer', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryTransfer', 1, 'colAvailableUOM', 'LB')
        .enterGridData('InventoryTransfer', 1, 'colTransferQty', '100')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToSubLocationName','Indy','strToSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToStorageLocationName','Indy Storage','strToStorageLocationName')

        .clickButton('PostPreview')
        .waitUntilLoaded('')
        .addResult('Successfully Opened',2000)
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

        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',3,0)
        .selectComboBoxRowValue('Transferor', '0001 - Fort Wayne', 'Transferor',0)
        .doubleClickSearchRowValue('ITNLTI - 01', 'strItemNo', 1)
        .waitUntilLoaded('icinventoryreceipt')
        .verifyData('Combo Box','ReceiptType','Transfer Order')
        .verifyData('Combo Box','Transferor','0001 - Fort Wayne')
        .verifyData('Combo Box','Location','0002 - Indianapolis')
        .verifyData('Combo Box','Currency','USD')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colSubLocation', 'Indy')
        .verifyGridData('InventoryReceipt', 1, 'colStorageLocation', 'Indy Storage')


        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .clickTab('Details')
        .waitUntilLoaded('')
        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0002-000')
        .verifyGridData('RecapTransaction', 1, 'colDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colAccountId', '16050-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Inventory Transfer for Non Lotted Item Shipment Required Location to Location Done =====')
        //endregion


        //region Scenario 8. Create Inventory Transfer for Lotted Item Shipment Required Different Location
        .displayText('===== Scenario 8. Create Inventory Transfer for Lotted Item Shipment Required Location to Location =====')
        .clickMenuScreen('Inventory Transfers','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventorytransfer')
        .verifyData('Combo Box','TransferType','Location to Location')
        .verifyData('Combo Box','FromLocation','0001 - Fort Wayne')
        .verifyData('Combo Box','SourceType','None')
        .selectComboBoxRowValue('ToLocation', '0002 - Indianapolis', 'ToLocation',1)
        .clickCheckBox('ShipmentRequired', true)
        .enterData('Text Field','Description','Test Transfer')

        .selectGridComboBoxRowValue('InventoryTransfer',1,'strItemNo','ITLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromSubLocationName','Raw Station','strFromSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromStorageLocationName','RM Storage','strFromStorageLocationName')
        .verifyGridData('InventoryTransfer', 1, 'colOwnershipType', 'Own')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strLotNumber','LOT-01','strLotNumber')
        .verifyGridData('InventoryTransfer', 1, 'colAvailableUOM', 'LB')
        .enterGridData('InventoryTransfer', 1, 'colTransferQty', '100')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToSubLocationName','Indy','strToSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToStorageLocationName','Indy Storage','strToStorageLocationName')

        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .addResult('Successfully Opened',2000)
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

        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',3,0)
        .selectComboBoxRowValue('Transferor', '0001 - Fort Wayne', 'Transferor',0)
        .doubleClickSearchRowValue('ITLTI - 01', 'strItemNo', 1)
        .waitUntilLoaded('icinventoryreceipt')
        .verifyData('Combo Box','ReceiptType','Transfer Order')
        .verifyData('Combo Box','Transferor','0001 - Fort Wayne')
        .verifyData('Combo Box','Location','0002 - Indianapolis')
        .verifyData('Combo Box','Currency','USD')
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'ITLTI - 01')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colSubLocation', 'Indy')
        .verifyGridData('InventoryReceipt', 1, 'colStorageLocation', 'Indy Storage')

        .selectGridRowNumber('InventoryReceipt', [1])

        .waitTillLoaded()
        .enterGridData('LotTracking', 1, 'colLotId', 'LOT-01')
        .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure','LB','strUnitMeasure')
        .enterGridData('LotTracking', 1, 'colLotQuantity', '100')
        .verifyGridData('LotTracking', 1, 'colLotGrossWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colLotNetWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM', 'LB')
        .verifyGridData('LotTracking', 1, 'colLotStorageLocation', 'Indy Storage')


        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .clickTab('Details')
        .waitUntilLoaded('')
        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0002-000')
        .verifyGridData('RecapTransaction', 1, 'colDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colAccountId', '16050-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Inventory Transfer for Non Lotted Item Shipment Required Location to Location Done =====')
        //endregion


        //region Scenario 9. Update Inventory Transfer
        .displayText('===== Scenario 9. Update Inventory Transfer =====')
        .clickMenuScreen('Inventory Transfers','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('Storage to Storage', 'strTransferType', 1)
        .waitUntilLoaded('')
        .addResult('Successfully Opened',2000)
        .clickButton('Unpost')
        .waitUntilLoaded('')
        .enterData('Text Field','Description','Test Transfer Updated')
        .selectGridRowNumber('InventoryTransfer', [1])
        .clickButton('RemoveItem')
        .waitUntilLoaded()
        //.verifyMessageBox('iRely i21','You are about to delete 1 row.  Are you sure you want to continue?','yesno','question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')

        .selectGridComboBoxRowValue('InventoryTransfer',1,'strItemNo','ITNLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromSubLocationName','Raw Station','strFromSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromStorageLocationName','RM Storage','strFromStorageLocationName')
        .verifyGridData('InventoryTransfer', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryTransfer', 1, 'colAvailableUOM', 'LB')
        .enterGridData('InventoryTransfer', 1, 'colTransferQty', '100')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToSubLocationName','Indy','strToSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToStorageLocationName','Indy Storage','strToStorageLocationName')

        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .addResult('Successfully Opened',2000)
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
        .doubleClickSearchRowValue('Storage to Storage', 'strTransferType', 1)
        .waitUntilLoaded('icinventorytransfer')
        .verifyData('Combo Box','FromLocation','0001 - Fort Wayne')
        .verifyData('Combo Box','ToLocation ','0002 - Indianapolis')
        .verifyData('Text Field','Description','Test Transfer Updated')
        .verifyGridData('InventoryTransfer', 1, 'colItemNumber', 'ITNLTI - 01')
        .verifyGridData('InventoryTransfer', 1, 'colFromSubLocation', 'Raw Station')
        .verifyGridData('InventoryTransfer', 1, 'colFromStorage', 'RM Storage')
        .verifyGridData('InventoryTransfer', 1, 'colAvailableUOM', 'LB')
        .verifyGridData('InventoryTransfer', 1, 'colTransferQty', '100')
        .verifyGridData('InventoryTransfer', 1, 'colToSubLocation', 'Indy')
        .verifyGridData('InventoryTransfer', 1, 'colToStorage', 'Indy Storage')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Update Inventory Transfer Done =====')
        //endregion



        .done();

})
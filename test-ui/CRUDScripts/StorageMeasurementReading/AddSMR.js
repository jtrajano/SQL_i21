StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)

        //region Scenario 1. Add new Storage Measurement Reading with 1 item only.

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
        .filterGridRecords('Search', 'FilterGrid', 'SMR - Category - 01')
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
                        commonIC.addCategory (t,next, 'SMR - Category - 01', 'Test Category Description', 2)
                    })
                    .clickMenuFolder('Inventory','Folder')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })


        /*====================================== Add Commodity ======================================*/

        .clickMenuScreen('Commodities','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'SMR - Commodity - 01')
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
                        commonIC.addCommodity (t,next, 'SMR - Commodity - 01', 'Test Commodity Description')
                    })
                    .clickMenuFolder('Inventory','Folder')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })


        /*====================================== Add Lotted Item ======================================*/
        .clickMenuScreen('Items','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'SMRLTI - 01')
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
                            'SMRLTI - 01'
                            , 'Test Lotted Item Description'
                            , 'SMR - Category - 01'
                            , 'SMR - Commodity - 01'
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

        .clickMenuScreen('Items','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'SMRLTI - 02')
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
                            'SMRLTI - 02'
                            , 'Test Lotted Item Description'
                            , 'SMR - Category - 01'
                            , 'SMR - Commodity - 01'
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


        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Pre-setup done =====')
        //endregion


        //Adding Stock to Items
        .displayText('===== Adding Stocks to Created items =====')

        .addFunction(function(next){
            commonIC.addDirectIRLotted (t,next, 'ABC Trucking', 1, 'SMRLTI - 01','LB', 1000, 10, 'Raw Station', 'RM Storage', 'LOT-01', 'LB')
        })
        .addFunction(function(next){
            commonIC.addDirectIRLotted (t,next, 'ABC Trucking', 1, 'SMRLTI - 02','LB', 1000, 10, 'Raw Station', 'RM Storage', 'LOT-01', 'LB')
        })
        
        .displayText('===== Adding Stocks to Created Done =====')
        .displayText('===== Pre-setup done =====')



        .displayText('===== Scenario 1. Add new Storage Measurement Reading with 1 item only. ====')
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
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                    .clickMessageBoxButton('no')
                    .waitUntilLoaded()
                    .clickButton('New')
                    .waitUntilLoaded()
                    .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',1)
                    .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strCommodity', 'SMR - Commodity - 01','strCommodity')
                    .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strItemNo','SMRLTI - 01','strItemNo')
                    .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strStorageLocationName','RM Storage','strStorageLocationName')
                    .waitUntilLoaded()
                    .verifyGridData('StorageMeasurementReading', 1, 'colSubLocation', 'Raw Station')
                    .enterGridData('StorageMeasurementReading', 1, 'dblAirSpaceReading', '20')
                    .enterGridData('StorageMeasurementReading', 1, 'dblCashPrice', '14')
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .displayText('===== Add new Storage Measurement Reading with 1 item only Done. ====')
                    .done();
            },
            continueOnFail: true
        })
        .clickButton('New')
        .waitUntilLoaded()
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',1)
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strCommodity', 'SMR - Commodity - 01','strCommodity')
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strItemNo','SMRLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strStorageLocationName','RM Storage','strStorageLocationName')
        .waitUntilLoaded()
        .verifyGridData('StorageMeasurementReading', 1, 'colSubLocation', 'Raw Station')
        .enterGridData('StorageMeasurementReading', 1, 'dblAirSpaceReading', '20')
        .enterGridData('StorageMeasurementReading', 1, 'dblCashPrice', '14')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== Add new Storage Measurement Reading with 1 item only Done. ====')


        //region Scenario 2. Add new Storage Measurement Reading with multiple items.
        .displayText('===== Scenario 2. Add new Storage Measurement Reading with multiple items. ====')
        .clickMenuScreen('Storage Measurement Reading','Screen')
        .clickButton('New')
        .waitUntilLoaded()
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',1)
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strCommodity', 'SMR - Commodity - 01','strCommodity')
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strItemNo','SMRLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strStorageLocationName','RM Storage','strStorageLocationName')
        .waitUntilLoaded()
        .verifyGridData('StorageMeasurementReading', 1, 'colSubLocation', 'Raw Station')
        .enterGridData('StorageMeasurementReading', 1, 'dblAirSpaceReading', '20')
        .enterGridData('StorageMeasurementReading', 1, 'dblCashPrice', '14')

        .selectGridComboBoxRowValue('StorageMeasurementReading',2,'strCommodity', 'SMR - Commodity - 01','strCommodity')
        .selectGridComboBoxRowValue('StorageMeasurementReading',2,'strItemNo','SMRLTI - 02','strItemNo')
        .selectGridComboBoxRowValue('StorageMeasurementReading',2,'strStorageLocationName','RM Storage','strStorageLocationName')
        .waitUntilLoaded()
        .verifyGridData('StorageMeasurementReading', 2, 'colSubLocation', 'Raw Station')
        .enterGridData('StorageMeasurementReading', 2, 'dblAirSpaceReading', '30')
        .enterGridData('StorageMeasurementReading', 2, 'dblCashPrice', '14')

        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== Add new Storage Measurement Reading with multiple items. ====')


        //region Scenario 3. Add another record, click Close, Cancel, No.
        .displayText('===== Scenario 3. Add another record, click Close, Cancel, No. ====')
        .clickMenuScreen('Storage Measurement Reading','Screen')
        .clickButton('New')
        .waitUntilLoaded()
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',1)
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strCommodity', 'SMR - Commodity - 01','strCommodity')
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strItemNo','SMRLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strStorageLocationName','RM Storage','strStorageLocationName')
        .waitUntilLoaded()
        .verifyGridData('StorageMeasurementReading', 1, 'colSubLocation', 'Raw Station')
        .enterGridData('StorageMeasurementReading', 1, 'dblAirSpaceReading', '20')
        .enterGridData('StorageMeasurementReading', 1, 'dblCashPrice', '14')
        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('cancel')

        .verifyGridData('StorageMeasurementReading', 1, 'colCommodity', 'SMR - Commodity - 01')
        .verifyGridData('StorageMeasurementReading', 1, 'colItem', 'SMRLTI - 01')
        .verifyGridData('StorageMeasurementReading', 1, 'colStorageLocation', 'RM Storage')
        .verifyGridData('StorageMeasurementReading', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('StorageMeasurementReading', 1, 'colAirSpaceReading', '20')

        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .displayText('===== 3. Add another record, click Close, Cancel, No. Done. ====')

        //region Scenario 4. Add duplicate Items in the grid.
        .displayText('===== Scenario 4. Add new Storage Measurement Reading with multiple items. ====')
        .clickMenuScreen('Storage Measurement Reading','Screen')
        .clickButton('New')
        .waitUntilLoaded()
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',1)

        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strCommodity','SMR - Commodity - 01','strCommodity')
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strItemNo','SMRLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strStorageLocationName','RM Storage','strStorageLocationName')
        .waitUntilLoaded()
        .verifyGridData('StorageMeasurementReading', 1, 'colSubLocation', 'Raw Station')
        .enterGridData('StorageMeasurementReading', 1, 'dblAirSpaceReading', '20')
        .enterGridData('StorageMeasurementReading', 1, 'dblCashPrice', '14')

        .selectGridComboBoxRowValue('StorageMeasurementReading',2,'strCommodity','SMR - Commodity - 01','strCommodity')
        .selectGridComboBoxRowValue('StorageMeasurementReading',2,'strItemNo','SMRLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('StorageMeasurementReading',2,'strStorageLocationName','RM Storage','strStorageLocationName')
        .waitUntilLoaded()
        .verifyGridData('StorageMeasurementReading', 2, 'colSubLocation', 'Raw Station')
        .enterGridData('StorageMeasurementReading', 2, 'dblAirSpaceReading', '20')
        .enterGridData('StorageMeasurementReading', 2, 'dblCashPrice', '14')

        .clickButton('Save')
        .verifyMessageBox('iRely i21','Storage Reading Measurement Conversions must be unique.','ok','error')
        .clickMessageBoxButton('ok')
        .clickButton('Close')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .displayText('===== Add new Storage Measurement Reading with multiple items. ====')

        //region Scenario 5. Update Storage Measurement Reading
        .displayText('===== Scenario 5. Update Storage Measurement Reading ====')
        .clickMenuScreen('Storage Measurement Reading','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded()
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',1)
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strCommodity','SMR - Commodity - 01','strCommodity')
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strItemNo','SMRLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strStorageLocationName','RM Storage','strStorageLocationName')
        .waitUntilLoaded()
        .verifyGridData('StorageMeasurementReading', 1, 'colSubLocation', 'Raw Station')
        .enterGridData('StorageMeasurementReading', 1, 'dblAirSpaceReading', '80')
        .enterGridData('StorageMeasurementReading', 1, 'dblCashPrice', '14')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()

        .clickMenuScreen('Storage Measurement Reading','Screen')
        .doubleClickSearchRowValue('0001 - Fort Wayne', 'strLocation', 1)
        .waitUntilLoaded('')
        .verifyGridData('StorageMeasurementReading', 1, 'colCommodity', 'SMR - Commodity - 01')
        .verifyGridData('StorageMeasurementReading', 1, 'colItem', 'SMRLTI - 01')
        .verifyGridData('StorageMeasurementReading', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('StorageMeasurementReading', 1, 'colStorageLocation', 'RM Storage')
        .enterGridData('StorageMeasurementReading', 1, 'dblCashPrice', '14')

        .selectGridComboBoxRowValue('StorageMeasurementReading',2,'strCommodity','SMR - Commodity - 01','strCommodity')
        .selectGridComboBoxRowValue('StorageMeasurementReading',2,'strItemNo','SMRLTI - 02','strItemNo')
        .selectGridComboBoxRowValue('StorageMeasurementReading',2,'strStorageLocationName','RM Storage','strStorageLocationName')
        .waitUntilLoaded()
        .verifyGridData('StorageMeasurementReading', 2, 'colSubLocation', 'Raw Station')
        .enterGridData('StorageMeasurementReading', 2, 'dblAirSpaceReading', '30')
        .enterGridData('StorageMeasurementReading', 2, 'dblCashPrice', '14')

        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('0001 - Fort Wayne', 'strLocation', 2)
        .waitUntilLoaded()
        .verifyGridData('StorageMeasurementReading', 1, 'colCommodity', 'SMR - Commodity - 01')
        .verifyGridData('StorageMeasurementReading', 1, 'colItem', 'SMRLTI - 01')
        .verifyGridData('StorageMeasurementReading', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('StorageMeasurementReading', 1, 'colStorageLocation', 'RM Storage')
        .enterGridData('StorageMeasurementReading', 1, 'dblCashPrice', '14')

        .verifyGridData('StorageMeasurementReading', 2, 'colCommodity', 'SMR - Commodity - 01')
        .verifyGridData('StorageMeasurementReading', 2, 'colItem', 'SMRLTI - 02')
        .verifyGridData('StorageMeasurementReading', 2, 'colSubLocation', 'Raw Station')
        .verifyGridData('StorageMeasurementReading', 2, 'colStorageLocation', 'RM Storage')
        .verifyGridData('StorageMeasurementReading', 2, 'dblAirSpaceReading', '30')
        .enterGridData('StorageMeasurementReading', 2, 'dblCashPrice', '14')
        .displayText('===== 5. Update Storage Measurement Reading ====')
        .clickButton('Close')
        .waitUntilLoaded()

        .done();


})
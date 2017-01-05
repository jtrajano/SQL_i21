StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        //region Scenario 1. Add new Storage Measurement Reading with 1 item only.
        .displayText('===== Scenario 1. Add new Storage Measurement Reading with 1 item only. ====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Storage Measurement Reading','Screen')
        .waitUntilLoaded()
        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded()
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',1)
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strCommodity','Corn','strCommodity')
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strItemNo','001 - CLTI','strItemNo')
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

        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strCommodity','Corn','strCommodity')
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strItemNo','001 - CLTI','strItemNo')
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strStorageLocationName','RM Storage','strStorageLocationName')
        .waitUntilLoaded()
        .verifyGridData('StorageMeasurementReading', 1, 'colSubLocation', 'Raw Station')
        .enterGridData('StorageMeasurementReading', 1, 'dblAirSpaceReading', '20')
        .enterGridData('StorageMeasurementReading', 1, 'dblCashPrice', '14')

        .selectGridComboBoxRowValue('StorageMeasurementReading',2,'strCommodity','Corn','strCommodity')
        .selectGridComboBoxRowValue('StorageMeasurementReading',2,'strItemNo','002 - CLTI','strItemNo')
        .selectGridComboBoxRowValue('StorageMeasurementReading',2,'strStorageLocationName','RM Storage','strStorageLocationName')
        .waitUntilLoaded()
        .verifyGridData('StorageMeasurementReading', 2, 'colSubLocation', 'Raw Station')
        .enterGridData('StorageMeasurementReading', 2, 'dblAirSpaceReading', '30')
        .enterGridData('StorageMeasurementReading', 2, 'dblCashPrice', '14')

        .selectGridComboBoxRowValue('StorageMeasurementReading',3,'strCommodity','Corn','strCommodity')
        .selectGridComboBoxRowValue('StorageMeasurementReading',3,'strItemNo','001 - CNLTI','strItemNo')
        .selectGridComboBoxRowValue('StorageMeasurementReading',3,'strStorageLocationName','RM Storage','strStorageLocationName')
        .waitUntilLoaded()
        .verifyGridData('StorageMeasurementReading', 3, 'colSubLocation', 'Raw Station')
        .enterGridData('StorageMeasurementReading', 3, 'dblAirSpaceReading', '40')
        .enterGridData('StorageMeasurementReading', 3, 'dblCashPrice', '14')

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
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strCommodity','Corn','strCommodity')
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strItemNo','001 - CLTI','strItemNo')
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strStorageLocationName','RM Storage','strStorageLocationName')
        .waitUntilLoaded()
        .verifyGridData('StorageMeasurementReading', 1, 'colSubLocation', 'Raw Station')
        .enterGridData('StorageMeasurementReading', 1, 'dblAirSpaceReading', '100')
        .enterGridData('StorageMeasurementReading', 1, 'dblCashPrice', '14')
        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('cancel')

        .verifyGridData('StorageMeasurementReading', 1, 'colCommodity', 'Corn')
        .verifyGridData('StorageMeasurementReading', 1, 'colItem', '001 - CLTI')
        .verifyGridData('StorageMeasurementReading', 1, 'colStorageLocation', 'RM Storage')
        .verifyGridData('StorageMeasurementReading', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('StorageMeasurementReading', 1, 'colAirSpaceReading', '100')

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

        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strCommodity','Corn','strCommodity')
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strItemNo','001 - CLTI','strItemNo')
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strStorageLocationName','RM Storage','strStorageLocationName')
        .waitUntilLoaded()
        .verifyGridData('StorageMeasurementReading', 1, 'colSubLocation', 'Raw Station')
        .enterGridData('StorageMeasurementReading', 1, 'dblAirSpaceReading', '20')
        .enterGridData('StorageMeasurementReading', 1, 'dblCashPrice', '14')

        .selectGridComboBoxRowValue('StorageMeasurementReading',2,'strCommodity','Corn','strCommodity')
        .selectGridComboBoxRowValue('StorageMeasurementReading',2,'strItemNo','001 - CLTI','strItemNo')
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
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strCommodity','Corn','strCommodity')
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strItemNo','001 - CLTI','strItemNo')
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
        .verifyGridData('StorageMeasurementReading', 1, 'colCommodity', 'Corn')
        .verifyGridData('StorageMeasurementReading', 1, 'colItem', '001 - CLTI')
        .verifyGridData('StorageMeasurementReading', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('StorageMeasurementReading', 1, 'colStorageLocation', 'RM Storage')
        .enterGridData('StorageMeasurementReading', 1, 'dblCashPrice', '14')

        .selectGridComboBoxRowValue('StorageMeasurementReading',2,'strCommodity','Corn','strCommodity')
        .selectGridComboBoxRowValue('StorageMeasurementReading',2,'strItemNo','002 - CLTI','strItemNo')
        .selectGridComboBoxRowValue('StorageMeasurementReading',2,'strStorageLocationName','RM Storage','strStorageLocationName')
        .waitUntilLoaded()
        .verifyGridData('StorageMeasurementReading', 2, 'colSubLocation', 'Raw Station')
        .enterGridData('StorageMeasurementReading', 2, 'dblAirSpaceReading', '30')
        .enterGridData('StorageMeasurementReading', 2, 'dblCashPrice', '14')

        .selectGridComboBoxRowValue('StorageMeasurementReading',3,'strCommodity','Corn','strCommodity')
        .selectGridComboBoxRowValue('StorageMeasurementReading',3,'strItemNo','001 - CNLTI','strItemNo')
        .selectGridComboBoxRowValue('StorageMeasurementReading',3,'strStorageLocationName','RM Storage','strStorageLocationName')
        .waitUntilLoaded()
        .verifyGridData('StorageMeasurementReading', 3, 'colSubLocation', 'Raw Station')
        .enterGridData('StorageMeasurementReading', 3, 'dblAirSpaceReading', '40')
        .enterGridData('StorageMeasurementReading', 3, 'dblCashPrice', '14')

        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('0001 - Fort Wayne', 'strLocation', 2)
        .waitUntilLoaded()
        .verifyGridData('StorageMeasurementReading', 1, 'colCommodity', 'Corn')
        .verifyGridData('StorageMeasurementReading', 1, 'colItem', '001 - CLTI')
        .verifyGridData('StorageMeasurementReading', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('StorageMeasurementReading', 1, 'colStorageLocation', 'RM Storage')
        .enterGridData('StorageMeasurementReading', 1, 'dblCashPrice', '14')

        .verifyGridData('StorageMeasurementReading', 2, 'colCommodity', 'Corn')
        .verifyGridData('StorageMeasurementReading', 2, 'colItem', '002 - CLTI')
        .verifyGridData('StorageMeasurementReading', 2, 'colSubLocation', 'Raw Station')
        .verifyGridData('StorageMeasurementReading', 2, 'colStorageLocation', 'RM Storage')
        .verifyGridData('StorageMeasurementReading', 2, 'dblAirSpaceReading', '30')
        .enterGridData('StorageMeasurementReading', 2, 'dblCashPrice', '14')

        .verifyGridData('StorageMeasurementReading', 3, 'colCommodity', 'Corn')
        .verifyGridData('StorageMeasurementReading', 3, 'colItem', '001 - CNLTI')
        .verifyGridData('StorageMeasurementReading', 3, 'colSubLocation', 'Raw Station')
        .verifyGridData('StorageMeasurementReading', 3, 'colStorageLocation', 'RM Storage')
        .verifyGridData('StorageMeasurementReading', 3, 'dblAirSpaceReading', '40')
        .enterGridData('StorageMeasurementReading', 3, 'dblCashPrice', '14')
        .displayText('===== 5. Update Storage Measurement Reading ====')
        .clickButton('Close')
        .waitUntilLoaded()

        .done();


})
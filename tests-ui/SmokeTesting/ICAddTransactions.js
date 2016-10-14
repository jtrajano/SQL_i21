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

        .displayText('"======== Scenario 1: Create Direct Inventory Receipt for Non Lotted Item. ========"').wait(500)
        .expandMenu('Inventory').wait(1000)
        .markSuccess('Inventory successfully expanded').wait(500)


        //Add Inventory Receipt
        //Scenario 1: Add Direct IR for NON Lotted Item
        .displayText('"======== Scenario 1:  Add Direct IR for NON Lotted Item ========"').wait(500)
        .displayText('"======== #1 Open New Inventory Receipt Screen ========"').wait(500)
        .openScreen('Inventory Receipts').wait(1000)
        .waitTillLoaded('Open Inventory Receipts Search Screen Successful').wait(500)
        .clickButton('#btnNew').wait(1000)
        .waitTillVisible('icinventoryreceipt','').wait(1000)
        .markSuccess('Open New Inventory Receipt Screen Successful')

        .displayText('======== #2. Enter/Select Inventory Receipt Details and Check Fields========')
        .selectComboRowByIndex('#cboReceiptType',3).wait(200)
        .selectComboRowByFilter('#cboVendor', 'ABC Trucking', 500, 'strName', 0).wait(200)
        //.selectComboRowByFilter('#cboVendor','0001005057',500, 'intEntityVendorId').wait(500)
        .selectComboRowByIndex('#cboLocation',0).wait(300)
        .selectGridComboRowByFilter('#grdInventoryReceipt', 0, 'strItemNo', 'NLTI - 01', 300, 'strItemNo').wait(1000)
        .selectGridComboRowByFilter('#grdInventoryReceipt', 0, 'strUnitMeasure', 'Bushels', 300, 'strUnitMeasure').wait(1000)
        .enterGridData('#grdInventoryReceipt', 0, 'colQtyToReceive', '1000').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colItemSubCurrency', 'USD').wait(300)
        .enterGridData('#grdInventoryReceipt', 0, 'colUnitCost', '10').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colCostUOM', 'Bushels').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colWeightUOM', 'Bushels').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colGross', '1000').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colNet', '1000').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colLineTotal', '10000').wait(500)
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                grid = win.down('#grdInventoryReceipt'),
                total = grid.down('#lblGrossWgt').text;
            if (total == 'Gross: 1,000.00') {
                t.ok(true, 'Gross is correct.');
            }
            else {
                t.ok(false, 'Grossl is incorrect.');
            }
            next();
        }).wait(200)
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                grid = win.down('#grdInventoryReceipt'),
                total = grid.down('#lblNetWgt').text;
            if (total == 'Net: 1,000.00') {
                t.ok(true, 'Net is correct.');
            }
            else {
                t.ok(false, 'Net is incorrect.');
            }
            next();
        }).wait(200)
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                grid = win.down('#grdInventoryReceipt'),
                total = grid.down('#lblTotal').text;
            if (total == 'Total: 10,000.00') {
                t.ok(true, 'Total is correct.');
            }
            else {
                t.ok(false, 'Total is incorrect.');
            }
            next();
        }).wait(200)
        .markSuccess('Enter/Select Inventory Recepit Details and Check Fields Successful')

        .displayText('======== #3. Open Recap Screen and Check Account IDs and Totlas ========')
        .clickButton('#btnRecap').wait(300)
        .waitTillLoaded('Open Recap Screen Successful')
        .checkGridData('#grdRecapTransaction', 0, 'colRecapAccountId', '16000-0001-000').wait(500)
        .checkGridData('#grdRecapTransaction', 0, 'colRecapDebit', '10000').wait(500)
        .checkGridData('#grdRecapTransaction', 1, 'colRecapAccountId', '21000-0001-000').wait(500)
        .checkGridData('#grdRecapTransaction', 1, 'colRecapCredit', '10000').wait(500)
        .markSuccess('======== Open Recap Screen and Check Details Successful ========')

        .displayText('======== #4. Post Inventory Receipt ========')
        .clickButton('#btnPost').wait(500)
        .waitTillLoaded('')
        .markSuccess('======== Posting of Inventory Receipt Successful ========')
        .clickButton('#btnClose').wait(200)
        .waitTillLoaded('')
        .markSuccess('======== Create Direct Receipt for Non Lotted Item Successful! ========')



        //Scenario 2: Add Direct IR for Lotted Item
        .displayText('"======== Scenario 2: Create Direct Inventory Receipt for Lotted Item. ========"').wait(500)
        .displayText('"======== #1 Open New Inventory Receipt Screen ========"').wait(500)
        .waitTillLoaded('Open Inventory Receipts Search Screen Successful').wait(500)
        .clickButton('#btnNew').wait(1000)
        .waitTillVisible('icinventoryreceipt','').wait(500)
        .displayText('"======== Open New Inventory Receipt Screen Successful ========"').wait(300)

        .displayText('======== #2. Enter/Select Inventory Recepit Details and Check Fields========')
        .selectComboRowByIndex('#cboReceiptType',3).wait(200)
        .selectComboRowByFilter('#cboVendor', 'ABC Trucking', 500, 'strName', 0).wait(200)
        //.selectComboRowByFilter('#cboVendor','0001005057',500, 'intEntityVendorId').wait(500)
        .selectComboRowByIndex('#cboLocation',0).wait(300)
        .selectGridComboRowByFilter('#grdInventoryReceipt', 0, 'strItemNo', 'LTI - 01', 300, 'strItemNo').wait(1000)
        .selectGridComboRowByFilter('#grdInventoryReceipt', 0, 'strUnitMeasure', 'Bushels', 300, 'strUnitMeasure').wait(1000)
        .enterGridData('#grdInventoryReceipt', 0, 'colQtyToReceive', '1000').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colItemSubCurrency', 'USD').wait(300)
        .enterGridData('#grdInventoryReceipt', 0, 'colUnitCost', '10').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colCostUOM', 'Bushels').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colWeightUOM', 'Bushels').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colGross', '1000').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colNet', '1000').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colLineTotal', '10000').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colSubLocation', 'Raw Station').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colStorageLocation', 'RM Storage').wait(500)

        .enterGridData('#grdLotTracking', 0, 'colLotId', 'LOT-01').wait(500)
        .selectGridComboRowByFilter('#grdLotTracking', 0, 'strUnitMeasure', 'Bushels', 300, 'strUnitMeasure').wait(1000)
        .enterGridData('#grdLotTracking', 0, 'colLotQuantity', '1000').wait(500)
        .checkGridData('#grdLotTracking', 0, 'colLotGrossWeight', '1000').wait(500)
        .checkGridData('#grdLotTracking', 0, 'colLotTareWeight', '0').wait(500)
        .checkGridData('#grdLotTracking', 0, 'colLotNetWeight', '1000').wait(500)
        .checkGridData('#grdLotTracking', 0, 'colLotWeightUOM', 'Bushels').wait(500)
        .checkGridData('#grdLotTracking', 0, 'colLotStorageLocation', 'RM Storage').wait(500)

        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                grid = win.down('#grdInventoryReceipt'),
                total = grid.down('#lblGrossWgt').text;
            if (total == 'Gross: 1,000.00') {
                t.ok(true, 'Gross is correct.');
            }
            else {
                t.ok(false, 'Grossl is incorrect.');
            }
            next();
        }).wait(200)
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                grid = win.down('#grdInventoryReceipt'),
                total = grid.down('#lblNetWgt').text;
            if (total == 'Net: 1,000.00') {
                t.ok(true, 'Net is correct.');
            }
            else {
                t.ok(false, 'Net is incorrect.');
            }
            next();
        }).wait(200)
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                grid = win.down('#grdInventoryReceipt'),
                total = grid.down('#lblTotal').text;
            if (total == 'Total: 10,000.00') {
                t.ok(true, 'Total is correct.');
            }
            else {
                t.ok(false, 'Total is incorrect.');
            }
            next();
        }).wait(200)
        .markSuccess('======== Enter/Select Inventory Recepit Details and Check Fields========')

        .displayText('======== #3. Open Recap Screen and Check Account IDs and Totlas ========')
        .clickButton('#btnRecap').wait(300)
        .waitTillLoaded('Open Recap Screen Successful')
        .checkGridData('#grdRecapTransaction', 0, 'colRecapAccountId', '16000-0001-000').wait(500)
        .checkGridData('#grdRecapTransaction', 0, 'colRecapDebit', '10000').wait(500)
        .checkGridData('#grdRecapTransaction', 1, 'colRecapAccountId', '21000-0001-000').wait(500)
        .checkGridData('#grdRecapTransaction', 1, 'colRecapCredit', '10000').wait(500)
        .markSuccess('======== Open Recap Screen and Check Details Successful========')

        .displayText('======== #4. Post Inventory Receipt ========')
        .clickButton('#btnPost').wait(500)
        .waitTillLoaded('Inventory Post Successful')
        .clickButton('#btnClose').wait(200)
        .waitTillLoaded('')
        .markSuccess('======== Post Inventory Receipt Successful ========')
        .markSuccess('======== Create Direct Receipt for Lotted Item Successful! ========')


        //Add Inventory Shipmnent
        //Scenario 3:  Add Direct IS for NON Lotted Item
        .displayText('"======== Scenario 3:  Add Direct IS for NON Lotted Item ========"').wait(500)
        .displayText('"======== #1 Open New Inventory Shipment Screen ========"').wait(500)
        .openScreen('Inventory Shipments').wait(1000)
        .waitTillLoaded('Open Inventory Shipments Search Screen Successful').wait(500)
        .clickButton('#btnNew').wait(500)
        .waitTillVisible('icinventoryshipment','').wait(500)
        .markSuccess('Open New Inventory Shipments Screen Successful')

        .displayText('======== #2. Enter/Select Inventory Shipment Details and Check Fields========')
        .selectComboRowByIndex('#cboOrderType',3).wait(200)
        .selectComboRowByFilter('#cboCustomer', 'Apple Spice Sales', 500, 'strName', 0).wait(200)
        //.selectComboRowByFilter('#cboVendor','0001005057',500, 'intEntityVendorId').wait(500)
        .selectComboRowByFilter('#cboFreightTerms', 'Truck', 500, 'strFreightTerm', 0).wait(200)
        .selectComboRowByIndex('#cboShipFromAddress',0).wait(300)
        .selectComboRowByIndex('#cboShipToAddress',0).wait(300)

        .selectGridComboRowByFilter('#grdInventoryShipment', 0, 'strItemNo', 'NLTI - 01', 300, 'strItemNo').wait(1000)
        .selectGridComboRowByFilter('#grdInventoryShipment', 0, 'strUnitMeasure', 'Bushels', 300, 'strUnitMeasure').wait(1000)
        .enterGridData('#grdInventoryShipment', 0, 'colQuantity', '100').wait(500)
        .enterGridData('#grdInventoryShipment', 0, 'colUnitPrice', '15').wait(500)
        .checkGridData('#grdInventoryShipment', 0, 'colLineTotal', '1500').wait(500)
        .checkGridData('#grdInventoryShipment', 0, 'colOwnershipType', 'Own').wait(500)
        .markSuccess('Enter/Select Inventory Shipment Details and Check Fields Successful')

        .displayText('======== #3. Open Recap Screen and Check Account IDs and Totlas ========')
        .clickButton('#btnRecap').wait(300)
        .waitTillLoaded('Open Recap Screen Successful')
        .checkGridData('#grdRecapTransaction', 0, 'colRecapAccountId', '16000-0001-000').wait(500)
        .checkGridData('#grdRecapTransaction', 0, 'colRecapCredit', '1000').wait(500)
        .checkGridData('#grdRecapTransaction', 1, 'colRecapAccountId', '16050-0001-000').wait(500)
        .checkGridData('#grdRecapTransaction', 1, 'colRecapDebit', '1000').wait(500)
        .markSuccess('======== Open Recap Screen and Check Details Successful ========')

        .displayText('======== #4. Post Inventory Shipment ========')
        .clickButton('#btnPost').wait(500)
        .waitTillLoaded('')
        .markSuccess('======== Posting of Inventory Shipment Successful ========')
        .clickButton('#btnClose').wait(200)
        .waitTillLoaded('')
        .markSuccess('======== Create Direct Shipment for Non Lotted Item Successful! ========')





        //Add Inventory Shipmnet
        //Scenario 4:  Add Direct IS for Lotted Item
        .displayText('"======== Scenario 4:  Add Direct IS for NON Lotted Item ========"').wait(500)
        .displayText('"======== #1 Open New Inventory Shipment Screen ========"').wait(500)
        .openScreen('Inventory Shipments').wait(1000)
        .waitTillLoaded('Open Inventory Shipments Search Screen Successful').wait(500)
        .clickButton('#btnNew').wait(500)
        .waitTillVisible('icinventoryshipment','').wait(500)
        .markSuccess('Open New Inventory Shipments Screen Successful')

        .displayText('======== #2. Enter/Select Inventory Shipment Details and Check Fields========')
        .selectComboRowByIndex('#cboOrderType',3).wait(200)
        .selectComboRowByFilter('#cboCustomer', 'Apple Spice Sales', 500, 'strName', 0).wait(200)
        //.selectComboRowByFilter('#cboVendor','0001005057',500, 'intEntityVendorId').wait(500)
        .selectComboRowByFilter('#cboFreightTerms', 'Truck', 500, 'strFreightTerm', 0).wait(200)
        .selectComboRowByIndex('#cboShipFromAddress',0).wait(300)
        .selectComboRowByIndex('#cboShipToAddress',0).wait(300)

        .selectGridComboRowByFilter('#grdInventoryShipment', 0, 'strItemNo', 'LTI - 01', 300, 'strItemNo').wait(1000)
        .selectGridComboRowByFilter('#grdInventoryShipment', 0, 'strUnitMeasure', 'Bushels', 300, 'strUnitMeasure').wait(1000)
        .enterGridData('#grdInventoryShipment', 0, 'colQuantity', '100').wait(500)
        .enterGridData('#grdInventoryShipment', 0, 'colUnitPrice', '15').wait(500)
        .checkGridData('#grdInventoryShipment', 0, 'colLineTotal', '1500').wait(500)
        .checkGridData('#grdInventoryShipment', 0, 'colOwnershipType', 'Own').wait(500)

        .selectGridComboRowByFilter('#grdLotTracking', 0, 'strLotId', 'LOT-01', 300, 'strLotNumber').wait(1000)
        .enterGridData('#grdLotTracking', 0, 'colShipQty', '100').wait(500)
        .checkGridData('#grdLotTracking', 0, 'colLotUOM', 'Bushels').wait(500)
        .checkGridData('#grdLotTracking', 0, 'colLotWeightUOM', 'Bushels').wait(500)
        .checkGridData('#grdLotTracking', 0, 'colGrossWeight', '100').wait(500)
        .checkGridData('#grdLotTracking', 0, 'colTareWeight', '0').wait(500)
        .checkGridData('#grdLotTracking', 0, 'colNetWeight', '100').wait(500)
        .markSuccess('Enter/Select Inventory Shipment Details and Check Fields Successful')

        .displayText('======== #3. Open Recap Screen and Check Account IDs and Totlas ========')
        .clickButton('#btnRecap').wait(300)
        .waitTillLoaded('Open Recap Screen Successful')
        .checkGridData('#grdRecapTransaction', 0, 'colRecapAccountId', '16000-0001-000').wait(500)
        .checkGridData('#grdRecapTransaction', 0, 'colRecapCredit', '1000').wait(500)
        .checkGridData('#grdRecapTransaction', 1, 'colRecapAccountId', '16050-0001-000').wait(500)
        .checkGridData('#grdRecapTransaction', 1, 'colRecapDebit', '1000').wait(500)
        .markSuccess('======== Open Recap Screen and Check Details Successful ========')

        .displayText('======== #4. Post Inventory Shipment ========')
        .clickButton('#btnPost').wait(500)
        .waitTillLoaded('')
        .markSuccess('======== Posting of Inventory Shipment Successful ========')
        .clickButton('#btnClose').wait(200)
        .waitTillLoaded('')
        .markSuccess('======== Create Direct Shipment for Non Lotted Item Successful! ========')


        //Scenario 3:  Add Inventory Transfers
        .displayText('"======== Scenario 3:  Add Inventory Transfer ========"').wait(500)
        .displayText('"======== #1 Open New Inventory Transfer Screen ========"').wait(500)
        .openScreen('Inventory Transfers').wait(1000)
        .waitTillLoaded('Open Inventory Transfers Search Screen Successful').wait(500)
        .clickButton('#btnNew').wait(500)

        .displayText('======== #2. Enter/Select Inventory Transfer Details and Check Fields========')
        .selectComboRowByFilter('#cboTransferType', 'Location to Location', 500, 'strTransferType', 0).wait(200)
        .selectComboRowByFilter('#cboFromLocation', '0001 - Fort Wayne', 500, 'intFromLocationId', 0).wait(200)
        .selectComboRowByFilter('#cboToLocation', '0001 - Fort Wayne', 500, 'intToLocationId', 0).wait(200)

        .selectGridComboRowByFilter('#grdInventoryTransfer', 0, 'strItemNo', 'LTI - 01', 300, 'strItemNo').wait(500)
        .selectGridComboRowByFilter('#grdInventoryTransfer', 0, 'strFromSubLocationName', 'Raw Station', 300, 'strFromSubLocationName').wait(500)
        .selectGridComboRowByFilter('#grdInventoryTransfer', 0, 'strFromStorageLocationName', 'RM Storage', 300, 'strFromStorageLocationName').wait(500)
        .checkGridData('#grdInventoryTransfer', 0, 'colOwnershipType', 'Own').wait(300)
        .selectGridComboRowByFilter('#grdInventoryTransfer', 0, 'strLotNumber', 'LOT-01', 300, 'strLotNumber').wait(500)
        .checkGridData('#grdInventoryTransfer', 0, 'colAvailableUOM', 'Bushels').wait(300)
        .enterGridData('#grdInventoryTransfer', 0, 'colTransferQty', '100').wait(500)
        .selectGridComboRowByFilter('#grdInventoryTransfer', 0, 'strToSubLocationName', 'FG Station', 300, 'strToSubLocationName').wait(500)
        .selectGridComboRowByFilter('#grdInventoryTransfer', 0, 'strToStorageLocationName', 'FG Storage', 300, 'strToStorageLocationName').wait(500)

        .displayText('======== #3. Post Inventory Transfer ========')
        .clickButton('#btnPost').wait(500)
        .waitTillLoaded('Post Successful')
        .clickButton('#btnClose').wait(200)
        .waitTillLoaded('')
        .markSuccess('======== Post Inventory Transfer Successful! ========')



        //Scenario 4: Add Inventory Adjustment
        .displayText('"======== Scenario 4:  Add Inventory Adjustment ========"').wait(500)
        .displayText('"======== #1 Open New Inventory Adjustment Screen ========"').wait(500)
        .openScreen('Inventory Adjustments').wait(1000)
        .waitTillLoaded('Open Inventory Transfers Search Screen Successful').wait(500)
        .clickButton('#btnNew').wait(500)

        .displayText('"======== #2 Quantity Change ========"').wait(500)
        .selectComboRowByFilter('#cboLocation', '0001 - Fort Wayne', 500, 'strName', 0).wait(200)
        .selectComboRowByIndex('#cboAdjustmentType',0).wait(300)
        .selectGridComboRowByFilter('#grdInventoryAdjustment', 0, 'strItemNo', 'LTI - 01', 300, 'strItemNo').wait(1000)
        .selectGridComboRowByFilter('#grdInventoryAdjustment', 0, 'strSubLocation', 'Raw Station', 300, 'strSubLocation').wait(500)
        .selectGridComboRowByFilter('#grdInventoryAdjustment', 0, 'strStorageLocation', 'RM Storage', 300, 'strStorageLocation').wait(500)
        .selectGridComboRowByFilter('#grdInventoryAdjustment', 0, 'strLotNumber', 'LOT-01', 300, 'strLotNumber').wait(500)
        .checkGridData('#grdInventoryAdjustment', 0, 'colUOM', 'Bushels').wait(300)
        .enterGridData('#grdInventoryAdjustment', 0, 'colAdjustByQuantity', '200').wait(500)
        .checkGridData('#grdInventoryAdjustment', 0, 'colUnitCost', '10').wait(300)
        .checkGridData('#grdInventoryAdjustment', 0, 'colNewUnitCost', '10').wait(300)
        .markSuccess('======== Enter Details successful ========')

        .displayText('======== #3. Open Recap Screen and Check Account IDs and Totlas ========')
        .clickButton('#btnRecap').wait(300)
        .waitTillLoaded('Open Recap Screen Successful')
        .checkGridData('#grdRecapTransaction', 0, 'colRecapAccountId', '16000-0001-000').wait(500)
        .checkGridData('#grdRecapTransaction', 0, 'colRecapDebit', '2000').wait(500)
        .checkGridData('#grdRecapTransaction', 1, 'colRecapAccountId', '16040-0001-000').wait(500)
        .checkGridData('#grdRecapTransaction', 1, 'colRecapCredit', '2000').wait(500)
        .markSuccess('======== Open Recap Screen and Check Details Successful========')

        .displayText('======== #4. Post Inventory Adjustment ========')
        .clickButton('#btnPost').wait(500)
        .waitTillLoaded('Inventory Post Successful')
        .clickButton('#btnClose').wait(200)
        .waitTillLoaded('')
        .markSuccess('======== Post Inventory Adjustment Successful ========')

        //#5 Lot Move
        .clickButton('#btnNew').wait(500)

        .displayText('"======== #5 Lot Move ========"').wait(500)
        .selectComboRowByFilter('#cboLocation', '0001 - Fort Wayne', 500, 'strName', 0).wait(200)
        .selectComboRowByIndex('#cboAdjustmentType',7).wait(300)
        .selectGridComboRowByFilter('#grdInventoryAdjustment', 0, 'strItemNo', 'LTI - 01', 300, 'strItemNo').wait(1000)
        .selectGridComboRowByFilter('#grdInventoryAdjustment', 0, 'strSubLocation', 'Raw Station', 300, 'strSubLocation').wait(500)
        .selectGridComboRowByFilter('#grdInventoryAdjustment', 0, 'strStorageLocation', 'RM Storage', 300, 'strStorageLocation').wait(500)
        .selectGridComboRowByFilter('#grdInventoryAdjustment', 0, 'strLotNumber', 'LOT-01', 300, 'strLotNumber').wait(500)
        .enterGridData('#grdInventoryAdjustment', 0, 'colNewLotNumber', 'LOT-02').wait(500)
        .checkGridData('#grdInventoryAdjustment', 0, 'colUOM', 'Bushels').wait(300)
        .enterGridData('#grdInventoryAdjustment', 0, 'colAdjustByQuantity', '-200').wait(500)
        //.checkGridData('#grdInventoryAdjustment', 0, 'colUnitCost', '10').wait(300)
        //.selectGridComboRowByFilter('#grdInventoryAdjustment', 0, 'strNewStorageLocation', 'RM Bin 1', 300, 'strNewStorageLocation').wait(500)
        //.checkGridData('#grdInventoryAdjustment', 0, 'colNewLocation', '0001 - Fort Wayne').wait(300)
        .checkGridData('#grdInventoryAdjustment', 0, 'colSubLocation', 'Raw Station').wait(300)
        .markSuccess('======== Enter Details successful ========')

        .displayText('======== #6 Open Recap Screen and Check Account IDs and Totlas ========')
        .clickButton('#btnRecap').wait(300)
        .waitTillLoaded('Open Recap Screen Successful')
        .checkGridData('#grdRecapTransaction', 0, 'colRecapAccountId', '16000-0001-000').wait(300)
        .checkGridData('#grdRecapTransaction', 0, 'colRecapCredit', '2000').wait(300)
        .checkGridData('#grdRecapTransaction', 1, 'colRecapAccountId', '16000-0001-000').wait(300)
        .checkGridData('#grdRecapTransaction', 1, 'colRecapDebit', '2000').wait(300)

        .checkGridData('#grdRecapTransaction', 2, 'colRecapAccountId', '16040-0001-000').wait(300)
        .checkGridData('#grdRecapTransaction', 2, 'colRecapDebit', '2000').wait(300)
        .checkGridData('#grdRecapTransaction', 3, 'colRecapAccountId', '16040-0001-000').wait(300)
        .checkGridData('#grdRecapTransaction', 3, 'colRecapCredit', '2000').wait(300)
        .markSuccess('======== Open Recap Screen and Check Details Successful========')

        .displayText('======== #7. Post Inventory Adjustment ========')
        .clickButton('#btnPost').wait(500)
        .waitTillLoaded('Inventory Post Successful')
        .clickButton('#btnClose').wait(200)
        .waitTillLoaded('')
        .markSuccess('======== Post Inventory Adjustment Successful ========')
        .markSuccess('======== Create Quantity Change Adjustment for Lotted Item Successful! ========')


        //Add Inventory Count
        .displayText('"======== Scenario 7:  Add Inventory Count ========"').wait(500)
        .displayText('"======== #1 Open New Inventory Count Screen ========"').wait(500)
        .openScreen('Inventory Count').wait(500)
        .waitTillLoaded('Open Inventory Count Search Screen Successful').wait(500)
        .clickButton('#btnNew').wait(500)
        .waitTillVisible('inventorycount','').wait(1000)
        .markSuccess('Open New Inventory Count Screen Successful')

        .displayText('======== #2. Enter/Select Inventory Count Details and Check Fields========')
        .selectComboRowByFilter('#cboCategory', 'Grains', 500, 'strCategoryCode', 0).wait(200)
        .selectComboRowByFilter('#cboCommodity', 'Corn', 500, 'strCommodityCode', 0).wait(200)
        .selectComboRowByFilter('#cboSubLocation', 'Raw Station', 500, 'strSubLocationName', 0).wait(200)
        .selectComboRowByFilter('#cboStorageLocation', 'RM Storage', 500, 'strName', 0).wait(200)
        .clickCheckBox('#chkIncludeZeroOnHand', true).wait(300)
        .clickCheckBox('#chkIncludeOnHand', true).wait(300)
        .clickCheckBox('#chkScannedCountEntry', true).wait(300)
        .clickCheckBox('#chkCountByLots', true).wait(300)
        .clickCheckBox('#chkCountByPallets', true).wait(300)


        .clickButton('#btnFetch').wait(300)
        .checkGridData('#grdPhysicalCount', 0, 'colItem', 'LTI - 01').wait(200)
        .checkGridData('#grdPhysicalCount', 0, 'colCategory', 'Grains').wait(200)
        .checkGridData('#grdPhysicalCount', 0, 'colSubLocation', 'Raw Station').wait(200)
        .checkGridData('#grdPhysicalCount', 0, 'colStorageLocation', 'RM Storage').wait(200)
        .checkGridData('#grdPhysicalCount', 0, 'colLotNo', 'LOT-01').wait(200)
        .markSuccess('Enter/Select Inventory Count Details and Check Fields Successful')

        .displayText('======== #3. Print Count Sheets ========')
        .clickButton('#btnPrintCountSheets').wait(500)
        .waitTillVisible('search', 'Print Count Sheets Displayed!')
        .clickButton('#btnClose').wait(200)
        .waitTillLoaded('')
        .clickButton('#btnClose').wait(200)
        .waitTillLoaded('')
        .markSuccess('======== Create Inventory Count Successful! ========')



        //Add Storage Measurement Reading
        .displayText('"======== Scenario 8:  Add Storage Measurement Reading ========"').wait(500)
        .displayText('"======== #1 Open New Storage Measurement Reading Screen ========"').wait(500)
        .openScreen('Storage Measurement Reading').wait(500)
        .waitTillLoaded('Open Storage Measurement Reading Search Screen Successful').wait(500)
        //.clickButton('#btnClose').wait(300)
        //.checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question').wait(1000)
        //.clickMessageBoxButton('no').wait(300)
        .clickButton('#btnNew').wait(300)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question').wait(1000)
        .clickMessageBoxButton('no').wait(300)
        .waitTillVisible('storagemeasurementreading','').wait(1000)
        .markSuccess('Open New Storage Measurement Reading Screen Successful')

        .displayText('======== #2. Enter/Select Storage Measurement Reading Details and Check Fields========')
        .selectComboRowByFilter('#cboLocation', '0001 - Fort Wayne', 500, 'strName', 0).wait(200)
        .selectGridComboRowByFilter('#grdStorageMeasurementReading', 0, 'strCommodity', 'Corn', 300, 'strCommodity').wait(500)
        //.selectGridComboRowByFilter('#grdStorageMeasurementReading', 0, 'strItemNo', 'LTI-01', 500, 'strItemNo').wait(1000)
        .selectGridComboRowByIndex('#grdStorageMeasurementReading', 0, 'strItemNo','0', 'strItemNo').wait(100)
        .selectGridComboRowByFilter('#grdStorageMeasurementReading', 0, 'strStorageLocationName', 'RM Storage', 300, 'strStorageLocationName').wait(500)
        .checkGridData('#grdStorageMeasurementReading', 0, 'colSubLocation', 'Raw Station').wait(200)
        .enterGridData('#grdStorageMeasurementReading', 0, 'colAirSpaceReading', '100').wait(500)
        .enterGridData('#grdStorageMeasurementReading', 0, 'colCashPrice', '15').wait(500)
        .displayText('======== Enter/Select Storage Measurement Reading Details and Check Fields Successful========')


        .displayText('======== #3. Save Storage Measurement Reading ========')
        .clickButton('#btnSave').wait(500)
        .markSuccess('======== Saveing Storage Measurement Reading Successful ========')
        .clickButton('#btnClose').wait(200)
        .waitTillLoaded('')
        .markSuccess('======== Create Storage Measurement Reading Successful! ========')


        .done();
});



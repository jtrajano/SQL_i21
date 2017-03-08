StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        //region Scenario 1. Create Direct Inventory Receipt for Non Lotted Item
        .displayText('=====  Scenario 1. Creeate Direct IR for Non Lotted Item  =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','NLTI - 02','strItemNo')
		
		.enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure', 100000, 'LB')
        		
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000000')

       .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
               total = win.down('#txtGrossWgt').value;
            if (total == 100000) {
                t.ok(true, 'Gross is correct.');
            }
            else {
                t.ok(false, 'Gross is incorrect.');
            }
            next();
        })
       .addFunction(function (next){
           var win =  Ext.WindowManager.getActive(),
               total = win.down('#txtNetWgt').value;
           if (total == 100000) {
               t.ok(true, 'Net is correct.');
           }
           else {
               t.ok(false, 'Net is incorrect.');
           }
           next();
       })
       .addFunction(function (next){
           var win =  Ext.WindowManager.getActive(),
                total = win.down('#txtTotal').value;
           if (total == 1000000) {
               t.ok(true, 'Total is correct.');
           }
           else {
               t.ok(false, 'Total is incorrect.');
           }
           next();
       })

        .clickTab('Post Preview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Direct Inventory Receipt for Non Lotted Item Done=====')


        //region Scenario 2. Create Direct Inventory Receipt for Lotted Item
        .displayText('=====  Scenario 2. Create Direct IR for Lotted Item  =====')
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','LTI - 02','strItemNo')
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

        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
               total = win.down('#txtGrossWgt').value;
            if (total == 100000) {
                t.ok(true, 'Gross is correct.');
            }
            else {
                t.ok(false, 'Gross is incorrect.');
            }
            next();
        })
       .addFunction(function (next){
           var win =  Ext.WindowManager.getActive(),
               total = win.down('#txtNetWgt').value;
           if (total == 100000) {
               t.ok(true, 'Net is correct.');
           }
           else {
               t.ok(false, 'Net is incorrect.');
           }
           next();
       })
       .addFunction(function (next){
           var win =  Ext.WindowManager.getActive(),
                total = win.down('#txtTotal').value;
           if (total == 1000000) {
               t.ok(true, 'Total is correct.');
           }
           else {
               t.ok(false, 'Total is incorrect.');
           }
           next();
       })

        .clickTab('Post Preview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Create Direct Inventory Receipt for Lotted Item=====')


        //region Scenario 3. Create Purchase Order Inventory Receipt for Non Lotted Item "Process Button"
        .displayText('=====  Scenario 3. Create PO to IR "Process Button" for Non Lotted Item  =====')
        .clickMenuFolder('Purchasing (Accounts Payable)','Folder')
        .clickMenuScreen('Purchase Orders','Screen')
        .clickButton('New')
        .waitUntilLoaded('appurchaseorder')
        .selectComboBoxRowValue('VendorId', 'ABC Trucking', 'VendorId',1)
        .waitUntilLoaded('')
        .selectGridComboBoxRowValue('Items',1,'strItemNo','NLTI - 02','strItemNo')
        .selectGridComboBoxRowValue('Items',1,'strUOM','LB','strUOM')
        .enterGridData('Items', 1, 'colQtyOrdered', '100')
        .verifyGridData('Items', 1, 'colTotal', '1000')
        .clickButton('Save')
        .waitUntilLoaded('')
        .clickButton('Process')
        .addResult('Processing PO to IR',1000)
        .waitUntilLoaded('icinventoryreceipt')
        .waitUntilLoaded('')
        .verifyData('Combo Box','ReceiptType','Purchase Order')
        .verifyData('Combo Box','Vendor','ABC Trucking')
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'NLTI - 02')
        .verifyGridData('InventoryReceipt', 1, 'colOrderUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colQtyOrdered', '100')
        .verifyGridData('InventoryReceipt', 1, 'colUOM', 'LB')
		.verifyUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 100, 'LB', 'equal')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryReceipt', 1, 'colStorageLocation', 'RM Storage')

       .addFunction(function (next){
           var win =  Ext.WindowManager.getActive(),
                total = win.down('#txtTotal').value;
           if (total == 1000) {
               t.ok(true, 'Total is correct.');
           }
           else {
               t.ok(false, 'Total is incorrect.');
           }
           next();
       })

        .clickTab('Post Preview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Purchasing (Accounts Payable)','Folder')
        .displayText('===== Create Purchase Order Inventory Receipt for Non Lotted Item "Process Button" Done=====')


        //region Scenario 4. Create Purchase Order Inventory Receipt for Lotted Item "Process Button"
        .displayText('=====  Scenario 4. Create Create PO to IR "Process Button" for Lotted Item  =====')
        .clickMenuFolder('Purchasing (Accounts Payable)','Folder')
        .clickMenuScreen('Purchase Orders','Screen')
        .clickButton('New')
        .waitUntilLoaded('appurchaseorder')
        .selectComboBoxRowValue('VendorId', 'ABC Trucking', 'VendorId',1)
        .waitUntilLoaded('')
        .selectGridComboBoxRowValue('Items',1,'strItemNo','LTI - 02','strItemNo')
        .selectGridComboBoxRowValue('Items',1,'strUOM','LB','strUOM')
        .enterGridData('Items', 1, 'colQtyOrdered', '100')
        .verifyGridData('Items', 1, 'colTotal', '1000')
        .clickButton('Save')
        .waitUntilLoaded('')
        .clickButton('Process')
        .addResult('Processing PO to IR',1000)
        .waitUntilLoaded('icinventoryreceipt')
        .waitUntilLoaded('')
        .verifyData('Combo Box','ReceiptType','Purchase Order')
        .verifyData('Combo Box','Vendor','ABC Trucking')
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'LTI - 02')
        .verifyGridData('InventoryReceipt', 1, 'colOrderUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colQtyOrdered', '100')
        .verifyGridData('InventoryReceipt', 1, 'colUOM', 'LB')
        .verifyUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 100, 'LB', 'equal')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryReceipt', 1, 'colStorageLocation', 'RM Storage')
        .verifyUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 100, 'LB', 'equal')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strWeightUOM','LB','strWeightUOM')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '100')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '100')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .waitUntilLoaded('')


        .enterGridData('LotTracking', 1, 'colLotId', 'LOT-01')
        .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure','LB','strUnitMeasure')
        .enterGridData('LotTracking', 1, 'colLotQuantity', '100')
        .verifyGridData('LotTracking', 1, 'colLotGrossWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colLotNetWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM', 'LB')
        .verifyGridData('LotTracking', 1, 'colLotStorageLocation', 'RM Storage')
       .addFunction(function (next){
           var win =  Ext.WindowManager.getActive(),
                total = win.down('#txtGrossWgt').value;
           if (total == 100) {
               t.ok(true, 'Gross is correct.');
           }
           else {
               t.ok(false, 'Grossl is incorrect.');
           }
           next();
       })
       .addFunction(function (next){
           var win =  Ext.WindowManager.getActive(),
                total = win.down('#txtNetWgt').value;
           if (total == 100) {
               t.ok(true, 'Net is correct.');
           }
           else {
               t.ok(false, 'Net is incorrect.');
           }
           next();
       })
       .addFunction(function (next){
           var win =  Ext.WindowManager.getActive(),
               total = win.down('#txtTotal').value;
           if (total == 1000) {
               t.ok(true, 'Total is correct.');
           }
           else {
               t.ok(false, 'Total is incorrect.');
           }
           next();
       })
        .clickTab('Post Preview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Purchasing (Accounts Payable)','Folder')
        .displayText('===== Create Purchase Order Inventory Receipt for Lotted Item "Process Button" Done=====')


        //region Scenario 5. Create Purchase Order Inventory Receipt for Non Lotted Item "Add Orders Screen"
        .displayText('=====  Scenario 5. Create PO to IR "Add Orders Screen" for Non Lotted Item  =====')
        .clickMenuFolder('Purchasing (Accounts Payable)','Folder')
        .clickMenuScreen('Purchase Orders','Screen')
        .clickButton('New')
        .waitUntilLoaded('appurchaseorder')
        .selectComboBoxRowValue('VendorId', 'ABC Trucking', 'VendorId',1)
        .waitUntilLoaded('')
        .selectGridComboBoxRowValue('Items',1,'strItemNo','NLTI - 02','strItemNo')
        .selectGridComboBoxRowValue('Items',1,'strUOM','LB','strUOM')
        .enterGridData('Items', 1, 'colQtyOrdered', '100')
        .verifyGridData('Items', 1, 'colTotal', '1000')
        .clickButton('Save')
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')

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
        .verifyData('Combo Box','ReceiptType','Purchase Order')
        .verifyData('Combo Box','Vendor','ABC Trucking')
        .verifyData('Combo Box','Currency','USD')
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'NLTI - 02')
        .verifyGridData('InventoryReceipt', 1, 'colOrderUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colQtyOrdered', '100')
        .verifyGridData('InventoryReceipt', 1, 'colUOM', 'LB')
        .verifyUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 100, 'LB', 'equal')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryReceipt', 1, 'colStorageLocation', 'RM Storage')

       .addFunction(function (next){
           var win =  Ext.WindowManager.getActive(),
               total = win.down('#txtTotal').value;
           if (total == 1000) {
               t.ok(true, 'Total is correct.');
           }
           else {
               t.ok(false, 'Total is incorrect.');
           }
           next();
       })

        .clickTab('Post Preview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuFolder('Purchasing (Accounts Payable)','Folder')
        .displayText('===== Create Purchase Order Inventory Receipt for Non Lotted Item "Process Button" Done=====')


        //region Scenario 6. Create Purchase Order Inventory Receipt for  Lotted Item "Process Button"
        .displayText('=====  Scenario 6. Create PO to IR "Process Button" for Lotted Item  =====')
        .clickMenuFolder('Purchasing (Accounts Payable)','Folder')
        .clickMenuScreen('Purchase Orders','Screen')
        .clickButton('New')
        .waitUntilLoaded('appurchaseorder')
        .selectComboBoxRowValue('VendorId', 'ABC Trucking', 'VendorId',1)
        .waitUntilLoaded('')
        .selectGridComboBoxRowValue('Items',1,'strItemNo','LTI - 02','strItemNo')
        .selectGridComboBoxRowValue('Items',1,'strUOM','LB','strUOM')
        .enterGridData('Items', 1, 'colQtyOrdered', '100')
        .verifyGridData('Items', 1, 'colTotal', '1000')
        .clickButton('Save')
        .waitUntilLoaded('')
        .clickButton('Process')
        .addResult('Processing PO to IR',1000)
        .waitUntilLoaded('icinventoryreceipt')
        .waitUntilLoaded('')
        .verifyData('Combo Box','ReceiptType','Purchase Order')
        .verifyData('Combo Box','Vendor','ABC Trucking')
        .verifyData('Combo Box','Currency','USD')
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'LTI - 02')
        .verifyGridData('InventoryReceipt', 1, 'colOrderUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colQtyOrdered', '100')
        .verifyGridData('InventoryReceipt', 1, 'colUOM', 'LB')
        .verifyUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 100, 'LB', 'equal')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryReceipt', 1, 'colStorageLocation', 'RM Storage')

        .verifyUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 100, 'LB', 'equal')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strWeightUOM','LB','strWeightUOM')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '100')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '100')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .waitUntilLoaded('')


        .enterGridData('LotTracking', 1, 'colLotId', 'LOT-01')
        .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure','LB','strUnitMeasure')
        .enterGridData('LotTracking', 1, 'colLotQuantity', '100')
        .verifyGridData('LotTracking', 1, 'colLotGrossWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colLotNetWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM', 'LB')
        .verifyGridData('LotTracking', 1, 'colLotStorageLocation', 'RM Storage')

       .addFunction(function (next){
           var win =  Ext.WindowManager.getActive(),
               total = win.down('#txtGrossWgt').value;
           if (total == 100) {
               t.ok(true, 'Gross is correct.');
           }
           else {
               t.ok(false, 'Gross is incorrect.');
           }
           next();
       })
       .addFunction(function (next){
           var win =  Ext.WindowManager.getActive(),
               total = win.down('#txtNetWgt').value;
           if (total == 100) {
               t.ok(true, 'Net is correct.');
           }
           else {
               t.ok(false, 'Net is incorrect.');
           }
           next();
       })
       .addFunction(function (next){
           var win =  Ext.WindowManager.getActive(),
               total = win.down('#txtTotal').value;
           if (total == 1000) {
               t.ok(true, 'Total is correct.');
           }
           else {
               t.ok(false, 'Total is incorrect.');
           }
           next();
       })

        .clickTab('Post Preview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Purchasing (Accounts Payable)','Folder')
        .displayText('===== Create Purchase Order Inventory Receipt for Lotted Item "Process Button" Done=====')


        //region Scenario 7. Create Purchase Order Inventory Receipt for  Lotted Item "Add Orders Screen"
        .displayText('=====  Scenario 7. Create PO to IR "Add Orders Screen" for Lotted Item =====')
        .clickMenuFolder('Purchasing (Accounts Payable)','Folder')
        .clickMenuScreen('Purchase Orders','Screen')
        .clickButton('New')
        .waitUntilLoaded('appurchaseorder')
        .selectComboBoxRowValue('VendorId', 'ABC Trucking', 'VendorId',1)
        .waitUntilLoaded('')
        .selectGridComboBoxRowValue('Items',1,'strItemNo','LTI - 02','strItemNo')
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
        .verifyData('Combo Box','ReceiptType','Purchase Order')
        .verifyData('Combo Box','Vendor','ABC Trucking')
        .verifyData('Combo Box','Currency','USD')
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'LTI - 02')
        .verifyGridData('InventoryReceipt', 1, 'colOrderUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colQtyOrdered', '100')
        .verifyGridData('InventoryReceipt', 1, 'colUOM', 'LB')
        .verifyUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 100, 'LB', 'equal')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryReceipt', 1, 'colStorageLocation', 'RM Storage')

        .verifyUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 100, 'LB', 'equal')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strWeightUOM','LB','strWeightUOM')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '100')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '100')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .waitUntilLoaded('')


        .enterGridData('LotTracking', 1, 'colLotId', 'LOT-01')
        .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure','LB','strUnitMeasure')
        .enterGridData('LotTracking', 1, 'colLotQuantity', '100')
        .verifyGridData('LotTracking', 1, 'colLotGrossWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colLotNetWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM', 'LB')
        .verifyGridData('LotTracking', 1, 'colLotStorageLocation', 'RM Storage')
       .addFunction(function (next){
           var win =  Ext.WindowManager.getActive(),
               total = win.down('#txtGrossWgt').value;
           if (total == 100) {
               t.ok(true, 'Gross is correct.');
           }
           else {
               t.ok(false, 'Gross is incorrect.');
           }
           next();
       })
       .addFunction(function (next){
           var win =  Ext.WindowManager.getActive(),
               total = win.down('#txtNetWgt').value;
           if (total == 100) {
               t.ok(true, 'Net is correct.');
           }
           else {
               t.ok(false, 'Net is incorrect.');
           }
           next();
       })
       .addFunction(function (next){
           var win =  Ext.WindowManager.getActive(),
               total = win.down('#txtTotal').value;
           if (total == 1000) {
               t.ok(true, 'Total is correct.');
           }
           else {
               t.ok(false, 'Total is incorrect.');
           }
           next();
       })

        .clickTab('Post Preview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Create Purchase Order Inventory Receipt for Lotted Item "Process Button" Done=====')


        //region Scenario 8. Create Purchase Contract Inventory Receipt for Non Lotted Item "Process Button"
        .displayText('=====  Scenario 8. Create Purchase Contract Inventory Receipt for Non Lotted Item "Process Button"  =====')
        .clickMenuFolder('Contract Management','Folder')
        .clickMenuScreen('Contracts','Screen')
        .clickButton('New')
        .waitUntilLoaded('ctcontract')
        .selectComboBoxRowValue('Type', 'Purchase', 'Type',1)
        .selectComboBoxRowValue('Customer', 'ABC Trucking', 'Customer',1)
        .selectComboBoxRowValue('Commodity', 'Corn', 'Commodity',1)
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
        .selectComboBoxRowValue('Item', 'NLTI - 02', 'Item',1)
        .selectComboBoxRowValue('NetWeightUOM', 'LB', 'NetWeightUOM',1)
        .verifyData('Text Field','NetWeight','100.0000')
        .verifyData('Combo Box','PricingType','Cash')
        .verifyData('Combo Box','PriceCurrency','USD')
        .verifyData('Combo Box','CashPriceUOM','LB')
        .enterData('Text Field','CashPrice','10')
        .clickButton('Save')
        .waitUntilLoaded('ctcontract')
        .clickButton('Save')
        .waitUntilLoaded('')
        .clickButton('Process')
        .waitUntilLoaded('icinventoryreceipt')
        .waitUntilLoaded('')

        .verifyData('Combo Box','ReceiptType','Purchase Contract')
        .verifyData('Combo Box','Vendor','ABC Trucking')
        .verifyData('Combo Box','Currency','USD')
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'NLTI - 02')
        .verifyGridData('InventoryReceipt', 1, 'colOrderUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colQtyOrdered', '100')
        .verifyGridData('InventoryReceipt', 1, 'colUOM', 'LB')
        .verifyUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 100, 'LB', 'equal')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')

       .addFunction(function (next){
           var win =  Ext.WindowManager.getActive(),
               total = win.down('#txtTotal').value;
           if (total == 1000) {
               t.ok(true, 'Total is correct.');
           }
           else {
               t.ok(false, 'Total is incorrect.');
           }
           next();
       })

        .clickTab('Post Preview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',3000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('ctcontract')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Contract Management','Folder')
        .displayText('===== Create Purchase Contract Inventory Receipt for Non Lotted Item "Process Button" Done=====')


         //region Scenario 9. Create Purchase Contract Inventory Receipt for Lotted Item "Process Button" - (Comment this out until TF bug fix is done for scroll bars)
        .displayText('=====  Scenario 9. Create Purchase Contract Inventory Receipt for Lotted Item "Process Button"  =====')
        .clickMenuFolder('Contract Management','Folder')
        .clickMenuScreen('Contracts','Screen')
        .clickButton('New')
        .waitUntilLoaded('ctcontract')
        .selectComboBoxRowValue('Type', 'Purchase', 'Type',1)
        .selectComboBoxRowValue('Customer', 'ABC Trucking', 'Customer',1)
        .selectComboBoxRowValue('Commodity', 'Corn', 'Commodity',1)
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
        .selectComboBoxRowValue('Item', 'LTI - 02', 'Item',1)
        .selectComboBoxRowValue('NetWeightUOM', 'LB', 'NetWeightUOM',1)
        .verifyData('Text Field','NetWeight','100.0000')
        .verifyData('Combo Box','PricingType','Cash')
        .verifyData('Combo Box','PriceCurrency','USD')
        .verifyData('Combo Box','CashPriceUOM','LB')
        .enterData('Text Field','CashPrice','10')
        .clickButton('Save')
        .waitUntilLoaded('ctcontract')
        .clickButton('Save')
        .waitUntilLoaded('')
        .clickButton('Process')
        .waitUntilLoaded('icinventoryreceipt')
        .waitUntilLoaded('')

        .verifyData('Combo Box','ReceiptType','Purchase Contract')
        .verifyData('Combo Box','Vendor','ABC Trucking')
        .verifyData('Combo Box','Currency','USD')
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'LTI - 02')
        .verifyGridData('InventoryReceipt', 1, 'colOrderUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colQtyOrdered', '100')
        .verifyGridData('InventoryReceipt', 1, 'colUOM', 'LB')
        .verifyUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 100, 'LB', 'equal')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')

        .verifyUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 100, 'LB', 'equal')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strWeightUOM','LB','strWeightUOM')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '100')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '100')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strSubLocationName','Raw Station','strSubLocationName')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strStorageLocationName','RM Storage','strStorageLocationName')
        .waitUntilLoaded('')


        .enterGridData('LotTracking', 1, 'colLotId', 'LOT-01')
        .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure','LB','strUnitMeasure')
        .enterGridData('LotTracking', 1, 'colLotQuantity', '100')
        .verifyGridData('LotTracking', 1, 'colLotGrossWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colLotNetWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM', 'LB')
        .verifyGridData('LotTracking', 1, 'colLotStorageLocation', 'RM Storage')
       .addFunction(function (next){
           var win =  Ext.WindowManager.getActive(),
               total = win.down('#txtGrossWgt').value;
           if (total == 100) {
               t.ok(true, 'Gross is correct.');
           }
           else {
               t.ok(false, 'Grossl is incorrect.');
           }
           next();
       })
       .addFunction(function (next){
           var win =  Ext.WindowManager.getActive(),
               total = win.down('#txtNetWgt').value;
           if (total == 100) {
               t.ok(true, 'Net is correct.');
           }
           else {
               t.ok(false, 'Net is incorrect.');
           }
           next();
       })
       .addFunction(function (next){
           var win =  Ext.WindowManager.getActive(),
               total = win.down('#txtTotal').value;
           if (total == 1000) {
               t.ok(true, 'Total is correct.');
           }
           else {
               t.ok(false, 'Total is incorrect.');
           }
           next();
       })
        .clickTab('Post Preview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',300)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Contract Management','Folder')
        .displayText('===== 9. Create Purchase Contract Inventory Receipt for Lotted Item "Process Button" Done=====')

        //region Scenario 10. Create Purchase Contract Inventory Receipt for Non Lotted Item "Add Orders Screen"
        .displayText('=====  Scenario 10. Create Purchase Contract to IR Add Orders Screen for Non Lotted Item  =====')
        .clickMenuFolder('Contract Management','Folder')
        .clickMenuScreen('Contracts','Screen')
        .clickButton('New')
        .waitUntilLoaded('ctcontract')
        .selectComboBoxRowValue('Type', 'Purchase', 'Type',1)
        .selectComboBoxRowValue('Customer', 'ABC Trucking', 'Customer',1)
        .selectComboBoxRowValue('Commodity', 'Corn', 'Commodity',1)
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
        .selectComboBoxRowValue('Item', 'NLTI - 02', 'Item',1)
        .selectComboBoxRowValue('NetWeightUOM', 'LB', 'NetWeightUOM',1)
        .verifyData('Text Field','NetWeight','100.0000')
        .verifyData('Combo Box','PricingType','Cash')
        .verifyData('Combo Box','PriceCurrency','USD')
        .verifyData('Combo Box','CashPriceUOM','LB')
        .enterData('Text Field','CashPrice','10')
        .clickButton('Save')
        .waitUntilLoaded('ctcontract')
        .clickButton('Save')
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Contract Management','Folder')

        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Receipts','Screen')
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',1,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .waitUntilLoaded('')
        .selectSearchRowNumber(1)
        .clickButton('OpenSelected')
        .waitUntilLoaded('icinventoryreceipt')


        .verifyData('Combo Box','ReceiptType','Purchase Contract')
        .verifyData('Combo Box','Vendor','ABC Trucking')
        .verifyData('Combo Box','Currency','USD')
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'NLTI - 02')
        .verifyGridData('InventoryReceipt', 1, 'colOrderUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colQtyOrdered', '100')
        .verifyGridData('InventoryReceipt', 1, 'colUOM', 'LB')
        .verifyUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 100, 'LB', 'equal')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strWeightUOM','LB','strWeightUOM')

       .addFunction(function (next){
           var win =  Ext.WindowManager.getActive(),
               total = win.down('#txtTotal').value;
           if (total == 1000) {
               t.ok(true, 'Total is correct.');
           }
           else {
               t.ok(false, 'Total is incorrect.');
           }
           next();
       })

        .clickTab('Post Preview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Create Purchase Contract Inventory Receipt for Non Lotted Item "Add Orders Screen" Done=====')


        //region Scenario 11. Create Purchase Contract Inventory Receipt for Lotted Item "Add Orders Screen"
        .displayText('=====  Scenario 11. Create Purchase Contract to IR Add Orders Screen for Lotted Item  =====')
        .clickMenuFolder('Contract Management','Folder')
        .clickMenuScreen('Contracts','Screen')
        .clickButton('New')
        .waitUntilLoaded('ctcontract')
        .selectComboBoxRowValue('Type', 'Purchase', 'Type',1)
        .selectComboBoxRowValue('Customer', 'ABC Trucking', 'Customer',1)
        .selectComboBoxRowValue('Commodity', 'Corn', 'Commodity',1)
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
        .selectComboBoxRowValue('Item', 'LTI - 02', 'Item',1)
        .selectComboBoxRowValue('NetWeightUOM', 'LB', 'NetWeightUOM',1)
        .verifyData('Text Field','NetWeight','100.0000')
        .verifyData('Combo Box','PricingType','Cash')
        .verifyData('Combo Box','PriceCurrency','USD')
        .verifyData('Combo Box','CashPriceUOM','LB')
        .enterData('Text Field','CashPrice','10')
        .clickButton('Save')
        .waitUntilLoaded('ctcontract')
        .clickButton('Save')
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Contract Management','Folder')

        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Receipts','Screen')
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',1,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .waitUntilLoaded('')
        .selectSearchRowNumber(1)
        .clickButton('OpenSelected')
        .waitUntilLoaded('icinventoryreceipt')


        .verifyData('Combo Box','ReceiptType','Purchase Contract')
        .verifyData('Combo Box','Vendor','ABC Trucking')
        .verifyData('Combo Box','Currency','USD')
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'LTI - 02')
        .verifyGridData('InventoryReceipt', 1, 'colOrderUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colQtyOrdered', '100')
        .verifyGridData('InventoryReceipt', 1, 'colUOM', 'LB')
        .verifyUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 100, 'LB', 'equal')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strWeightUOM','LB','strWeightUOM')

        .selectGridComboBoxRowValue('InventoryReceipt',1,'strSubLocationName','Raw Station','strSubLocationName')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strStorageLocationName','RM Storage','strStorageLocationName')
        .waitUntilLoaded('')


        .enterGridData('LotTracking', 1, 'colLotId', 'LOT-01')
        .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure','LB','strUnitMeasure')
        .enterGridData('LotTracking', 1, 'colLotQuantity', '100')
        .verifyGridData('LotTracking', 1, 'colLotGrossWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colLotNetWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM', 'LB')
        .verifyGridData('LotTracking', 1, 'colLotStorageLocation', 'RM Storage')

       .addFunction(function (next){
           var win =  Ext.WindowManager.getActive(),
               total = win.down('#txtTotal').value;
           if (total == 1000) {
               t.ok(true, 'Total is correct.');
           }
           else {
               t.ok(false, 'Total is incorrect.');
           }
           next();
       })

        .clickTab('Post Preview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Create Purchase Contract Inventory Receipt for Lotted Item "Add Orders Screen" Done=====')



        //region Scenario 12. Create Purchase Contract Inbound Shipment Inventory Receipt for Lotted Item "Add Orders Screen"
        .displayText('=====  Scenario 12. Create Inbound Shipment Purchase Contract Inventory Receipt for Lotted Item "Add Orders Screen"  =====')
        .clickMenuFolder('Contract Management','Folder')
        .clickMenuScreen('Contracts','Screen')
        .clickButton('New')
        .waitUntilLoaded('ctcontract')
        .selectComboBoxRowValue('Type', 'Purchase', 'Type',1)
        .selectComboBoxRowValue('Customer', 'The Scoular Company', 'Customer',1)
        .selectComboBoxRowValue('Commodity', 'Corn', 'Commodity',1)
        .enterData('Text Field','Quantity','100')
        .selectComboBoxRowValue('CommodityUOM', 'LB', 'CommodityUOM',1)
        .selectComboBoxRowValue('Position', 'On Shipment', 'Position',1)
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
        .selectComboBoxRowValue('Item', 'LTI - 02', 'Item',1)
        .selectComboBoxRowValue('NetWeightUOM', 'LB', 'NetWeightUOM',1)
        .verifyData('Text Field','NetWeight','100.0000')
        .verifyData('Combo Box','PricingType','Cash')
        .verifyData('Combo Box','PriceCurrency','USD')
        .verifyData('Combo Box','CashPriceUOM','LB')
        .enterData('Text Field','CashPrice','10')
        .clickButton('Save')
        .waitUntilLoaded('ctcontract')
        .clickButton('Save')
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Contract Management','Folder')

        .clickMenuFolder('Logistics','Folder')
        .clickMenuScreen('Load / Shipment Schedules')
        .clickButton('New')
        .waitUntilLoaded('shipmentschedule')
        .selectComboBoxRowNumber('ShipmentType',1,0)
        .selectComboBoxRowNumber('Type',1,0)
        .selectComboBoxRowNumber('SourceType',2,0)
        .selectComboBoxRowNumber('TransportationMode',2,0)
        .selectComboBoxRowValue('WeightUnit', 'LB', 'WeightUnit',2)
        .selectGridComboBoxRowValue('LoadSchedule',1,'strVendor','The Scoular Company','strVendor')
        .selectGridComboBoxRowNumber('LoadSchedule',1,'colPurchaseContract',1)
        .clickTab('Container')
        .enterGridData('ContainerInformation', 1, 'colContNumber', '1')
        .enterGridData('ContainerInformation', 1, 'colContQuantity', '100')
        .selectGridComboBoxRowValue('ContainerInformation',1,'strUnitMeasure','LB','strUnitMeasure')
        .verifyGridData('ContainerInformation', 1, 'colContGrossWt', '100')
        .verifyGridData('ContainerInformation', 1, 'colContNetWt', '100')
        .verifyGridData('ContainerInformation', 1, 'colContWeightUOM', 'LB')
        .clickButton('Link')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Post')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .clickMenuFolder('Logistics','Folder')

        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Receipts','Screen')
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',1,0)
        .selectComboBoxRowNumber('SourceType',3,0)
        .selectComboBoxRowValue('Vendor', 'The Scoular Company', 'Vendor',1)
        .waitUntilLoaded('')
        .selectSearchRowNumber(1)
        .clickButton('OpenSelected')
        .waitUntilLoaded('icinventoryreceipt')


        .verifyData('Combo Box','ReceiptType','Purchase Contract')
        .verifyData('Combo Box','Vendor','The Scoular Company')
        .verifyData('Combo Box','Currency','USD')
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'LTI - 02')
        .verifyGridData('InventoryReceipt', 1, 'colOrderUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colQtyOrdered', '100')
        .verifyGridData('InventoryReceipt', 1, 'colUOM', 'LB')
        .verifyUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 100, 'LB', 'equal')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strWeightUOM','LB','strWeightUOM')

        .selectGridComboBoxRowValue('InventoryReceipt',1,'strSubLocationName','Raw Station','strSubLocationName')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strStorageLocationName','RM Storage','strStorageLocationName')
        .waitUntilLoaded('')


        .enterGridData('LotTracking', 1, 'colLotId', 'LOT-01')
        .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure','LB','strUnitMeasure')
        .enterGridData('LotTracking', 1, 'colLotQuantity', '100')
        .verifyGridData('LotTracking', 1, 'colLotGrossWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colLotNetWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM', 'LB')
        .verifyGridData('LotTracking', 1, 'colLotStorageLocation', 'RM Storage')

       .addFunction(function (next){
           var win =  Ext.WindowManager.getActive(),
               total = win.down('#txtTotal').value;
           if (total == 1000) {
               t.ok(true, 'Total is correct.');
           }
           else {
               t.ok(false, 'Total is incorrect.');
           }
           next();
       })

        .clickTab('Post Preview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Create Purchase Contract Inventory Receipt for Lotted Item "Add Orders Screen" Done=====')



        //region Scenario 13. Create Purchase Contract Inbound Shipment Inventory Receipt for Non Lotted Item "Add Orders Screen"
        .displayText('=====  Scenario 13. Create Inbound Shipment Purchase Contract Inventory Receipt for Non Lotted Item "Add Orders Screen"  =====')
        .clickMenuFolder('Contract Management','Folder')
        .clickMenuScreen('Contracts','Screen')
        .clickButton('New')
        .waitUntilLoaded('ctcontract')
        .selectComboBoxRowValue('Type', 'Purchase', 'Type',1)
        .selectComboBoxRowValue('Customer', 'The Mill Feed Co.', 'Customer',1)
        .selectComboBoxRowValue('Commodity', 'Corn', 'Commodity',1)
        .enterData('Text Field','Quantity','100')
        .selectComboBoxRowValue('CommodityUOM', 'LB', 'CommodityUOM',1)
        .selectComboBoxRowValue('Position', 'On Shipment', 'Position',1)
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
        .selectComboBoxRowValue('Item', 'NLTI - 02', 'Item',1)
        .selectComboBoxRowValue('NetWeightUOM', 'LB', 'NetWeightUOM',2)
        .verifyData('Text Field','NetWeight','100.0000')
        .verifyData('Combo Box','PricingType','Cash')
        .verifyData('Combo Box','PriceCurrency','USD')
        .verifyData('Combo Box','CashPriceUOM','LB')
        .enterData('Text Field','CashPrice','10')
        .clickButton('Save')
        .waitUntilLoaded('ctcontract')
        .clickButton('Save')
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Contract Management','Folder')

        .clickMenuFolder('Logistics','Folder')
        .clickMenuScreen('Load / Shipment Schedules')
        .clickButton('New')
        .waitUntilLoaded('shipmentschedule')
        .selectComboBoxRowNumber('ShipmentType',1,0)
        .selectComboBoxRowNumber('Type',1,0)
        .selectComboBoxRowNumber('SourceType',2,0)
        .selectComboBoxRowNumber('TransportationMode',2,0)
        .selectComboBoxRowValue('WeightUnit', 'LB', 'WeightUnit',2)
        .selectGridComboBoxRowValue('LoadSchedule',1,'strVendor','The Mill Feed Co.','strVendor')
        .selectGridComboBoxRowValue('LoadSchedule',1,'strPContractNumber','1','strPContractNumber')
        .clickTab('Container')
        .enterGridData('ContainerInformation', 1, 'colContNumber', '1')
        .enterGridData('ContainerInformation', 1, 'colContQuantity', '100')
        .selectGridComboBoxRowValue('ContainerInformation',1,'strUnitMeasure','LB','strUnitMeasure')
        .verifyGridData('ContainerInformation', 1, 'colContGrossWt', '100')
        .verifyGridData('ContainerInformation', 1, 'colContNetWt', '100')
        .verifyGridData('ContainerInformation', 1, 'colContWeightUOM', 'LB')
        .clickButton('Link')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Post')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .clickMenuFolder('Logistics','Folder')

        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Receipts','Screen')
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',1,0)
        .selectComboBoxRowNumber('SourceType',3,0)
        .selectComboBoxRowValue('Vendor', 'The Mill Feed Co.', 'Vendor',1)
        .waitUntilLoaded('')
        .selectSearchRowNumber(1)
        .clickButton('OpenSelected')
        .waitUntilLoaded('icinventoryreceipt')


        .verifyData('Combo Box','ReceiptType','Purchase Contract')
        .verifyData('Combo Box','Vendor','The Mill Feed Co.')
        .verifyData('Combo Box','Currency','USD')
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'NLTI - 02')
        .verifyGridData('InventoryReceipt', 1, 'colOrderUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colQtyOrdered', '100')
        .verifyGridData('InventoryReceipt', 1, 'colUOM', 'LB')
        .verifyUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 100, 'LB', 'equal')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strWeightUOM','LB','strWeightUOM')

        .selectGridComboBoxRowValue('InventoryReceipt',1,'strSubLocationName','Raw Station','strSubLocationName')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strStorageLocationName','RM Storage','strStorageLocationName')
        .waitUntilLoaded('')

       .addFunction(function (next){
           var win =  Ext.WindowManager.getActive(),
               total = win.down('#txtTotal').value;
           if (total == 1000) {
               t.ok(true, 'Total is correct.');
           }
           else {
               t.ok(false, 'Total is incorrect.');
           }
           next();
       })

        .clickTab('Post Preview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Create Purchase Contract Inventory Receipt for Non Lotted Item "Add Orders Screen" Done=====')


        //region Scenario 14. Update Inventory Receipt
        .displayText('=====  Scenario 14. Update Inventory Receipt  =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('Direct', 'strOrderType', 2)
        .waitUntilLoaded('icinventoryreceipt')
        .addResult('Successfully Opened',4000)
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'NLTI - 02')
        .verifyGridData('InventoryReceipt', 1, 'colUOM', 'LB')
        .verifyUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 100000, 'LB', 'equal')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000000')

       .addFunction(function (next){
           var win =  Ext.WindowManager.getActive(),
               total = win.down('#txtTotal').value;
           if (total == 1000000) {
               t.ok(true, 'Total is correct.');
           }
           else {
               t.ok(false, 'Total is incorrect.');
           }
           next();
       })

        .clickButton('Receive')
        .waitUntilLoaded('icinventoryreceipt')
        .addResult('Successfully Unposted',3000)
        .selectComboBoxRowValue('Vendor', 'Frito-Lay', 'Vendor',1)
        .verifyUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 1000, 'LB', 'equal')
        .clickButton('Save')
        .waitUntilLoaded('')

        .verifyData('Combo Box','Vendor','Frito-Lay')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '10000')

       .addFunction(function (next){
           var win =  Ext.WindowManager.getActive(),
               total = win.down('#txtTotal').value;
           if (total == 10000) {
               t.ok(true, 'Total is correct.');
           }
           else {
               t.ok(false, 'Total is incorrect.');
           }
           next();
       })


        .clickTab('Post Preview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '10000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '10000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .doubleClickSearchRowValue('Direct', 'strOrderType', 2)
        .waitUntilLoaded('icinventoryreceipt')
        .addResult('Successfully Opened',3000)
        .verifyData('Combo Box','Vendor','Frito-Lay')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '10000')

       .addFunction(function (next){
           var win =  Ext.WindowManager.getActive(),
               total = win.down('#txtTotal').value;
           if (total == 10000) {
               t.ok(true, 'Total is correct.');
           }
           else {
               t.ok(false, 'Total is incorrect.');
           }
           next();
       })

        .clickButton('Close')
        .waitUntilLoaded('')
        .clearTextFilter('FilterGrid')
        .displayText('===== Update Inventory Receipt Done=====')
        //endregion
        .done();

})
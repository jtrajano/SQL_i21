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


        .displayText('"======== Scenario 1: Create Direct Inventory Receipt for Non Lotted Item. ========"').wait(1000)
        .expandMenu('Inventory').wait(1000)
        .markSuccess('Inventory successfully expanded').wait(500)

        .displayText('"======== #1 Open New Inventory Receipt Screen ========"').wait(500)
        .openScreen('Inventory Receipts').wait(1000)
        .waitTillLoaded('Open Inventory Receipts Search Screen Successful').wait(500)
        .clickButton('#btnNew').wait(1000)
        .waitTillVisible('icinventoryreceipt','Open New Inventory Receipt Screen Successful').wait(1000)

        .selectComboRowByIndex('#cboReceiptType',3).wait(200)
        .selectComboRowByFilter('#cboVendor', 'ABC Trucking', 500, 'strName', 0).wait(200)
        //.selectComboRowByFilter('#cboVendor','0001005057',500, 'intEntityVendorId').wait(500)
        .selectComboRowByIndex('#cboLocation',0).wait(300)
        .selectGridComboRowByFilter('#grdInventoryReceipt', 0, 'strItemNo', 'CORN', 300, 'strItemNo').wait(1000)
        .selectGridComboRowByFilter('#grdInventoryReceipt', 0, 'strUnitMeasure', 'Bushels', 300, 'strUnitMeasure').wait(1000)
        .enterGridData('#grdInventoryReceipt', 0, 'colQtyToReceive', '100').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colItemSubCurrency', 'USD').wait(300)
        .enterGridData('#grdInventoryReceipt', 0, 'colUnitCost', '10').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colCostUOM', 'Bushels').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colWeightUOM', 'Bushels').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colGross', '100').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colNet', '100').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colLineTotal', '1000').wait(500)
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                grid = win.down('#grdInventoryReceipt'),
                total = grid.down('#lblGrossWgt').text;
            if (total == 'Gross: 100.00') {
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
            if (total == 'Net: 100.00') {
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
            if (total == 'Total: 1,000.00') {
                t.ok(true, 'Total is correct.');
            }
            else {
                t.ok(false, 'Total is incorrect.');
            }
            next();
        }).wait(200)
        .clickButton('#btnRecap').wait(300)
        .waitTillLoaded('Open Recap Screen Successful')
        //.checkGridData('#grdRecapTransaction', 0, 'colGross', '100').wait(500)
        //.checkGridData('#grdRecapTransaction', 0, 'colGross', '100').wait(500)
        .clickButton('#btnPost').wait(500)
        .waitTillLoaded('Inventory Post Successful')
        .markSuccess('======== Add Inventory Receipt Successful! ========')

        .done();
});



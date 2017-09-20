StartTest (function (t) {
var record;
var PONumber;

    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)

        /*====================================== Scenario 1: Inventory Receipt Add Orders, Order Type: Purchase Order, Purchase Order Status: Open  ======================================*/
            .addScenario(1,'Inventory Receipt Add Orders, Order Type: Purchase Order, Purchase Order Status: Open',1000)
            .addFunction(function(next){
                record=Math.floor((Math.random() * 1000000) + 1);
                new iRely.FunctionalTest().start(t, next)
                .done()
            })
            .clickMenuFolder('Inventory')

            .addFunction(function(next){
                commonIC.insertInventoryItem(t,next,record)
            })
            .waitUntilLoaded()
            .addFunction(function(next){
                commonIC.createPurchaseOrder(t,next,record)
            })
            .addFunction(function (next) {
                PONumber = Ext.WindowManager.getActive().down('#txtPurchaseOrderNo').rawValue;
                new iRely.FunctionalTest().start(t, next)
                .waitUntilLoaded('appurchaseorder')
                .clickButton('Close')
                .waitUntilLoaded()
                .addFunction(function (next) {
                     commonIC.createInventoryReceipt(t,next,100,true,10)
                })
                .waitUntilLoaded()
                .clickMenuFolder('Inventory')

        /*====================================== Scenario 2: Inventory Receipt Add Orders, Order Type: Purchase Order, Purchase Order Status: Closed  ======================================*/
                .addScenario(2,'Inventory Receipt Add Orders, Order Type: Purchase Order, Purchase Order Status: Closed',1000)

                .clickMenuScreen('Purchase Orders')
                .waitUntilLoaded()
                .doubleClickSearchRowValue(PONumber, 'strPurchaseOrderNumber', 1)
                .waitUntilLoaded('appurchaseorder')
                .verifyData('Combo Box', 'OrderStatus', 'Closed')
                .clickButton('Close')

                .addFunction(function (next) {
                    commonIC.checkIfClosedPOShowsInIR(t,next,PONumber)
                })
               .done()
            })


        /*====================================== Scenario 3: Inventory Receipt Add Orders, Order Type: Purchase Order, Purchase Order Status: Partial ======================================*/
            .addScenario(3,'Inventory Receipt Add Orders, Order Type: Purchase Order, Purchase Order Status: Partial',1000)
            .addFunction(function(next){
                record=Math.floor((Math.random() * 1000000) + 1);
                new iRely.FunctionalTest().start(t, next)
                .done()
            })
            .addFunction(function(next){
                commonIC.insertInventoryItem(t,next,record)
            })
            .clickMenuFolder('Purchasing (Accounts Payable)')
            .addFunction(function(next){
                commonIC.createPurchaseOrder(t,next,record)
            })
            .addFunction(function (next) {
                PONumber = Ext.WindowManager.getActive().down('#txtPurchaseOrderNo').rawValue;
                new iRely.FunctionalTest().start(t, next)
                .clickButton('Close')
                .addFunction(function (next) {
                     commonIC.createInventoryReceipt(t,next,50,true,10)
                })
                .clickMenuScreen('Purchase Orders')
                .waitUntilLoaded()
                .doubleClickSearchRowValue(PONumber, 'strPurchaseOrderNumber', 1)
                .waitUntilLoaded('appurchaseorder')
                .verifyData('Combo Box', 'OrderStatus', 'Partial')
                .clickButton('Close') 
                .clickMenuFolder('Inventory')
                .displayText(PONumber)
        /*====================================== Scenario 4: Inventory Receipt Add Orders, Order Type: Purchase Order, Purchase Order Status: Cancelled======================================*/
                .addScenario(4,'Inventory Receipt Add Orders, Order Type: Purchase Order, Purchase Order Status: Cancelled',1000)
                .addFunction(function (next) {
                    commonIC.checkIfClosedPOShowsInIR(t,next,PONumber)
                })
              .done()
           })

        /*====================================== Scenario 5: Inventory Receipt Add Orders, Order Type: Purchase Order, Purchase Order Status: Pending ======================================*/
            .addScenario(5,'Inventory Receipt Add Orders, Order Type: Purchase Order, Purchase Order Status: Pending',1000)
            .addFunction(function(next){
                record=Math.floor((Math.random() * 1000000) + 1);
                new iRely.FunctionalTest().start(t, next)
                .done()
            })
            .addFunction(function(next){
                commonIC.insertInventoryItem(t,next,record)
            })
            .clickMenuFolder('Purchasing (Accounts Payable)')
            .addFunction(function(next){
                commonIC.createPurchaseOrder(t,next,record)
            })
            .addFunction(function (next) {
                PONumber = Ext.WindowManager.getActive().down('#txtPurchaseOrderNo').rawValue;
                new iRely.FunctionalTest().start(t, next)
                .clickButton('Close')
                .addFunction(function (next) {
                     commonIC.createInventoryReceipt(t,next,100,false,10)
                })
                .clickMenuScreen('Purchase Orders')
                .waitUntilLoaded()
                .doubleClickSearchRowValue(PONumber, 'strPurchaseOrderNumber', 1)
                .waitUntilLoaded('appurchaseorder')
                .verifyData('Combo Box', 'OrderStatus', 'Pending')
                .clickButton('Close') 
                .addFunction(function (next) {
                     commonIC.createInventoryReceipt(t,next,100,true,10)
                })
        /*====================================== Scenario 6: Inventory Receipt Add Orders, Order Type: Purchase Order, Purchase Order Status: Short Closed ======================================*/
                .addScenario(6,'Inventory Receipt Add Orders, Order Type: Purchase Order, Purchase Order Status: Short Closed',1000)
                .clickMenuFolder('Inventory')
                .addFunction(function (next) {
                    commonIC.checkIfClosedPOShowsInIR(t,next,PONumber)
                })
              .done()
           })
        /*====================================== Scenario 7: Inventory Receipt Add Orders, Order Type: Purchase Order, Purchase Order Status: Open, Vendor has no currency setup ======================================*/
            .addScenario(7,'Inventory Receipt Add Orders, Order Type: Purchase Order, Purchase Order Status: Open, Vendor has no currency setup',1000)
            .waitUntilLoaded()
			.clickMenuScreen('Vendors')
			.waitUntilLoaded()
        	.doubleClickSearchRowValue('0001005057', 'strVendorID', 1)
			.waitUntilLoaded()
            .clickTab('Vendor')
            .waitUntilLoaded()
            .selectComboBoxRowValue('VendorCurrency', '[BACKSPACE]', 'intCurrencyId') 
            .clickButton('Save')
            .waitUntilLoaded()
            .clickButton('Close')
            .waitUntilLoaded()
            .addFunction(function(next){
                record=Math.floor((Math.random() * 1000000) + 1);
                new iRely.FunctionalTest().start(t, next)
                .done()
            })
           .addFunction(function(next){
                commonIC.insertInventoryItem(t,next,record)
            })
            .clickMenuFolder('Purchasing (Accounts Payable)')
            .addFunction(function(next){
                commonIC.createPurchaseOrder(t,next,record)
            })
            .addFunction(function (next) {
                PONumber = Ext.WindowManager.getActive().down('#txtPurchaseOrderNo').rawValue;
                new iRely.FunctionalTest().start(t, next)
                .clickButton('Close')     
                .addFunction(function (next) {
                     commonIC.createInventoryReceipt(t,next,100,true,10)
                })
                .clickMenuFolder('Inventory')
                .displayText(PONumber)
               .done()
            })
 
        .done();

})
StartTest (function (t) {
var record;
var PONumber;

    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)
                  
             
            .addScenario(1,'',1000)
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
                     commonIC.createInventoryReceipt(t,next,100,true)
                })
                .waitUntilLoaded()  
                .clickMenuFolder('Inventory')
                

                .addScenario(2,'',1000)

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



            .addScenario(3,'',1000)
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
                     commonIC.createInventoryReceipt(t,next,50,true)
                })
                .clickMenuScreen('Purchase Orders')
                .waitUntilLoaded()
                .doubleClickSearchRowValue(PONumber, 'strPurchaseOrderNumber', 1)
                .waitUntilLoaded('appurchaseorder')
                .verifyData('Combo Box', 'OrderStatus', 'Partial')
                .clickButton('Close') 
                .clickMenuFolder('Inventory')
                .displayText(PONumber)
                .addScenario(4,'',1000)
                .addFunction(function (next) {
                    commonIC.checkIfClosedPOShowsInIR(t,next,PONumber)
                })
              .done()
           })
           

            .addScenario(5,'',1000)
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
                     commonIC.createInventoryReceipt(t,next,100,false)
                })
                .clickMenuScreen('Purchase Orders')
                .waitUntilLoaded()
                .doubleClickSearchRowValue(PONumber, 'strPurchaseOrderNumber', 1)
                .waitUntilLoaded('appurchaseorder')
                .verifyData('Combo Box', 'OrderStatus', 'Pending')
                .clickButton('Close') 
                .addFunction(function (next) {
                     commonIC.createInventoryReceipt(t,next,100,true)
                })
                .addScenario(6,'',1000)
                .clickMenuFolder('Inventory')
                .addFunction(function (next) {
                    commonIC.checkIfClosedPOShowsInIR(t,next,PONumber)
                })
              .done()
           })
            .addScenario(7,'',1000)
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
                     commonIC.createInventoryReceipt(t,next,100,true)
                })
                .clickMenuFolder('Inventory')
                .displayText(PONumber)
               .done()
            })
 
        .done();

})
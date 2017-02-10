StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)


        //Scenario 3: Check Gross/Net UOM and Line Total where Receipt UOM and Gross/Net UOM is the same
        .displayText('===== Scenario 3: Check Gross/Net UOM and Line Total where Receipt UOM and Gross/Net UOM is the same =====')
        .addFunction(function(next){
            commonIC.addDirectIRLotted (t,next, 4, 1, 'Direct - LTI - 01','LB', 1000, 10, 'Raw Station', 'RM Storage', 'LOT-01', 'LB')
        })


        //Create Direct IR for Non Lotted Item
        .displayText('===== Scenario 2: Create Direct IR for Non Lotted Item =====')
        .addFunction(function(next){
            commonIC.addDirectIRNonLotted (t,next, 4, 1, 'Direct - NLTI - 01','LB', 1000, 10)
        })





        .done();

})
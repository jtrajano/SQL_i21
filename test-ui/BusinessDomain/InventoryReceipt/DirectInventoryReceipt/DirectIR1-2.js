StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)

        //Create Direct IR for Lotted Item
        .displayText('===== Scenario 1: Create Direct IR for Lotted Item =====')
        .addFunction(function(next){
            commonIC.addDirectIRLotted (t,next, 'ABC Trucking', 1, 'Direct - LTI - 01','LB', 100, 10, 'Raw Station', 'RM Storage', 'LOT-01', 'LB')
        })
        .displayText('===== Adding Stocks to Created Done =====')


        //Create Direct IR for Non Lotted Item
        .displayText('===== Scenario 2: Create Direct IR for Non Lotted Item =====')
        .addFunction(function(next){
            commonIC.addDirectIRNonLotted (t,next, 'ABC Trucking', 1, 'Direct - NLTI - 01','LB', 100, 10)
        })


        .done();

})
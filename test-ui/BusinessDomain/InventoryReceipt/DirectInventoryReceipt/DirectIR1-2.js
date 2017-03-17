StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)


        //Presetup Create Lotted and Non Lotted Item
        //Add Non Lotted Item
        .addFunction(function(next){
            commonIC.addInventoryItem
            (t,next,
                'Direct - NLTI - 01'
                , 'Test Non Lotted Item Description'
                , 'Category-1'
                , 'Commodity-1'
                ,4
                , 'LB'
                , 'LB'
                , 10
                , 10
                , 40
            )
        })


        //Add Lotted Item - Manual
        .addFunction(function(next){
            commonIC.addInventoryItem
            (t,next,
                'Direct - LTI - 01'
                , 'Test Non Lotted Item Description'
                , 'Category-1'
                , 'Commodity-1'
                , 3
                , 'LB'
                , 'LB'
                , 10
                , 10
                , 40
            )
        })

        //Create Direct IR for Lotted Item
        .displayText('===== Scenario 1: Create Direct IR for Lotted Item =====')
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
StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)


        //region

        //Add Category
        .addFunction(function(next){
            commonIC.addCategory (t,next, 'Category-1', 'Test Category Description', 2)
        })

        //Add Commodity
        .addFunction(function(next){
            commonIC.addCommodity (t,next, 'Commodity-1', 'Test Commodity Description')
        })

        //Add Non Lotted Item
        .addFunction(function(next){
            commonIC.addInventoryItem
            (t,next,
                'Test - LTI - 01'
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

        //Add Lotted Item - Manual
        .addFunction(function(next){
            commonIC.addInventoryItem
            (t,next,
                'Test - NLTI - 01'
                , 'Test Lotted Item Description'
                , 'Grains'
                , 'Corn'
                , 4
                , 'LB'
                , 'LB'
                , 10
                , 10
                , 40
            )
        })

        //Adding Stock to Items
        .displayText('===== Adding Stocks to Created items =====')
        .addFunction(function(next){
            commonIC.addDirectIRNonLotted (t,next, 'ABC Trucking', 1, 'Test - NLTI - 01','LB', 1000, 10)
        })

        .addFunction(function(next){
            commonIC.addDirectIRLotted (t,next, 'ABC Trucking', 1, 'Test - LTI - 01','LB', 1000, 10, 'Raw Station', 'RM Storage', 'LOT-01', 'LB')
        })
        .displayText('===== Adding Stocks to Created Done =====')


        .displayText('===== Pre-setup done =====')

        //endregion



        .done();

})
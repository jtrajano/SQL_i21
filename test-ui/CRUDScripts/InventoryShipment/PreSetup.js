StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)

        //region Preseteup

        //Add Category
        .addFunction(function(next){
            commonIC.addCategory (t,next, 'TestGrains2', 'Test Category Description', 2)
        })

        .displayText('=== Creating Commodity ===')
        .addFunction(function(next){
            commonIC.addCommodity (t,next, 'TestCorn2', 'Test Commodity Description')
        })
        .displayText('=== Commodity Created ===')

        //Add Non Lotted Item
        .addFunction(function(next){
            commonIC.addInventoryItem
            (t,next,
                'ISNLTI - 01'
                , 'Test Non Lotted Item Description'
                , 'TestGrains2'
                , 'TestCorn2'
                , 4
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
                'ISLTI - 01'
                , 'Test Lotted Item Description'
                , 'TestGrains2'
                , 'TestCorn2'
                , 3
                , 'LB'
                , 'LB'
                , 10
                , 10
                , 40
            )
        })

        //Add Non Lotted Item
        .addFunction(function(next){
            commonIC.addInventoryItem
            (t,next,
                'ISDNLTI - 01'
                , 'Test Non Lotted Item Description'
                , 'TestGrains2'
                , 'TestCorn'
                , 4
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
                'ISDLTI - 01'
                , 'Test Lotted Item Description'
                , 'TestGrains2'
                , 'TestCorn'
                , 3
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
            commonIC.addDirectIRNonLotted (t,next, 'ABC Trucking', 1, 'ISNLTI - 01','LB', 10000, 10)
        })

        .addFunction(function(next){
            commonIC.addDirectIRLotted (t,next, 'ABC Trucking', 1, 'ISLTI - 01','LB', 10000, 10, 'Raw Station', 'RM Storage', 'LOT-01', 'LB')
        })
        .displayText('===== Adding Stocks to Created Done =====')


        .displayText('===== Pre-setup done =====')


        //endregion

        .done();

})
//endregion
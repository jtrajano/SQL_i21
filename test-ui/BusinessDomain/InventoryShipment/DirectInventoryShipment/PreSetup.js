StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)

        //region Preseteup

        //Add Category
        .addFunction(function(next){
            commonIC.addCategory (t,next, 'TestGrains3', 'Test Category Description', 2)
        })

        .displayText('=== Creating Commodity ===')
        .addFunction(function(next){
            commonIC.addCommodity (t,next, 'TestCorn3', 'Test Commodity Description')
        })
        .displayText('=== Commodity Created ===')

        //Add Non Lotted Item - Negative Inventory NO
        .addFunction(function(next){
            commonIC.addInventoryItem
            (t,next,
                'DS - NLTI - 01'
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

        //Add Lotted Item - Manual - Negative Inventory NO
        .addFunction(function(next){
            commonIC.addInventoryItem
            (t,next,
                'DS - LTI - 01'
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

        //Add Non Lotted Item - Negative Inventory Yes
        .addFunction(function(next){
            commonIC.addInventoryItemNegative
            (t,next,
                'DS - NLTI - 02'
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

        //Add Lotted Item - Manual - Negative Inventory Yes
        .addFunction(function(next){
            commonIC.addInventoryItemNegative
            (t,next,
                'DS - LTI - 02'
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

        //Receive Non Lotted Item 1
        .displayText('===== Receive Non Lotted Item 1 =====')
        .addFunction(function(next){
            commonIC.addDirectIRNonLotted (t,next, 'ABC Trucking', 1, 'DS - NLTI - 01','LB', 10000, 10)
        })
        .displayText('===== Receive Non Lotted Item 1 Done =====')


        //Receive Non Lotted Item 2
        .displayText('===== Receive Non Lotted Item 2 =====')
        .addFunction(function(next){
            commonIC.addDirectIRNonLotted (t,next, 'ABC Trucking', 1, 'DS - NLTI - 02','LB', 10000, 10)
        })
        .displayText('===== Receive Non Lotted Item 2 Done =====')


        //Receive Lotted Item 1
        .displayText('===== Receive Lotted Item 1 =====')
        .addFunction(function(next){
            commonIC.addDirectIRLotted (t,next, 'ABC Trucking', 1, 'DS - LTI - 01','LB', 10000, 10, 'Raw Station', 'RM Storage', 'LOT-01', 'LB')
        })
        .displayText('===== Adding Stocks to Created Done =====')
        .displayText('===== Receive Lotted Item 1 Done =====')


        //Receive Lotted Item 2
        .displayText('===== Receive Lotted Item 2 =====')
        .addFunction(function(next){
            commonIC.addDirectIRLotted (t,next, 'ABC Trucking', 1, 'DS - LTI - 02','LB', 10000, 10, 'Raw Station', 'RM Storage', 'LOT-01', 'LB')
        })
        .displayText('===== Adding Stocks to Created Done =====')
        .displayText('===== Receive Lotted Item 2 Done =====')


        .displayText('===== Pre-setup done =====')


        //endregion

        .done();

})
//endregion
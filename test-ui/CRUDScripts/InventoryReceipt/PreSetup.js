StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)

        //region Preseteup

        //Add Category
        .addFunction(function(next){
            commonIC.addCategory (t,next, 'TestGrains', 'Test Category Description', 2)
        })


        .displayText('=== Creating Commodity ===')
        .addFunction(function(next){
            commonIC.addCommodity (t,next, 'TestCorn', 'Test Commodity Description')
        })
        .displayText('=== Commodity Created ===')

        //Add Non Lotted Item
        .addFunction(function(next){
            commonIC.addInventoryItem
            (t,next,
                'NLTI - 100'
                , 'Test Non Lotted Item Description'
                , 'TestGrains'
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
                'LTI - 100'
                , 'Test Lotted Item Description'
                , 'TestGrains'
                , 'TestCorn'
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
                'DNLTI - 02'
                , 'Test Non Lotted Item Description'
                , 'TestGrains'
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
                'DLTI - 02'
                , 'Test Lotted Item Description'
                , 'TestGrains'
                , 'TestCorn'
                , 3
                , 'LB'
                , 'LB'
                , 10
                , 10
                , 40
            )
        })
        //endregion

        .done();

})
//endregion
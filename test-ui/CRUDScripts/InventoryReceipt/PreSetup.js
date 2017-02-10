StartTest (function (t) {
    new iRely.FunctionalTest().start(t)


        //region Preseteup
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
                , 'Grains'
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
                , 'Grains'
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
                'DNLTI - 01'
                , 'Test Non Lotted Item Description'
                , 'Grains'
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
                'DLTI - 01'
                , 'Test Lotted Item Description'
                , 'Grains'
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
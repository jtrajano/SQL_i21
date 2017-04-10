StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)


        //Presetup

        //Add Category
        .displayText('===== Create Category =====')
        .addFunction(function(next){
            commonIC.addCategory (t,next, 'DIR - Category', 'Test Category Description', 2)
        })
        .displayText('===== Create Category Done =====')

        //Add Commodity
        .displayText('===== Create Commodity =====')
        .addFunction(function(next){
            commonIC.addCommodity (t,next, 'DIR - Commodity', 'Test Commodity Description')
        })
        .displayText('===== Create Commodity Done =====')


        //Add Non Lotted Item
        .displayText('===== Create Non Lotted Item =====')
        .addFunction(function(next){
            commonIC.addInventoryItem
            (t,next,
                'Direct - NLTI - 01'
                , 'Test Non Lotted Item Description'
                , 'DIR - Category'
                , 'DIR - Commodity'
                , 4
                , 'LB'
                , 'LB'
                , 10
                , 10
                , 40
            )
        })
        .displayText('===== Create Non Lotted Item Done =====')

        //Add Lotted Item - Manual
        .displayText('===== Create Lotted Item =====')
        .addFunction(function(next){
            commonIC.addInventoryItem
            (t,next,
                'Direct - LTI - 01'
                , 'Test Lotted Item Description'
                , 'DIR - Category'
                , 'DIR - Commodity'
                , 3
                , 'LB'
                , 'LB'
                , 10
                , 10
                , 40
            )
        })
        .displayText('===== Create Non Lotted Item Done =====')

        .done();

})
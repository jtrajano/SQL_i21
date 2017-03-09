StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)


        //region

//        //Add Category
//        .addFunction(function(next){
//            commonIC.addCategory (t,next, 'Category-2', 'Test Category Description', 2)
//        })
//
//        //Add Commodity
//        .addFunction(function(next){
//            commonIC.addCommodity (t,next, 'Commodity-2', 'Test Commodity Description')
//        })

//        //Add Non Lotted Item
//        .addFunction(function(next){
//            commonIC.addInventoryItem
//            (t,next,
//                'Test - LTI - 02'
//                , 'Test Non Lotted Item Description'
//                , 'Category-2'
//                , 'Commodity-2'
//                , 3
//                , 'LB'
//                , 'LB'
//                , 10
//                , 10
//                , 40
//            )
//        })
//
//        //Add Lotted Item - Manual
//        .addFunction(function(next){
//            commonIC.addInventoryItem
//            (t,next,
//                'Test - NLTI - 02'
//                , 'Test Lotted Item Description'
//                , 'Category-2'
//                , 'Commodity-2'
//                , 4
//                , 'LB'
//                , 'LB'
//                , 10
//                , 10
//                , 40
//            )
//        })

        //Adding Stock to Items
        .displayText('===== Adding Stocks to Created items =====')
        .addFunction(function(next){
            commonIC.addDirectIRNonLotted (t,next, 'ABC Trucking', 1, 'Test - NLTI - 02','LB', 1000, 10)
        })

        .addFunction(function(next){
            commonIC.addDirectIRLotted (t,next, 'ABC Trucking', 1, 'Test - LTI - 02','LB', 1000, 10, 'Raw Station', 'RM Storage', 'LOT-01', 'LB')
        })
        .displayText('===== Adding Stocks to Created Done =====')


        .displayText('===== Pre-setup done =====')

        //endregion



        .done();

})
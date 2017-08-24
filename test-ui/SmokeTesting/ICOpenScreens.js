StartTest (function (t) {
    var commonICST = Ext.create('Inventory.CommonICSmokeTest');
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)


        /*====================================== IC Open Screens  ======================================*/
        //region
        .displayText('===== Opening IC Screens ====')
        .addFunction(function(next){
            commonICST.openICScreens (t,next)
        })
        //endregion


        .done();

})
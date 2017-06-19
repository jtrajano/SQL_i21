StartTest (function (t) {
    var commonICST = Ext.create('Inventory.CommonICSmokeTest');
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)


        /*====================================== Open IC Screens ======================================*/
        //region
        .displayText('===== Scenario 1. Opening IC Screens ====')
        .addFunction(function(next){
            commonICST.openICScreens (t,next)
        })


        .done();

})
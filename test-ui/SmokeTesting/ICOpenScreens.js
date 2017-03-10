StartTest (function (t) {
    var commonICST = Ext.create('Inventory.CommonICSmokeTest');
    new iRely.FunctionalTest().start(t)

                //Open IC Screens
        .addFunction(function(next){
            commonICST.openICScreens (t,next)
        })

        .done();

})
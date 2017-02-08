StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)

                //Open IC Screens
        .addFunction(function(next){
            commonIC.openICScreens (t,next)
        })

        .done();

})
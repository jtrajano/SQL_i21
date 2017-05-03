var karmaLoadedFunction = window.__karma__.loaded;
    window.__karma__.loaded = function () {
};


// @require @packageOverrides
Ext.Loader.setConfig({
    enabled: true,
    paths: {
        i21: 'test/api/SystemManager/app',
        GlobalComponentEngine: 'test/api/GlobalComponentEngine/app',
        Dashboard: 'test/api/Dashboard/app',
        SystemManager: 'test/api/SystemManager/app',
        GeneralLedger: 'test/api/GeneralLedger/app'
    }
});

//noinspection JSHint
var app;

Ext.application({
    requires: [
        'Ext.Loader'
    ],
    name: 'i21',
    launch: function() {
        //noinspection JSHint
        app = this;

        Ext.onReady(function(){
            // Wait for Ext to be ready before running the karma test suite.
            window.__karma__.loaded = karmaLoadedFunction;
            window.__karma__.loaded();
            window.__karma__.start();
        });
    }

});
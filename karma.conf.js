// Karma configuration
// Generated on Thu Aug 18 2016 11:21:34 GMT+0800 (China Standard Time)

var extJs = [
    {pattern: '../resources/extjs/ext-6.0.2/build/ext-all.js', watched: false},
    {pattern: '../resources/extjs/ext-6.0.2/build/packages/charts/modern/charts.js', watched: false},
    //{pattern: 'app.js', watched: false },

    // load the override for Ext.data.Connection.
    {pattern: '../resources/test/override/Ext.data.Connection.js', watched: false},

    // Load the MICR CSS and font
    {pattern: '../resources/font/micrfont/!*.*', included: false, watched: false, served: true},
    {pattern: '../resources/font/micr.css', watched: false},


     // Load the application dependencies, similar on how SM did it.
     {pattern: '../SystemManager/app/controller/UtilityManager.js', watched: false},
     {pattern: '../SystemManager/app/controller/PreferenceManager.js', watched: false},
     {pattern: '../SystemManager/app/controller/ModuleManager.js', watched: false},
     {pattern: '../SystemManager/app/controller/Module.js', watched: false},
     {pattern: '../SystemManager/app/model/*.js', watched: false},
     {pattern: '../SystemManager/app/store/*.js', watched: false},
     {pattern: '../SystemManager/app/data/validator/*.js', watched: false},

     {pattern: '../GlobalComponentEngine/iRely/BaseEntity.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/model/EntityCredential.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/model/EntityToContact.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/model/EntityLocation.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/model/EntityNote.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/model/Entity.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/model/EntityContact.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/Functions.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/preference/Manager.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/Messages.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/Configuration.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/Exporter.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/writer/JsonBatch.js', watched: false},

     {pattern: '../resources/js/deft/deft.js', watched: false},
     {pattern: '../resources/js/filesaver/filesaver.js', watched: false},
     {pattern: '../resources/js/ux/moment/moment-min.js', watched: false},
     {pattern: '../resources/js/ux/async.js', watched: false},

    // Load Base 64 js
    {pattern: '../resources/js/fn/Base64.js', watched: false},
];
var inventoryFiles = [
    { pattern: 'app/model/**/*.js', watched: true },
    { pattern: 'app/store/**/*.js', watched: true },
    { pattern: 'app/controller/**/*.js', watched: true },
    { pattern: 'app/view/**/*.js', watched: true }
];

var testFiles = [
    {pattern: 'test/specs/**/*.js', watched: true}
];

var libs = [
    {pattern: 'app/lib/**/*.js', watched: true }
];

var files = libs.concat(extJs).concat(inventoryFiles).concat(testFiles);

module.exports = function (config) {
    config.set({

        // base path that will be used to resolve all patterns (eg. files, exclude)
        basePath: '',


        // frameworks to use
        // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
        // 'jasmine',
        frameworks: ['mocha', 'chai'],


        // list of files / patterns to load in the browser
        files: files,


        // list of files to exclude
        exclude: [],


        // preprocess matching files before serving them to the browser
        // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
        preprocessors: {},


        // test results reporter to use
        // possible values: 'dots', 'progress'
        // available reporters: https://npmjs.org/browse/keyword/karma-reporter
        reporters: ['progress', 'coverage'],


        // web server port
        port: 9876,


        // enable / disable colors in the output (reporters and logs)
        colors: true,


        // level of logging
        // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
        logLevel: config.LOG_INFO,


        // enable / disable watching file and executing tests whenever any file changes
        autoWatch: true,


        // start these browsers
        // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
        browsers: ['PhantomJS'],


        // Continuous Integration mode
        // if true, Karma captures browsers, runs the tests and exits
        singleRun: false,

        // Concurrency level
        // how many browser should be started simultaneous
        concurrency: Infinity
    });
};


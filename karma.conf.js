var libFiles = [
    { pattern: 'app/lib/rx.all.js', watched: true },
    { pattern: 'app/lib/numeraljs/numeral.js', watched: true },
    { pattern: 'app/lib/underscore.js', watched: true }
];

var dependencies = require('./test/dependencies.js');

var mockFiles = [
    {pattern: 'test/mock/**/*.js', watched: true}
];

var testFiles = [
    { pattern: 'node_modules/extjs-spec-generator/src/UnitTestEngine.js', watched: true },
    {pattern: 'test/specs/inventory-receipt.viewcontroller.spec.js', watched: true}
];

var files = libFiles.concat(dependencies.frameworkFiles).concat(mockFiles).concat(dependencies.files).concat(testFiles);

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
       //preprocessors: { 'app/**/*.js': ['coverage'] },


        // test results reporter to use
        // possible values: 'dots', 'progress'
        // available reporters: https://npmjs.org/browse/keyword/karma-reporter
        reporters: ['mocha'],


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


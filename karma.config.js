var libFiles = [
    { pattern: 'app/lib/rx.all.js', watched: true },
    { pattern: 'app/lib/numeraljs/numeral.js', watched: true },
    { pattern: 'app/lib/underscore.js', watched: true },
    { pattern: 'node_modules/extjs-spec-generator/src/UnitTestEngine.js', watched: true }
];

var mainAppFiles = [
    //{ pattern: 'test/app.js', watched: true }
];

var dependencies = require('./test/dependencies.js');

var testFiles = [
    { pattern: 'test/specs/inventory-receipt.viewcontroller.spec.js', watched: true }
];

var files = dependencies.frameworkFiles.concat(libFiles).concat(dependencies.files).concat(mainAppFiles).concat(testFiles);

module.exports = function (config) {
    config.set({
        basePath: '',
        frameworks: ['mocha', 'chai'],
        files: files,
        exclude: [],
        reporters: ['mocha'],
        browsers: ['PhantomJS'],
        port: 9876,
        colors: true,
        logLevel: config.LOG_INFO,
        autoWatch: true,
        singleRun: false,
        concurrency: Infinity
    });
};
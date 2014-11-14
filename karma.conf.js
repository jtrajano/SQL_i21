/**
 * Created by LZabala on 9/10/2014.
 */
var ExternalModuleFiles = [
    {pattern: '../i21_SystemManager/app/model/Country.js', watched: false},
    {pattern: '../i21_SystemManager/app/store/CountryBuffered.js', watched: false},
    {pattern: '../i21_SystemManager/app/model/ZipCode.js', watched: false},
    {pattern: '../i21_SystemManager/app/store/ZipCodeBuffered.js', watched: false},
    {pattern: '../i21_SystemManager/app/model/CompanyLocation.js', watched: false},
    {pattern: '../i21_SystemManager/app/store/CompanyLocationBuffered.js', watched: false},
    {pattern: '../i21_SystemManager/app/model/FreightTerm.js', watched: false},
    {pattern: '../i21_SystemManager/app/store/FreightTermsBuffered.js', watched: false},

    {pattern: '../i21_accountsreceivable/app/model/CustomerBuffered.js', watched: false},
    {pattern: '../i21_accountsreceivable/app/store/CustomerBuffered.js', watched: false},


    {pattern: '../i21_accountspayable/app/Util.js', watched: false},
    {pattern: '../i21_accountspayable/app/Configurations.js', watched: false},
    {pattern: '../i21_accountspayable/app/rest/RestBufferedBase.js', watched: false},
    {pattern: '../i21_accountspayable/app/common/Filter.js', watched: false},
    {pattern: '../i21_accountspayable/app/model/VendorToContact.js', watched: false},
    {pattern: '../i21_accountspayable/app/model/VendorHistory.js', watched: false},
    {pattern: '../i21_accountspayable/app/model/Vendor.js', watched: false},
    {pattern: '../i21_accountspayable/app/store/BufferedBase.js', watched: false},
    {pattern: '../i21_accountspayable/app/store/VendorBuffered.js', watched: false},

    {pattern: '../i21_generalledger/app/model/AccountId.js', watched: false},
    {pattern: '../i21_generalledger/app/store/BufAccountId.js', watched: false},

    {pattern: '../GlobalComponentEngine/irely/container/ImageContainer.js', watched: false},
];

var InventoryFiles = [
//    // Load the mock data and config.
//    {pattern: 'test/json/*.json', included: false, watched: false, served: true},
//    {pattern: 'test/mock.data.conf.js', watched: false},
//
    // Load the Inventory dependencies

    {pattern: 'app/view/Filter1ViewModel.js', watched: false},
    {pattern: 'app/view/StatusBar1ViewModel.js', watched: false},
    {pattern: 'app/view/StatusBarPaging1ViewModel.js', watched: false},
    {pattern: 'app/view/Filter1.js', watched: false},
    {pattern: 'app/view/StatusBar1.js', watched: false},
    {pattern: 'app/view/StatusBarPaging1.js', watched: false},

    {pattern: 'app/model/CommodityAccount.js', watched: false},
    {pattern: 'app/model/CommodityClass.js', watched: false},
    {pattern: 'app/model/CommodityGrade.js', watched: false},
    {pattern: 'app/model/CommodityOrigin.js', watched: false},
    {pattern: 'app/model/CommodityProductType.js', watched: false},
    {pattern: 'app/model/CommodityProductLine.js', watched: false},
    {pattern: 'app/model/CommodityRegion.js', watched: false},
    {pattern: 'app/model/CommoditySeason.js', watched: false},
    {pattern: 'app/model/CommodityUnitMeasure.js', watched: false},

    {pattern: 'app/model/CategoryLocation.js', watched: false},
    {pattern: 'app/model/CategoryAccount.js', watched: false},
    {pattern: 'app/model/CategoryVendor.js', watched: false},

    {pattern: 'app/model/ItemKitDetail.js', watched: false},
    {pattern: 'app/model/ItemKit.js', watched: false},
    {pattern: 'app/model/ItemAccount.js', watched: false},
    {pattern: 'app/model/ItemPricing.js', watched: false},
    {pattern: 'app/model/ItemPricingLevel.js', watched: false},
    {pattern: 'app/model/ItemSpecialPricing.js', watched: false},
    {pattern: 'app/model/ItemStock.js', watched: false},
    {pattern: 'app/model/ItemAssembly.js', watched: false},
    {pattern: 'app/model/ItemBundle.js', watched: false},
    {pattern: 'app/model/ItemNote.js', watched: false},
    {pattern: 'app/model/ItemCertification.js', watched: false},
    {pattern: 'app/model/ItemContractDocument.js', watched: false},
    {pattern: 'app/model/ItemContract.js', watched: false},
    {pattern: 'app/model/ItemUOM.js', watched: false},
    {pattern: 'app/model/ItemManufacturingUOM.js', watched: false},
    {pattern: 'app/model/ItemPOSSLA.js', watched: false},
    {pattern: 'app/model/ItemPOSCategory.js', watched: false},
    {pattern: 'app/model/ItemLocation.js', watched: false},
    {pattern: 'app/model/ItemUPC.js', watched: false},
    {pattern: 'app/model/ItemVendorXref.js', watched: false},
    {pattern: 'app/model/ItemCustomerXref.js', watched: false},

    {pattern: 'app/model/ReceiptItemLot.js', watched: false},
    {pattern: 'app/model/ReceiptItemTax.js', watched: false},
    {pattern: 'app/model/ReceiptItem.js', watched: false},
    {pattern: 'app/model/ReceiptInspection.js', watched: false},
    {pattern: 'app/model/ReceiptItemLot.js', watched: false},
    {pattern: 'app/model/ReceiptItemTax.js', watched: false},

    {pattern: 'app/model/UnitMeasureConversion.js', watched: false},
    {pattern: 'app/model/FuelTaxClassProductCode.js', watched: false},
    {pattern: 'app/model/ManufacturingCellPackType.js', watched: false},
    {pattern: 'app/model/PackTypeDetail.js', watched: false},
    {pattern: 'app/model/CertificationCommodity.js', watched: false},
    {pattern: 'app/model/Certification.js', watched: false},
    {pattern: 'app/model/Document.js', watched: false},

    {pattern: 'app/model/*.js', watched: false},
    {pattern: 'app/store/*.js', watched: false},
//    {pattern: 'app/view/override/*ViewModel.js', watched: false},
//    {pattern: 'app/view/override/*.js', watched: false},
    {pattern: 'app/view/*ViewModel.js', watched: false},
    {pattern: 'app/view/*ViewController.js', watched: false},
    {pattern: 'app/view/*.js', watched: false},

    // Load the test/app.js (similar to how we call it in SM's app.js)
    {pattern: 'test/app.js', watched: false},

    // Load the Unit test files
    {pattern: 'test/view/*.js', watched: false}

];

var resources = require('../resources/karma.dependencies.js');
var dependencyFiles = resources.getDependencyFiles();

var externalFiles = dependencyFiles.concat(ExternalModuleFiles);

var files = externalFiles.concat(InventoryFiles);

module.exports = function(config) {
    "use strict";

    config.set({
        // base path that will be used to resolve all patterns (eg. files, exclude)
        basePath: '',

        // frameworks to use
        // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
        frameworks: ['mocha', 'sinon-chai'],

        plugins: ['karma-mocha', 'karma-chai', 'karma-phantomjs-launcher', 'karma-sinon-chai', 'karma-coverage', 'karma-junit-reporter'],

        // list of files / patterns to load in the browser
        files: files,

        // list of files to exclude
        exclude: [],

        // preprocess matching files before serving them to the browser
        // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
        preprocessors: {
//            'app/common/*.js': ['coverage'],
//            'app/controller/*.js': ['coverage']
        },

        coverageReporter: {
            type: 'html',
            dir: 'coverage/'
        },

        // test results reporter to use
        // possible values: 'dots', 'progress'
        // available reporters: https://npmjs.org/browse/keyword/karma-reporter
        reporters: ['dots', 'junit'],

        junitReporter: {
            outputFile: 'test-results.xml',
            suite: 'Cash Management Unit Test Results'
        },

        // web server port
        port: 9018,

        // enable / disable colors in the output (reporters and logs)
        colors: true,

        // level of logging
        // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
        logLevel: config.LOG_INFO,

        // enable / disable watching file and executing tests whenever any file changes
        autoWatch: false,

        // start these browsers
        // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
        //browsers: ['Chrome'],
        browsers: ['PhantomJS'],

        // Continuous Integration mode
        // if true, Karma captures browsers, runs the tests and exits
        singleRun: true,

        //Timeout for capturing a browser (in ms). Default is 60000 (1 minute)
        captureTimeout: 60000,

        //How long does Karma wait for a message from a browser before disconnecting it (in ms). Default is 10000
        browserNoActivityTimeout: 30000
    });
};
// Karma configuration
// Generated on Thu Aug 18 2016 11:21:34 GMT+0800 (China Standard Time)

var extJs = [
    { pattern: '../i21_resources/extjs/ext-6.0.2/build/ext-all.js', watched: false },
    { pattern: '../i21_resources/extjs/ext-6.0.2/build/packages/charts/modern/charts.js', watched: false },
    { pattern: 'app.js', watched: false },

    // load the override for Ext.data.Connection.
    { pattern: '../i21_resources/test/override/Ext.data.Connection.js', watched: false },

    // Load the Ext.ux.ajax.SimManager components. This is used in mocking data using the Ext JS's simlet.
    { pattern: '../i21_resources/test/ux/Simlet.js', watched: false },
    { pattern: '../i21_resources/test/ux/SimXhr.js', watched: false },
    { pattern: '../i21_resources/test/ux/DataSimlet.js', watched: false },
    { pattern: '../i21_resources/test/ux/JsonSimlet.js', watched: false },
    { pattern: '../i21_resources/test/ux/XmlSimlet.js', watched: false },
    { pattern: '../i21_resources/test/ux/SimManager.js', watched: false },

    // Load the JQuery
    { pattern: '../i21_resources/js/jquery/jQuery2.1.0.js', watched: false },
    { pattern: '../i21_resources/js/jquery/jQueryMigrate1.2.1.js', watched: false },
    { pattern: '../i21_resources/js/jquery/jquery.signalR-2.0.2.js', watched: false },

    // Load the LinqJS
    { pattern: '../i21_resources/js/linqJs/linqJs.js', watched: false },

    // Load the Pivot Grid
    { pattern: '../i21_resources/js/ux/mzPivotGrid/overrides/util/Format.js', watched: false },
    { pattern: '../i21_resources/js/ux/mzPivotGrid/mzPivotGrid.css', watched: false },

    // Load the CSS, images, and icons.
    { pattern: '../i21_resources/themes/modern/6.0.2/i21-classic-theme-all.css', watched: false },
    { pattern: '../i21_resources/js/ux/css/Dashboard.css', watched: false },
    { pattern: '../i21_resources/images/images.css', watched: false },
    { pattern: '../i21_resources/js/ux/redactor/css/redactor.css', watched: false },
    { pattern: '../i21_resources/js/ux/redactor/css/clips.css', watched: false },
    { pattern: '../i21_resources/!**!/!*.gif', included: false, watched: false, served: true },
    { pattern: '../i21_resources/!**!/!*.png', included: false, watched: false, served: true },

    // Load the MICR CSS and font
    { pattern: '../i21_resources/font/micrfont/!*.*', included: false, watched: false, served: true },
    { pattern: '../i21_resources/font/micr.css', watched: false },


    // Load the application dependencies, similar on how SM did it.
    { pattern: '../121_systemmanager/app/controller/UtilityManager.js', watched: false },
    { pattern: '../121_systemmanager/app/controller/PreferenceManager.js', watched: false },
    { pattern: '../121_systemmanager/app/controller/ModuleManager.js', watched: false },
    { pattern: '../121_systemmanager/app/controller/Module.js', watched: false },
    { pattern: '../121_systemmanager/app/model/*.js', watched: false },
    { pattern: '../121_systemmanager/app/store/*.js', watched: false },
    { pattern: '../121_systemmanager/app/data/validator/*.js', watched: false },

    { pattern: '../i21_globalcomponentengine/app/view/StatusbarViewModel.js', watched: false },
    { pattern: '../i21_globalcomponentengine/app/view/Statusbar.js', watched: false },
    { pattern: '../i21_globalcomponentengine/app/view/StatusbarPagingViewModel.js', watched: false },
    { pattern: '../i21_globalcomponentengine/app/view/StatusbarPaging.js', watched: false },
    { pattern: '../i21_globalcomponentengine/app/controller/Statusbar.js', watched: false },

    { pattern: '../i21_globalcomponentengine/iRely/BaseEntity.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/model/EntityCredential.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/model/EntityToContact.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/model/EntityLocation.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/model/EntityNote.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/model/Entity.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/model/EntityContact.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/Functions.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/preference/Manager.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/Messages.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/Configuration.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/Exporter.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/writer/JsonBatch.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/form/field/GridComboBox.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/form/field/ComboBox.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/form/field/GridFilter.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/form/field/GridPanelComboBox.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/form/field/MoneyNumber.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/grid/AdvanceFilterPanel.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/data/store/EntityContact.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/data/store/EntityLocation.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/data/store/EntityNote.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/data/store/EntityToContact.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/util/GridKeyNav.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/custom/Manager.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/attachment/Manager.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/data/Validator.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/data/Manager.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/grid/NewRow.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/grid/Filter.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/grid/Manager.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/container/ImageContainer.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/screen/Toolbar.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/screen/Binding.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/screen/Manager.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/screen/Security.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/security/Control.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/security/Screen.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/security/Dashboard.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/security/Report.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/security/FinancialReport.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/Engine.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/custom/Manager.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/attachment/Manager.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/data/Validator.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/data/Manager.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/grid/NewRow.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/grid/Filter.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/grid/Manager.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/screen/Toolbar.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/screen/Binding.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/screen/Manager.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/screen/Security.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/security/Control.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/security/Screen.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/security/Dashboard.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/security/Report.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/security/FinancialReport.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/Engine.js', watched: false },
    { pattern: '../i21_globalcomponentengine/iRely/writer/JsonBatch.js', watched: false },
    { pattern: '../i21_globalcomponentengine/app/controller/GlobalComponentEngine.js', watched: false },

    // Filter
    { pattern: '../i21_globalcomponentengine/app/view/FilterViewModel.js', watched: false },
    { pattern: '../i21_globalcomponentengine/app/view/Filter.js', watched: false },

    // Screen
    { pattern: '../i21_globalcomponentengine/app/model/Screen.js', watched: false },
    { pattern: '../i21_globalcomponentengine/app/store/Screen.js', watched: false },

    // Attachment
    { pattern: '../i21_globalcomponentengine/app/model/Attachment.js', watched: false },
    { pattern: '../i21_globalcomponentengine/app/store/Attachment.js', watched: false },
    { pattern: '../i21_globalcomponentengine/app/view/AttachmentGridViewModel.js', watched: false },
    { pattern: '../i21_globalcomponentengine/app/view/AttachmentGrid.js', watched: false },
    { pattern: '../i21_globalcomponentengine/app/view/AttachmentPropertiesViewModel.js', watched: false },
    { pattern: '../i21_globalcomponentengine/app/view/AttachmentProperties.js', watched: false },
    { pattern: '../i21_globalcomponentengine/app/view/AttachFileViewModel.js', watched: false },
    { pattern: '../i21_globalcomponentengine/app/view/AttachFile.js', watched: false },
    { pattern: '../i21_globalcomponentengine/app/controller/AttachFile.js', watched: false },
    { pattern: '../i21_globalcomponentengine/app/controller/AttachmentProperties.js', watched: false },

    // Custom fields
    { pattern: '../i21_globalcomponentengine/app/view/override/CustomFieldRevisedViewModel.js', watched: false },
    { pattern: '../i21_globalcomponentengine/app/view/override/CustomFieldRevisedViewController.js', watched: false },
    { pattern: '../i21_globalcomponentengine/app/view/CustomFieldRevisedViewModel.js', watched: false },
    { pattern: '../i21_globalcomponentengine/app/view/CustomFieldRevisedViewController.js', watched: false },
    { pattern: '../i21_globalcomponentengine/app/view/CustomFieldRevised.js', watched: false },

    // Search
    { pattern: '../i21_globalcomponentengine/app/view/SearchGridViewModel.js', watched: false },
    { pattern: '../i21_globalcomponentengine/app/view/SearchGrid.js', watched: false },
    { pattern: '../i21_globalcomponentengine/app/view/SearchViewModel.js', watched: false },
    { pattern: '../i21_globalcomponentengine/app/view/Search.js', watched: false },
    { pattern: '../i21_globalcomponentengine/app/controller/Search.js', watched: false },

    // Grid Template
    { pattern: '../i21_globalcomponentengine/app/view/GridTemplateViewModel.js', watched: false },
    { pattern: '../i21_globalcomponentengine/app/view/GridTemplate.js', watched: false },

    // Simulate the Ext.Loader.loadScript
    { pattern: '../i21_globalcomponentengine/override/Ext.Button.js', watched: false },
    //{pattern: '../i21_globalcomponentengine/override/Ext.Component.js', watched: false},
    //{pattern: '../i21_globalcomponentengine/override/Ext.data.Model.js', watched: false},
    //{pattern: '../i21_globalcomponentengine/override/Ext.data.NodeStore.js', watched: false},
    { pattern: '../i21_globalcomponentengine/override/Ext.data.schema.Role.js', watched: false },
    { pattern: '../i21_globalcomponentengine/override/Ext.data.operation.Operation.js', watched: false },
    { pattern: '../i21_globalcomponentengine/override/Ext.data.Store.js', watched: false },
    { pattern: '../i21_globalcomponentengine/override/Ext.data.proxy.Ajax.js', watched: false },
    { pattern: '../i21_globalcomponentengine/override/Ext.util.FilterCollection.js', watched: false },
    { pattern: '../i21_globalcomponentengine/override/Ext.data.field.Field.js', watched: false },
    { pattern: '../i21_globalcomponentengine/override/Ext.data.ErrorCollection.js', watched: false },
    { pattern: '../i21_globalcomponentengine/override/Ext.data.validator.OptionalUrl.js', watched: false },
    { pattern: '../i21_globalcomponentengine/override/Ext.data.validator.OptionalEmail.js', watched: false },
    { pattern: '../i21_globalcomponentengine/override/Ext.data.validator.OptionalPhone.js', watched: false },
    { pattern: '../i21_globalcomponentengine/override/Ext.data.validator.Phone.js', watched: false },
    { pattern: '../i21_globalcomponentengine/override/Ext.data.validator.Url.js', watched: false },
    //{pattern: '../i21_globalcomponentengine/override/Ext.data.reader.Reader.js', watched: false},
    { pattern: '../i21_globalcomponentengine/override/Ext.form.Basic.js', watched: false },
    { pattern: '../i21_globalcomponentengine/override/Ext.form.field.Number.js', watched: false },
    { pattern: '../i21_globalcomponentengine/override/Ext.form.VTypes.js', watched: false },
    { pattern: '../i21_globalcomponentengine/override/Ext.tree.Panel.js', watched: false },
    { pattern: '../i21_globalcomponentengine/override/Ext.grid.Panel.js', watched: false },
    { pattern: '../i21_globalcomponentengine/override/Ext.grid.column.Number.js', watched: false },
    //{pattern: '../i21_globalcomponentengine/override/Ext.grid.feature.Summary.js', watched: false},
    { pattern: '../i21_globalcomponentengine/override/Ext.selection.Model.js', watched: false },
    { pattern: '../i21_globalcomponentengine/override/Ext.util.Format.js', watched: false },
    { pattern: '../i21_globalcomponentengine/override/Ext.util.Collection.js', watched: false },
    //{pattern: '../i21_globalcomponentengine/override/Ext.view.AbstractView.js', watched: false},
    //{pattern: '../i21_globalcomponentengine/override/Ext.view.NodeCache.js', watched: false},
    //{pattern: '../i21_globalcomponentengine/override/Ext.view.Table.js', watched: false},
    { pattern: '../i21_globalcomponentengine/override/Ext.picker.Date.js', watched: false },
    { pattern: '../i21_resources/js/deft/deft.js', watched: false },
    { pattern: '../i21_resources/js/filesaver/filesaver.js', watched: false },
    { pattern: '../i21_resources/js/ux/moment/moment-min.js', watched: false },
    { pattern: '../i21_resources/js/ux/async.js', watched: false },

    // Load Base 64 js
    { pattern: '../i21_resources/js/fn/Base64.js', watched: false },

    // Store
    { pattern: '../store/app/model/SubCategory.js', watched: false },
    { pattern: '../store/app/store/Family.js', watched: false }
];
var inventoryFiles = [
    { pattern: 'app/model/**/*.js', watched: true },
    { pattern: 'app/store/**/*.js', watched: true },
    { pattern: 'app/view/**/*.js', watched: true }
    /*{ pattern: 'app/controller/!**!/!*.js', watched: true },
    { pattern: 'app/view/!**!/!*.js', watched: true }*/
];

var testFiles = [
    { pattern: 'test/mock/**/*.js', watched: true },
    { pattern: 'test/TestUtils.js', watched: true },
    { pattern: 'test/specs/**/*.js', watched: true }
];

var libs = [
    { pattern: 'app/lib/**/*.js', watched: true }
];

var files = libs.concat(extJs).concat(inventoryFiles).concat(testFiles);

module.exports = function (config) {
    config.set({

        // base path that will be used to resolve all patterns (eg. files, exclude)
        basePath: '',


        // frameworks to use
        // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
        // 'jasmine',
        frameworks: ['mocha', 'chai', 'sinon'],

        // plugins : [
        //     'karma-mocha',
        //     'karma-chai',
        //     'karma-sinon'
        // ],

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
        reporters: ['progress', 'html', 'mocha'],

        htmlReporter: {
            outputDir: 'karma_html', // where to put the reports  
            templatePath: null, // set if you moved jasmine_template.html 
            focusOnFailures: true, // reports show failures on start 
            namedFiles: false, // name files instead of creating sub-directories 
            pageTitle: null, // page title for reports; browser info by default 
            urlFriendlyName: false, // simply replaces spaces with _ for files/dirs 
            reportName: 'report-summary-filename', // report summary filename; browser info by default 


            // experimental 
            preserveDescribeNesting: false, // folded suites stay folded  
            foldAll: false, // reports start folded (only with preserveDescribeNesting) '
        },

        // web server port
        port: 9876,


        // enable / disable colors in the output (reporters and logs)
        colors: true,


        // level of logging
        // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
        logLevel: config.LOG_ERROR,


        // enable / disable watching file and executing tests whenever any file changes
        autoWatch: true,


        // start these browsers
        // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
        browsers: ['Chrome', 'PhantomJS'],


        // Continuous Integration mode
        // if true, Karma captures browsers, runs the tests and exits
        singleRun: false,

        // Concurrency level
        // how many browser should be started simultaneous
        concurrency: Infinity
    });
};


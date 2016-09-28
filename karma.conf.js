// Karma configuration
// Generated on Thu Aug 18 2016 11:21:34 GMT+0800 (China Standard Time)

var extJs = [
    {pattern: '../resources/extjs/ext-6.0.2/build/ext-all.js', watched: false},
    {pattern: '../resources/extjs/ext-6.0.2/build/packages/charts/modern/charts.js', watched: false},
    {pattern: 'app.js', watched: false },

    // load the override for Ext.data.Connection.
    {pattern: '../resources/test/override/Ext.data.Connection.js', watched: false},

     // Load the Ext.ux.ajax.SimManager components. This is used in mocking data using the Ext JS's simlet.
    {pattern: '../resources/test/ux/Simlet.js', watched: false},
    {pattern: '../resources/test/ux/SimXhr.js', watched: false},
    {pattern: '../resources/test/ux/DataSimlet.js', watched: false},
    {pattern: '../resources/test/ux/JsonSimlet.js', watched: false},
    {pattern: '../resources/test/ux/XmlSimlet.js', watched: false},
    {pattern: '../resources/test/ux/SimManager.js', watched: false},

    // Load the JQuery
    {pattern: '../resources/js/jquery/jQuery2.1.0.js', watched: false},
    {pattern: '../resources/js/jquery/jQueryMigrate1.2.1.js', watched: false},
    {pattern: '../resources/js/jquery/jquery.signalR-2.0.2.js', watched: false},

    // Load the LinqJS
    {pattern: '../resources/js/linqJs/linqJs.js', watched: false},

      // Load the Pivot Grid
    {pattern: '../resources/js/ux/mzPivotGrid/overrides/util/Format.js', watched: false},
    {pattern: '../resources/js/ux/mzPivotGrid/mzPivotGrid.css', watched: false},

    // Load the CSS, images, and icons.
    {pattern: '../resources/themes/modern/6.0.2/i21-classic-theme-all.css', watched: false},
    {pattern: '../resources/js/ux/css/Dashboard.css', watched: false},
    {pattern: '../resources/images/images.css', watched: false},
    {pattern: '../resources/js/ux/redactor/css/redactor.css', watched: false},
    {pattern: '../resources/js/ux/redactor/css/clips.css', watched: false},
    {pattern: '../resources/!**!/!*.gif', included: false, watched: false, served: true},
    {pattern: '../resources/!**!/!*.png', included: false, watched: false, served: true},

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

     {pattern: '../GlobalComponentEngine/app/view/StatusbarViewModel.js', watched: false},
     {pattern: '../GlobalComponentEngine/app/view/Statusbar.js', watched: false},
     {pattern: '../GlobalComponentEngine/app/view/StatusbarPagingViewModel.js', watched: false},
     {pattern: '../GlobalComponentEngine/app/view/StatusbarPaging.js', watched: false},
     {pattern: '../GlobalComponentEngine/app/controller/Statusbar.js', watched: false},

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
     {pattern: '../GlobalComponentEngine/iRely/form/field/GridComboBox.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/form/field/ComboBox.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/form/field/GridFilter.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/form/field/GridPanelComboBox.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/form/field/MoneyNumber.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/grid/AdvanceFilterPanel.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/data/store/EntityContact.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/data/store/EntityLocation.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/data/store/EntityNote.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/data/store/EntityToContact.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/util/GridKeyNav.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/custom/Manager.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/attachment/Manager.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/data/Validator.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/data/Manager.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/grid/NewRow.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/grid/Filter.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/grid/Manager.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/container/ImageContainer.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/screen/Toolbar.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/screen/Binding.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/screen/Manager.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/screen/Security.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/security/Control.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/security/Screen.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/security/Dashboard.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/security/Report.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/security/FinancialReport.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/Engine.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/custom/Manager.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/attachment/Manager.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/data/Validator.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/data/Manager.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/grid/NewRow.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/grid/Filter.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/grid/Manager.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/screen/Toolbar.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/screen/Binding.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/screen/Manager.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/screen/Security.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/security/Control.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/security/Screen.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/security/Dashboard.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/security/Report.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/security/FinancialReport.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/Engine.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/writer/JsonBatch.js', watched: false},
     {pattern: '../GlobalComponentEngine/app/controller/GlobalComponentEngine.js', watched: false},

     // Filter
     {pattern: '../GlobalComponentEngine/app/view/FilterViewModel.js', watched: false},
     {pattern: '../GlobalComponentEngine/app/view/Filter.js', watched: false},

     // Screen
     {pattern: '../GlobalComponentEngine/app/model/Screen.js', watched: false},
     {pattern: '../GlobalComponentEngine/app/store/Screen.js', watched: false},

     // Attachment
     {pattern: '../GlobalComponentEngine/app/model/Attachment.js', watched: false},
     {pattern: '../GlobalComponentEngine/app/store/Attachment.js', watched: false},
     {pattern: '../GlobalComponentEngine/app/view/AttachmentGridViewModel.js', watched: false},
     {pattern: '../GlobalComponentEngine/app/view/AttachmentGrid.js', watched: false},
     {pattern: '../GlobalComponentEngine/app/view/AttachmentPropertiesViewModel.js', watched: false},
     {pattern: '../GlobalComponentEngine/app/view/AttachmentProperties.js', watched: false},
     {pattern: '../GlobalComponentEngine/app/view/AttachFileViewModel.js', watched: false},
     {pattern: '../GlobalComponentEngine/app/view/AttachFile.js', watched: false},
     {pattern: '../GlobalComponentEngine/app/controller/AttachFile.js', watched: false},
     {pattern: '../GlobalComponentEngine/app/controller/AttachmentProperties.js', watched: false},

     // Custom fields
     {pattern: '../GlobalComponentEngine/app/view/override/CustomFieldRevisedViewModel.js', watched: false},
     {pattern: '../GlobalComponentEngine/app/view/override/CustomFieldRevisedViewController.js', watched: false},
     {pattern: '../GlobalComponentEngine/app/view/CustomFieldRevisedViewModel.js', watched: false},
     {pattern: '../GlobalComponentEngine/app/view/CustomFieldRevisedViewController.js', watched: false},
     {pattern: '../GlobalComponentEngine/app/view/CustomFieldRevised.js', watched: false},

     // Search
     {pattern: '../GlobalComponentEngine/app/view/SearchGridViewModel.js', watched: false},
     {pattern: '../GlobalComponentEngine/app/view/SearchGrid.js', watched: false},
     {pattern: '../GlobalComponentEngine/app/view/SearchViewModel.js', watched: false},
     {pattern: '../GlobalComponentEngine/app/view/Search.js', watched: false},
     {pattern: '../GlobalComponentEngine/app/controller/Search.js', watched: false},

     // Grid Template
     {pattern: '../GlobalComponentEngine/app/view/GridTemplateViewModel.js', watched: false},
     {pattern: '../GlobalComponentEngine/app/view/GridTemplate.js', watched: false},

     // Simulate the Ext.Loader.loadScript
     {pattern: '../GlobalComponentEngine/override/Ext.Button.js', watched: false},
     //{pattern: '../GlobalComponentEngine/override/Ext.Component.js', watched: false},
     //{pattern: '../GlobalComponentEngine/override/Ext.data.Model.js', watched: false},
     //{pattern: '../GlobalComponentEngine/override/Ext.data.NodeStore.js', watched: false},
     {pattern: '../GlobalComponentEngine/override/Ext.data.schema.Role.js', watched: false},
     {pattern: '../GlobalComponentEngine/override/Ext.data.operation.Operation.js', watched: false},
     {pattern: '../GlobalComponentEngine/override/Ext.data.Store.js', watched: false},
     {pattern: '../GlobalComponentEngine/override/Ext.data.proxy.Ajax.js', watched: false},
     {pattern: '../GlobalComponentEngine/override/Ext.util.FilterCollection.js', watched: false},
     {pattern: '../GlobalComponentEngine/override/Ext.data.field.Field.js', watched: false},
     {pattern: '../GlobalComponentEngine/override/Ext.data.ErrorCollection.js', watched: false},
     {pattern: '../GlobalComponentEngine/override/Ext.data.validator.OptionalUrl.js', watched: false},
     {pattern: '../GlobalComponentEngine/override/Ext.data.validator.OptionalEmail.js', watched: false},
     {pattern: '../GlobalComponentEngine/override/Ext.data.validator.OptionalPhone.js', watched: false},
     {pattern: '../GlobalComponentEngine/override/Ext.data.validator.Phone.js', watched: false},
     {pattern: '../GlobalComponentEngine/override/Ext.data.validator.Url.js', watched: false},
     //{pattern: '../GlobalComponentEngine/override/Ext.data.reader.Reader.js', watched: false},
     {pattern: '../GlobalComponentEngine/override/Ext.form.Basic.js', watched: false},
     {pattern: '../GlobalComponentEngine/override/Ext.form.field.Number.js', watched: false},
     {pattern: '../GlobalComponentEngine/override/Ext.form.VTypes.js', watched: false},
     {pattern: '../GlobalComponentEngine/override/Ext.tree.Panel.js', watched: false},
     {pattern: '../GlobalComponentEngine/override/Ext.grid.Panel.js', watched: false},
     {pattern: '../GlobalComponentEngine/override/Ext.grid.column.Number.js', watched: false},
     //{pattern: '../GlobalComponentEngine/override/Ext.grid.feature.Summary.js', watched: false},
     {pattern: '../GlobalComponentEngine/override/Ext.selection.Model.js', watched: false},
     {pattern: '../GlobalComponentEngine/override/Ext.util.Format.js', watched: false},
     {pattern: '../GlobalComponentEngine/override/Ext.util.Collection.js', watched: false},
     //{pattern: '../GlobalComponentEngine/override/Ext.view.AbstractView.js', watched: false},
     //{pattern: '../GlobalComponentEngine/override/Ext.view.NodeCache.js', watched: false},
     //{pattern: '../GlobalComponentEngine/override/Ext.view.Table.js', watched: false},
     {pattern: '../GlobalComponentEngine/override/Ext.picker.Date.js', watched: false},
     {pattern: '../resources/js/deft/deft.js', watched: false},
     {pattern: '../resources/js/filesaver/filesaver.js', watched: false},
     {pattern: '../resources/js/ux/moment/moment-min.js', watched: false},
     {pattern: '../resources/js/ux/async.js', watched: false},

    // Load Base 64 js
    {pattern: '../resources/js/fn/Base64.js', watched: false},

    // Store
    {pattern: '../store/app/model/SubCategory.js', watched: false},
    {pattern: '../store/app/store/Family.js', watched: false}
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
        reporters: ['progress'],


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
        browsers: ['Chrome', 'PhantomJS'],


        // Continuous Integration mode
        // if true, Karma captures browsers, runs the tests and exits
        singleRun: false,

        // Concurrency level
        // how many browser should be started simultaneous
        concurrency: Infinity
    });
};


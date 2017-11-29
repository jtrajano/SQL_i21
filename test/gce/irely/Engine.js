/**
 * Engine integrates all necessary classes to run a transactional screen.
 *
 * Creating an Engine is easy.
 *
 *     var context = Ext.create('iRely.Engine', {
 *         store: yourStore,
 *         window: yourWindow,
 *         paging: yourPaging,
 *         controller: yourController
 *     });
 *
 * See this [link](http://inet.irelyserver.com/display/i21/GCE+-+Data+Manager "Title")  for more details.
 */
Ext.define('iRely.Engine', {
    extend: 'Ext.util.Observable',
    alternateClassName: 'iRely.mvvm.Engine',

    requires: [
        'iRely.data.Manager',
        'iRely.screen.Manager'
    ],

    /**
     * @cfg {Object} configuration Object containing one or more properties used on setting up Grid Manager:
     *
     * @cfg {Ext.data.Store} configuration.store Main store
     *
     * @cfg {Ext.window.Window} configuration.window Window object.
     *
     * @cfg {Ext.form.Panel} configuration.form Form panel.
     *
     * @cfg {Ext.app.Controller} configuration.controller Main controller.
     *
     * @cfg {String} [configuration.fieldTitle] Column to where to get the display value of the window.
     *
     * @cfg {iRely.grid.Manager} [configuration.singleGridMgr] Grid Manager object for Single Grid mode.
     *
     * @cfg {iRely.data.Detail[]} [configuration.details] Detail configuration.
     *
     * @cfg {Ext.paging.Toolbar} [configuration.paging] Paging toolbar component. Defaults to the first instance of 'ipagingstatusbar' of the window.
     *
     * @cfg {Ext.toolbar.Toolbar} [configuration.status] Status toolbar component. Defaults to the first instance of 'istatusbar' of the window.
     *
     * @cfg {iRely.attachment.Manager} [configuration.attachment] Attachment Grid Manager.
     *
     * @cfg {iRely.custom.Manager} [configuration.custom] Custom Field Manager.
     *
     * @cfg {Boolean} [configuration.checkChange] When set to false, disables the save confirmation message.
     *
     * @cfg {Boolean} [configuration.allowBelongsTo] When set to true will try to loop all details to find if a certain belongsTo has a changes. Defaults to false.
     *
     * @cfg {Boolean} [configuration.enableUndelete] When set to true will mark the record as deleted instead of actually deleting it in the database and vice versa. Defaults to false.
     *
     * @cfg {Function} [configuration.onNewClick] Don't use this anymore
     *
     * @cfg {Function} [configuration.onSaveClick] Don't use this anymore
     *
     * @cfg {Function} [configuration.onUndoClick] Don't use this anymore
     *
     * @cfg {Function} [configuration.onDeleteClick] Don't use this anymore
     *
     * @cfg {Function} [configuration.onBeforeWindowClose] Don't use this anymore
     *
     * @cfg {Function} [configuration.onBeforePageChange] Don't use this anymore
     *
     * @cfg {Function} [configuration.onPageChange] Don't use this anymore
     *
     * @cfg {Function} [configuration.onSearchClick] Don't use this anymore
     *
     * @cfg {Object/Function} [configuration.validateRecord] Object containing properties for scope and function. It overrides {@link iRely.data.Validator#validateRecord validateRecord}.
     *
     * @cfg {Object} [configuration.validateRecord.scope] The scope of the function.
     *
     * @cfg {Function} [configuration.validateRecord.fn] Function that is invoked when a request for validation is triggered. Usually called before saving process.
     *
     * @cfg {Object/Function} [configuration.createRecord] Object containing properties for scope and function.
     *
     * @cfg {Object} [configuration.createRecord.scope] The scope of the function.
     *
     * @cfg {Function} [configuration.createRecord.fn] Method that is invoked by {@link iRely.data.Manager#addRecord addRecord} method. When configured, overrides the default {@link iRely.data.Manager#createRecord createRecord} method for setting up default values.
     */
    configuration: {},

    /**
     * @cfg {Ext.app.Controller} controller
     * Main Controller
     */
    controller: {},

    /**
     * @cfg {iRely.attachment.Manager} attachment
     * Attachment Manager
     */
    attachment: {},

    /**
     * @cfg {iRely.attachment.Manager} comment
     * Comment Manager
     */
    comment: {},

    /**
     * @cfg {iRely.custom.Manager} custom
     * Custom Manager
     */
    custom: {},

    /**
     * @cfg {iRely.data.Manager} data
     * Data Manager
     */
    data: undefined,

    /**
     * @cfg {iRely.screen.Manager} screenMgr
     * Screen Manager
     */
    screenMgr: undefined,

    /**
     * Constructor.
     * @param {Object} options Object containing one or more properties used on setting up Grid Manager:
     *
     * @param {Ext.data.Store} options.store Main store
     *
     * @param {Ext.window.Window} options.window Window object.
     *
     * @param {Ext.form.Panel} options.form Form panel.
     *
     * @param {Ext.app.Controller} options.controller Main controller.
     *
     * @param {String} [options.fieldTitle] Column to where to get the display value of the window.
     *
     * @param {iRely.grid.Manager} [options.singleGridMgr] Grid Manager object for Single Grid mode.
     *
     * @param {iRely.data.Detail[]} [options.details] Detail configuration.
     *
     * @param {Ext.paging.Toolbar} [options.paging] Paging toolbar component. Defaults to the first instance of 'ipagingstatusbar' of the window.
     *
     * @param {Ext.toolbar.Toolbar} [options.status] Status toolbar component. Defaults to the first instance of 'istatusbar' of the window.
     *
     * @param {iRely.attachment.Manager} [options.attachment] Attachment Grid Manager.
     *
     * @param {iRely.custom.Manager} [options.custom] Custom Field Manager.
     *
     * @param {Boolean} [options.checkChange] When set to false, disables the save confirmation message.
     *
     * @param {Boolean} [options.allowBelongsTo] When set to true will try to loop all details to find if a certain belongsTo has a changes. Defaults to false.
     *
     * @param {Boolean} [options.enableUndelete] When set to true will mark the record as deleted instead of actually deleting it in the database and vice versa. Defaults to false.
     *
     * @param {Function} [options.onNewClick] Don't use this anymore
     *
     * @param {Function} [options.onSaveClick] Don't use this anymore
     *
     * @param {Function} [options.onUndoClick] Don't use this anymore
     *
     * @param {Function} [options.onDeleteClick] Don't use this anymore
     *
     * @param {Function} [options.onBeforeWindowClose] Don't use this anymore
     *
     * @param {Function} [options.onBeforePageChange] Don't use this anymore
     *
     * @param {Function} [options.onPageChange] Don't use this anymore
     *
     * @param {Function} [options.onSearchClick] Don't use this anymore
     *
     * @param {Object/Function} [options.validateRecord] Object containing properties for scope and function. It overrides {@link iRely.data.Validator#validateRecord validateRecord}.
     *
     * @param {Object} [options.validateRecord.scope] The scope of the function.
     *
     * @param {Function} [options.validateRecord.fn] Function that is invoked when a request for validation is triggered. Usually called before saving process.
     *
     * @param {Object/Function} [options.createRecord] Object containing properties for scope and function.
     *
     * @param {Object} [options.createRecord.scope] The scope of the function.
     *
     * @param {Function} [options.createRecord.fn] Method that is invoked by {@link iRely.data.Manager#addRecord addRecord} method. When configured, overrides the default {@link iRely.data.Manager#createRecord createRecord} method for setting up default values.
     */
    constructor: function(options) {
        options = options || {};

        var me = this,
            config = {
                store               : options.store,
                window              : options.window,
                viewModel           : options.viewModel ? options.viewModel : options.window.viewModel,
                form                : options.form ? options.form : options.window ? options.window.down('form') : undefined,
                controller          : options.controller ? options.controller : options.window.getController(),
                title               : options.window ? options.window.title : '',
                descriptor          : options.descriptor || 'current',
                fieldTitle          : options.fieldTitle,
                singleGridMgr       : options.singleGridMgr,
                binding             : options.binding,
                details             : options.details,
                include             : options.include,
                paging              : options.paging ? options.paging : options.window ? options.window.down('ipagingstatusbar') : undefined,
                status              : options.status ? options.status : options.window ? options.window.down('istatusbar') : undefined,
                attachment          : options.attachment,
                payment             : options.payment,
                custom              : options.custom,
                audit               : options.audit,
                approval            : options.approval,
                enableAudit         : options.enableAudit,
                enableAttachment    : options.enableAttachment,
                enablePayment       : options.enablePayment,
                enableCustom        : options.enableCustom,
                enableActivity      : options.enableActivity,
                enableCalendar      : options.enableCalendar,
                enableApproval      : options.enableApproval,
                enableCustomGrid    : options.enableCustomGrid,
                enableCustomTab     : options.enableCustomTab,
                enableLockRecord    : options.enableLockRecord == undefined ? true: options.enableLockRecord,
                calendarField       : options.calendarField,
                checkChange         : options.checkChange === undefined ? true : options.checkChange,
                allowBelongsTo      : options.allowBelongsTo === undefined ? false : options.allowBelongsTo,
                enableUndelete      : options.enableUndelete === undefined ? false : options.enableUndelete,
                deleteMsg           : options.deleteMsg,
                onNewClick          : options.onNewClick,
                onSaveClick         : options.onSaveClick,
                onUndoClick         : options.onUndoClick,
                onDeleteClick       : options.onDeleteClick,
                onBeforeWindowClose : options.onBeforeWindowClose,
                onBeforePageChange  : options.onBeforePageChange,
                onPageChange        : options.onPageChange,
                onSearchClick       : options.onSearchClick,
                onCloseClick        : options.onCloseClick,
                validateRecord      : options.validateRecord,
                createRecord        : options.createRecord,
                createApproval      : options.createApproval,
                logRenderer         : options.logRenderer,
                enableDocumentMessage: options.enableDocumentMessage,
                documentMessage     : options.documentMessage,
                createDocumentMessage: options.createDocumentMessage,
                createTransaction: options.createTransaction,
                enableJiraIssue     : options.enableJiraIssue,
                enableHoursWorked     : options.enableHoursWorked,
                viewOnlyOnApproval  : options.viewOnlyOnApproval,
                validateApproval    : options.validateApproval
            };

        me.viewModel = config.viewModel;
        me.controller = config.controller;
        me.configuration = config;
        me.attachment = config.attachment = config.enableAttachment ? Ext.create('iRely.attachment.Manager', { window: config.window }) : config.attachment;
        me.payment = config.payment = config.enablePayment ? Ext.create('iRely.payment.Manager', { window: config.window }) : config.payment;
        me.custom = config.custom = config.enableCustom ? Ext.create('iRely.custom.Manager', { window: config.window }) : config.custom;
        me.audit = config.audit = config.enableAudit ? Ext.create('iRely.audit.Manager', { window: config.window, logRenderer: config.logRenderer }) : config.audit;
        me.calendar = config.calendar = config.enableCalendar ? Ext.create('iRely.calendar.Manager', { window: config.window }) : config.calendar;
        me.approval = config.approval = config.enableApproval ? Ext.create('iRely.approval.Manager', { window: config.window, createApproval: config.createApproval, viewOnlyOnApproval: config.viewOnlyOnApproval, validateApproval: config.validateApproval }) : config.approval;
        me.customGrid = config.customGrid = config.enableCustomGrid ? Ext.create('iRely.custom.Grid', { window: config.window }) : config.customGrid;
        me.customTab = config.customTab = config.enableCustomTab ? Ext.create('iRely.custom.Tab', { window: config.window }) : config.enableCustomTab;
        me.activity = config.activity = config.enableActivity ? Ext.create('iRely.activity.Manager', { window: config.window, createTransaction: config.createTransaction }) : config.enableActivity;
        me.documentMessage = config.documentMessage = config.enableDocumentMessage ? Ext.create('iRely.documentmessage.Manager', { window: config.window, createDocumentMessage: config.createDocumentMessage }) : config.documentMessage;

        me.customJiraIssue = config.customJiraIssue = config.enableJiraIssue ? Ext.create('iRely.jira.Manager', { window: config.window }) : config.enableJiraIssue;
        me.customHoursWorked = config.customHoursWorked = config.enableHoursWorked ? Ext.create('iRely.hoursworked.Manager', { window: config.window }) : config.enableHoursWorked;

        me.data = config.data = Ext.create('iRely.data.Manager', config);
        me.screenMgr = Ext.create('iRely.screen.Manager', config);
        

        if (config.singleGridMgr) {
            config.singleGridMgr.setAsSingle();
        }
    }
});
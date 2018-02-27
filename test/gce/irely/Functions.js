Ext.define('iRely.Functions', {

    name: 'functions',
    alternateClassName: 'i21.functions',
    statics: {


        /**
         * Checks if the passed object is empty. This adds additional checking of empty object from Ext.isEmpty
         * @@param {object} obj
         * @return {bool}
         */
        isEmpty: function (obj, allowEmptyString) {
            try {
                if (JSON.stringify(obj) === '{}') {
                    return true;
                }
                else {
                    return (obj === null) || (obj === undefined) || (!allowEmptyString ? obj === '' : false) || (Ext.isArray(obj) && obj.length === 0);
                }
            } catch (err) {
                return false;
            }
        },
        /**
         * show a Standard Save Message dialog
         * @sender {component} element
         * @action {string} function
         * @message {string} message [optional]
         */
        showSaveDialog: function (sender, action, message) {
            iRely.Msg.showSave(action, sender, message);
        },
        /**
         * show a Standard Delete Message dialog
         * @sender {component} element
         * @action {string} function
         * @message {string} message [optional]
         */
        showDeleteDialog: function (sender, action, message) {
            iRely.Msg.showDelete(action, sender, message);
        },
        /**
         * show a Standard Form Error Validation Message dialog
         * @message {string} error message
         * @action {string} function [optional]
         */
        showErrorDialog: function (message, action) {
            iRely.Msg.showError(message, Ext.MessageBox.OK, action);
        },
        /**
         * show a Standard Form Information Message dialog
         * @message {string} info message
         * @action {string} function [optional]
         */
        showInfoDialog: function (message, action) {
            iRely.Msg.showInfo(message, action);
        },

        /**
         * Convenience object to setup the dialog type when showing a message box.
         *
         */
        dialogType: {
            ERROR: 'error',
            QUESTION: 'question',
            INFORMATION: 'information',
            WARNING: 'warning'
        },

        /**
         * Convenience object to setup the dialog button types when showing a message box.
         *
         */
        dialogButtonType: {
            YESNOCANCEL: 'yesnocancel',
            YESNO: 'yesno',
            OKCANCEL: 'okcancel',
            OK: 'ok'
        },

        /**
         * show a Standard Custom Message dialog
         * @type {string} [error|question|information|warning]
         * @buttons {string} [yesnocancel|yesno|okcancel|ok]
         * @message {string} display message
         * @action {string} function [optional]
         */
        showCustomDialog: function (type, buttons, message, action) {
            iRely.Msg.showCustom(type, buttons, message, action);
        },

        getDecimalPlaces: function (n) {
            //http://stackoverflow.com/questions/9539513/is-there-a-reliable-way-in-javascript-to-obtain-the-number-of-decimal-places-of
            var s = "" + (+n);
            // Make sure it is a number and use the builtin number -> string.
            // Pull out the fraction and the exponent.
            var match = /(?:\.(\d+))?(?:[eE]([+\-]?\d+))?$/.exec(s);
            // NaN or Infinity or integer.
            // We arbitrarily decide that Infinity is integral.
            if (!match) { return 0; }
            // Count the number of digits in the fraction and subtract the
            // exponent to simulate moving the decimal point left by exponent places.
            // 1.234e+2 has 1 fraction digit and '234'.length -  2 == 1
            // 1.234e-2 has 5 fraction digit and '234'.length - -2 == 5
            return Math.max(
                0,  // lower limit.
                (match[1] == '0' ? 0 : (match[1] || '').length)  // fraction length
                - (match[2] || 0));  // exponent
        },

        getPreferenceValue: function (preferences, name) {
            var result = $.grep(preferences, function (e) { return e.data.strPreference == name; });
            if (result !== null && result !== undefined && result.length > 0) {
                return result[0].data.strValue;
            }
            else {
                return null;
            }

        },

        setPreferenceValue: function (preferences, name, newValue) {

            var result = preferences.data.findBy(function (e) { if (e.data.strPreference === name) return e; });
            if (result !== null && result !== undefined) {
                result.set('strValue', newValue);
            } else {
                //Add by Jayson - should add records initialy.
                preferences.add(Ext.create("i21.model.Preferences", {
                    intPreferenceID: 0,
                    strPreference: name,
                    strDescription: name,
                    strValue: newValue,
                    intSort: null,
                    intConcurrencyID: null
                }));
            }
        },

        /**
         * Disables all the field controls found inside a panel except for items indicated in the exemption list.
         * Styles are applied on the controls enabled or changed to readonly by this function.
         *
         * @param options
         * @cfg {Object} options
         * @cfg {Ext.panel.Panel} [options.panel] Accepts any object that is derived from Ext.panel.Panel. For example, It
         * can accept Ext.window.Window because it derives from panel.
         * @cfg {String Array} [options.exemption] The item id's of the fields that will disregard.
         * @cfg {Boolean} [options.disabled] Default value is true. When true, it will disable all the fields. When false,
         * it enables it. It works with the exception list. If true (disable is a yes), all items in the exception list will
         * become enabled. If false (disable is a no), all items in the exception list will become disabled.
         *
         */
        setControlDisabled: function (options) {
            if (options === undefined)
                return;

            var panel = options.panel,
                exemption = options.exemption,
                disabled = options.disabled !== undefined ? options.disabled : true;

            // check if panel is a valid object (Ext.panel.Panel or Ext.window.Window)
            if (panel === undefined && !(panel instanceof Ext.panel.Panel || panel instanceof Ext.window.Window))
                return;

            // Define the xTypes of the field controls and toolbar to disable (or enable)
            var searchXTypes = ['button', 'textfield', 'datefield', 'combobox', 'gridpanel'];

            // Process each xType one by one.
            searchXTypes.forEach(function (xtype) {

                // Load all the fields that have the current xtype.
                var objects = panel.query(xtype);

                // Disable the fields found with a specific xtype.
                objects.forEach(function (obj) {
                    if (obj.getItemId() !== 'inputItem') {
                        var action = disabled;
                        var actionReadOnly = disabled;

                        // Keep current setup for items in the exemption list.
                        if (exemption && exemption.length > 0) {
                            for (i = 0; i < exemption.length; i++) {
                                if (obj.getItemId() === exemption[i].toString()) {
                                    action = obj.isDisabled();

                                    if (Ext.isFunction(obj.setReadOnly))
                                        actionReadOnly = obj.readOnly;

                                    break;
                                }
                                else {
                                    // Apply style on the enabled or disabled field control.
                                    if (Ext.isFunction(obj.setFieldStyle)) {
                                        if (action === true)
                                            obj.setFieldStyle("color:grey;");
                                        else
                                            obj.setFieldStyle("color:black;");
                                    }
                                }
                            }
                        }

                        // Do the action (disable it or enable it).
                        if (Ext.isFunction(obj.setReadOnly)) {
                            obj.setReadOnly(actionReadOnly);

                            if (actionReadOnly === true) {
                                if (Ext.isFunction(obj.setFieldStyle)) {
                                    obj.setFieldStyle("color:grey;");
                                }
                            }
                        }

                        // Do the action (disable it or enable it).
                        if (xtype == 'button' && Ext.isFunction(obj.setDisabled) && !(obj.getItemId() === 'first' || obj.getItemId() === 'prev' || obj.getItemId() === 'next' || obj.getItemId() === 'last' || obj.getItemId() === 'refresh' || obj.getItemId() === 'btnHelp' || obj.getItemId() === 'btnSupport' || obj.getItemId() === 'btnFieldName'))
                            obj.setDisabled(action);

                        // Do a special step for grid panels.
                        if (xtype === 'gridpanel') {

                            if (action === true) obj.setBodyStyle('color: gray;');
                            else obj.setBodyStyle('color: black;');

                            // Disable the editors in the grid-columns.
                            var columns = obj.columnManager.getColumns();
                            if (columns) {
                                columns.forEach(function (column) {
                                    if (Ext.isFunction(column.getEditor)) {
                                        var editor = column.getEditor();
                                        if (editor && Ext.isFunction(editor.setDisabled))
                                            editor.setDisabled(action);

                                        if (editor && Ext.isFunction(editor.setReadOnly))
                                            editor.setReadOnly(action);
                                    }
                                });
                            }

                            // Disable any docked items in the grid.
                            var dockedItems = obj.getDockedItems();
                            if (dockedItems) {
                                dockedItems.forEach(function (dockedItem) {
                                    if (dockedItem.getXType() != 'toolbar') {
                                        if (Ext.isFunction(dockedItem.setDisabled))
                                            dockedItem.setDisabled(action);

                                        if (Ext.isFunction(dockedItem.setReadOnly))
                                            dockedItem.setReadOnly(action);
                                    }
                                });
                            }
                        }
                    }
                });
            });
        },

        setControlReadOnly: function (component, readonly, exceptions) {
            var win = component;

            if (win) {
                var _xtypes = ['textfield', 'datefield', 'combobox'];
                for (var x = 0; x <= _xtypes.length - 1; x++) {
                    var _containers = win.query(_xtypes[x]);
                    for (var y = 0; y <= _containers.length - 1; y++) {
                        var Obj = _containers[y];
                        if (exceptions.length > 0) {
                            for (var z = 0; z <= exceptions.length - 1; z++) {
                                if (exceptions[z].toString() === Obj.getItemId()) {
                                    exceptions.splice(z, 1);
                                    z = exceptions.length;
                                }
                                else {
                                    Obj.setReadOnly(readonly);
                                }
                            }
                        }
                        else {
                            Obj.setReadOnly(readonly);
                        }
                    }
                }
            }
        },

        generateFilterString: function (data, key) {
            var filters = [];
            for (var i in data) {
                var d = data[i].data;
                filters.push({
                    column: key,
                    value: d[key],
                    condition: 'eq',
                    conjunction: 'Or'
                });
            }
            return Ext.encode(filters);
        },

        openURL: function (url) {
            // matches http:// or https://
            var protocolRegex = /^((http|https)\:\/\/)/i;

            if (protocolRegex.test(url)) {
                window.open(url, '_blank');
            }
            else {
                window.open('http://' + url, '_blank');
            }
        },

        convertToProperLink: function (rawLink) {
            var result = '';
            if (/(https?:\/\/)?(www.)?[-a-zA-Z0-9]{2,}\.[a-z]{2,}\b(\/[-a-zA-Z0-9@:%_\+.~#?&//=]*)?/g.test(rawLink)) {
                result = /^((http|https)\:\/\/)/i.test(rawLink) ? rawLink : 'http://' + rawLink;
            }

            return result;
        },

        sendEmail: function (email) {
            window.location.href = "mailto:" + email + "";
        },

        openMAP: function (address) {
            window.open('http://maps.google.com/maps?q=' + address, '_blank')
        },

        validateEmail: function (email) {
            var ereg = /^\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/;
            var testResult = ereg.test(email);
            if (testResult === true) return true;
            else return false;
        },

        /**
         * http://jsfiddle.net/briguy37/2MVFd/
         */
        generateUID: function () {
            var d = new Date().getTime();
            var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
                var r = (d + Math.random() * 16) % 16 | 0;
                d = Math.floor(d / 16);
                return (c == 'x' ? r : (r & 0x7 | 0x8)).toString(16);
            });
            return uuid;
        },

        encodeSorters: function (sorts) {
            var newSorts = [];

            for (var index in sorts) {
                var sort = sorts[index],
                    newSort = {
                        property: sort._property,
                        direction: sort._direction
                    };

                newSorts.push(newSort);
            }

            return Ext.encode(newSorts);
        },

        encodeFilters: function (filters) {
            var filterCollection = [];
            for (var i = 0; i < filters.length; i++) {
                var rawFilter = filters[i];

                var filter = {
                    c: rawFilter.column || (rawFilter.config ? rawFilter.config.property : undefined) || rawFilter.dataIndex,
                    v: rawFilter.value || (rawFilter.config ? rawFilter.config.value : rawFilter.value),
                    co: rawFilter.condition || (rawFilter.config ? rawFilter.config.condition : undefined) || 'eq',
                    cj: rawFilter.conjunction || (rawFilter.config ? rawFilter.config.conjunction : undefined) || 'or',
                    g: rawFilter.group || (rawFilter.config ? rawFilter.config.group : undefined) || 'g' + i
                };
                if (filter.co === 'eq')
                    delete filter.co;
                if (filter.cj === 'or')
                    delete filter.cj;

                filterCollection.push(filter);
            }
            return Ext.encode(filterCollection);
        },

        addSpaceToProperCase: function (char) {
            var rawChar = char.substring(char.lastIndexOf('.') + 1);
            var properName = "";

            for (var i = 0; i < rawChar.length; i++) {
                if (rawChar.charAt(i) == rawChar.charAt(i).toUpperCase()) {
                    var nextWord = "";

                    for (var j = i; j < rawChar.length; j++) {
                        if (!(rawChar.charAt(j) == rawChar.charAt(i).toUpperCase() && nextWord !== "")) {
                            nextWord += rawChar.charAt(j);
                            i++;
                        }
                        else {
                            i--;
                            break;
                        }
                    }

                    properName += (properName !== "" ? " " : "") + nextWord;
                }
            }

            return properName;
        },

        convertToProperCase: function (string) {
            return string.replace(/\b\w/g, function (txt) { return txt.toUpperCase(); });
        },

        getComponentByQuery: function (itemId) {
            return Ext.ComponentQuery.query(itemId)[0];
        },

        getChildControl: function (itemId, parent) {
            if (parent) {
                if (parent.down) {
                    return parent.down(itemId);
                }
            }

            return undefined;
        },

        getControlText: function (item, parent) {
            var text = "";
            if (item) {
                if (typeof item === "string") {
                    var control = parent.down(item);
                    if (control) {
                        text = control.text || "";
                    }
                } else {
                    text = item.text || "";
                }
            }

            return text;
        },

        isComponentShown: function (item) {
            var result = false;
            if (typeof item === "string") {
                var com = iRely.Functions.getComponentByQuery(item);
                if (com) {
                    result = com.rendered && com.hidden === false;
                }
            } else {
                result = item.rendered && item.hidden === false;
            }

            return result;
        },

        isComponentRendered: function (item) {
            var result = false;
            if (typeof item === "string") {
                var com = iRely.Functions.getComponentByQuery(item);
                if (com) {
                    result = com.rendered;
                }
            } else {
                result = item.rendered;
            }

            return result;
        },

        checkScreenPermission: function (screenName, callback) {
            if (screenName === 'i21.view.Login' ||
                screenName === 'i21.view.OfflineConfiguration' ||
                screenName === 'i21.view.ForgotLogin' ||
                screenName === 'i21.view.ElectronicAgreement' ||
                screenName === 'i21.view.TwoStepVerificationCode' ||
                screenName === 'GlobalComponentEngine.view.IntegratedDashboard' ||
                screenName === 'GlobalComponentEngine.view.Home' ||
                screenName === 'GlobalComponentEngine.view.CompanyRegistration' ||
                screenName === 'i21.view.TwoStepVerification' ||
                screenName === 'i21.view.TwoFactorAuthentication' ||
                screenName === 'GlobalComponentEngine.view.Activity' ||
                screenName === 'GlobalComponentEngine.view.ActivityEmail' ||
                iRely.config.Security.LoginType == 'Installer') {
                callback('full access');
                return;
            }

            var store = Ext.create('GlobalComponentEngine.store.ScreenPermission', {
                remoteFilter: true,
                pageSize: 0
            });

            if (iRely.Configuration.Security.IsContact) {
                store.proxy.api.read = '../globalcomponentengine/api/screenpermission/searchportal';
            }

            var filters = [];
            if (iRely.Configuration.Security.IsContact) {
                filters = [
                    {
                        column: 'strNamespace',
                        value: screenName
                    },
                    {
                        column: 'intUserRoleId',
                        value: iRely.Configuration.Security.UserRoleId,//iRely.Configuration.Security.ContactId,
                        conjunction: 'and'
                    }
                ];
            }
            else {
                filters = [
                    {
                        column: 'strNamespace',
                        value: screenName
                    },
                    {
                        column: 'intCompanyLocationId',
                        value: iRely.config.Application.CurrentLocation,
                        conjunction: 'and'
                    },
                    {
                        column: 'intEntityId',
                        value: iRely.config.Security.EntityId,
                        conjunction: 'and'
                    }/*,
                    {
                        column: 'intUserRoleId',
                        value: iRely.config.Application.CurrentLocation <= 0 ? iRely.config.Security.UserRoleId : -1,
                        conjunction: 'and'
                    }*/
                ];

            }

            store.addFilter(filters);
            store.load({
                callback: function (records, operation, success) {
                    if (success) {
                        var record = records[0];
                        if (record) {
                            callback(record.get('strPermission').toLowerCase());
                        } else {
                            callback('full access');
                        }
                    } else {
                        callback('error');
                    }
                }
            });
        },

        configureSearch: function (config) {
            config = config || {};

            var me = this,
                controller = config.controller,
                param = config.param,
                searchCommand = config.searchCommand,
                permission = config.permission,
                searchConfig = (controller.config && controller.config.searchConfig) || {};

            Ext.apply(searchConfig, param.searchConfig || {});

            if (searchCommand) {
                Ext.apply(searchConfig, controller.config[searchCommand] || {});
            }

            if (!me.isEmpty(searchConfig)) {
                if (param && param.filters && param.filters.length > 0) {
                    searchConfig.syntaxFilters = [];
                    Ext.apply(searchConfig.syntaxFilters, param.filters);
                }

                if (permission === 'view only' || permission === 'edit') {
                    searchConfig.showNew = false;
                }

                if (param && param.activeTabIndex != undefined) {
                    searchConfig.activeTabIndex = param.activeTabIndex;
                }
                if (param && param.isFloating != undefined) {
                    searchConfig.isFloating = param.isFloating;
                }

                controller.config = controller.config || {};
                controller.config.searchConfig = searchConfig;

                //type will be used as key on search
                searchConfig.type = searchCommand ? controller.getView().$className + ':' + searchCommand : controller.getView().$className;
                if (searchConfig.searchConfig && searchConfig.searchConfig.length > 0) {
                    searchConfig.searchConfig.forEach(function (sc) {
                        sc.type = searchCommand ? controller.getView().$className + ':' + searchCommand : controller.getView().$className;
                    });
                }
                searchConfig.uri = controller.getView().uri;
                searchConfig.controller = controller;

                if (searchConfig.isFloating) {
                    //                    var search = i21.ModuleMgr.Search;
                    //                    search.showSearchByController(controller, true);
                    iRely.Functions.openScreen('GlobalComponentEngine.view.FloatingSearch', {
                        searchSettings: searchConfig,
                        viewConfig: {
                            listeners: {
                                openselectedclick: function (button, e, result, filters, cfg) {
                                    iRely.Functions.openScreen(searchConfig.type, cfg);
                                },
                                newclick: function (button, e, cfg) {
                                    iRely.Functions.openScreen(searchConfig.type, cfg);
                                },
                                scope: me
                            },
                            moduleController: controller
                        }
                    });
                }
                else {
                    this.openScreen('GlobalComponentEngine.view.IntegratedDashboard', {
                        searchSettings: searchConfig,
                        activeTab: controller.config.activeTab || ''
                    });
                    app.redirectTo(controller.getView().uri);
                    controller.destroy();
                }

                return true;
            } else {
                return false;
            }
        },

        showScreen: function (screenName, actionOrFilter, searchCommand) {
            var me = this,
                viewPort = Ext.ComponentQuery.query('viewport')[0],
                queryFilter = {};

            Ext.apply(queryFilter, actionOrFilter);

            for (var key in actionOrFilter) {
                if (key != 'filters' && typeof (queryFilter[key]) == 'object' || typeof (queryFilter[key]) == 'function') {
                    delete queryFilter[key];
                }
            }

            var alias = screenName.substring(screenName.indexOf('view.') + 5, screenName.length),
                moduleName = screenName.substring(0, screenName.indexOf('.view')),
                prefix = (screenName === 'i21.view.Login') ? 'sm' : iRely.Functions.getModulePrefix(moduleName),
                uri = '#/' + prefix + '/' + alias;

            uri += (searchCommand) ? ('/' + searchCommand) : '';
            uri += '?' + Ext.Object.toQueryString(queryFilter, true);

            alias = prefix + alias;

            var id = parseInt(actionOrFilter) ? actionOrFilter : null,
                action = (id === null && typeof actionOrFilter === "string" && actionOrFilter.toLowerCase() === "new") ? "new" : null,
                param = (id === null && action === null) ? actionOrFilter : null;

            var viewConfig = {
                controller: alias.toLowerCase(),
                viewModel: { type: alias.toLowerCase() },
                uri: uri
            };

            if (param && param.viewConfig) {
                Ext.apply(viewConfig, param.viewConfig);
            }

            me.checkScreenPermission(screenName, function (permission) {
                if (viewPort) {
                    viewPort.setLoading(false);
                }

                if (permission === 'error') {
                    me.showInfoDialog('Failed to load the screen.');
                }
                else if (permission === 'no access') {
                    var screen = screenName.substring(screenName.indexOf('view.') + 5, screenName.length);
                    me.showInfoDialog('You don\'t have access to open ' + iRely.Functions.addSpaceToProperCase(screen) + ' screen.', function () {
                        if (Ext.WindowManager.zIndexStack.items.length == 0) {
                            window.location.replace('#menu')
                        }
                    });
                } else {

                    var view = Ext.create(screenName, viewConfig);
                    if (view) {
                        var controller = view.getController(),
                            viewModel = view.getViewModel();

                        if (controller && controller.configClass) {
                            var customCfg = Ext.create(controller.configClass);
                            if (customCfg) {
                                controller.config = controller.config ? controller.config : {};
                                Ext.Object.merge(controller.config, customCfg);
                            }
                        }

                        if (viewModel) {
                            viewModel.set('securityPermission', permission);
                        }

                        if (controller && controller.show) {
                            if (permission === 'add') {
                                controller.show({
                                    action: 'new',
                                    param: param
                                });
                                return;
                            }
                            if (param && param.searchCommand) {
                                searchCommand = param.searchCommand;
                            }
                            if (param && searchCommand) {
                                var controllerConfig = controller.config[searchCommand];
                                Ext.Object.merge(controllerConfig || {}, param.searchConfig || {});
                                param.searchConfig = controllerConfig;
                            }

                            if (param && param.searchConfig) {
                                controller.config.searchConfig = controller.config.searchConfig ? controller.config.searchConfig : {};
                                Ext.Object.merge(controller.config.searchConfig, param.searchConfig || {});
                            }

                            if (param && param.showSearch) {
                                if (me.configureSearch({
                                    controller: controller,
                                    param: param,
                                    searchCommand: searchCommand,
                                    permission: permission
                                })) {
                                    return;
                                }

                            }

                            if (param && !param.searchSettings && param.showSearch) {
                                me.clearViewPort();
                            }

                            controller.showCfg = {
                                action: action || (param && param.action) || 'edit',
                                id: id,
                                filters: (param && param.filters),
                                param: param,
                                routeId: (param && param.routeId)
                            };

                            controller.show(controller.showCfg);
                        } else {
                            view.show();
                        }
                    }
                }
            });
        },

        getRouteFromNamespace: function (namespace, param) {
            var me = this,
                alias = namespace.substring(namespace.indexOf('view.') + 5, namespace.length),
                moduleName = namespace.substring(0, namespace.indexOf('.view')),
                prefix = (namespace === 'i21.view.Login') ? 'sm' : iRely.Functions.getModulePrefix(moduleName),
                uri = '#/' + prefix + '/' + alias;

            var queryFilter = me.getCommandParameter(param, namespace);
            uri += '?' + Ext.Object.toQueryString(queryFilter, true);

            return uri;
        },

        getCommandParameter: function (param, command) {
            if (command.indexOf('?') === -1)
                return param;

            var parameters = param || {};
            var parameterString = command.substring(command.indexOf('?') + 1, command.length);
            var parameterArray = parameterString.split("&");

            for (var i in parameterArray) {
                var keyValue = parameterArray[i];
                var key = keyValue.substring(0, keyValue.indexOf("="));
                var value = keyValue.substring(keyValue.indexOf("=") + 1);
                parameters[key] = value;
            }

            return parameters;
        },

        getScreenName: function (command) {
            var screenName = '';

            if (command.indexOf(':') !== -1)
                screenName = command.substring(command.indexOf(':'), command.length - command.indexOf);
            else if (command.indexOf('?') !== -1)
                screenName = command.substring(command.indexOf('?'), command.length - command.indexOf);
            else
                screenName = command;

            return screenName;
        },

        openScreen: function (command, param) {
            var me = this,
                viewPort = Ext.ComponentQuery.query('viewport')[0],
                screenName = me.getScreenName(command),
                searchCommand = command.indexOf(':') === -1 ? null : command.substring(command.indexOf(':') + 1, command.length),
                param = me.getCommandParameter(param, command);

            if (screenName !== 'i21.view.Login' &&
                screenName.indexOf('HelpDesk') < 0 &&
                screenName.indexOf('CRM') < 0 &&
                iRely.config.Security.IsContact) {
                if (param !== undefined && param !== null) {
                    param.searchCommand = null;
                }
            }

            if (viewPort) {
                viewPort.setLoading('Initializing..');
            }

            if (screenName) {
                if (Ext.ClassManager.isCreated(screenName)) {
                    me.showScreen(screenName, param, searchCommand);
                }
                else {
                    Ext.require([
                        screenName,
                        screenName + 'ViewController',
                        screenName + 'ViewModel'
                    ], function () {
                        me.showScreen(screenName, param, searchCommand);
                    }, this);
                }
            }
        },

        getModulePrefix: function (namespace) {
            var store = this.moduleStore = (this.moduleStore || Ext.create('i21.store.ModuleList')),
                prefix = 'frm';

            namespace = namespace === 'i21' ? 'SystemManager' : namespace;

            var idx = store.findBy(function (record) {
                return record.get('strNamespace').replace(/\s+/g, '') === namespace
            });

            var module = store.getAt(idx);
            if (module) {
                prefix = module.get('strPrefix');
            }

            return prefix;
        },

        getNamespace: function (modulePrefix) {
            var store = this.moduleStore = (this.moduleStore || Ext.create('i21.store.ModuleList'));

            var idx = store.findBy(function (record) {
                return record.get('strPrefix') === modulePrefix
            });

            var module = store.getAt(idx),
                namespace;

            if (module) {
                namespace = module.get('strNamespace').replace(/\s+/g, '');
            }

            return namespace;
        },

        createIdentityToken: function (user, password, company, userId, entityId, isContact, contactParentId) {
            var token = user + ':' + password + ':' + company + ':' + userId + ':' + entityId + ':' + (isContact === 'undefined' ? false : isContact) + ':' + (contactParentId === 'undefined' ? 0 : contactParentId);
            var hash = Ext.util.Base64.encode(token);
            return hash;
        },

        addScript: function (path, callback) {
            var head = document.getElementsByTagName("head")[0],
                script = document.createElement('script');

            script.setAttribute('src', path);
            script.setAttribute('type', 'text/javascript');
            script.addEventListener('load', callback);
            head.appendChild(script);
        },

        addCssLink: function (filename) {
            var head = document.getElementsByTagName("head")[0],
                link = document.createElement('link');

            link.setAttribute("rel", "stylesheet");
            link.setAttribute("type", "text/css");
            link.setAttribute("href", filename);

            head.appendChild(link);
        },

        /*setupAppletLauncher: function(callback) {
         if (typeof launcher === 'undefined') {
         var body = document.getElementsByTagName("body")[0],
         frame = document.createElement('iframe');

         frame.setAttribute('src','applet.html');
         frame.setAttribute('width', 1);
         frame.setAttribute('height', 1);
         frame.setAttribute('id','cobolFrame');
         body.appendChild(frame);

         $(frame).load(function () {
         var frameDoc = frame.contentDocument || frame.contentWindow.document;
         launcher = frameDoc.getElementById('launcher');

         if (callback) {
         callback();
         }
         });
         }
         else {
         if (callback) {
         callback();
         }
         }
         },*/

        callExternalApp: function (args) {
            var url = window.location.href,
                index = url.includes('debug.htm') ? url.indexOf('debug.htm') : url.indexOf('#'),
                finalURL = url.substring(0, index - 1),
                token = iRely.config.Security.AuthToken;

            var body = document.getElementsByTagName("body")[0],
                frame = document.createElement('iframe');

            frame.setAttribute('src', args.replace('{url}', finalURL).replace('{token}', token));
            frame.setAttribute('width', 1);
            frame.setAttribute('height', 1);
            frame.setAttribute('id', 'cobolFrame');
            body.appendChild(frame);

            setTimeout(function () {
                body.removeChild(frame);
            }, 5000);
        },

        createScreen: function (screenName, callback, viewConfig) {
            var createScreen = function () {
                viewConfig = viewConfig || {};

                var alias = screenName.substring(screenName.indexOf('view.') + 5, screenName.length),
                    moduleName = screenName.substring(0, screenName.indexOf('.view')),
                    prefix = iRely.Functions.getModulePrefix(moduleName);

                alias = prefix + alias;

                Ext.apply(viewConfig, { controller: alias.toLowerCase(), viewModel: { type: alias.toLowerCase() } });

                var view = Ext.create(screenName, viewConfig);
                if (view && callback) {
                    callback(view);
                }
            }

            if (Ext.ClassManager.isCreated(screenName)) {
                createScreen();
            }
            else {
                Ext.require([
                    screenName,
                    screenName + 'ViewController',
                    screenName + 'ViewModel'
                ], function () {
                    createScreen();
                }, this);
            }
        },

        bindControls: function (win, binding) {
            "use strict";

            if (!(win && binding)) {
                return;
            }

            var me = this,
                configureColumn = function (column, config) {
                    column.dataIndex = config.dataIndex || (typeof config === 'string' ? config : '');
                    column.drillDownClick = config.drillDownClick ? config.drillDownClick : column.drillDownClick;
                    column.drillDownText = config.drillDownText ? config.drillDownText : column.drillDownText;
                    column.drillDownEmptyClick = config.drillDownEmptyClick ? config.drillDownEmptyClick : column.drillDownEmptyClick;
                    column.drillDownEmptyText = config.drillDownEmptyText ? config.drillDownEmptyText : column.drillDownEmptyText;
                    column.headerDrillDownClick = config.headerDrillDownClick ? config.headerDrillDownClick : column.headerDrillDownClick;
                    column.headerDrillDownText = config.headerDrillDownText ? config.headerDrillDownText : column.headerDrillDownText;
                    if (config.editor) {
                        if (column.editor) {
                            column.editor.bind = config.editor;
                        } else {
                            var editor = column.getEditor();
                            if (editor) {
                                editor.setBind(config.editor);
                            }
                        }
                    }

                    if (Ext.isObject(config)) {
                        var bindObj = {};
                        for (var i in config) {
                            if (!(i === 'dataIndex' || i === 'editor' || i.toString().toLowerCase().indexOf('drilldown') > -1)) {
                                bindObj[i] = config[i];
                            }
                        }

                        if (!me.isEmpty(bindObj)) {
                            column.setBind(bindObj);
                        }
                    }
                };

            for (var i in binding) {
                var bindConfig = binding[i],
                    control;

                control = i === 'bind' ? win : (win.lookupReference(i) || win.down('#' + i));
                if (control) {
                    if (control instanceof Ext.grid.Column) {
                        configureColumn(control, bindConfig);
                        continue;
                    }
                    else if (control instanceof Ext.grid.Panel) {
                        if (Ext.isObject(bindConfig)) {
                            for (var c in bindConfig) {
                                var colConfig = bindConfig[c],
                                    column = win.lookupReference(c) || control.down('#' + c);

                                if (column instanceof Ext.grid.Column) {
                                    configureColumn(column, colConfig);
                                    continue;
                                } else if (c === 'store' || c == 'readOnly' || c === 'hidden') {
                                    var cfg = {};
                                    cfg[c] = colConfig;

                                    control.setBind(cfg);
                                }
                            }

                            continue;
                        }
                    }
                    else if(control instanceof Ext.tab.Tab && Ext.isObject(bindConfig) && bindConfig.hasOwnProperty('disabled')) {
                        control.on('disable', me.onTabDisable)
                    }

                    control.setBind(bindConfig);
                }
            }
        },

        //this will disable all controls inside the tab panel and activate the next tab if present
        onTabDisable: function(component, e, eOpts) {
            var me = this;

            if(component && component.isDisabled()) {
                var tabBar = component.up('panel'),
                    activeTab = tabBar.getActiveTab(),
                    activeTabIndex = tabBar.items.items.indexOf(activeTab),
                    fields = activeTab.query('field');

                if(activeTab.tab.getItemId() == component.getItemId() && component.isVisible()) {
                    fields.forEach(function (field) {
                        if (typeof field.setDisabled == 'function') {
                            field.setDisabled(true);
                        }
                    });

                    if(activeTabIndex !== -1 && activeTabIndex < tabBar.items.items.length -1 ) {

                        for(var idx in tabBar.items.items) {
                            var item = tabBar.items.items[parseInt(idx)]
                            if(idx > activeTabIndex && !item.tab.isDisabled()) {
                                tabBar.setActiveTab(parseInt(idx));
                                break;
                            }
                        };
                    }

                }

            }

        },

        resetSecurityBinding: function (win, binding, reverse) {
            "use strict";

            if (!(win && binding)) {
                return;
            }

            for (var i in binding) {
                var bindConfig = binding[i],
                    control;

                control = i === 'bind' ? win : (win.lookupReference(i) || win.down('#' + i));
                if (control) {
                    if (control instanceof Ext.grid.Panel) {
                        if (Ext.isObject(bindConfig)) {
                            for (var c in bindConfig) {
                                var column = win.lookupReference(c) || win.down('#' + c);
                                if (!(column instanceof Ext.grid.Column)) {
                                    control.setBind({
                                        readOnly: reverse ? bindConfig['readOnly'] : '{securityViewOnly}'
                                    });
                                }
                            }

                            continue;
                        }
                    }

                    if (Ext.isObject(bindConfig)) {
                        for (var c in bindConfig) {
                            if (c === 'readOnly') {
                                control.setBind({
                                    readOnly: reverse ? bindConfig[c] : '{securityViewOnly}'
                                });
                            }
                        }
                    }
                }
            }
        },

        validateGrid: function (grid) {
            "use strict";

            if (!grid.editingPlugin) {
                return [];
            }

            var columnIndexes = grid.getColumnIndexes(),
                view = grid.getView(),
                store = grid.store,
                errorResult = [];

            var items = store.queryBy(function (record) {
                return (record.dirty === true || record.phantom) && !record.dummy
            }).items;

            Ext.each(items, function (record) {
                if (!record.dummy) {
                    var errors = record.validate();

                    if (errors && errors.length > 0) {
                        Ext.each(columnIndexes, function (columnIndex, x) {
                            var cellErrors,
                                cell,
                                column,
                                record = this;

                            column = grid.columnManager && grid.columnManager.getHeaderByDataIndex && grid.columnManager.getHeaderByDataIndex(columnIndex) || grid.columns[x];
                            cellErrors = errors.getByField(columnIndex);

                            if (!Ext.isEmpty(cellErrors)) {
                                cell = view.getCell(record, column);
                                grid.setCellInvalid(cell, cellErrors);
                            }
                        }, record);

                        errorResult = errorResult.concat(errors);
                    }
                }
            });

            return errorResult;
        },

        dockToViewPort: function (component) {
            "use strict";

            var viewPort = Ext.ComponentQuery.query('viewport')[0],
                pnlMain = viewPort.down('#pnlMain');

            if (pnlMain) {

                var pnlIntegratedDashboard = viewPort.down('#pnlIntegratedDashboard'),
                    pnlIntegratedDashboardGridPanel = viewPort.down('#pnlIntegratedDashboardGridPanel'),
                    tabMain = viewPort.down('#tabMain'),
                    homePanelDashboard = viewPort.down('dashboard'),
                    calendarPanel = viewPort.down('calendarpanel');

                if (homePanelDashboard)
                    pnlMain.remove(homePanelDashboard);

                if (calendarPanel)
                    pnlMain.remove(calendarPanel);

                if (tabMain)
                    pnlMain.remove(tabMain);

                if (pnlIntegratedDashboard) { //existing search screen, should be hidden!!
                    if (pnlIntegratedDashboardGridPanel && viewPort.gridPanelCollection != undefined) {
                        viewPort.gridPanelCollection.add(pnlIntegratedDashboardGridPanel.type, pnlIntegratedDashboardGridPanel);
                        pnlIntegratedDashboard.setHidden(true);
                    }
                    else {
                        pnlIntegratedDashboard.setHidden(true);
                    }
                }

                var dockedItems = Ext.clone(pnlMain.items.items);
                dockedItems.forEach(function (item) {
                    if (item.isHidden && !item.isHidden()) { //module screen, remove all un specified screen
                        var cmp = Ext.getCmp(item.id);
                        if (cmp) {
                            pnlMain.remove(cmp);
                        }
                    }
                });

                pnlMain.add(component);
            }


        },

        clearViewPort: function () {
            var viewPort = Ext.ComponentQuery.query('viewport')[0],
                pnlMain = viewPort.down('#pnlMain');

            if (pnlMain) {
                var pnlIntegratedDashboard = viewPort.down('#pnlIntegratedDashboard'),
                    tabMain = viewPort.down('#tabMain');

                if (pnlIntegratedDashboard)
                    pnlIntegratedDashboard.setHidden(true);
            }
        },

        dockAnnouncementBanner: function (component) {
            var viewPort = Ext.ComponentQuery.query('viewport')[0];

            if (viewPort) {
                var pnlAnnouncementBanner = Ext.create('Ext.panel.Panel', {
                    region: 'north',
                    baseCls: 'i-white-background',
                    itemId: 'pnlAnnouncementBanner',
                    height: 71,
                    maxHeight: 250,
                    layout: 'fit'
                });

                if (component) {
                    pnlAnnouncementBanner.add(component);
                }

                viewPort.insert(0, pnlAnnouncementBanner);

            }

        },

        removeAnnouncementBanner: function () {
            var viewPort = Ext.ComponentQuery.query('viewport')[0],
                pnlAnnouncementBanner = viewPort.down('#pnlAnnouncementBanner');

            if (pnlAnnouncementBanner) {
                pnlAnnouncementBanner.destroy();
            }
        },

        updateUserMainViewPortDetail: function (config) {
            var viewPort = Ext.ComponentQuery.query('viewport')[0],
                imgUser = viewPort.down('#imgUser'),
                menuUsername = viewPort.down('#menuUsername');

            if (!config) return;

            if (config.imgPhoto && config.imgPhoto !== "") {
                imgUser.setVisible(true);
                imgUser.setSrc("data:image/jpeg;base64," + Ext.util.Base64.decode(config.imgPhoto));
            }
            //            else {
            //                imgUser.setVisible(false);
            //            }

            if (config.strName)
                menuUsername.setText(config.strName);
        },

        clearStoreFilters: function (store, silent) {
            "use strict";

            store.currentFilters = [];
            //store.suspendEvent('filterchange');

            var length = store.getFilters().items.length;
            for (var x = 0; x <= length - 1; x++) {
                var filter = store.filters.items[x];
                if (filter.config.property === store.foreignKeyName) {
                    continue;
                }

                store.currentFilters.push(filter);
            }


            var toRemoveLength = store.currentFilters.length;
            for (var x = 0; x <= toRemoveLength - 1; x++) {
                store.suppressNextFilter = !!silent;
                var filter = store.currentFilters[x];
                store.removeFilter(filter, store.suppressNextFilter);
            }
            store.suppressNextFilter = false;

            //FRM-3747 and FRM-3652
            //store collection 'filtered' property must be set to false after we cleared the filter.
            store.data.filtered = false;

            //store.resumeEvent('filterchange');
        },

        hostReachable: function () {
            // Handle IE and more capable browsers
            var xhr = new (window.ActiveXObject || XMLHttpRequest)('Microsoft.XMLHTTP');

            // Open new request as a HEAD to the root hostname with a random param to bust the cache
            xhr.open('HEAD', '//' + window.location.hostname + '/?rand=' + Math.floor((1 + Math.random()) * 0x10000), false);

            // Issue request and handle response
            try {
                xhr.send();

                return (xhr.status >= 200 && xhr.status < 300 || xhr.status === 304);
            }
            catch (error) {
                return false;
            }
        },

        openRecurring: function (transactionType, transactionId) {
            if ((!transactionType || !transactionId) ||
                (transactionType === '' || transactionId === '')) {
                return;
            }

            iRely.Functions.createScreen('i21.view.RecurringTransaction', function (win) {
                var config = {},
                    param = {},
                    transType = transactionType,
                    transId = transactionId;

                param.type = transType;
                config.param = param;

                win.controller.show(config);
                var context = win.context;

                win.controller.getViewModel().bind('{recurringTransaction}', function (store) {
                    var grdRecurring = win.down('#grdRecurring');
                    var defaultFilters = [
                        {
                            column: 'strTransactionNumber',
                            condition: 'eq',
                            conjunction: 'And',
                            value: transId,
                            displayCondition: 'Equals'
                        }
                    ];
                    grdRecurring.controller.applyFilters(defaultFilters);
                });

                //                var callback = function() {
                //                    context.data.store.un('load', callback);
                //                    Ext.defer(function(){
                //                        var grd = win.down('#grdRecurring');
                //                        grd.allColumnSearch();
                //                    },10)
                //                };
                //
                //                context.data.store.on('load', callback);
                //                context.data.load();
            });
        },

        copyToClipboard: function (text) {
            $("body").append("<input type='text' id='temp' style='position:absolute;opacity:0;'>");
            $("#temp").val(text).select();
            document.execCommand("copy");
            $("#temp").remove();
        },

        // --*** Exporting | export client raw data to file
        exportDataToFile: function (grid, type, allowHidden, allowZeroWith, includeFormat, useClientDataType, useSearchScreenDesign) {
            var me = this, win, title = '',
                selModel, displayColumns = [], columns = '',  filters, sorts,
                data = [], params = {}, aggregates = '', isSearchScreen, filterFields = [];

            if (!grid) return;
            isSearchScreen = ((grid.up('#pnlIntegratedDashboard') || grid.up('#floatingPnlIntegratedDashboard')) ? true : false) || useSearchScreenDesign;
            filters = typeof grid.controller.getAllFilterExpression === 'function' ? grid.controller.getAllFilterExpression() : [];
            sorts = typeof grid.getDefaultSort === 'function' ? grid.getDefaultSort(grid.getView()) : [];
            win = grid.up('window') ? grid.up('window') : grid.up('panel');
            title = win.title.replace(/\s+/g, ' ').trim();
            if (grid.getSelectionModel && grid.getSelectionModel().getSelection)
                selModel = grid.getSelectionModel().getSelection();

            if (selModel.length <= 0)
                selModel = grid.getStore().getRange();

            if (!selModel) return;

            if (grid.store.getFilters() && grid.store.getFilters().length > 0)
                filters.push.apply(filters, grid.store.getFilters().items);

            if (grid.store.getSorters() && grid.store.getSorters().length > 0)
                sorts.push.apply(sorts, grid.store.getSorters().items);

            var gridColumns = grid.getColumnManager().columns;
            for (var g in gridColumns) {
                var isHidden = !allowHidden ? !gridColumns[g].hidden : allowHidden;
                var isZeroWidth = !allowZeroWith ? ((typeof gridColumns[g].width === 'undefined' || gridColumns[g].width === null) ? gridColumns[g].getWidth() : gridColumns[g].width) > 0 : allowZeroWith;
                if (filters.length > 0) {
                    var col = filters.filter(function (a) { if (a.column == gridColumns[g].dataIndex) return true; });
                    if (col && col.length > 0 && !col[0].hidden) {
                        filterFields.push({ c: gridColumns[g].dataIndex, t: gridColumns[g].text });
                    }
                }
                if (isHidden && isZeroWidth) {
                    if (!gridColumns[g].dataIndex)
                        continue;
                    columns += gridColumns[g].dataIndex + ':';
                    var format = gridColumns[g].xtype.indexOf('boolean') > -1 ? Ext.String.format('{0}/{1}', gridColumns[g].trueText, gridColumns[g].falseText) :
                        gridColumns[g].config.format || gridColumns[g].config.aggregateFormat || gridColumns[g].config.colformat || gridColumns[g].colformat || gridColumns[g].format || ''
                    displayColumns.push({
                        c: gridColumns[g].dataIndex.toString().trim(),
                        t: gridColumns[g].text.toString().trim(),
                        f: format.toString().trim()
                    });
                    if (gridColumns[g].summaryRenderer && gridColumns[g].summaryType) {
                        aggregates += gridColumns[g].dataIndex + "|" + gridColumns[g].summaryType + ":"
                    }
                }
            }

            Ext.each(selModel, function (model) {
                var obj = {};
                Ext.each(displayColumns, function (column) {
                    obj[column.c] = model.data[column.c];
                });
                data.push(obj);
            });

            if (filters && filters.length > 0)
                params.filter = iRely.Functions.encodeFilters(filters);
            if (sorts && sorts.length > 0)
                params.sort = iRely.Functions.encodeSorters(sorts);
            params.filterFields = filterFields.length > 0 ? Ext.JSON.encode(filterFields) : undefined;
            params.type = type;
            params.name = title;
            params.fields = Ext.JSON.encode(displayColumns);
            params.aggregates = aggregates;
            params.isSearchScreen = isSearchScreen;
            params.includeFormat = includeFormat;
            params.companyName = iRely.config.Application.Title;
            me._exportToFile(Ext.encode(data), params, undefined, useClientDataType);
        },

        exportToFile: function (grid, type, allowHidden, allowZeroWith, customUrl, includeFormat, includeStoreExtraParams, useSearchScreenDesign) {
            var me = this, uri, total, win,
                columns = '', displayColumns = [], allColumns = '',
                title = '', filters, sorts,
                regEx = /^\.{2}\/[a-z0-9\/]+$/i,
                include, params = {}, lblTotal, aggregates = '', isSearchScreen, selectedRowsKey, selectedRecords, filterFields = [],
                storeExtraParams = '';

            if (!grid) return;
            isSearchScreen = ((grid.up('#pnlIntegratedDashboard') || grid.up('#floatingPnlIntegratedDashboard')) ? true : false) || useSearchScreenDesign;
            filters = typeof grid.getAllFilterExpression === 'function' ? grid.getAllFilterExpression() : [];
            sorts = typeof grid.getDefaultSort === 'function' ? grid.getDefaultSort(grid.getView()) : [];

            if (grid.store) {
                win = grid.up('window') ? grid.up('window') : grid.up('panel');
                title = win.title.replace(/\s+/g, ' ').trim();

                if (!customUrl) {
                    uri = grid.url ? grid.url : grid.store.baseUrl;
                    uri = (uri && regEx.test(uri)) ? uri
                        : (grid.store.getProxy().url ? grid.store.getProxy().url
                            : (grid.store.getProxy().api ? grid.store.getProxy().api.read : ''));
                    if (!regEx.test(uri) && win.context)
                        uri = win.context.data.store.getProxy().url
                            ? win.context.data.store.getProxy().url
                            : (win.context.data.store.getProxy().api
                                ? win.context.data.store.getProxy().api.read : '');
                } else {
                    uri = customUrl
                }

                if (grid.store.getFilters() && grid.store.getFilters().length > 0)
                    filters.push.apply(filters, grid.store.getFilters().items);

                if (grid.store.getSorters() && grid.store.getSorters().length > 0)
                    sorts.push.apply(sorts, grid.store.getSorters().items);

                if (grid.store.getProxy().extraParams)
                    include = grid.store.getProxy().extraParams.include ?
                        grid.store.getProxy().extraParams.include : '';

                if(grid.store.getProxy().extraParams) {
                    var tempExtraParams = Ext.clone(grid.store.getProxy().extraParams);
                    if(tempExtraParams.include) {
                        delete tempExtraParams.include;
                    }
                    storeExtraParams = Ext.encode(tempExtraParams);
                }

                if (grid.down('#lblTotalRecords') && grid.down('#lblTotalRecords').text) {
                    lblTotal = grid.down('#lblTotalRecords').text;
                    if (lblTotal.split(' ').length > 0)
                        total = parseInt(lblTotal.trim().split(' ')[0].replace(',', ''));
                } else
                    total = (grid.store.totalCount && grid.store.totalCount > 0)
                        ? grid.store.totalCount : grid.store.data.length;
            }

            if (isSearchScreen) {
                selectedRecords = grid.getSelectionModel().getSelection();
            }
            var gridColumns = grid.getColumnManager().columns;
            for (var g in gridColumns) {
                var isHidden = !allowHidden ? !gridColumns[g].hidden : allowHidden;
                var isZeroWidth = !allowZeroWith ? ((typeof gridColumns[g].width === 'undefined' || gridColumns[g].width === null) ? gridColumns[g].getWidth() : gridColumns[g].width) > 0 : allowZeroWith;
                if (filters.length > 0) {
                    var col = filters.filter(function (a) { if (a.column == gridColumns[g].dataIndex) return true; });
                    if (col && col.length > 0 && !col[0].hidden) {
                        filterFields.push({ c: gridColumns[g].dataIndex, t: gridColumns[g].text });
                    }
                }
                if (gridColumns[g].dataIndex)
                    allColumns += gridColumns[g].dataIndex + ':';
                if (isHidden && isZeroWidth) {
                    if (!gridColumns[g].dataIndex)
                        continue;
                    columns += gridColumns[g].dataIndex + ':';
                    var format = gridColumns[g].xtype.indexOf('boolean') > -1 ? Ext.String.format('{0}/{1}', gridColumns[g].trueText, gridColumns[g].falseText) :
                        gridColumns[g].config.format || gridColumns[g].config.aggregateFormat || gridColumns[g].config.colformat || gridColumns[g].colformat || gridColumns[g].format || ''
                    displayColumns.push({
                        c: gridColumns[g].dataIndex.toString().trim(),
                        t: (gridColumns[g].text.indexOf('<') > -1) ? (gridColumns[g].config.text.toString().trim() || gridColumns[g].text.toString().trim()) : gridColumns[g].text.toString().trim(),      //for custom image in header text
                        f: format.toString().trim()
                    });
                    if (gridColumns[g].summaryRenderer && gridColumns[g].summaryType) {
                        aggregates += gridColumns[g].dataIndex + "|" + gridColumns[g].summaryType + ":"
                    }
                }
                if (gridColumns[g].key && selectedRecords && selectedRecords.length > 0) {
                    selectedRowsKey = gridColumns[g].dataIndex;
                    displayColumns.push({ c: gridColumns[g].dataIndex, t: gridColumns[g].text });

                    if(columns.indexOf(Ext.String.format('{0}:', gridColumns[g].dataIndex)) < 0)
                        columns += gridColumns[g].dataIndex + ':';
                }
            }

            if (isSearchScreen && selectedRecords.length > 0 && selectedRowsKey) {
                var values = '';
                selectedRecords.forEach(function (rec) { values = values + rec.getData()[selectedRowsKey] + '|^|'; });
//                filters.push({ column: selectedRowsKey, condition: 'eq', value: values, conjunction: 'or' });
                filters.splice(0, 0, { column: selectedRowsKey, condition: 'eq', value: values, conjunction: 'or' })
            }
            params.page = 1;
            params.start = 0;
            params.limit = total;
            params.columns = columns;
            params.allColumns = allColumns;
            if (filters && filters.length > 0)
                params.filter = iRely.Functions.encodeFilters(filters);
            if (sorts && sorts.length > 0)
                params.sort = iRely.Functions.encodeSorters(sorts);
            if (include && include.length > 0)
                params.include = include;
            params.url = uri;
            params.name = title;
            params.type = type;
            params.fields = Ext.JSON.encode(displayColumns);
            params.aggregates = aggregates;
            params.isSearchScreen = isSearchScreen;
            params.selectedRowsKey = selectedRowsKey ? selectedRowsKey : undefined;
            params.filterFields = filterFields.length > 0 ? Ext.JSON.encode(filterFields) : undefined;
            params.includeFormat = includeFormat;
            params.companyName = iRely.config.Application.Title;
            params.includeStoreExtraParams = includeStoreExtraParams;
            params.storeExtraParams = storeExtraParams;

            me._exportToFile(null, params, 'POST');
        },
        
        _exportToFile: function (data, parameter, method, useClientDataType) {
            var me = this,
                methodType = !method ? 'POST' : method, name = '',
                viewPort = Ext.ComponentQuery.query('viewport')[0],
                url = (method && method !== 'POST')
                    ? '../globalcomponentengine/api/export/get'
                    : '../globalcomponentengine/api/export/post',
                xhr = !window.XMLHttpRequest ? new ActiveXObject('Microsoft.XMLHTTP') : new XMLHttpRequest();

            if (data && data !== null && data !== undefined) {
                url += '?isData=true';
                if (useClientDataType && useClientDataType !== null && useClientDataType !== undefined)
                    url += '&useClientDataType=true';
            }

            iRely.Msg.showWait('Exporting...');

            var newTitle = '',
                today = new Date(),
                dateFormat = today.getFullYear() + '-';

            dateFormat += today.getMonth() < 10 ? ('0' + (today.getMonth() + 1) + '-') : (today.getMonth() + 1) + '-';
            dateFormat += today.getDate() + ' ';
            dateFormat += today.getHours();
            dateFormat += today.getMinutes();
            dateFormat += today.getMilliseconds();

            name = parameter.name + ' ' + dateFormat;
            switch (parameter.type) {
                case "excel":
                case "xls":
                    newTitle += name + ".xls";
                    break;
                case "pdf":
                    newTitle += name + ".pdf";
                    break;
                case "csv":
                    newTitle += name + ".csv";
                    break;
                case "txt":
                    newTitle += name + ".txt";
                    break;
                case "word":
                case "doc":
                    newTitle += name + ".doc";
                    break;
            }
            xhr.open(methodType, url, true);
            xhr.setRequestHeader('Content-Type', 'application/json');
            xhr.setRequestHeader('Authorization', iRely.Configuration.Security.AuthToken);
            xhr.responseType = 'blob';

            var obj = {
                params: {
                    page: parameter.page,
                    start: parameter.start,
                    limit: parameter.limit,
                    columns: parameter.columns,
                    filter: parameter.filter,
                    sort: parameter.sort,
                    include: parameter.include,
                    aggregates: parameter.aggregates
                },
                url: parameter.url,
                name: parameter.name,
                type: parameter.type,
                fields: parameter.fields,
                data: data,
                clientDateTime: today.toLocaleString(),
                isSearchScreen: parameter.isSearchScreen,
                selectedRowsKey: parameter.selectedRowsKey,
                filterFields: parameter.filterFields,
                allColumns: parameter.allColumns,
                includeFormat: parameter.includeFormat,
                companyName: parameter.companyName,
                globalNumberFormat: iRely.Configuration.Application.NumberFormat,
                includeStoreExtraParams: parameter.includeStoreExtraParams,
                storeExtraParams: parameter.storeExtraParams
            };

            xhr.onreadystatechange = function () {
                if (this.readyState == 4) {
                    if (this.readyState == 4 && this.status == 200) {
                        var blobURL = window.URL.createObjectURL(this.response),
                            anchor = document.createElement('a');
                        anchor.download = newTitle;
                        anchor.href = blobURL;
                        anchor.click();
                        iRely.Msg.hide();
                    } else if (this.readyState == 4 && this.status != 200) {
                        me.getExportMessage(obj, methodType, url);
                    }
                }
            };
            xhr.send(Ext.encode(obj));
        },

        getExportMessage: function (obj, methodType, url) {
            var xhr = !window.XMLHttpRequest ? new ActiveXObject('Microsoft.XMLHTTP') : new XMLHttpRequest();
            xhr.open(methodType, url, true);
            xhr.setRequestHeader('Content-Type', 'application/json');
            xhr.setRequestHeader('Authorization', iRely.Configuration.Security.AuthToken);
            xhr.responseType = 'json';
            xhr.onloadend = function () {
                if (this.readyState == 4 && this.status != 200) {
                    iRely.Msg.hide();
                    var message = '';
                    if (typeof (this.response) == 'object')
                        message = this.response.Message + (this.response.ExceptionMessage ? ('<br>' + this.response.ExceptionMessage) : '');
                    else
                        message = this.response;

                    i21.functions.showErrorDialog(message);
                }
            }
            xhr.send(Ext.encode(obj));
        },

        exportStringToFile: function (strMessage, type, fileName) {
            var me = this,
                methodType = 'POST',
                viewPort = Ext.ComponentQuery.query('viewport')[0],
                url = '../globalcomponentengine/api/export/stringtofile',
                xhr = !window.XMLHttpRequest ? new ActiveXObject('Microsoft.XMLHTTP') : new XMLHttpRequest(),
                name, title;

            if (!type || !strMessage || strMessage == '') {
                return;
            }

            iRely.Msg.showWait(Ext.String.format('Exporting File to {0}...', type.toUpperCase()));

            name = (fileName != '' && fileName != undefined) ? fileName : 'Exported File';
            switch (type) {
                case "excel":
                case "xls":
                    title = name + ".xls";
                    break;
                case "pdf":
                    title = name + ".pdf";
                    break;
                case "csv":
                    title = name + ".csv";
                    break;
                case "word":
                case "doc":
                    title = name + ".doc";
                    break;
            }
            xhr.open(methodType, url, true);
            xhr.setRequestHeader('Content-Type', 'application/json');
            xhr.setRequestHeader('Authorization', iRely.Configuration.Security.AuthToken);
            xhr.responseType = 'blob';

            var obj = {
                name: name,
                type: type,
                stringToExport: strMessage
            };

            xhr.onreadystatechange = function () {
                if (this.readyState == 4) {
                    if (this.readyState == 4 && this.status == 200) {
                        var blobURL = window.URL.createObjectURL(this.response),
                            anchor = document.createElement('a');
                        anchor.download = title;
                        anchor.href = blobURL;
                        anchor.click();
                        iRely.Msg.hide();
                    } else if (this.readyState == 4 && this.status != 200) {
                        me.getExportMessage(obj, methodType, url);
                    }
                }
            };
            xhr.send(Ext.encode(obj));
        },

        createFileFromString: function (options) {
            options = options || {};

            var fileName = options.fileName,
                fileType = options.fileType,
                message = options.message,
                xhr = !window.XMLHttpRequest ? new ActiveXObject('Microsoft.XMLHTTP') : new XMLHttpRequest(),
                name, title;

            if (!fileType || !message) {
                return;
            }

            name = fileName ? fileName : 'Exported File';

            switch (fileType) {
                case "excel":
                case "xls":
                    title = name + ".xls";
                    break;
                case "pdf":
                    title = name + ".pdf";
                    break;
                case "csv":
                    title = name + ".csv";
                    break;
                case "word":
                case "doc":
                    title = name + ".doc";
                    break;
            }

            return new Promise(function (resolve, reject) {
                xhr.open('POST', '../globalcomponentengine/api/export/stringtofile', true);
                xhr.setRequestHeader('Content-Type', 'application/json');
                xhr.setRequestHeader('Authorization', iRely.Configuration.Security.AuthToken);
                xhr.responseType = 'blob';

                xhr.onreadystatechange = function () {
                    var me = this;
                    if (me.readyState == 4 && me.status == 200) {
                        var file = me.response;
                        file.name = title;
                        resolve(file);
                    }
                };
                xhr.onerror = reject;

                xhr.send(Ext.encode({
                    name: name,
                    type: fileType,
                    stringToExport: message
                }));
            });


        },

        getItemTaxes: function (current, computeTaxFunction, scope) {
            var me = scope || this,
                itemId = current.ItemId,
                locationId = current.LocationId || 0,
                transactionDate = current.TransactionDate,
                transactionType = current.TransactionType,
                entityId = current.EntityId || 0,
                taxGroupId = current.TaxGroupId || null,
                billShipToLocationId = current.BillShipToLocationId || null,
                freightTermId = current.FreightTermId || null,
                cardId = current.CardId || null,
                vehicleId = current.VehicleId || null,
                includeExemptedCodes = current.IncludeExemptedCodes || false,

                itemTaxParam = {
                    ItemId: itemId,
                    LocationId: locationId,
                    TransactionDate: transactionDate,
                    TransactionType: transactionType,
                    EntityId: entityId,
                    TaxGroupId: taxGroupId,
                    BillShipToLocationId: billShipToLocationId,
                    FreightTermId: freightTermId,
                    CardId: cardId,
                    VehicleId: vehicleId,
                    IncludeExemptedCodes: includeExemptedCodes
                };

            Ext.Ajax.request({
                url: '../i21/api/TaxCode/GetItemTaxes',
                headers: { Authorization: createIdentityToken(app.UserName, app.Password, app.Company, app.ID) },
                contentType: 'application/json; charset=utf-8',
                jsonData: {},
                dataType: 'json',
                method: 'GET',
                params: {
                    itemTax: Ext.encode(itemTaxParam)
                },
                success: function (response) {
                    var responseData = Ext.decode(response.responseText);
                    var detailTaxes = new Array();

                    if (responseData.data) {
                        for (var itemTax in responseData.data) {
                            var itemDetailTax = {
                                intTransactionDetailTaxId: responseData.data[itemTax].intTransactionDetailTaxId,
                                intTransactionDetailId: responseData.data[itemTax].intTransactionDetailId,
                                //                                intTaxGroupMasterId: responseData.data[itemTax].intTaxGroupMasterId,
                                intTaxGroupId: responseData.data[itemTax].intTaxGroupId,
                                intTaxCodeId: responseData.data[itemTax].intTaxCodeId,
                                intTaxClassId: responseData.data[itemTax].intTaxClassId,
                                strTaxCode: responseData.data[itemTax].strTaxCode,
                                strTaxableByOtherTaxes: responseData.data[itemTax].strTaxableByOtherTaxes,
                                strCalculationMethod: responseData.data[itemTax].strCalculationMethod,
                                dblRate: responseData.data[itemTax].dblRate,
                                dblTax: responseData.data[itemTax].dblTax,
                                dblAdjustedTax: responseData.data[itemTax].dblAdjustedTax,
                                intTaxAccountId: responseData.data[itemTax].intTaxAccountId,
                                ysnTaxAdjusted: responseData.data[itemTax].ysnTaxAdjusted,
                                ysnSeparateOnInvoice: responseData.data[itemTax].ysnSeparateOnInvoice,
                                ysnCheckoffTax: responseData.data[itemTax].ysnCheckoffTax,
                                ysnTaxExempt: responseData.data[itemTax].ysnTaxExempt,
                                strTaxGroup: responseData.data[itemTax].strTaxGroup,
                                strNotes: responseData.data[itemTax].strNotes
                            };
                            detailTaxes.push(itemDetailTax);
                        }
                    }

                    if (computeTaxFunction)
                        computeTaxFunction(detailTaxes, me);
                }
            });
        },

        updateIRelySecurityConfiguration: function (config) {
            if (!config) return;

            try {
                iRely.config.Security[config.property] = config.value;
                app[config.property] = config.value;
            }
            catch (err) {
                return;
            }
        },

        /**
         * Send email to multiple recipient
         * @param  {String}   toEmails List of emails delimited by a comma or semicolon
         * @param  {String}   subject  The subject of the email
         * @param  {String}   message  The body of the email
         * @param  {Function} callback The callback function to be executed when request succeeded or failed
         */
        sendEmail2: function (toEmails, subject, message, callback) {
            Ext.Ajax.request({
                method: 'POST',
                url: '../GlobalComponentEngine/api/emailurl/send',
                timeout: 240000,
                header: {
                    'Content-Type': 'application/json'
                },
                jsonData: {
                    ToEmail: toEmails,
                    Subject: subject,
                    Message: message
                },

                callback: function (options, success, response) {
                    if (typeof (callback) == 'function')
                        callback(success);
                }
            });
        },

        startsWith: function (str, searchString) {
            var position = position || 0;

            if (String.prototype.startsWith)
                return str.startsWith(searchString);
            return str.indexOf(searchString, position) === position;
        },

        addRecurringTransaction: function (transaction) {
            var storeName = 'i21.store.RecurringTransaction',
                formatter = Ext.create('iRely.formatter.Recurring');

            if (!transaction || !transaction.dirty)
                return;

            transaction.set('strFrequency', 'Monthly');
            transaction.set('dtmLastProcess', formatter.resetHour(new Date(transaction.get('dtmLastProcess'))));
            transaction.set('strDayOfMonth', new Date(transaction.get('dtmLastProcess')).getDate());
            transaction.set('ysnActive', true);
            transaction.set('intIteration', 1);
            transaction.set('ysnAvailable', true);
            transaction.set('strAssignedUser', iRely.config.Security.FullName);
            transaction.set('intEntityId', iRely.config.Security.EntityId);

            formatter.adjustDates(transaction, '');
            formatter.setDue(transaction);

            var action = function () {
                var store = Ext.create(storeName);

                store.add(transaction)
                store.sync();
            };

            if (Ext.ClassManager.isCreated(storeName))
                action();
            else
                Ext.require([storeName], action);
        },

        getQueryStringValue: function (param) {

            var hash = window.location.hash,
                ioQM = hash.indexOf('?'),
                qs = !!~ioQM ? hash.substring(ioQM + 1) : '',
                objQS = qs.length ? Ext.Object.fromQueryString(qs, true) : {};

            return objQS[param] || undefined;

        },

        setUriFiltersToCurrentRecord: function (id, hash, queryStringPropertyReplacement) {

            hash = hash || window.location.hash;
            queryStringPropertyReplacement = queryStringPropertyReplacement || {};

            var ioQM = hash.indexOf('?'),
                uri = !!~ioQM ? hash.substring(0, ioQM + 1) : hash + '?',
                queryString = !!~ioQM ? hash.substring(ioQM + 1) : '',
                objQueryString = !!queryString ? Ext.Object.fromQueryString(queryString, true) : {},
                matchedFilters = [],
                ultimateFilter, newQueryString;

            if (typeof id !== 'number' || !parseInt(id))
                return hash;

            if (objQueryString) {
                if (typeof objQueryString.filters === 'object' && objQueryString.filters.length) {

                    objQueryString.filters.forEach(function (item) {
                        if (/\b(?:int)/.test(item.column) && /\d(?:\|\^\|)/.test(item.value)) {
                            matchedFilters.push(item);
                        }
                    });

                    if (matchedFilters.length) {

                        ultimateFilter = matchedFilters[0];
                        ultimateFilter.value = id;

                        objQueryString.filters = new Array(ultimateFilter);

                    }

                }
            }

            Ext.apply(objQueryString, queryStringPropertyReplacement);

            newQueryString = uri + Ext.Object.toQueryString(objQueryString, true);

            return newQueryString;

        },

        /**
         * Add calendar event programmatically
         * @param {GCE.model.Event} eventData   Event data.
         * @param {Array}           invitees    List of entityId of the users as the default invitees of the event.
         * @param {Function}        callback    Callback function.
         *
         * Example eventData:
         *
         * Ext.create('GlobalComponentEngine.model.Event', {
         *      'intEntityId'    : iRely.Configuration.Security.EntityId,
         *      'strEventTitle'  : title,
         *      'strEventDetail' : details,
         *      'dtmStart'       : moment.utc(startDate).toDate(),
         *      'dtmEnd'         : moment.utc(endDate).toDate(),
         *      'strJsonData'    : JSON.stringify(additionalProperties || {}),
         *      'strScreen'      : namespace,
         *      'strRecordNo'    : recordNo
         * });
         *
         */
        addToCalendar: function (eventData, invitees, callback) {

            callback = (typeof callback === 'function') && callback || Ext.emptyFn;

            var me = this;

            Ext.Ajax.request({

                url: '../GlobalComponentEngine/api/Event/Post',
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                jsonData: [eventData.data],

                success: function (response, opts) {

                    var jsonRes = JSON.parse(response.responseText),
                        data = jsonRes.data[0],
                        inviteesData = [];

                    if (invitees && invitees.length) {

                        invitees.forEach(function (id) {
                            inviteesData.push({
                                intEventId: data.intEventId,
                                intEntityId: id,
                            });
                        });

                        Ext.Ajax.request({
                            url: '../GlobalComponentEngine/api/Event/SyncInvitees',
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                            params: { eventId: data.intEventId },
                            jsonData: inviteesData
                        });

                    }

                },
                callback: function (options, success, response) {
                    callback(success);
                }

            });

        },

        getCurrencyExchangeRateDetail: function (currencyExchangeRateId, rateTypeId, validFromDate, callback) {
            var _currencyExchangeRateId = currencyExchangeRateId,
                _rateTypeId = rateTypeId,
                _validFromDate = new Date(validFromDate);

            Ext.Ajax.request({
                url: '../i21/api/CurrencyExchangeRate/GetCurrencyExchangeRateDetail',
                headers: { Authorization: createIdentityToken(app.UserName, app.Password, app.Company, app.ID) },
                contentType: 'application/json; charset=utf-8',
                method: 'GET',
                params: {
                    currencyExchangeRateId: Ext.encode(_currencyExchangeRateId),
                    rateTypeId: Ext.encode(_rateTypeId),
                    validFromDate: _validFromDate
                },
                success: function (response) {
                    var responseData = Ext.decode(response.responseText);
                    var currencyExchangeRateDetails = new Array();

                    if (responseData.data) {
                        for (var index in responseData.data) {
                            var currencyExchangeRateDetail = {
                                intCurrencyExchangeRateDetailId: responseData.data[index].intCurrencyExchangeRateDetailId,
                                dblRate: responseData.data[index].dblRate,
                                dtmValidFromDate: responseData.data[index].dtmValidFromDate,
                                intCurrencyExchangeRateId: responseData.data[index].intCurrencyExchangeRateId,
                                intRateTypeId: responseData.data[index].intRateTypeId,
                                strFromCurrency: responseData.data[index].strFromCurrency,
                                strFromToCurrency: responseData.data[index].strFromToCurrency,
                                strRateType: responseData.data[index].strRateType,
                                strRateTypeDescription: responseData.data[index].strRateTypeDescription,
                                strToCurrency: responseData.data[index].strToCurrency
                            };
                            currencyExchangeRateDetails.push(currencyExchangeRateDetail);
                        }
                    }

                    if (callback)
                        callback(currencyExchangeRateDetails);
                }
            });
        },

        getForexRate: function (fromCurrencyId, rateTypeId, validFromDate, successCallback, failureCallback) {
           var _fromCurrencyId = fromCurrencyId,
               _functionalCurrency = i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId'),
               _rateTypeId = rateTypeId,
               _validFromDate = new Date(validFromDate);

            Ext.Ajax.request({
                url: '../i21/api/CurrencyExchangeRate/GetForexRate',
                headers: { Authorization: createIdentityToken(app.UserName, app.Password, app.Company, app.ID) },
                contentType: 'application/json; charset=utf-8',
                method: 'GET',
                params: {
                    fromCurrencyId: Ext.encode(_fromCurrencyId),
                    functionalCurrency: Ext.encode(_functionalCurrency),
                    rateTypeId: Ext.encode(_rateTypeId),
                    validFromDate: _validFromDate
                },
                success: function (response) {
                    var responseData = Ext.decode(response.responseText);
                    var currencyExchangeRateDetails = new Array();

                    if (responseData.data) {
                        for (var index in responseData.data) {
                            var currencyExchangeRateDetail = {
                                intCurrencyExchangeRateDetailId: responseData.data[index].intCurrencyExchangeRateDetailId,
                                dblRate: responseData.data[index].dblRate,
                                dtmValidFromDate: responseData.data[index].dtmValidFromDate,
                                intCurrencyExchangeRateId: responseData.data[index].intCurrencyExchangeRateId,
                                intRateTypeId: responseData.data[index].intRateTypeId,
                                strFromCurrency: responseData.data[index].strFromCurrency,
                                strFromToCurrency: responseData.data[index].strFromToCurrency,
                                strRateType: responseData.data[index].strRateType,
                                strRateTypeDescription: responseData.data[index].strRateTypeDescription,
                                strToCurrency: responseData.data[index].strToCurrency
                            };
                            currencyExchangeRateDetails.push(currencyExchangeRateDetail);
                        }
                    }

                    if (successCallback)
                        successCallback(currencyExchangeRateDetails);
                },
                failure: function (response, options) {
                    if(failureCallback) 
                        failureCallback('An error occured retrieving the Forex Rate...');
                }
            });
        },

        sendEmailToEntity: function (toEntityIdList, ccEntityIdList, bccEntityIdList, subject, message, screen, messageType, filter, entityId, callback) {

            if (Ext.isEmpty(iRely.config.Security.AuthToken)) {
                Ext.data.Connection.prototype._defaultHeaders = {
                    'Authorization': createIdentityToken(
                        iRely.config.Security.UserName,
                        iRely.config.Security.Password,
                        iRely.config.Security.Company,
                        iRely.config.Security.UserId,
                        iRely.config.Security.EntityId
                    )
                };
            }

            Ext.Ajax.request({
                url: '../globalcomponentengine/api/transaction/post',
                method: 'POST',
                jsonData: [
                    {
                        strNamespace: 'GlobalComponentEngine.view.ActivityEmail',
                        strRecordNo: '0',
                        dtmDate: new Date()
                    }
                ],
                headers: { 'Content-Type': 'application/json; charset=UTF-8' }

            }).then(function (response) {

                var respObj = Ext.decode(response.responseText);

                var me = this,
                    newDate = new Date(),
                    activity = Ext.create('GlobalComponentEngine.model.Activity', {
                        strNamespace: 'GlobalComponentEngine.view.ActivityEmail',
                        strKeyValue: '0',
                        strType: "Email",
                        strPriority: 'Normal',
                        dtmStartDate: new Date(newDate.getFullYear(), newDate.getMonth(), newDate.getDate(), 12, 0, 0),
                        dtmStartTime: new Date(newDate.getFullYear(), newDate.getMonth(), newDate.getDate(), 12, 0, 0),
                        dtmEndDate: new Date(newDate.getFullYear(), newDate.getMonth(), newDate.getDate(), 12, 0, 0),
                        dtmEndTime: new Date(newDate.getFullYear(), newDate.getMonth(), newDate.getDate(), 12, 0, 0),
                        dtmCreated: newDate,
                        strCreatedBy: iRely.Configuration.Security.UserName,
                        intCreatedBy: iRely.Configuration.Security.EntityId,
                        strStatus: 'New',
                        strSubject: subject,
                        strDetails: message,
                        strMessageType: 'HTML',
                        strFilter: filter || JSON.stringify([{ column: 'intEntityId', condition: 'eq', value: toEntityIdList.join('|^|') }])
                    });

                // Initialize the association
                var emailRecipient = activity['tblSMEmailRecipients']();

                var appendRecipients = function (ids, type) {
                    for (var i in ids) {
                        emailRecipient.add({
                            intEntityContactId: ids[i],
                            strRecipientType: type
                        });
                    }
                };

                appendRecipients(toEntityIdList, 'TO');
                appendRecipients(ccEntityIdList, 'CC');
                appendRecipients(bccEntityIdList, 'BCC');

                var store = Ext.create('GlobalComponentEngine.store.Activity');
                var proxy = store.getProxy(),
                    writer = Ext.create('iRely.writer.JsonBatch', {
                        allowSingle: false,
                        nameProperty: 'mapping'
                    });

                proxy.setWriter(writer);
                proxy.batchActions = true;

                store.add(activity);
                store.sync({
                    callback: function (batch, eOpts, success) {
                        Ext.Ajax.request({
                            url: '../globalcomponentengine/api/email/send?emailId=' + store.data.items[0].get('intActivityId'),
                            method: 'POST',
                            success: function (response, opts) {
                                if (response.responseText !== '"success"') {
                                    if (callback) callback();
                                }
                            },
                            failure: function (response, opts) {
                            }
                        });
                    }
                });
            });
        },

        openEmailScreen: function (data) {
            if (data.filters == null) {
                console.log('Please provide a filter for entity store.');
                return;
            }
            else {
                data.filters.push({ column: 'strEmail', condition: 'noteq', value: '', conjunction: 'and' });
            }

            if (data.parentId == null || Ext.isEmpty(data.screenName))
                return;

            iRely.Functions.openScreen('GlobalComponentEngine.view.ActivityEmail', {
                action: 'new',
                parentId: data.parentId,
                subject: data.subject,
                message: data.message,
                recipientFilters: data.filters,//[{ column: 'ysnDefaultContact', condition: 'eq', value: true }, { column: 'User', condition: 'eq', value: '1', conjunction: 'and' }]
                files: data.files,
                selectAll: data.selectAll,
                screenName: data.screenName,
                defaultSender: data.defaultSender,
                defaultRecipient: data.defaultRecipient,
                callback: data.callback
            });
        },

        formatPhoneNumber: function (value, country) {

            var filters = [{
                column: 'strCountry',
                value: country,
                condition: 'eq',
                conjunction: 'and'
            }];

            return new Promise(function (resolve, reject) {
                Ext.Ajax.request({
                    url: '../i21/api/Country/GetCountries',
                    method: 'GET',
                    params: {
                        filter: iRely.Functions.encodeFilters(filters)
                    },

                    success: function (response, options) {

                        var resp = Ext.decode(response.responseText),
                            data, newValue, countryValue, areaCityValue, localNumberValue;

                        if (resp.total) {

                            data = resp.data[0];

                            newValue = normalize(value, data);
                            countryValue = format(newValue.substr(0, data.strCountryCode.length), data.strCountryFormat); // Country format
                            areaCityValue = format(newValue.substr(data.strCountryCode.length, 3), data.strAreaCityFormat); // Area city format
                            localNumberValue = format(newValue.substr(data.strCountryCode.length + 3), data.strLocalNumberFormat); // Local number format
                            newValue = countryValue.concat(areaCityValue, localNumberValue);

                            resolve(newValue);

                        }
                        else {
                            reject('Invalid country!');
                        }

                    },
                    failure: function (response, options) {
                        reject('An error occured retrieving the country info...');
                    }
                });
            });

            /* --------------- Functions --------------- */

            function normalize(value, data) {

                value = value.replace(/\D/g, '');

                if (value.search(data.strCountryCode) !== 0)
                    value = data.strCountryCode + value;

                return value;

            }

            function format(value, format) {

                format = format.toLowerCase();

                switch (format) {
                    case 'dash':
                        return value + '-';
                    case 'space':
                        return value + ' ';
                    case 'parentheses':
                        return '(' + value + ')';
                    case 'parentheses + space':
                        return '(' + value + ') ';
                    case 'period':
                        return value + '.';
                    case '3 + dash':
                        return value.substr(0, 3) + '-' + value.substr(3);
                    case '4 + dash':
                        return value.substr(0, 4) + '-' + value.substr(4);
                    case '3 + space':
                        return value.substr(0, 3) + ' ' + value.substr(3);
                    case '4 + space':
                        return value.substr(0, 4) + ' ' + value.substr(4);
                    case '3 + period':
                        return value.substr(0, 3) + '.' + value.substr(3);
                    case '4 + period':
                        return value.substr(0, 4) + '.' + value.substr(4);
                    case 'none':
                        return value;
                    default:
                        return value;
                }

            }

        },




        /**
         * Disconnected Model {
         * Below are the methods used by Disconnected Model
         */
        exportOfflineRecords: function () {
            iRely.Functions.showCustomDialog('warning', 'yesno', 'Offline records will be deleted after exporting. Continue?', function (button) {

                if (button !== 'yes')
                    return;

                iRely.IndexedDb.db.offlineRequests.toArray()
                    .then(function (result) {
                        saveAs(new Blob([JSON.stringify(result)], { type: 'application/json;charset=utf-8' }), 'i21 Offline Records.json');
                        iRely.Functions.showCustomDialog('information', 'ok', 'Offline records had been exported successfully.');
                        indexedDB.deleteDatabase('i21');
                    });

            });
        },

        checkConnectionState: function (callback) {

            callback = (typeof callback === 'function') && callback || Ext.emptyFn;

            var me = this,
                myMsg = Ext.create('Ext.window.MessageBox', {
                    width: 300,
                    modal: true,
                    closable: false
                });

            var onConfirmedUp = function () {

                Offline.off('confirmed-up', onConfirmedUp);
                Offline.off('confirmed-down', onConfirmedDown);

                myMsg.destroy();

                callback('up');

            };

            var onConfirmedDown = function () {

                Offline.off('confirmed-down', onConfirmedDown);
                Offline.off('confirmed-up', onConfirmedUp);

                myMsg.destroy();

                callback('down');

            };

            myMsg.show()
                .wait('', 'iRely i21', {
                    interval: 1000,
                    increment: 15,
                    text: 'Checking connection state...'
                });

            Offline.on('confirmed-up', onConfirmedUp);
            Offline.on('confirmed-down', onConfirmedDown);
            Offline.check();

        },

        syncServerLocalDb: function (callback) {

            callback = ((typeof callback === 'function') && callback) || Ext.emptyFn;

            var me = this,
                myMsg = Ext.create('Ext.window.MessageBox', {
                    width: 300,
                    modal: true,
                    closable: false
                });

            myMsg.show()
                .wait('', 'iRely i21', {
                    interval: 1000,
                    increment: 15,
                    text: 'Updating local environment...'
                });

            Ext.Ajax.request({
                url: '../i21/api/OfflineConfiguration/SyncTables',
                method: 'GET',
                timeout: 999999999,
                callback: function (opts, success, response) {

                    var jsonRes = !Ext.isEmpty(response.responseText) ? JSON.parse(response.responseText) : { message: 'Error updating local environment' };

                    myMsg.destroy();

                    if (jsonRes.success)
                        iRely.Functions.showCustomDialog('information', 'ok', jsonRes.message, callback);
                    else
                        iRely.Functions.showCustomDialog('warning', 'ok', jsonRes.message, callback);

                }
            });

        },

        syncOfflineRecords: function (callback) {

            callback = ((typeof callback === 'function') && callback) || Ext.emptyFn;

            if (!localStorage.getItem('i21OnlineServerUrl')) {
                iRely.Functions.showErrorDialog('No settings found for Online Server URL. Please specify your Online Server URL before syncing your Offline Records.');
                return;
            }

            var me = this,
                failedRecordKeys = [],
                myMsg = Ext.create('Ext.window.MessageBox', {
                    width: 300,
                    modal: true,
                    closable: false
                });

            myMsg.show()
                .wait('', 'iRely i21', {
                    interval: 1000,
                    increment: 15,
                    text: 'Syncing records...'
                });

                
            Ext.Ajax.request({
                url: '../i21/api/OfflineLog/GetOfflineData?contextId=' + iRely.Notification.hub.connection.id,
                method: 'GET',
                timeout: 24000,
                headers: {
                    Authorization: iRely.Configuration.Security.AuthToken,
                    ICompany: iRely.Configuration.Security.Company
                },
                success: function (response, options) {
                    // var result = Ext.decode(response.responseText);
                    // if (result.success) {

                    // }
                }, 
                callback: function (options, success, response) {
                    var result = Ext.decode(response.responseText),
                        record = result.data,
                        count = result.count;
                  //  debugger
                    //lock recrds
                   // me.setOfflineFlag(true);
                   // debugger
                    if (count) {
                        Ext.Array.forEach(record, function (data, index) {
                            //iRely.Notification.sendToAll({funcName:'lockOfflineRecord',isLockOfflineRecord:true});
                            var jsonData = JSON.parse(data.strData);
                            var recordObj = [];
                            Ext.Ajax.request({
                                url: localStorage.getItem('i21OnlineServerUrl') + data.strUrl.replace('../', ''),//data.strUrl,
                                method: data.strMethod,
                                timeout: 60000,
                                headers: {
                                    Authorization: 'Bearer ' + iRely.Configuration.Security.EntityId,
                                    ICompany: iRely.Configuration.Security.Company
                                },
                                jsonData: [jsonData],
                                success: function (response, options) {
                                    var jsonRes = Ext.decode(response.responseText),
                                        status = jsonRes.message.status;
                                    if (jsonRes.success)
                                        recordObj.push({
                                            intOfflineLogId: data.intOfflineLogId,
                                            ysnSent: true, strUrl: data.strUrl,
                                            strDetails: 'Successful'
                                        });
                                    else {
                                        recordObj.push(
                                            {
                                                intOfflineLogId: data.intOfflineLogId,
                                                ysnSent: false, strUrl: data.strUrl,
                                                strDetails: jsonRes.message.status
                                            });
                                        if (status.includes('UNIQUE KEY') && status.includes('strOfflineGuid')) {
                                            recordObj[0].ysnSent = true;
                                            recordObj[0].strDetails = 'Successful';
                                        }
                                        else if (status.includes('UNIQUE KEY')) {
                                            recordObj[0].strDetails = 'Cannot insert duplicate key value.';
                                        }
                                    }

                                },
                                failure: function (response, options) {
                                    //debugger
                                    recordObj.push({
                                        intOfflineLogId: data.intOfflineLogId,
                                        ysnSent: false, strUrl: data.strUrl,
                                        strDetails: response.status
                                    });

                                    if (response.status.includes('UNIQUE KEY') &&
                                        status.includes('strOfflineGuid')) { recordObj[0].ysnSent = true; }

                                },
                                callback: function (options, success, response) {
                                    updateOfflineRecords(recordObj, index,
                                        jsonData, record, callback);


                                    if (index === (record.length - 1)) {
                                        myMsg.destroy();
                            


                                    }
                                }
                            })
                        });
                    }
                    else {
                        myMsg.destroy();
                        iRely.Functions.showCustomDialog('warning', 'ok', 'You have no pending offline records to be synced!', callback);
                    }
                }


            });
             /***FUNCTIONS*/
            function updateOfflineRecords(recordId, recordIndex, jsonData, allrecord, callback) {

                callback = ((typeof callback === 'function') && callback) || Ext.emptyFn;

                if (recordId.length) {
                    Ext.Ajax.request({
                        url: '../i21/api/OfflineLog/UpdateOfflineRecord',
                        method: 'PUT',
                        timeout: 600000,
                        headers: {
                            Authorization: iRely.Configuration.Security.AuthToken,//'Bearer ' + iRely.Configuration.Security.EntityId,
                            ICompany: iRely.Configuration.Security.Company
                        },
                        jsonData: recordId,
                        success: function (response, options) {
                            var s = response;
                        },
                        failure: function (response, options) {
                            var s = response;
                        },
                        callback: function (options, success, response) {
                     
                            var failCounter = 0;
                            if (success) {
                                xhook.disable();
                                Ext.Array.forEach(recordId, function (data, index) {
                                    var ysnSent = data.ysnSent,
                                        recordURL = data.strUrl;

                                    if (ysnSent) {
                                        Ext.Ajax.request({
                                            url: recordURL.substring(0, recordURL.lastIndexOf('/')) + '/Delete',
                                            method: 'DELETE',
                                            timeout: 600000,
                                            headers: {
                                                Authorization: iRely.Configuration.Security.AuthToken,
                                                ICompany: iRely.Configuration.Security.Company
                                            },
                                            jsonData: [jsonData], //[param.data],
                                            success: function (response, options) {
                                               // console.log('Delete ticket successful');
                                            },
                                            failure: function (response, option) {
                                            },
                                            callback: function (options, success, response) {
                                            }

                                        })
                                    }
                                    else {
                                        failCounter++;

                                    }

                                });
                                if (recordIndex === allrecord.length - 1) {
                     
                                    if (!failCounter) {
                                        iRely.Functions.showCustomDialog('information', 'ok', 'Offline records had been synced successfully.', callback);
                                    }
                                    else {
                                        iRely.Functions.showCustomDialog('warning', 'ok', 'Syncing has finished with error. Some of the records has not been synced with the server.');
                                        xhook.disable();
                                       // iRely.Functions.toggleSwitchOnOfflineButton();
                                       // iRely.Offline.reloadMenu(); 
                             
                                    }

                                 


                                }
                            }

                        }
                    })
                }
                else callback();
            }

        },
           setOfflineFlag: function (isLock) {
            Ext.Ajax.request({
                url: '../i21/api/OfflineLog/UpdateOfflineFlag?isLock=' + isLock,
                method: 'PUT',
                timeout: 600000,
                headers: {
                    Authorization: iRely.Configuration.Security.AuthToken,
                    ICompany: iRely.Configuration.Security.Company
                },
                success: function (response, options) {
                  
                },
                failure: function (response, options) {
                  
                },
                callback: function (options, success, response) {
     
                }
            });
        },
            getOfflineRequestCount: function (callback) {

            callback = (typeof callback === 'function') && callback || Ext.emptyFn;
            Ext.Ajax.request({
                url: '../i21/api/OfflineLog/GetOfflineData?contextId=' + iRely.Notification.hub.connection.id,
                method: 'GET',
                timeout: 24000,
                headers: {
                    Authorization: iRely.Configuration.Security.AuthToken,
                    ICompany: iRely.Configuration.Security.Company
                },
                success: function (response, options) {
             
                },
                callback: function (options, success, response) {
                    var result = Ext.decode(response.responseText),
                        count = result.count;
                    callback(count);

                }

            });
        },
        toggleSwitchOnOfflineButton: function (callback) {

            callback = (typeof callback === 'function') && callback || Ext.emptyFn;

            var me = this,
                lblMode = Ext.ComponentQuery.query('#lblMode')[0],
                button = Ext.ComponentQuery.query('#btnSwitchOnOffline')[0];

            if (localStorage.getItem('i21Offline-Mode') === 'online') {

                window.localStorage.setItem('i21Offline-Mode', 'offline');

                button.setIconCls('small-move-up');

                $('.tooltip-switch-onoffline').tooltipster('content', 'Switch to Online Mode');

                lblMode.setText('Mode: Offline');

                callback('offline');

            }
            else {
                iRely.Functions.checkConnectionState(function (state) {
                    if (state === 'up') {

                        window.localStorage.setItem('i21Offline-Mode', 'online');

                        button.setIconCls('small-move-down');

                        $('.tooltip-switch-onoffline').tooltipster('content', 'Switch to Offline Mode');

                        lblMode.setText('Mode: Online');

                        callback('online');

                    }
                    else {
                        iRely.Functions.showCustomDialog('error', 'ok', 'Unable to switch to Online Mode. Failed to establish internet connection.');
                    }
                });
            }

        },

        validateBuildNumber: function (callback) {

            Ext.Ajax.request({

                url: '../i21/api/OfflineConfiguration/GetBuildNumber',
                method: 'GET',

                success: function (response, options) {

                    var buildNumber = JSON.parse(response.responseText);

                    Ext.Ajax.request({

                        url: localStorage.getItem('i21OnlineServerUrl') + 'i21/api/OfflineConfiguration/GetBuildNumber',
                        method: 'GET',
                        headers: {
                            Authorization: 'Bearer ' + iRely.Configuration.Security.EntityId,//'Bearer ' + iRely.Configuration.Security.ApiKey + '.' + iRely.Configuration.Security.ApiSecret,
                            ICompany: iRely.Configuration.Security.Company
                        },

                        success: function (response, options) {

                            if (JSON.parse(response.responseText) === buildNumber)
                                callback(true);
                            else
                                callback(false);

                        },
                        failure: function (response, options) {
                            callback(false);
                        }

                    });

                },
                failure: function (response, options) {
                    callback(false);
                }

            });

        },
        getLatLong: function (address, holder, callback) {
            if (holder) {
                holder.setLoading('Loading...')
            }
            address = address.replace(/ /ig, "+");
            var url = Ext.String.format('https://maps.googleapis.com/maps/api/geocode/json?address={0}&key=AIzaSyCja7DAM5DO7P0bORtMRHL3z9Tx_Enh4Ic', address);
            $.ajax({
                url: url,
            }).done(function (response) {
                if (holder) {
                    holder.setLoading(false);
                }

                if (response.status == "OK" && response.results && response.results.length > 0) {
                    var data = response.results[0];
                    var geo = data.geometry;
                    var location = (geo && geo.location) || null;
                    callback(location, response);
                }
                else {
                    callback(null, response);
                }
            });
        },
        getTimeZone: function (lat, lng, callback) {
            var myDate = new Date(); // Your timezone!
            var myEpoch = myDate.getTime() / 1000.0;
            var url = Ext.String.format('https://maps.googleapis.com/maps/api/timezone/json?location={0},{1}&timestamp={2}&key=AIzaSyCja7DAM5DO7P0bORtMRHL3z9Tx_Enh4Ic', lat, lng, myEpoch);

            $.ajax({
                url: url,
            }).done(function (response) {

                var data = response;
                var dst = 0;
                var raw = 0;
                if (data && data.status && data.status == "OK") {
                    dst = data.dstOffset;
                    raw = data.rawOffset;

                    if (dst > 0) {
                        dst = dst / 3600;
                    }
                    if (raw && raw !== 0) {
                        raw = raw / 3600;
                    }
                    var fin = (Math.abs(raw) - Math.abs(dst));

                    var fin1 = fin * 60;
                    var neg = (raw / Math.abs(raw)) < 0;
                    var finHour = ((fin1) - fin1 % 60) / 60;
                    var finMinutes = Math.abs(fin1 % 60);
                    data.cleanName = Ext.String.format("(UTC{3}{0}:{1}) {2}", Ext.String.leftPad(finHour, 2, "0"), Ext.String.leftPad(finMinutes, 2, "0"), data.timeZoneName, neg ? "-" : "+");
                    data.lat = lat;
                    data.lng = lng;
                }

                callback(data);

            });
        },
        getTimezoneBasedOnAddress: function (address, holder, callback) {
            var me = this;
            var getTz = function (location) {
                me.getTimeZone(location.lat, location.lng, callback);
            }

            me.getLatLong(address, holder, getTz);
        }
        /* Disconnected Model } */
    }
});

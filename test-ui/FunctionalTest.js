Ext.define('iRely.FunctionalTest', {
    extend: 'Ext.util.Observable',
    alternateClassName: 'TestFramework',

    //region Framework

    /**
     * @cfg {Array} chain
     * Siesta Chain commands
     */
    chain: [],

    /**
     * Constructor.
     * @param {Object} options Object containing one or more properties used on setting up Test Engine:
     *
     * @param {Siesta.Test} options.t Main Siesta Test
     *
     * @param {Function} options.next Next function.
     */
    constructor: function(options) {
        options = options || {};

        var me = this,
            config = {
                t    : options.t,
                next : options.next
            };

        me.t = config.t;
        me.next = config.next;
        me.chain = [];
    },

    /**
     * This configures Siesta Object (t) into the Test Engine.
     *
     * @param {Siesta.Test} t Main Siesta Test
     *
     * @param {Function} [next] Next function.
     *
     * @returns {iRely.FunctionalTest}
     */
    start: function(t, next) {
        var me = this;
        me.t = t;
        me.next = next;

        me.waitUntilMainMenuLoaded();

        return me;
    },

    /**
     * Completes the composition of test and starts the actual execution.
     */
    done: function() {
        var t = this.t,
            next = this.next;

        t.chain([
            this.chain,
            next
        ]);
    },

    //endregion


    //region Menu Functions

    /**
     * Expand or Collapse folder in the menu.
     *
     * @param {String} folderName Folder name to expand in the menu.
     *
     * @param {String} type Type of menu ('Folder', 'Screen', 'Report', 'Favorites').
     *
     * @returns {iRely.FunctionalTest}
     */
    clickMenuFolder: function(folderName, type) {
        var me = this,
            t = me.t,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                folder = type !== undefined ? type : 'folder',
                record = me.getRecordFromMenu(folder, folderName),
                node = null;
            t.chain([
                function (next) {
                    t.waitForFn(function () {
                        node = me.getNodeFromMenu(folder, folderName);
                        if (node) {
                            var loadmask = Ext.ComponentQuery.query('loadmask');
                            if (loadmask) {
                                for (var x = loadmask.length - 1; x >= 0; x--) {
                                    if (loadmask[x].isVisible() == true) {
                                        break;
                                    }
                                    else if (x == 0) {
                                        return true;
                                    }
                                }
                            }
                        }
                    }, function () {
                        next();
                    }, this, 60000);
                },
                function (next) {
                    var task = new Ext.util.DelayedTask(function () {
                        next();
                    });
                    task.delay(2000);
                },
                function (next) {
                    t.waitForFn(function () {
                        node = me.getNodeFromMenu(folder, folderName);
                        if (node) {
                            var loadmask = Ext.ComponentQuery.query('loadmask');
                            if (loadmask) {
                                for (var x = loadmask.length - 1; x >= 0; x--) {
                                    if (loadmask[x].isVisible() == true) {
                                        break;
                                    }
                                    else if (x == 0) {
                                        return true;
                                    }
                                }
                            }
                        }
                    }, function () {
                        next();
                    }, this, 60000);
                },
                function (next) {
                    record = me.getRecordFromMenu(folder, folderName),
                        node = me.getNodeFromMenu(folder, folderName);
                    t.click(node, next);
                },
                next
            ]);
        };

        chain.push({action:fn,timeout:180000});
        return this;
    },

    /**
     * Open screen in the menu.
     *
     * @param {String} screenName Screen to open in the menu.
     *
     * @param {String} type Type of menu ('Folder', 'Screen', 'Report', 'Favorites', 'Home').
     *
     * @returns {iRely.FunctionalTest}
     */
    clickMenuScreen: function(screenName, type) {
        var me = this,
            t = me.t,
            chain = me.chain,
            timeout = 30000;

        var fn = function(next) {
            var t = this,
                menu = type !== undefined ? type : 'screen',
                node = null;

            t.waitForFn(function() {
                node = me.getNodeFromMenu(menu, screenName);
                if(node) return true;
            },function() {
                node = me.getNodeFromMenu(menu, screenName);
                if (node) {
                    t.click(node, next);
                } else {
                    next();
                }
            },this, timeout)
        };

        chain.push(fn);
        me.waitTillLoaded();

        return this;
    },

    /*
     * @private
     * Gets the actual record on the main menu
     *
     * @param {String} type Type of menu ('Folder', 'Screen', 'Report').
     *
     * @param {String} menuName Menu Name.
     */
    getRecordFromMenu: function (type, menuName) {
        var mainMenu = this.getComponentByQuery('viewport');
        if(!mainMenu) return null;

        var treeView = mainMenu.down('#trvMenu');
        if(!treeView) return null;

        var treeStore = treeView.dataSource;
        if(!treeStore) return null;

        var menus = treeStore.queryBy(function(record) {
            return record.get('strType').toLowerCase() === type.toLowerCase() &&
                record.get('strMenuName').toLowerCase() === menuName.toLowerCase();
        });

        return menus.items[0];
    },

    /*
     * @private
     * Gets the node of the main menu
     *
     * @param {String} type Type of menu ('Folder', 'Screen', 'Report').
     *
     * @param {String} menuName Menu Name.
     */
    getNodeFromMenu: function (type, menuName) {
        var mainMenu = this.getComponentByQuery('viewport');
        if(!mainMenu) return null;

        var treeView = mainMenu.down('#trvMenu');
        if(!treeView) return null;

        var record = this.getRecordFromMenu(type, menuName);
        if(!record) return null;

        return treeView.getNodeByRecord(record);
    },

    //endregion

    //region Click Events

    //region Button

    /**
     * Clicks a message box button.
     *
     * @param {String} item Name of the button. ('yes', 'no', 'cancel', 'ok', 'x').
     *
     * @returns {iRely.FunctionalTest}
     */
    clickMessageBoxButton: function(item) {
        var me = this,
            chain = this.chain;

        var fn = function(next) {
            var t = this,
                btn;

            switch (item) {
                case 'yes':
                    btn = Ext.query('.sweet-alert button.confirm');
                    break;
                case 'no':
                    btn = Ext.query('.sweet-alert button.cancel');
                    break;
                case 'cancel':
                    btn = Ext.query('.sweet-alert button.cancel2');
                    break;
                case 'ok':
                    btn = Ext.query('.sweet-alert button.confirm');
                    break;
            }

            if (btn) {
                me.logEvent('Clicking ' + item + ' messagebox button');
                t.chain([
                    {
                        action: 'click',
                        target: btn[0]
                    },
                    function (next){
                        me.logSuccess('Successfully clicked ' + item + ' messagebox button');
                        next();
                    },
                    next
                ]);
            }
            else {
                me.logFailed('Messagebox ' + item + ' button is not found');
                next();
            }
        };
        chain.push(fn);
        return this;
    },

    /**
     * Clicks a button.
     *
     * @param {String} item Item Id (without prefix) of the button.
     *
     * @param {Integer} tab Index of the tab to be filtered. Optional.
     *
     * @returns {iRely.FunctionalTest}
     */
    clickButton: function(item, tab) {
        var me = this,
            chain = me.chain;

        var fn = function (next) {
            var t = this,
                win = Ext.WindowManager.getActive() || me.getComponentByQuery('viewport').down('#pnlIntegratedDashboard') || me.getComponentByQuery('viewport');

            if (win) {
                var button = win.down('#btn' + item);
                if (tab) {
                    var tabPanel = win.down('tabpanel').items.items[tab-1];
                    button = tabPanel.down('#btn' + item);
                }
                if (!button) {
                    button = win.down('#mnu' + item);
                    if (tab) {
                        var tabPanel = win.down('tabpanel').items.items[tab-1];
                        button = tabPanel.down('#mnu' + item);
                    }
                }

                if (button) {
                    me.logEvent('Clicking ' + item + ' button');
                    t.chain([
                        {
                            action: 'click',
                            target: button
                        },
                        function (next) {
                            var task = new Ext.util.DelayedTask(function () {
                                next();
                            });
                            task.delay(500);
                        },
                        function (next) {
                            t.waitForFn(function () {
                                me.waitUntilLoaded();
                                return true;
                            }, function () {
                                next();
                            }, this, 60000);
                        },
                        function (next) {
                            var newActive = Ext.WindowManager.getActive();
                            if (newActive) {
                                if (newActive.xtype === 'quicktip') {
                                    newActive.close();
                                }
                            }
                            next();
                        },
                        function (next){
                            me.logSuccess('Successfully clicked ' + item + ' button');
                            next();
                        },
                        next
                    ]);
                } else {
                    me.logFailed(item + ' button is not found');
                    next();
                }
            } else {
                next();
            }
        };

        chain.push(fn);

        return this;
    },

    /**
     * Clicks any button on title bar area
     *
     * @param {String} button Name ex. collapse, minimize, maximize, restore, close.
     *
     * @returns {iRely.FunctionalTest}
     */
    clickTitleBarButton: function(button) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();
            if (win) {
                var btn = null;
                for (var i=0;i<win.tools.length;i++){
                    btn = win.tools[i];
                    if (btn.type === button){
                        break;
                    }
                }
                if (btn){
                    me.logEvent('Clicking ' + button + ' titlebar button');
                    t.chain([
                        {
                            action: 'click',
                            target: btn
                        },
                        function (next){
                            me.logSuccess('Successfully clicked ' + button + ' titlebar button');
                            next();
                        },
                        next
                    ]);
                } else {
                    me.logFailed('Titlebar ' + button + ' button is not found');
                    next();
                }
            } else {
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    /**
     * Clicks an ellipse button in the textbox.
     *
     * @param {String} item Item Id (without prefix) of the textbox.
     *
     * @param {Integer} tab Index of the tab to be filtered. Optional.
     *
     * @returns {iRely.FunctionalTest}
     */
    clearTextFilter: function(item, tab) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive() || me.getComponentByQuery('viewport').down('#pnlIntegratedDashboard');
            if (win) {
                var control = win.down('#txt'+item);
                if (tab) {
                    var tabpanel = win.down('tabpanel').items.items[tab-1];
                    control = tabpanel.down('#txt'+item);
                }

                if (control) {
                    var ellipsis = control.triggerEl.elements[0];

                    me.logEvent('Clicking ' + item + ' ellipse button');
                    t.chain([
                        {
                            action: 'click',
                            target: ellipsis
                        },
                        function (next){
                            me.logSuccess('Successfully clicked ' + item + ' ellipse button');
                            next();
                        },
                        next
                    ]);
                }
                else {
                    me.logFailed(item + ' ellipse button is not found');
                    next();
                }
            } else {
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    //endregion

    //region Checkbox

    /**
     * Clicks a check box.
     *
     * @param {String/DOMElement/Function} item Item Id (without prefix) / the DOM element or a function to return the DOM Element of the check box.
     *
     * @param {Boolean} [checked] Checked state of the checkbox
     *
     * @returns {iRely.FunctionalTest}
     */
    clickCheckBox: function(item, checked) {
        var me = this,
            chain = this.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();
            if (win) {
                var chkBox = typeof item === 'function' ? item(win) : (item.tagName || item.nodeName) ? item : win.down('#chk'+item);

                if (chkBox) {
                    if(typeof checked !== 'undefined') {
                        if(typeof checked !== 'boolean') {
                            me.logFailed('Checked value should be of type boolean found: ' + typeof checked);
                            next();
                        }

                        if(chkBox.getValue) {
                            if(chkBox.getValue() !== checked) {
                                me.logEvent('Clicking ' + item + ' checkbox');
                                t.chain([
                                    {
                                        action: 'click',
                                        target: chkBox
                                    },
                                    function (next){
                                        me.logSuccess('Successfully clicked ' + item + ' checkbox');
                                        next();
                                    },
                                    next
                                ]);
                            }
                            else {
                                next();
                            }
                        }
                        else {
                            if(chkBox.type !== 'checkbox') {
                                var el = chkBox;

                                while(!/x-form-type-checkbox/i.test(el.className)) {
                                    el = el.parentNode;
                                }

                                if(/x-form-cb-checked/i.test(el.className) !== checked) {
                                    me.logEvent('Clicking ' + item + ' checkbox');
                                    t.chain([
                                        {
                                            action: 'click',
                                            target: chkBox
                                        },
                                        function (next){
                                            me.logSuccess('Successfully clicked ' + item + ' checkbox');
                                            next();
                                        },
                                        next
                                    ]);
                                }
                                else {
                                    next();
                                }
                            }
                            else {
                                if(chkBox.checked !== checked) {
                                    me.logEvent('Clicking ' + item + ' checkbox');
                                    t.chain([
                                        {
                                            action: 'click',
                                            target: chkBox
                                        },
                                        function (next){
                                            me.logSuccess('Successfully clicked ' + item + ' checkbox');
                                            next();
                                        },
                                        next
                                    ]);
                                }
                                else {
                                    next();
                                }
                            }
                        }
                    }
                    else {
                        me.logEvent('Clicking ' + item + ' checkbox');
                        t.chain([
                            {
                                action: 'click',
                                target: chkBox
                            },
                            function (next){
                                me.logSuccess('Successfully clicked ' + item + ' checkbox');
                                next();
                            },
                            next
                        ]);
                    }
                } else {
                    me.logFailed(item + ' checkbox is not found');
                    next();
                }
            } else {
                next();
            }
        };

        chain.push({action:fn,timeout:120000});
        return this;
    },

    /**
     * Clicks a check box in the grid
     *
     * @param {String} item Item Id (without prefix) of the grid.
     *
     * @param {String} column Data index of the column you want to filter
     *
     * @param {String} filter Search keyword
     *
     * @param {String} checkbox Data index of check box column
     *
     * @param {Boolean} checked Expected value of the check box (true or false)
     *
     * @returns {iRely.FunctionalTest}
     */
    clickGridCheckBox:function(item, column, filter, checkbox, checked) {
        var me = this,
            chain = this.chain;

        var fn = function(next) {
            if(typeof checked !== 'boolean') {
                me.logFailed('Checked value should be of type boolean found: ' + typeof checked);
                next();
            }

            var t = this,
                win = Ext.WindowManager.getActive(),
                grid = win.down('#grd'+item),
                gridRow = grid.getStore().findRecord(column, filter),
                gridColumn = Ext.Array.findBy(grid.columnManager.getColumns(), function(col) {
                        if(col.dataIndex === checkbox){
                            return true;
                        } else {
                            return false;
                        }
                    }
                );

            if(gridRow && gridColumn){
                if (gridRow.get(checkbox) !== checked){
                    var  cell = grid.down('tableview').getCell(gridRow, gridColumn);

                    me.logEvent('Clicking grid checkbox');
                    t.chain([
                        {
                            action: 'click',
                            target: cell
                        },
                        function (next){
                            me.logSuccess('Successfully clicked grid checkbox');
                            next();
                        },
                        next
                    ]);

                } else {
                    next();
                }
            } else {
                me.logFailed('Checkbox is not found');
                next();
            }

        };

        chain.push({action:fn,timeout:120000});
        return this;
    },

    //endregion

    //region Misc

    /**
     * Clicks a label hyperlink.
     *
     * @param {String} item Item Id (without prefix) of the combo box.
     *
     * @returns {iRely.FunctionalTest}
     */
    clickLabel: function(item) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();
            if (win) {
                var field = win.down('#cbo'+item);
                if (field) {
                    me.logEvent('Clicking ' + item + ' label hyperlink');
                    var label = field.labelEl || field.el;
                    t.chain([
                        {
                            action: 'click',
                            target: label
                        },
                        function (next){
                            me.logSuccess('Successfully clicked ' + item + ' label hyperlink');
                            var task = new Ext.util.DelayedTask(function () {
                                next();
                            });
                            task.delay(1500);
                        },
                        next
                    ]);
                } else {
                    me.logFailed(item + ' label hyperlink is not found');
                    next();
                }
            } else {
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    /**
     * Clicks a tab.
     *
     * @param {String} item Item Id (without prefix) or Text of the tab.
     *
     * @returns {iRely.FunctionalTest}
     */
    clickTab: function(item) {
        var me = this,
            chain = this.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive() || me.getComponentByQuery('viewport').down('#pnlIntegratedDashboard');

            if (win) {
                var tab = win.down('pge'+item) || win.down('tabpanel [text='+ item  +']' || win.down('tab'+item));

                if (tab) {
                    if(tab.xtype == 'panel') tab = tab.tab;

                    if(tab.active === false ){
                        me.logEvent('Clicking ' + item + ' tab page');
                        t.chain([
                            {
                                action: 'click',
                                target: tab
                            },
                            function (next){
                                me.logSuccess('Successfully clicked ' + item + ' tab page');
                                next();
                            },
                            next
                        ]);
                    }
                    else{
                        next();
                    }
                } else {
                    me.logFailed(item + ' tab page is not found');
                    next();
                }
            } else {
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    //endregion

    //region Report Viewer

    /**
     * Clicks a button.
     *
     * @param {String} item Item Id of the button in Financial Report Viewer
     *
     * @returns {iRely.FunctionalTest}
     */
    clickButtonFRD: function(item) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                iframe = window.parent.document.getElementsByClassName('tr-iframe')[window.parent.document.getElementsByClassName('tr-iframe').length-1];

            if (iframe) {
                var button = iframe.contentWindow.frames[0].document.getElementById(item);
                if (button) {
                    me.logEvent('Clicking button ' + item);

                    t.chain([
                        {
                            action: 'click',
                            target: button
                        },
                        {
                            action: 'wait',
                            delay: 500
                        },
                        function(next) {
                            var newActive = Ext.WindowManager.getActive();
                            if (newActive) {
                                if (newActive.xtype === 'quicktip') {
                                    newActive.close();
                                }
                            }
                            next();
                        },
                        next
                    ]);
                } else {
                    me.logFailed(item + ' is not found');
                    next();
                }
            } else {
                next();
            }

        };

        chain.push(fn);
        return this;
    },

    /**
     * Clicks a button.
     *
     * @param {Integer} index parent button in Financial Report Viewer
     *
     * @param {String} item Item Id of the child button in Financial Report Viewer
     *
     * @returns {iRely.FunctionalTest}
     */
    clickToolbarFRD: function(index, item) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                iframe = window.parent.document.getElementsByClassName('tr-iframe');

            if (iframe) {
                var parentButton = window.parent.document.getElementsByClassName('tr-iframe')[window.parent.document.getElementsByClassName('tr-iframe').length-1];
                parentButton = parentButton.contentWindow.frames[0].document.getElementsByClassName("dxr-lblContent")[index];

                var button = window.parent.document.getElementsByClassName('tr-iframe')[window.parent.document.getElementsByClassName('tr-iframe').length-1];
                button = button.contentWindow.frames[0].document.getElementById(item);
                if (button) {
                    me.logEvent('Clicking button ' + item);

                    t.chain([
                        {
                            action: 'click',
                            target: parentButton
                        },
                        {
                            action: 'wait',
                            delay: 500
                        },
                        {
                            action: 'click',
                            target: button
                        },
                        {
                            action: 'wait',
                            delay: 1000
                        },
                        function(next) {
                            var newActive = Ext.WindowManager.getActive();
                            if (newActive) {
                                if (newActive.xtype === 'quicktip') {
                                    newActive.close();
                                }
                            }
                            next();
                        },
                        next
                    ]);
                } else {
                    me.logFailed(item + ' is not found');
                    next();
                }
            } else {
                next();
            }

        };

        chain.push(fn);
        return this;
    },

    //endregion

    //endregion

    //region DoubleClick Events

    /**
     * Open a row in Search screen based on the index specified.
     *
     * @param {Number} index Index of the row to select.
     *
     * @param {Integer} tab Index of the tab to be filtered.
     *
     * @returns {iRely.FunctionalTest}
     */
    doubleClickSearchRowNumber: function(index,tab){
        var me = this,
            chain = this.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive() || me.getComponentByQuery('viewport').down('#pnlIntegratedDashboard');

            if (win) {
                if (win.xtype === 'search' || 'frmintegrateddashboard') {
                    var grid = win.down('#grdSearch'),
                        store = grid.getStore();
                    if (tab){
                        var tabPanel = win.down('tabpanel').items.items[tab-1];
                        grid = tabPanel.down('#grdSearch');
                    }

                    if (grid) {
                        me.logEvent('Double clicking Search record number ' + index);
                        t.chain([
                            function(next) {
                                if(store.remoteFilter == true && store.isLoading() == true){
                                    t.waitForStoresToLoad(store, function () {
                                        next();
                                    })
                                }
                                else {
                                    var task = new Ext.util.DelayedTask(function () {
                                        next();
                                    });
                                    task.delay(1500);
                                }
                            },
                            function(next){
                                t.waitForRowsVisible(grid, function(){
                                    var node = grid.getView().getNode(index-1);
                                    t.doubleClick(node, next);
                                });
                            },
                            function(next){
                                me.logSuccess('Record has been successfully double clicked');
                                next();
                            },
                            next
                        ]);
                    } else {
                        me.logFailed('Search Grid is not found');
                        next();
                    }
                }
                else {
                    me.logFailed('Search Grid is not found');
                    next();
                }
            }
            else {
                me.logFailed('Search Grid is not found');
                next();
            }
        };

        chain.push(fn);

        return this;
    },

    /**
     * Open a row in Search screen based on the filter specified.
     *
     * @param {String} filter All column filter to apply.
     *
     * @param {String} gridColumn Data Index of the column to be filtered.
     *
     * @param {Integer} index Index of the record to be selected after filtered.
     *
     * @param {Integer} tab Index of the tab to be filtered.
     *
     * @returns {iRely.FunctionalTest}
     */
    doubleClickSearchRowValue: function(filter, gridColumn, index, tab){
        var me = this,
            chain = this.chain;

        if(index > 0) index = index - 1;
        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive() || me.getComponentByQuery('viewport').down('#pnlIntegratedDashboard');

            if (win) {
                if (win.xtype === 'search' || 'frmintegrateddashboard') {
                    var filterGrid = win.down('#txtFilterGrid');

                    if (tab){
                        var tabPanel = win.down('tabpanel').items.items[tab-1];
                        filterGrid = tabPanel.down('#txtFilterGrid');
                    }

                    if (filterGrid) {
                        me.logEvent('Double clicking Search record');
                        t.chain([
                            {
                                action: 'click',
                                target: filterGrid
                            },
                            function(next) {
                                t.selectText(filterGrid, 0, 20);
                                next();
                            },
                            function(next) {
                                t.type(filterGrid, filter, next);
                            },
                            function(next) {
                                t.type(filterGrid, '[RETURN]', next);
                            },
                            function(next) {
                                var grid =  win.down('#grdSearch'),
                                    store = grid.store;
                                if(store.isLoading() == true){
                                    t.waitForStoresToLoad(store, function () {
                                        next();
                                    });
                                }
                                else {
                                    var task = new Ext.util.DelayedTask(function () {
                                        next();
                                    });
                                    task.delay(1500);
                                }
                            },
                            function(next){
                                var grid =  win.down('#grdSearch');
                                if (tab) grid = tabPanel.down('#grdSearch');

                                var store = grid.store,
                                    storeCount = store.getCount();

                                if (storeCount === 1){
                                    if (typeof(grid.getView) == "function") {
                                        t.waitForRowsVisible(grid, function(){
                                            var node = grid.getView().getNode(0);
                                            t.doubleClick(node, next);
                                        });
                                    } else {
                                        next();
                                    }
                                }
                                else {
                                    var filterRec = store.findExact(gridColumn, filter);
                                    if (filterRec){
                                        if (filterRec === -1 && index == null){
                                            me.logFailed('No record found');
                                            next();
                                        } else {
                                            var node = grid.getView().getNode(index);
                                            t.doubleClick(node, next);
                                        }
                                    }
                                    else {
                                        var node = grid.getView().getNode(0);
                                        t.doubleClick(node, next);
                                    }
                                }
                            },
                            function(next){
                                me.logSuccess('Record has been successfully double clicked');
                                next();
                            },
                            next
                        ]);
                    }
                } else {
                    me.logFailed('Search Grid is not found');
                    next();
                }
            } else {
                me.logFailed('Search Grid is not found');
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    //endregion

    //region Select Events

    //region Grid

    /**
     * Select a row in Search screen based on the index specified.
     *
     * @param {Number[]/Number} index Array of Indexs or Index of the row to select.
     *
     * @param {Integer} tab Index of the tab to be filtered.
     *
     * @returns {iRely.FunctionalTest}
     */
    selectSearchRowNumber: function(index, tab){
        var me = this,
            chain = this.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive() || me.getComponentByQuery('viewport').down('#pnlIntegratedDashboard');

            if (win) {
                if (win.xtype === 'search' || 'frmintegrateddashboard') {
                    me.logEvent('Selecting Search record number ' + index);

                    var grid = win.down('#grdSearch');
                    if (tab){
                        var tabPanel = win.down('tabpanel').items.items[tab-1];
                        grid = tabPanel.down('#grdSearch');
                    }

                    var sm = grid.getSelectionModel(),
                        store = grid.getStore(),
                        indexArrs = Ext.isArray(index) ? index : [index],
                        selected = [], bufferedData;

                    if(store.buffered && store.getCount() > store.config.pageSize) {
                        bufferedData =  store.data.getRange(0, store.config.pageSize);
                    }
                    else{
                        bufferedData =  store.data.getRange(0, store.getCount());
                    }

                    for(var i = 0; i < indexArrs.length; i++) {
                        var idx = indexArrs[i] - 1;
                        if(store.buffered) {
                            if(bufferedData[idx]) {
                                selected.push(bufferedData[idx]);
                            }
                        }
                        else {
                            if(store.data.items[idx]) {
                                selected.push(store.data.items[idx]);
                            }
                        }
                    }

                    t.waitForRowsVisible(grid, function () {
                        sm.select(selected);
                        me.logSuccess('Record has been successfully selected');
                        next();
                    });
                }
                else {
                    me.logFailed('Search Grid is not found');
                    next();
                }
            }
            else {
                me.logFailed('Search Grid is not found');
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    /**
     * Select a rows in Search screen based on the start and end specified.
     *
     * @param {Integer} start Start of the row to select.
     *
     * @param {Integer} end End of the row to select.
     *
     * @param {Integer} tab Index of the tab to be filtered.
     *
     * @returns {iRely.FunctionalTest}
     */
    selectSearchRowByRange: function(start, end, tab){
        var me = this,
            chain = this.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();

            if (win) {
                if (win.xtype === 'search') {
                    me.logEvent('Selecting Search record number from ' + start + ' to ' + end);

                    var grid = win.down('#grdSearch');
                    if (tab){
                        var tabPanel = win.down('tabpanel').items.items[tab-1];
                        grid = tabPanel.down('#grdSearch');
                    }

                    var sm = grid.getSelectionModel();
                    t.waitForRowsVisible(grid, function() {
                        sm.selectRange(start-1, end-1);
                        me.logSuccess('Records has been successfully selected');
                        next();
                    });
                } else {
                    me.logFailed('Search Grid is not found');
                    next();
                }
            } else {
                me.logFailed('Search Grid is not found');
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    /**
     * Select a row in Search screen based on the filter specified.
     *
     * @param {String} filter All column filter to apply.
     *
     * @param {String} gridColumn Data Index of the column to be filtered.
     *
     * @param {Integer} tab Index of the tab to be filtered.
     *
     * @returns {iRely.FunctionalTest}
     */
    selectSearchRowValue: function(filter, gridColumn, tab) {
        var me = this,
            chain = this.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive() || me.getComponentByQuery('viewport').down('#pnlIntegratedDashboard');

            if (win) {
                if (win.xtype === 'search' || 'frmintegrateddashboard') {
                    var filterGrid = win.down('#txtFilterGrid');

                    if (tab){
                        var tabPanel = win.down('tabpanel').items.items[tab-1];
                        filterGrid = tabPanel.down('#txtFilterGrid');
                    }

                    if (filterGrid) {
                        me.logEvent('Selecting Search record');
                        t.chain([
                            {
                                action: 'click',
                                target: filterGrid
                            },
                            function(next) {
                                t.selectText(filterGrid, 0, 20);
                                next();
                            },
                            function(next) {
                                t.type(filterGrid, filter, next);
                            },
                            function(next) {
                                t.type(filterGrid, '[RETURN]', next);
                            },
                            function(next){
                                var task = new Ext.util.DelayedTask(function () {
                                    next();
                                });
                                task.delay(1000);
                            },
                            function(next) {
                                var grid =  win.down('#grdSearch'),
                                    store = grid.store;
                                if(store.isLoading() == true){
                                    t.waitForStoresToLoad(store, function () {
                                        next();
                                    });
                                }
                                else {
                                    var task = new Ext.util.DelayedTask(function () {
                                        next();
                                    });
                                    task.delay(1500);
                                }
                            },
                            function(next){
                                var grid =  win.down('#grdSearch');
                                if (tab) grid = tabPanel.down('#grdSearch');

                                var store = grid.store,
                                    storeCount = store.getCount();

                                if (storeCount === 1){
                                    if (typeof(grid.getView) == "function") {
                                        t.waitForRowsVisible(grid, function(){
                                            var node = grid.getView().getNode(0);
                                            t.click(node, next);
                                        });
                                    } else {
                                        next();
                                    }
                                }
                                else {
                                    var filterRec = store.findExact(gridColumn, filter);

                                    if (filterRec){

                                        if (filterRec === -1){
                                            me.logFailed('No record found');
                                            next();
                                        } else {
                                            var record = store.getAt(filterRec),
                                                node1 = grid.getView().getNode(record);

                                            t.click(node1, next);
                                        }
                                    }
                                    else {
                                        var node2 = grid.getView().getNode(0);
                                        t.click(node2, next);
                                    }
                                }
                            },
                            function(next){
                                me.logSuccess('Record has been successfully selected');
                                next();
                            },
                            next
                        ]);
                    }
                } else {
                    me.logFailed('Search Grid is not found');
                    next();
                }
            } else {
                me.logFailed('Search Grid is not found');
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    /**
     * Select a row in Search screen based on the index specified.
     *
     * @param {Number[]/Number} index Array of Indexs or Index of the row to select.
     *
     * @param {Integer} tab Index of the tab to be filtered.
     *
     * @returns {iRely.FunctionalTest}
     */
    selectSearchHyperLinkByIndex: function(row, column, index) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive() || me.getComponentByQuery('viewport').down('#pnlIntegratedDashboard');
            if (win) {
                var grid = win.down('#grdSearch');
                if (grid) {
                    var store = grid.store;
                    if (store.indexOf(row) === -1) {
                        row = store.getAt(row);
                    }

                    if (Ext.Array.indexOf(grid.columns, column) === -1) {
                        column = grid.columns[column] || grid.columnManager.getHeaderById(column) || grid.down('[dataIndex=' + column + ']');
                    }

                    if (row && column) {
                        var view = grid.getView(),
                            cell = view.getCell(row, column);

                        t.click(cell);
                        next();

                        //if (plugin.clicksToEdit === 1) {
                        //    t.click(cell);
                        //} else {
                        //    t.doubleClick(cell);
                        //}

                        //if (plugin.activeEditor) {
                        //    var editor = plugin.activeEditor,
                        //        els = (function() {
                        //            var cell = editor.field.el.query('.x-trigger-cell'),
                        //                form = editor.field.el.query('.x-form-trigger');
                        //
                        //            return (cell.length && cell) || (form.length && form);
                        //        })(),
                        //        length = els.length,
                        //        trigger = els[length - 1];
                        //
                        //    me.logEvent('Entering data on grid ' + item);
                        //
                        //    t.chain([
                        //        {
                        //            action: 'click',
                        //            target: trigger
                        //        },
                        //        function(next) {
                        //            var panel = Ext.WindowManager.getActive(),
                        //                grid;
                        //
                        //            if (panel.getView) {
                        //                grid = panel.getView();
                        //            } else {
                        //                grid = editor.field.getPicker();
                        //            }
                        //
                        //            if (grid) {
                        //                var node = grid.getNode(index);
                        //                t.click(node, function() {
                        //                    editor.completeEdit();
                        //                    next();
                        //                });
                        //            } else {
                        //                me.logFailed('Combo Box is not found');
                        //                next();
                        //            }
                        //        },
                        //        next
                        //    ]);
                        //} else {
                        //    me.logFailed('Combo Box is not found');
                        //    next();
                        //}
                    } else {
                        me.logFailed('Cell is not found');
                        next();
                    }
                } else {
                    me.logFailed('Cell is not found');
                    next();
                }
            } else {
                me.logFailed('Cell is not found');
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    /**
     * Select a row based on the grid and index specified.
     *
     * @param {String} item Item Id (without prefix) of the Grid.
     *
     * @param {Number[]/Number} index Array of indexes or index of the row to select.
     *
     * @param {Integer} tab Index of the tab to be filtered. Optional.
     *
     * @returns {iRely.FunctionalTest}
     */
    selectGridRowNumber: function(item, index, tab){
        var me = this,
            chain = this.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive() || me.getComponentByQuery('viewport').down('#pnlIntegratedDashboard') || me.getComponentByQuery('viewport');

            if (win) {
                var grid = iRely.Functions.getChildControl('#grd'+item, win);

                if (tab){
                    var tabPanel = win.down('tabpanel').items.items[tab-1];
                    grid = tabPanel.down('#grd'+item);
                }

                if (grid) {
                    me.logEvent('Selecting ' + item + ' grid record number ' + index);

                    var sm = grid.getSelectionModel(),
                        store = grid.getStore(),
                        indexArrs = Ext.isArray(index) ? index : [index],
                        selected = [], bufferedData;

                    if(store.buffered && store.getCount() > store.config.pageSize) {
                        bufferedData =  store.data.getRange(0, store.config.pageSize);
                    }
                    else{
                        bufferedData =  store.data.getRange(0, store.getCount());
                    }

                    for(var i = 0; i < indexArrs.length; i++) {
                        var idx = indexArrs[i] - 1;

                        if(store.buffered) {
                            if(bufferedData[idx]) {
                                selected.push(bufferedData[idx]);
                            }
                        }
                        else {
                            if(store.data.items[idx]) {
                                selected.push(store.data.items[idx]);
                            }
                        }
                    }

                    t.waitForRowsVisible(grid, function () {
                        sm.select(selected);
                        me.logSuccess('Record has been successfully selected');
                    });
                } else {
                    me.logFailed('Grid is not found');
                }
            } else {
                me.logFailed('Grid is not found');
            }

            next();
        };

        chain.push(fn);
        return this;
    },

    /**
     * Select a row on the grid based on a filter specified.
     *
     * @param {String} item Item Id (without prefix) of the Grid.
     *
     * @param {Object[]/Object} [filters] Array of filters or filter expression of the row to select.
     *
     * @param {String} [filters.dataIndex] dataIndex of a column to search
     *
     * @param {Object/Function} [filters.value] the search expression to match
     *
     * @param {Boolean} [filters.matchCase] match the data exactly. defaults to True, only applicable to Strings.
     *
     * @returns {iRely.FunctionalTest}
     */
    selectGridRowValue: function(item, filters){
        var me = this,
            chain = this.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();

            if (win) {
                var grid = iRely.Functions.getChildControl('#grd'+item, win);
                if (grid) {
                    me.logEvent('Selecting ' + item + ' grid record');

                    var sm = grid.getSelectionModel(),
                        store = grid.getStore(),
                        selected = [], data = [],
                        filterArrs = Ext.isArray(filters) ? filters : [filters],
                        filterFn = function(filter) {
                            if(!data.length && !filter) return;
                            var matchCase = typeof filter.matchCase === 'undefined' ? true : filter.matchCase;

                            for(var i = 0; i < data.length; i++) {
                                var currentData = data[i].data;
                                if(matchCase) {
                                    var value = typeof filter.value === 'function' ? filter.value() : filter.value;
                                    if(currentData[filter.dataIndex] === value) {
                                        return data[i];
                                    }
                                }
                                else {
                                    if(typeof filter.value === 'string') {
                                        var regEx = new RegExp(filter.value, 'ig');
                                        if(regEx.test(currentData[filter.dataIndex])) {
                                            return data[i];
                                        }
                                    }
                                }
                            }
                        };

                    if(store.buffered) {
                        data =  store.data.getRange(0, store.getCount());
                    }
                    else {
                        data = store.data.items;
                    }

                    filterArrs.forEach(function(f){
                        var match = filterFn(f);
                        if(match) {
                            selected.push(match);
                        }
                    });

                    sm.select(selected);
                    me.logSuccess('Record has been successfully selected');
                } else {
                    me.logFailed('Grid is not found');
                }
            } else {
                me.logFailed('Grid is not found');
            }

            next();
        };

        chain.push(fn);
        return this;
    },

    /**
     * @private
     * Selects the dummy row
     *
     * @param {String} item Item Id (without prefix) of the grid.
     *
     * @returns {iRely.FunctionalTest}
     */
    selectDummyRow : function(item) {
        var me = this,
            chain = me.chain,
            fn = function (next) {
                var w = Ext.WindowManager.getActive(),
                    grid = w.down('#grd'+item),
                    store = grid.getStore(),
                    sm = grid.getSelectionModel(),
                    idx;

                var storeLoadCheck = setInterval(function() {
                    if(store.isLoaded()) {
                        clearInterval(storeLoadCheck);
                        for (var i = 0; i < store.data.items.length; i++) {
                            if (store.data.items[i].dummy) {
                                idx = i;
                                break;
                            }
                        }
                        sm.select(idx);
                        next();
                    }
                }, 30);
            };
        chain.push(fn);
        return this;
    },

    //endregion

    //region Combobox

    /**
     * Selects item in the combo box based in the index specified.
     *
     * @param {String} item Item Id (without prefix) of the combo box.
     *
     * @param {Integer} index Index of the row to select.
     *
     * @param {Integer} tab Index of the tab to be filtered. Optional.
     *
     * @returns {iRely.FunctionalTest}
     */
    selectComboBoxRowNumber: function(item, index, tab) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive() || me.getComponentByQuery('viewport').down('#pnlIntegratedDashboard');

            if (win) {
                var combo = item.value ? item : win.down('#cbo'+item);
                if (tab){
                    var tabPanel = win.down('tabpanel').items.items[tab-1];
                    combo = item.value ? item : tabPanel.down('#cbo'+item);
                }

                if (combo) {
                    me.logEvent('Selecting item on ' + item + ' combobox at row number: ' + index);
                    var els = (function() {
                            var cell = combo.el.query('.x-trigger-cell'),
                                form = combo.el.query('.x-form-trigger');

                            return (cell.length && cell) || (form.length && form);
                        })(),
                        length = els.length,
                        trigger = els[length - 1];

                    t.chain([
                        {
                            action: 'click',
                            target: trigger
                        },
                        function(next) {
                            var panel = Ext.WindowManager.getActive(),
                                store = combo.getStore(),
                                grid;

                            if (panel.getView) {
                                grid = panel.getView();
                            } else {
                                grid = combo.getPicker();
                            }

                            if(index > 0) index = index - 1;
                            if(store.isLoading() == true){
                                t.waitForStoresToLoad(store, function () {
                                    if (grid && grid.getNode) {
                                        var node = grid.getNode(index);
                                        var task = new Ext.util.DelayedTask(function(){
                                            t.click(node, next);
                                        });

                                        task.delay(1000);
                                    }
                                    else if(grid && grid.getView){
                                        var view = grid.getView(),
                                            node = view.getNode(index);
                                        var task = new Ext.util.DelayedTask(function(){
                                            t.click(node, next);
                                        });

                                        task.delay(1000);
                                    } else {
                                        me.logFailed('Combo Box is not found');
                                        next();
                                    }
                                })
                            }
                            else if (grid && grid.getNode) {
                                var node = grid.getNode(index);
                                var task = new Ext.util.DelayedTask(function(){
                                    t.click(node, next);
                                });

                                task.delay(1000);
                            }
                            else if(grid && grid.getView){
                                var view = grid.getView(),
                                    node = view.getNode(index);
                                var task = new Ext.util.DelayedTask(function(){
                                    t.click(node, next);
                                });

                                task.delay(1000);
                            } else {
                                me.logFailed('Combo Box is not found');
                                next();
                            }
                        },
                        function (next){
                            me.logSuccess('Item has been successfully selected');
                            next();
                        },
                        next
                    ]);
                } else {
                    me.logFailed('Combo Box is not found');
                    next();
                }
            } else {
                me.logFailed('Combo Box is not found');
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    /**
     * Selects item in the combo box based on the filter specified.
     *
     * @param {String} item Item Id (without prefix) of the combo box.
     *
     * @param {String/[Object]} filter Simple/Advance filter to be applied.
     *
     *     .selectComboRowByFilter('#cboType', 'My Type')
     *
     * or
     *
     *     .selectComboRowByFilter('#cboType', [
     *     {
     *         dataIndex: 'strType',
     *         value: 'sample',
     *         condition: 'ct'
     *     },
     *     {
     *         dataIndex: 'strOtherField',
     *         value: 'other',
     *         condition: 'eq',
     *         conjuction: 'and'
     *     }])
     *
     * {String} comboColumn FieldName of the combo grid to be filtered
     *
     * @returns {iRely.FunctionalTest}
     */
    selectComboBoxRowValue: function(item, filter, comboColumn, index, tab) {
        var me = this,
            chain = this.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();
            if (win) {
                var combo = item.value ? item : win.down('#cbo'+item);
                if (tab){
                    var tabPanel = win.down('tabpanel').items.items[tab-1];
                    combo = item.value ? item : tabPanel.down('#cbo'+item);
                }

                if (combo) {
                    me.logEvent('Selecting item on ' + item + ' combobox filtered by ' + filter);

                    var els = (function() {
                            var cell = combo.el.query('.x-trigger-cell'),
                                form = combo.el.query('.x-form-trigger');

                            return (cell.length && cell) || (form.length && form);
                        })(),
                        length = els.length,
                        trigger = els[length - 1],
                        store = combo.store;

                    if (Ext.isArray(filter)) {
                        combo.defaultFilters = filter;

                        t.chain([
                            {
                                action: 'click',
                                target: trigger
                            },
                            function(next) {
                                var comboGrid =  combo.picker;
                                if (typeof(comboGrid.getView) == "function") {
                                    var node = comboGrid.getView().getNode(0);
                                    t.click(node, next);
                                } else {
                                    next();
                                }
                            },
                            next
                        ]);
                        return;
                    }

                    t.chain([
                        {
                            action: 'click',
                            target: trigger
                        },
                        {
                            action: 'click',
                            target: combo
                        },
                        function(next){
                            t.selectText(combo, 0, 50);
                            next();
                        },
                        function(next) {
                            t.type(combo, filter, next);
                        },
                        function(next) {
                            if(store.remoteFilter == true){
                                t.waitForStoresToLoad(store, function () {
                                    next();
                                })
                            }
                            else {
                                var task = new Ext.util.DelayedTask(function () {
                                    next();
                                });
                                task.delay(1500);
                            }
                        },
                        function(next){
                            var store = combo.store,
                                storeCount = store.getCount();

                            if(index > 0 && index) index = index - 1;
                            if (storeCount === 1){
                                var comboGrid = combo.picker || combo.getPicker();

                                if (typeof(comboGrid.getView) == "function") {
                                    var node = comboGrid.getView().getNode(0);
                                    t.click(node, next);
                                } else {
                                    next();
                                }
                            }
                            else if(store.isLoading() == true) {
                                t.waitForStoresToLoad(store, function () {
                                    var filterRec = store.findExact(comboColumn, filter),
                                        record = store.getAt(filterRec),
                                        comboGrid1 =  combo.picker || combo.getPicker();

                                    var task = new Ext.util.DelayedTask(function(){
                                        if(index != null) filterRec = index;
                                        if (typeof(comboGrid1.getView) == "function") {
                                            var node1 = comboGrid1.getView().getNode(filterRec);
                                            t.click(node1, next);
                                        } else {
                                            next();
                                        }
                                    });
                                    task.delay(1000);
                                })
                            }
                            else{
                                var filterRec = store.findExact(comboColumn, filter),
                                    record = store.getAt(filterRec),
                                    comboGrid1 =  combo.picker || combo.getPicker();

                                var task = new Ext.util.DelayedTask(function(){
                                    if(index != null) filterRec = index;
                                    if (typeof(comboGrid1.getView) == "function") {
                                        var node1 = comboGrid1.getView().getNode(filterRec);
                                        t.click(node1, next);
                                    } else {
                                        next();
                                    }
                                });
                                task.delay(1000);
                            }
                        },
                        function (next){
                            me.logSuccess('Item has been successfully selected');
                            next();
                        },
                        next
                    ]);
                } else {
                    me.logFailed('Combo Box is not found');
                    next();
                }
            } else {
                me.logFailed('Combo Box is not found');
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    /**
     * Enters data in the grid.
     *
     * @param {String} item Item Id (without prefix) of the grid.
     *
     * @param {Integer} row Index of the row in the grid.
     *
     * @param {String} column Data Index or the Item Id of the column.
     *
     * @param {Integer} index Index of the row to select.
     *
     * @returns {iRely.FunctionalTest}
     */
    selectGridComboBoxRowNumber: function(item, row, column, index) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();
            if (win) {
                var grid = item.editingPlugin ? item : win.down('#grd'+item);
                if (grid) {
                    var store = grid.store;
                    grid.editingPlugin.completeEdit();
                    row = store.getAt(row-1);

                    if(isNaN(column)) {
                        if (Ext.Array.indexOf(grid.columns, column) === -1) {
                            column = grid.columns[column] || grid.columnManager.getHeaderById(column) || grid.down('[dataIndex=' + (column) + ']');
                        }
                    }
                    else {
                        if (Ext.Array.indexOf(grid.columns, column-1) === -1) {
                            column = grid.columns[column-1] || grid.columnManager.getHeaderById(column) || grid.down('[dataIndex=' + (column-1) + ']');
                        }
                    }

                    if (row && column) {
                        var plugin = grid.editingPlugin,
                            cell = plugin.getCell(row, column);

                        if (plugin.clicksToEdit === 1) {
                            t.click(cell);
                        } else {
                            t.doubleClick(cell);
                        }

                        if (plugin.activeEditor) {
                            me.logEvent('Entering combobox data on ' + item + ' grid');

                            var editor = plugin.activeEditor,
                                els = (function() {
                                    var cell = editor.field.el.query('.x-trigger-cell'),
                                        form = editor.field.el.query('.x-form-trigger');

                                    return (cell.length && cell) || (form.length && form);
                                })(),
                                length = els.length,
                                trigger = els[length - 1];

                            var panel = Ext.WindowManager.getActive(),
                                grid,
                                comboStore;

                            t.chain([
                                {
                                    action: 'click',
                                    target: trigger
                                },
                                function(next){
                                    if (panel.getView) {
                                        grid = panel.getView();
                                    } else {
                                        grid = editor.field.getPicker();
                                    }
                                    comboStore = grid.getStore();
                                    if(comboStore.remoteFilter == true){
                                        if(comboStore.isLoading() == true) {
                                            t.waitForStoresToLoad(comboStore, function () {
                                                next();
                                            })
                                        }
                                        else{
                                            next();
                                        }
                                    }
                                    else {
                                        var task = new Ext.util.DelayedTask(function () {
                                            next();
                                        });
                                        task.delay(1500);
                                    }
                                },
                                function(next) {
                                    if (panel.getView) {
                                        grid = panel.getView();
                                    } else {
                                        grid = editor.field.getPicker();
                                    }

                                    if(grid.getView && !grid.getNode){
                                        grid = grid.getView();
                                    }

                                    if (grid) {
                                        var node = grid.getNode(index-1);
                                        t.click(node, function() {
                                            editor.completeEdit();
                                            next();
                                        });
                                    } else {
                                        me.logFailed('Combo Box is not found');
                                        next();
                                    }
                                },
                                function (next){
                                    me.logSuccess('Data has been successfully entered');
                                    next();
                                },
                                next
                            ]);
                        } else {
                            me.logFailed('Combo Box is not found');
                            next();
                        }
                    } else {
                        me.logFailed('Cell is not found');
                        next();
                    }
                } else {
                    me.logFailed('Cell is not found');
                    next();
                }
            } else {
                me.logFailed('Cell is not found');
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    /**
     * Enters data in the grid.
     *
     * @param {String} item Item Id (without prefix) of the grid.
     *
     * @param {Integer} row Index of the row in the grid.
     *
     * @param {String} column Data Index or the Item Id of the column.
     *
     * @param {String/[Object]} filter Simple/Advance filter to be applied.
     *
     *     .selectGridComboRowByFilter('#grdSample', 0, 'strType', 'My Type')
     *
     * or
     *
     *     .selectGridComboRowByFilter('#grdSample', 0, 'strType', [
     *     {
     *         dataIndex: 'strType',
     *         value: 'sample',
     *         condition: 'ct'
     *     },
     *     {
     *         dataIndex: 'strOtherField',
     *         value: 'other',
     *         condition: 'eq',
     *         conjuction: 'and'
     *     }])
     *
     * @param {String} comboColumn Fieldname of the combo grid to be filtered.
     *
     * @param {Integer} index Index of the row to select.
     *
     * @returns {iRely.FunctionalTest}
     */
    selectGridComboBoxRowValue: function(item, row, column, filter, comboColumn, index) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();
            if (win) {
                var grid = item.editingPlugin ? item : win.down('#grd'+item);
                if (grid) {
                    if(row > 0) row = row - 1;
                    if(index > 0) index = index - 1;

                    var store = grid.store;
                    grid.editingPlugin.completeEdit();
                    row = store.getAt(row);

                    if(isNaN(column)) {
                        if (Ext.Array.indexOf(grid.columns, column) === -1) {
                            column = grid.columns[column] || grid.columnManager.getHeaderById(column) || grid.down('[dataIndex=' + column + ']');
                        }
                    }
                    else {
                        if (Ext.Array.indexOf(grid.columns, column-1) === -1) {
                            column = grid.columns[column-1] || grid.columnManager.getHeaderById(column) || grid.down('[dataIndex=' + (column-1) + ']');
                        }
                    }

                    if (row && column) {
                        var plugin = grid.editingPlugin,
                            cell = plugin.getCell(row, column);

                        if (plugin.clicksToEdit === 1) {
                            t.click(cell);
                        } else {
                            t.doubleClick(cell);
                        }

                        if (plugin.activeEditor) {
                            me.logEvent('Entering combobox data on ' + item + ' grid');

                            var editor = plugin.activeEditor,
                                els = (function() {
                                    var cell = editor.field.el.query('.x-trigger-cell'),
                                        form = editor.field.el.query('.x-form-trigger');

                                    return (cell.length && cell) || (form.length && form);
                                })(),
                                length = els.length,
                                trigger = els[length - 1];

                            if (Ext.isArray(filter)) {
                                editor.field.defaultFilters = filter;

                                t.chain([
                                    {
                                        action: 'wait',
                                        delay: 100
                                    },
                                    function(next) {
                                        editor.field.expand();
                                        next();
                                    },
                                    function(next) {
                                        var comboGrid =  editor.field.getPicker();
                                        if (typeof(comboGrid.getView) == "function") {
                                            var node = comboGrid.getView().getNode(0);
                                            t.click(node, function() {
                                                editor.completeEdit();
                                                next();
                                            });
                                        } else {
                                            next();
                                        }
                                    },
                                    next
                                ]);

                                return;
                            }

                            t.chain([
                                {
                                    action: 'click',
                                    target: trigger
                                },
                                function(next){
                                    var task = new Ext.util.DelayedTask(function(){
                                        next();
                                    });
                                    task.delay(1000);
                                },
                                function(next){
                                    t.selectText(editor, 0, 30);
                                    next();
                                },
                                function(next){
                                    t.type(editor, filter, next);
                                },
                                function(next){
                                    if(store.remoteFilter == true){
                                        var task = new Ext.util.DelayedTask(function () {
                                            if(store.isLoading() == true) {
                                                t.waitForStoresToLoad(store, function () {
                                                    next();
                                                })
                                            }
                                            else{
                                                next();
                                            }
                                        });
                                        task.delay(1000);
                                    }
                                    else {
                                        var task = new Ext.util.DelayedTask(function () {
                                            next();
                                        });
                                        task.delay(1500);
                                    }
                                },
                                function(next){
                                    if (editor.field.isExpanded === true){
                                        var comboGrid =  editor.field.getPicker(),
                                            store1 = comboGrid.store,
                                            storeCount = store1.getCount();

                                        if (storeCount === 1){
                                            if (typeof(comboGrid.getView) == "function") {
                                                var node = comboGrid.getView().getNode(0);
                                                t.click(node, function() {
                                                    editor.completeEdit();
                                                    next();
                                                });
                                            } else {
                                                next();
                                            }
                                        } else if (store1.isLoading() == true){
                                            t.waitForStoresToLoad(store1, function () {
                                                var filterRec = store1.findExact(comboColumn, filter),
                                                    record = store1.getAt(filterRec);

                                                if(index != null) record = index;
                                                if (typeof(comboGrid.getView) == "function") {
                                                    var node1 = comboGrid.getView().getNode(record);
                                                    t.click(node1, next);
                                                } else {
                                                    next();
                                                }
                                            })
                                        } else {
                                            var filterRec = store1.findExact(comboColumn, filter),
                                                record = store1.getAt(filterRec);

                                            if(index != null) record = index;
                                            if (typeof(comboGrid.getView) == "function") {
                                                var node1 = comboGrid.getView().getNode(record);
                                                t.click(node1, next);
                                            } else {
                                                next();
                                            }
                                        }
                                    } else {
                                        next();
                                    }
                                },
                                function (next){
                                    me.logSuccess('Data has been successfully entered');
                                    next();
                                },
                                next
                            ]);
                        } else {
                            me.logFailed('Combo Box is not found');
                            next();
                        }
                    } else {
                        me.logFailed('Cell is not found');
                        next();
                    }
                } else {
                    me.logFailed('Cell is not found');
                    next();
                }
            } else {
                me.logFailed('Cell is not found');
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    /**
     * Enters value in the bottom row of the grid.
     *
     * @param {String} item Item Id (without prefix) of the grid.
     *
     * @param {String} column Data Index or the Item Id of the column.
     *
     * @param {String/[Object]} filter Simple/Advance filter to be applied.
     *
     * @param {String} comboColumn Data Index or the Item Id of the column in the combo box.
     *
     * @param {Integer} index Index of the row to select.
     *
     * @returns {iRely.FunctionalTest}
     */
    selectGridComboBoxBottomRowValue: function(item,  column, filter, comboColumn, index) {
        var me = this,
            chain = me.chain;
        me.selectBottomRow(item);
        var fn = function (next) {
            var t = this,
                win = Ext.WindowManager.getActive();
            if (win) {
                var grid = item.editingPlugin ? item : win.down('#grd'+item);
                if (grid) {
                    var store = grid.store,
                        sm = grid.getSelectionModel(),
                        selected, row;
                    if (!sm) {
                        t.ok(false, 'No Selected Record');
                    }
                    selected = sm.getSelection();
                    if (selected > 1) {
                        t.ok(false, 'Only supports 1 data row entry at one time');
                    }
                    row = store.indexOf(selected[0]);
                    index = index - 1;
                    if (row !== -1) {
                        row = store.getAt(row);
                    }
                    else {
                        next();
                    }
                    if (Ext.Array.indexOf(grid.columns, column) === -1) {
                        column = grid.columns[column] || grid.columnManager.getHeaderById(column) || grid.down('[dataIndex=' + column + ']');
                    }
                    if (row && column) {
                        var plugin = grid.editingPlugin,
                            cell = plugin.getCell(row, column);
                        if (plugin.clicksToEdit === 1) {
                            t.click(cell);
                        } else {
                            t.doubleClick(cell);
                        }
                        if (plugin.activeEditor) {
                            var editor = plugin.activeEditor,
                                els = (function () {
                                    var cell = editor.field.el.query('.x-trigger-cell'),
                                        form = editor.field.el.query('.x-form-trigger');
                                    return (cell.length && cell) || (form.length && form);
                                })(),
                                length = els.length,
                                trigger = els[length - 1];
                            t.diag('Entering data on grid ' + item);
                            if (Ext.isArray(filter)) {
                                editor.field.defaultFilters = filter;
                                t.chain([
                                    {
                                        action: 'wait',
                                        delay: 100
                                    },
                                    function (next) {
                                        editor.field.expand();
                                        next();
                                    },
                                    function (next) {
                                        var comboGrid = editor.field.getPicker();
                                        if (typeof(comboGrid.getView) == "function") {
                                            var node = comboGrid.getView().getNode(0);
                                            t.click(node, function () {
                                                editor.completeEdit();
                                                next();
                                            });
                                        } else {
                                            next();
                                        }
                                    },
                                    next
                                ]);
                                return;
                            }
                            t.chain([
                                {
                                    action: 'click',
                                    target: trigger
                                },
                                function(next)
                                {
                                    var task = new Ext.util.DelayedTask(function(){
                                        next();
                                    });

                                    task.delay(1000);
                                },
                                function (next) {
                                    t.selectText(editor, 0, 30);
                                    next();
                                },
                                function (next) {
                                    t.type(editor, filter, next);
                                },
                                function(next)
                                {
                                    var task = new Ext.util.DelayedTask(function(){
                                        next();
                                    });

                                    task.delay(1000);
                                },
                                function (next) {
                                    if (editor.field.isExpanded === true) {
                                        var comboGrid = editor.field.getPicker(),
                                            store1 = comboGrid.store,
                                            storeCount = store1.getCount();
                                        if (storeCount === 1) {
                                            if (typeof(comboGrid.getView) == "function") {
                                                var node = comboGrid.getView().getNode(0);
                                                t.click(node, function () {
                                                    editor.completeEdit();
                                                    next();
                                                });
                                            } else {
                                                next();
                                            }
                                        } else if (store1.isLoading() == true) {
                                            t.waitForStoresToLoad(store1, function () {
                                                var filterRec = store1.findExact(comboColumn, filter),
                                                    record = store1.getAt(filterRec);
                                                if (index != null) record = index;
                                                if (typeof(comboGrid.getView) == "function") {
                                                    var node1 = comboGrid.getView().getNode(record);
                                                    t.click(node1, next);
                                                } else {
                                                    next();
                                                }
                                            })
                                        } else {
                                            var filterRec = store1.findExact(comboColumn, filter),
                                                record = store1.getAt(filterRec);
                                            if (index != null) record = index;
                                            if (typeof(comboGrid.getView) == "function") {
                                                var node1 = comboGrid.getView().getNode(record);
                                                t.click(node1, next);
                                            } else {
                                                next();
                                            }
                                        }
                                    } else {
                                        next();
                                    }
                                },
                                next
                            ]);
                        } else {
                            t.ok(false, 'Combo Box is not existing.');
                            next();
                        }
                    } else {
                        t.ok(false, 'Cell is not existing.');
                        next();
                    }
                } else {
                    t.ok(false, 'Cell is not existing.');
                    next();
                }
            } else {
                t.ok(false, 'Cell is not existing.');
                next();
            }
        };
        chain.push(fn);
        return this;
    },

    /**
     * Selects the bottom row of the grid.
     *
     * @param {String} item Item Id (without prefix) of the grid.
     *
     * @returns {iRely.FunctionalTest}
     */
    selectBottomRow : function(item) {
        var me = this,
            chain = me.chain,
            fn = function (next) {
                var w = Ext.WindowManager.getActive(),
                    grid = w.down(!item ? 'grid' : item),
                    store = grid.getStore(),
                    sm = grid.getSelectionModel();
                var storeLoadCheck = setInterval(function () {
                    if (store.isLoaded()) {
                        clearInterval(storeLoadCheck);
                        if (store.data.items.length.bottom){
                            sm.select(store.data.items.length - 2);
                        }
                        next();
                    }
                }, 30);
            };
        chain.push(fn);
        return this;
    },

    /**
     * Enters value in the dummy row of the grid.
     *
     * @param {String} item Item Id (without prefix) of the grid.
     *
     * @param {String} column Data Index or the Item Id of the column.
     *
     * @param {String/[Object]} filter Simple/Advance filter to be applied.
     *
     * @param {String} comboColumn Data Index or the Item Id of the column in the combo box.
     *
     * @param {Integer} index Index of the row to select.
     *
     * @returns {iRely.FunctionalTest}
     */
    selectGridComboBoxDummyRowValue: function(item,  column, filter, comboColumn, index) {
        var me = this,
            chain = me.chain;
        me.selectDummyRow(item);
        var fn = function (next) {
            var t = this,
                win = Ext.WindowManager.getActive();
            if (win) {
                var grid = item.editingPlugin ? item : win.down('#grd'+item);
                if (grid) {
                    var store = grid.store,
                        sm = grid.getSelectionModel(),
                        selected, row;
                    if (!sm) {
                        t.ok(false, 'No Selected Record');
                    }
                    index = index - 1;
                    selected = sm.getSelection();
                    if (selected > 1) {
                        t.ok(false, 'Only supports 1 data row entry at one time');
                    }
                    row = store.indexOf(selected[0]);
                    if (row !== -1) {
                        row = store.getAt(row);
                    }
                    else {
                        next();
                    }
                    if (Ext.Array.indexOf(grid.columns, column) === -1) {
                        column = grid.columns[column] || grid.columnManager.getHeaderById(column) || grid.down('[dataIndex=' + column + ']');
                    }
                    if (row && column) {
                        var plugin = grid.editingPlugin,
                            cell = plugin.getCell(row, column);
                        if (plugin.clicksToEdit === 1) {
                            t.click(cell);
                        } else {
                            t.doubleClick(cell);
                        }
                        if (plugin.activeEditor) {
                            var editor = plugin.activeEditor,
                                els = (function () {
                                    var cell = editor.field.el.query('.x-trigger-cell'),
                                        form = editor.field.el.query('.x-form-trigger');
                                    return (cell.length && cell) || (form.length && form);
                                })(),
                                length = els.length,
                                trigger = els[length - 1];
                            t.diag('Entering data on grid ' + item);
                            if (Ext.isArray(filter)) {
                                editor.field.defaultFilters = filter;
                                t.chain([
                                    {
                                        action: 'wait',
                                        delay: 100
                                    },
                                    function (next) {
                                        editor.field.expand();
                                        next();
                                    },
                                    function (next) {
                                        var comboGrid = editor.field.getPicker();
                                        if (typeof(comboGrid.getView) == "function") {
                                            var node = comboGrid.getView().getNode(0);
                                            t.click(node, function () {
                                                editor.completeEdit();
                                                next();
                                            });
                                        } else {
                                            next();
                                        }
                                    },
                                    next
                                ]);
                                return;
                            }
                            t.chain([
                                {
                                    action: 'click',
                                    target: trigger
                                },
                                function(next)
                                {
                                    var task = new Ext.util.DelayedTask(function(){
                                        next();
                                    });

                                    task.delay(1000);
                                },
                                function (next) {
                                    t.selectText(editor, 0, 30);
                                    next();
                                },
                                function (next) {
                                    t.type(editor, filter, next);
                                },
                                function(next)
                                {
                                    var task = new Ext.util.DelayedTask(function(){
                                        next();
                                    });

                                    task.delay(1000);
                                },
                                function (next) {
                                    if (editor.field.isExpanded === true) {
                                        var comboGrid = editor.field.getPicker(),
                                            store1 = comboGrid.store,
                                            storeCount = store1.getCount();
                                        if (storeCount === 1) {
                                            if (typeof(comboGrid.getView) == "function") {
                                                var node = comboGrid.getView().getNode(0);
                                                t.click(node, function () {
                                                    editor.completeEdit();
                                                    next();
                                                });
                                            } else {
                                                next();
                                            }
                                        } else if (store1.isLoading() == true) {
                                            t.waitForStoresToLoad(store1, function () {
                                                var filterRec = store1.findExact(comboColumn, filter),
                                                    record = store1.getAt(filterRec);
                                                if (index != null) record = index;
                                                if (typeof(comboGrid.getView) == "function") {
                                                    var node1 = comboGrid.getView().getNode(record);
                                                    t.click(node1, next);
                                                } else {
                                                    next();
                                                }
                                            })
                                        } else {
                                            var filterRec = store1.findExact(comboColumn, filter),
                                                record = store1.getAt(filterRec);
                                            if (index != null) record = index;
                                            if (typeof(comboGrid.getView) == "function") {
                                                var node1 = comboGrid.getView().getNode(record);
                                                t.click(node1, next);
                                            } else {
                                                next();
                                            }
                                        }
                                    } else {
                                        next();
                                    }
                                },
                                next
                            ]);
                        } else {
                            t.ok(false, 'Combo Box is not existing.');
                            next();
                        }
                    } else {
                        t.ok(false, 'Cell is not existing.');
                        next();
                    }
                } else {
                    t.ok(false, 'Cell is not existing.');
                    next();
                }
            } else {
                t.ok(false, 'Cell is not existing.');
                next();
            }
        };
        chain.push(fn);
        return this;
    },

    //endregion

    //endregion

    //region Record Navigation

    /**
     * Moves to the first record by clicking the move first button of the paging toolbar
     *
     * @returns {iRely.FunctionalTest}
     */
    moveFirstRecord: function() {
        this.recordNavigation('#first','first');
        return this;
    },

    /**
     * Moves to the previous record by clicking the move previous button of the paging toolbar
     *
     * @returns {iRely.FunctionalTest}
     */
    movePreviousRecord: function() {
        this.recordNavigation('#prev','previous');
        return this;
    },

    /**
     * Moves to the next record by clicking the move next button of the paging toolbar
     *
     * @returns {iRely.FunctionalTest}
     */
    moveNextRecord: function() {
        this.recordNavigation('#next','next');
        return this;
    },

    /**
     * Moves to the last record by clicking the move last button of the paging toolbar
     *
     * @returns {iRely.FunctionalTest}
     */
    moveLastRecord: function() {
        this.recordNavigation('#last','last');
        return this;
    },

    /**
     * Reloads the current record by clicking the refresh button of the toolbar.
     *
     * @returns {iRely.FunctionalTest}
     */
    refreshRecord: function() {
        this.recordNavigation('#refresh','refresh');
        return this;
    },

    /*
     * @private
     * This method navigate records
     *
     * @param {String} item Navigation button name.
     *
     * @param {String} msg Custom message.
     */
    recordNavigation: function(item, msg) {
        var me = this,
            chain = me.chain;

        var fn = function (next) {
            var t = this,
                win = Ext.WindowManager.getActive() || me.getComponentByQuery('viewport').down('#pnlIntegratedDashboard') || me.getComponentByQuery('viewport');

            if (win) {
                var button = win.down(item);
                if (button) {
                    me.logEvent('Moving to ' + msg + ' record');
                    t.chain([
                        {
                            action: 'click',
                            target: button
                        },
                        function (next) {
                            var task = new Ext.util.DelayedTask(function () {
                                next();
                            });
                            task.delay(500);
                        },
                        function (next) {
                            t.waitForFn(function () {
                                me.waitUntilLoaded();
                                return true;
                            }, function () {
                                next();
                            }, this, 60000);
                        },
                        function (next) {
                            var newActive = Ext.WindowManager.getActive();
                            if (newActive) {
                                if (newActive.xtype === 'quicktip') {
                                    newActive.close();
                                }
                            }
                            next();
                        },
                        function (next){
                            me.logSuccess('Record successfully loaded');
                            next();
                        },
                        next
                    ]);
                } else {
                    me.logFailed(msg + ' button is not found');
                    next();
                }
            } else {
                next();
            }
        };

        chain.push(fn);

        return this;
    },

    //endregion

    //region Control/Data Checking

    //region Control

    /**
     * Checks the control if readonly/editable.
     *
     * @param {String} type Type of control
     *
     * Form Panel = frm
     * Text Field = txt
     * Combo Box = cbo
     * Button = btn
     * Label = lbl
     * Check Box = chk
     * Date Field = dtm
     * Number Field = num
     * Grid = grd
     * Tab Panel = tab
     * Tab Page = pge
     * Panel = pnl
     * Container = con
     * Toolbar = tlb
     * Paging Toolbar = pgt
     * Separator = sep
     * Column = col
     * Grid View = grv
     *
     * @param {String/[String]} items Item Id/Array of Item Ids of the control(s) to assert.
     *
     * @param {Boolean} readOnly True to assert if the control is readonly otherwise editable.
     *
     * @param {Integer} tab Index of the tab to be filtered. Optional.
     *
     * @returns {iRely.FunctionalTest}
     */
    isControlReadOnly: function(type, items, readOnly, tab) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive(),
                msg = readOnly ? 'readonly' : 'editable';

            items = Ext.isArray(items) ? items : [items];

            for (var i in items) {
                var item = items[i],
                    control = win.down(me.getControlId(type,item));

                if (tab) {
                    var tabPanel = win.down('tabpanel').items.items[tab-1];
                    control = tabPanel.down(me.getControlId(type,item));
                }

                if (control) {
                    me.logEvent('Checking ' + item + ' ' + type + ' control' + msg);
                    var hidden = control.hidden;
                    if (hidden) {
                        me.logFailed(item + ' is not visible');
                    } else {
                        var result = control.readOnly === readOnly;
                        t.ok(result, result ? (readOnly ? item + ' is read only' : item + ' is editable') : (readOnly ? item + ' is editable' : item + ' is read only'));
                    }
                } else {
                    me.logFailed(item + ' is not found');
                }
            }

            next();
        };

        chain.push(fn);
        return this;
    },

    /**
     * Checks the control if visible/hidden.
     *
     * @param {String} type Type of control
     *
     * Form Panel = frm
     * Text Field = txt
     * Combo Box = cbo
     * Button = btn
     * Label = lbl
     * Check Box = chk
     * Date Field = dtm
     * Number Field = num
     * Grid = grd
     * Tab Panel = tab
     * Tab Page = pge
     * Panel = pnl
     * Container = con
     * Toolbar = tlb
     * Paging Toolbar = pgt
     * Separator = sep
     * Column = col
     * Grid View = grv
     *
     * @param {String/[String]} items Item Id/Array of Item Ids of the control(s) to assert.
     *
     * @param {Boolean} visible True to assert if the control is visible otherwise hidden.
     *
     * @param {Integer} tab Index of the tab to be filtered. Optional.
     *
     * @returns {iRely.FunctionalTest}
     */
    isControlVisible: function(type, items, visible, tab) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive(),
                msg = visible ? 'visible' : 'hidden';

            items = Ext.isArray(items) ? items : [items];

            if (win.xtype === 'quicktip') {
                win.close();
                win = Ext.WindowManager.getActive();
            }

            for (var i in items) {
                var item = items[i],
                    control = win.down(me.getControlId(type,item));

                if (tab) {
                    var tabPanel = win.down('tabpanel').items.items[tab-1];
                    control = tabPanel.down(me.getControlId(type,item));
                }

                if (control) {
                    me.logEvent('Checking ' + item + ' ' + type + ' control' + msg);
                    var result = control.hidden === !visible;
                    t.ok(result, result ? (visible ? item + ' is visible' : item + ' is not visible') : (visible ? item + ' is hidden' : item + ' is not hidden'));
                } else {
                    me.logFailed(item + ' is not found');
                }
            }

            next();
        };

        chain.push(fn);
        return this;
    },

    /**
     * Checks the control if disabled/enabled.
     *
     * @param {String} type Type of control
     *
     * Form Panel = frm
     * Text Field = txt
     * Combo Box = cbo
     * Button = btn
     * Label = lbl
     * Check Box = chk
     * Date Field = dtm
     * Number Field = num
     * Grid = grd
     * Tab Panel = tab
     * Tab Page = pge
     * Panel = pnl
     * Container = con
     * Toolbar = tlb
     * Paging Toolbar = pgt
     * Separator = sep
     * Column = col
     * Grid View = grv
     *
     * @param {String/[String]} items Item Id/Array of Item Ids of the control(s) to assert.
     *
     * @param {Boolean} disabled True to assert if the control is disabled otherwise enabled.
     *
     * @param {Integer} tab Index of the tab to be filtered. Optional.
     *
     * @returns {iRely.FunctionalTest}
     */
    isControlDisable: function(type, items, disabled, tab) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive(),
                msg = disabled ? 'disabled' : 'enabled';

            items = Ext.isArray(items) ? items : [items];

            for (var i in items) {
                var item = items[i],
                    control = win.down(me.getControlId(type,item));

                if (tab) {
                    var tabPanel = win.down('tabpanel').items.items[tab-1];
                    control = tabPanel.down(me.getControlId(type,item));
                }

                if (control) {
                    me.logEvent('Checking ' + item + ' ' + type + ' control' + msg);
                    var hidden = control.hidden;
                    if (hidden) {
                        me.logFailed(item + ' is not visible');
                    } else {
                        var result = control.disabled === disabled;
                        t.ok(result, result ? (disabled ? item + ' is disabled' : item + ' is enabled') : (disabled ? item + ' is enabled' : item + ' is disabled'));
                    }
                } else {
                    me.logFailed(item + ' is not visible');
                }
            }

            next();
        };

        chain.push(fn);
        return this;
    },

    /*
     * @private
     * Checks if a component is shown or not.
     *
     * @param {String/Object} Xtype or the actual component to check.
     */
    isComponentShown: function(item) {
        var result = false;
        if (typeof item === "string") {
            var com = this.getComponentByQuery(item);

            if (com) {
                result = /*com.rendered || */com.hidden === false;
            }
        } else {
            result = /*item.rendered || */item.hidden === false;
        }

        return result;
    },

    /**
     * Verify if the checkbox is checked
     *
     * @param {String} item Item Id (without prefix) of the check box.
     *
     * @param {Boolean} checked Expected value of the checkbox
     *
     * @returns {iRely.FunctionalTest}
     */
    verifyCheckboxValue:function(item, checked) {
        var me = this,
            chain = this.chain;

        var fn = function(next) {
            if(typeof checked !== 'boolean') {
                me.logFailed('Checked value should be of type boolean found: ' + typeof checked);
                next();
            }

            var win = Ext.WindowManager.getActive();
            if(win) {
                var chkBox = win.down('#chk'+item);
                if(chkBox) {
                    me.logEvent('Verifying ' + item + ' checkbox value');
                    if(checked === chkBox.getValue()) {
                        me.logSuccess('Checkbox value is correct');
                    }
                    else {
                        me.logFailed('Checkbox value is incorrect');
                    }
                }
                else {
                    me.logFailed(item + ' is not found');
                }
            }

            next();
        };

        chain.push({action:fn,timeout:120000});
        return this;
    },


    /**
     * Checks the Screen's toolbar button.
     * Note: Without passing a parameter means it will checks all basic buttons (new, save, delete, search, undo, close)
     *
     * @param {Object} [options] Object.
     *
     * @param {Boolean} [options.new] False to exclude new button from checking. Defaults to true.
     *
     * @param {Boolean} [options.save] False to exclude save button from checking. Defaults to true.
     *
     * @param {Boolean} [options.delete] False to exclude delete button from checking. Defaults to true.
     *
     * @param {Boolean} [options.search] False to exclude search button from checking. Defaults to true.
     *
     * @param {Boolean} [options.refresh] False to exclude refresh button from checking. Defaults to true.
     *
     * @param {Boolean} [options.undo] False to exclude undo button from checking. Defaults to true.
     *
     * @param {Boolean} [options.close] False to exclude close button from checking. Defaults to true.
     *
     * @returns {iRely.FunctionalTest}
     */
    verifyToolbarButton: function(options) {
        var me = this,
            chain = me.chain;

        options = options || {};

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive(),
                newButton = options.new === undefined ? true : options.new,
                saveButton = options.save === undefined ? true : options.save,
                searchButton = options.search === undefined ? true : options.search,
                refreshButton = options.refresh === undefined ? true : options.refresh,
                deleteButton = options.delete === undefined ? true : options.delete,
                undoButton = options.undo === undefined ? true : options.undo,
                closeButton = options.close === undefined ? true : options.close;

            if (newButton) {
                var button = win.down('#btnNew');
                if (button) {
                    var visible = button.hidden === false,
                        text = button.text === 'New';

                    if (visible) {
                        me.logSuccess('New button is visible');
                        t.ok(text, text ? 'New button text is correct' : 'New button text is incorrect');
                    } else {
                        me.logFailed('New button is not visible');
                    }
                } else {
                    me.logFailed('New button is not found');
                }
            }

            if (saveButton) {
                var button = win.down('#btnSave');
                if (button) {
                    var visible = button.hidden === false,
                        text = button.text === 'Save';

                    if (visible) {
                        me.logSuccess('Save button is visible');
                        t.ok(text, text ? 'Save button text is correct' : 'Save button text is incorrect');
                    } else {
                        me.logFailed('Save button is not visible');
                    }
                } else {
                    me.logFailed('Save button is not found');
                }
            }

            if (searchButton) {
                var button = win.down('#btnSearch') || win.down('#btnFind');
                if (button) {
                    var visible = button.hidden === false,
                        text = button.text === 'Search';

                    if (visible) {
                        me.logSuccess('Search button is visible');
                        t.ok(text, text ? 'Search button text is correct' : 'Search button text is incorrect');
                    } else {
                        me.logFailed('Search button is not visible');
                    }
                } else {
                    me.logFailed('Search button is not found');
                }
            }

            if (refreshButton) {
                var button = win.down('#btnRefresh');
                if (button) {
                    var visible = button.hidden === false,
                        text = button.text === 'Refresh';

                    if (visible) {
                        me.logSuccess('Refresh button is visible');
                        t.ok(text, text ? 'Refresh button text is correct' : 'Refresh button text is incorrect');
                    } else {
                        me.logFailed('Refresh button is not visible');
                    }
                } else {
                    me.logFailed('Refresh button is not found');
                }
            }

            if (deleteButton) {
                var button = win.down('#btnDelete');
                if (button) {
                    var visible = button.hidden === false,
                        text = button.text === 'Delete';

                    if (visible) {
                        me.logSuccess('Delete button is visible');
                        t.ok(text, text ? 'Delete button text is correct' : 'Delete button text is incorrect');
                    } else {
                        me.logFailed('Delete button is not visible');
                    }
                } else {
                    me.logFailed('Delete button is not found');
                }
            }

            if (undoButton) {
                var button = win.down('#btnUndo');
                if (button) {
                    var visible = button.hidden === false,
                        text = button.text === 'Undo';

                    if (visible) {
                        me.logSuccess('Undo button is visible');
                        t.ok(text, text ? 'Undo button text is correct' : 'Undo button text is incorrect');
                    } else {
                        me.logFailed('Undo button is not visible');
                    }
                } else {
                    me.logFailed('Undo button is not found');
                }
            }

            if (closeButton) {
                var button = win.down('#btnClose');
                if (button) {
                    var visible = button.hidden === false,
                        text = button.text === 'Close';

                    if (visible) {
                        me.logSuccess('Close button is visible');
                        t.ok(text, text ? 'Close button text is correct' : 'Close button text is incorrect');
                    } else {
                        me.logFailed('Close button is not visible');
                    }
                } else {
                    me.logFailed('Close button is not found');
                }
            }

            next();
        };

        chain.push(fn);
        return this;
    },

    /**
     * Checks the Search Screen's toolbar buttons.
     * Note: Without passing a parameter means it will checks all basic buttons (new, save, delete, search, undo, close)
     *
     * @param {Object} [options] Object.
     *
     * @param {Boolean} [options.new] False to exclude new button from checking. Defaults to true.
     *
     * @param {Boolean} [options.open] False to exclude open button from checking. Defaults to true.
     *
     * @param {Boolean} [options.openselected] False to exclude openselected button from checking. Defaults to true.
     *
     * @param {Boolean} [options.openall] False to exclude openall button from checking. Defaults to true.
     *
     * @param {Boolean} [options.refresh] False to exclude refresh button from checking. Defaults to true.
     *
     * * @param {Boolean} [options.export] False to exclude export button from checking. Defaults to true.
     *
     * @param {Boolean} [options.close] False to exclude close button from checking. Defaults to true.
     *
     * @returns {iRely.FunctionalTest}
     */
    verifySearchToolbarButton: function(options) {
        var me = this,
            chain = me.chain;

        options = options || {};

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive() || me.getComponentByQuery('viewport').down('#pnlIntegratedDashboard'),
                newButton = options.new === undefined ? true : options.new,
                openButton = options.open === undefined ? true : options.open,
                openselectedButton = options.openselected === undefined ? true : options.openselected,
                openallButton = options.openall === undefined ? true : options.openall,
                refreshButton = options.refresh === undefined ? true : options.refresh,
                exportButton = options.export === undefined ? true : options.export,
                closeButton = options.close === undefined ? true : options.close;

            if (newButton) {
                var button = win.down('#btnNew');
                if (button) {
                    var visible = button.hidden === false,
                        text = button.text === 'New';

                    if (visible) {
                        me.logSuccess('New button is visible');
                        t.ok(text, text ? 'New button text is correct' : 'New button text is incorrect');
                    } else {
                        me.logFailed('New button is not visible');
                    }
                } else {
                    me.logFailed('New button is not found');
                }
            }

            if (openButton) {
                var button = win.down('#btnOpenSelected');
                if (button) {
                    var visible = button.hidden === false,
                        text = button.text === 'Open';

                    if (visible) {
                        me.logSuccess('Open button is visible');
                        t.ok(text, text ? 'Open button text is correct' : 'Open button text is incorrect');
                    } else {
                        me.logFailed('Open button is not visible');
                    }
                } else {
                    me.logFailed('Open button is not found');
                }
            }

            if (openselectedButton) {
                var button = win.down('#btnOpenSelected');
                if (button) {
                    var visible = button.hidden === false,
                        text = button.text === 'Open Selected';

                    if (visible) {
                        me.logSuccess('Open Selected button is visible');
                        t.ok(text, text ? 'Open Selected button text is correct' : 'Open Selected button text is incorrect');
                    } else {
                        me.logFailed('Open Selected button is not visible');
                    }
                } else {
                    me.logFailed('Open Selected button is not found');
                }
            }

            if (openallButton) {
                var button = win.down('#btnOpenAll');
                if (button) {
                    var visible = button.hidden === false,
                        text = button.text === 'Open All';

                    if (visible) {
                        me.logSuccess('Open All button is visible');
                        t.ok(text, text ? 'Open All button text is correct' : 'Open All button text is incorrect');
                    } else {
                        me.logFailed('Open All button is not visible');
                    }
                } else {
                    me.logFailed('Open All button is not found');
                }
            }

            if (refreshButton) {
                var button = win.down('#btnRefresh');
                if (button) {
                    var visible = button.hidden === false,
                        text = button.text === 'Refresh';

                    if (visible) {
                        me.logSuccess('Refresh button is visible');
                        t.ok(text, text ? 'Refresh button text is correct' : 'Refresh button text is incorrect');
                    } else {
                        me.logFailed('Refresh button is not visible');
                    }
                } else {
                    me.logFailed('Refresh button is not found');
                }
            }

            if (exportButton) {
                var button = win.down('#btnExport');
                if (button) {
                    var visible = button.hidden === false,
                        text = button.text === 'Export';

                    if (visible) {
                        me.logSuccess('Export button is visible');
                        t.ok(text, text ? 'Export button text is correct' : 'Export button text is incorrect');
                    } else {
                        me.logFailed('Export button is not visible');
                    }
                } else {
                    me.logFailed('Export button is not found');
                }
            }

            if (closeButton) {
                var button = win.down('#btnClose');
                if (button) {
                    var visible = button.hidden === false,
                        text = button.text === 'Close';

                    if (visible) {
                        me.logSuccess('Close button is visible');
                        t.ok(text, text ? 'Close button text is correct' : 'Close button text is incorrect');
                    } else {
                        me.logFailed('Close button is not visible');
                    }
                } else {
                    me.logFailed('Close button is not found');
                }
            }
            next();
        };

        chain.push(fn);
        return this;
    },


    /**
     * Checks if the active screen uses our standard status bar (istatusbar)
     *
     * @returns {iRely.FunctionalTest}
     */
    verifyStatusBar: function() {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();

            me.logEvent('Checking Status bar');

            var result = win.down('istatusbar') !== undefined || win.down('istatusbar') !== null;
            t.ok(result, result ? 'Status bar is correct' : 'Status bar is incorrect');

            next();
        };

        chain.push(fn);
        return this;
    },

    /**
     * Checks the status bar message.
     *
     * @param {String} status Message of the status bar ('Ready', 'Edited', 'Saved').
     *
     * @returns {iRely.FunctionalTest}
     */
    verifyStatusMessage: function(status) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive(),
                statusBar = win.down('ipagingstatusbar');

            me.logEvent('Checking Status Message');

            if (!statusBar) {
                statusBar = win.down('istatusbar');
            }

            if (statusBar) {
                var label = statusBar.down('#lblStatus'),
                    result = label.el.dom.textContent === status;
                t.ok(result, result ? 'Status Message is correct' : 'Status Message is incorrect');
            }

            next();
        };

        chain.push(fn);
        return this;
    },

    /**
     * Checks if the active screen uses our standard paging status bar (ipagingstatusbar)
     *
     * @returns {iRely.FunctionalTest}
     */
    verifyPagingStatusBar: function() {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();

            me.logEvent('Checking Paging status bar');

            var result = win.down('ipagingstatusbar') !== undefined || win.down('ipagingstatusbar') !== null;
            t.ok(result, result ? 'Paging status bar is correct' : 'Paging status bar is incorrect');

            next();
        };

        chain.push(fn);
        return this;
    },


    /**
     * Checks the Screen.
     *
     * @param {Object} options Object.
     *
     * @param {String} options.alias User alias of the screen to check.
     *
     * @param {String} options.title Title of the screen.
     *
     * @param {Boolean} [options.collapse] False to exclude collapse button from checking. Defaults to true.
     *
     * @param {Boolean} [options.minimize] False to exclude minimize button from checking. Defaults to true.
     *
     * @param {Boolean} [options.maximize] False to exclude maximize button from checking. Defaults to true.
     *
     * @param {Boolean} [options.restore] False to exclude restore button from checking. Defaults to true.
     *
     * @param {Boolean} [options.close] False to exclude close button from checking. Defaults to true.
     *
     * @returns {iRely.FunctionalTest}
     */
    verifyScreenWindow: function(options) {
        var me = this,
            chain = me.chain;

        options = options || {};

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive(),
                alias = options.alias,
                title = options.title,
                collapseButton = options.collapse === undefined ? true : options.collapse,
                maximizeButton = options.maximize === undefined ? true : options.maximize,
                minimizeButton = options.minimize === undefined ? true : options.minimize,
                restoreButton = options.restore === undefined ? true : options.restore,
                closeButton = options.close === undefined ? true : options.close;

            if (win) {
                me.logEvent('Checking Screen Window');

                var icon = win.iconCls === 'small-icon-i21' || win.iconCls === 'small-irely-icon', //TODO: Verify this
                    titleResult = win.title === title;

                if (alias) {
                    var userAlias = win.alias[0];
                    if (userAlias.replace('widget.', '') === alias) {
                        me.logSuccess('Screen is shown');
                    } else {
                        me.logFailed('Screen is not shown');
                        next();
                        return;
                    }
                }

                //t.ok(icon, icon ? 'Screen icon is correct.' : 'Screen icon is incorrect');
                t.ok(titleResult, titleResult ? 'Screen title is correct' : 'Screen title is incorrect');

                if (collapseButton) {
                    var result = win.tools['collapse-top'];
                    t.ok(result, result ? 'Collapse button is visible' : 'Collapse button is not visible');
                }

                if (maximizeButton) {
                    var result = win.tools['maximize'];
                    t.ok(result, result ? 'Maximize button is visible' : 'Maximize button is not visible');
                }

                if (minimizeButton) {
                    var result = win.tools['minimize'];
                    t.ok(result, result ? 'Minimize button is visible' : 'Minimize button is not visible');
                }

                if (restoreButton) {
                    var result = win.tools['restore'];
                    t.ok(result, result ? 'Restore button is visible' : 'Restore button is not visible');
                }

                if (closeButton) {
                    var result = win.tools['close'];
                    t.ok(result, result ? 'Close button is visible' : 'Close button is not visible');
                }
            }

            next();
        };

        chain.push(fn);
        return this;
    },

    /**
     * Checks the Screen title of integrated Search.
     *
     * @param {String} title Title of the screen.
     *
     * @returns {iRely.FunctionalTest}
     */
    verifyScreenTitle_intSearch : function(title) {
        var me = this,
            chain = this.chain;

        var fn = function(next) {
            var t = this,
                win = me.getComponentByQuery('viewport').down('#pnlIntegratedDashboard');

            if (win) {
                me.logEvent('Checking Screen Title of the integrated search');

                var intGrid = win.down('#pnlIntegratedDashboardGridPanel');

                if (intGrid.title === title) {
                    me.logSuccess(title + ' is correct');
                } else {
                    me.logFailed(title + ' is incorrect');
                }
                next();
            } else {
                me.logFailed('Screen is not shown');
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    /**
     * Checks if the screen is properly closed
     *
     * @param {String} item Item Id or alias of the window
     *
     * @returns {iRely.FunctionalTest}
     */
    verifyIfScreenClosed : function(item) {
        var me = this,
            chain = this.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive(),
                com = Ext.ComponentQuery.query(item)[0];

            if (win === null || win === undefined) {
                me.logSuccess(item + ' screen is closed');
                next();
            } else {
                if(!com) {
                    me.logSuccess(item + ' screen is closed');
                }
                else {
                    me.logFailed(item + ' screen is not closed');
                }
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    /**
     * Checks the screen if it's shown.
     *
     * @param {String} alias User alias of the screen to check.
     *
     * @returns {iRely.FunctionalTest}
     */
    verifyScreenShown: function(alias) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                shown = me.isComponentShown(alias);

            t.ok(shown, shown ? 'Screen is shown' : 'Screen is not shown');
            next();
        };

        chain.push(fn);
        return this;
    },


    /**
     * Checks the columns available in the grid.
     *
     * @param {String} item Item Id (without prefix) of the grid.
     *
     * @param {Object[]} columns Object definition for the column
     *
     *          {String} columns.dataIndex Data Index or Column Name
     *
     *          {String} columns.text The text display of the column
     *
     * @returns {iRely.FunctionalTest}
     */
    verifyGridColumnNames: function(item, columns) {
        var me = this,
            chain = me.chain;

        columns.forEach(function(column) {
            chain.push(function(next) {
                var win = Ext.WindowManager.getActive() || me.getComponentByQuery('viewport').down('#pnlIntegratedDashboard'),
                    grid = win.down('#grd'+item), cols, col;

                if(win) {
                    if(grid) {
                        cols = grid.columns;

                        col = Ext.Array.findBy(cols, function(gridCol) {
                            return gridCol.dataIndex === column.dataIndex;
                        });

                        if(col) {
                            if(col.text === column.text) {
                                me.logSuccess('Column \'' + column.text + '\' is in the grid');
                            }
                            else {
                                me.logFailed('Column \'' + column.text + '\' text is incorrect');
                            }
                        }
                        else {
                            me.logFailed('Column \'' + column.dataIndex + '\' is not present in the grid');
                        }
                        next();
                    }
                    else {
                        me.logFailed(item + ' grid is not found');
                        next();
                    }
                }
                else {
                    me.logFailed('There is no Active Window Open');
                    next();
                }
            });
        });

        return me;
    },

    /**
     * Function that opens the combo box and allows you to check its data
     *
     * @param {String} item Item Id (without prefix) of the combo box.
     *
     * @param {Function} checker Function for the combo box
     *
     * @returns {iRely.FunctionalTest}
     */
    verifyComboBox : function (item, checker) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();
            if (win) {
                var combo = item.value ? item : win.down('#cbo'+item);
                if (combo) {
                    me.logEvent('Verifying ' + item + ' combobox');

                    var length = combo.triggerEl.elements.length,
                        trigger = combo.triggerEl.elements[length - 1];

                    t.chain([
                        {
                            action: 'click',
                            target: trigger
                        },
                        {
                            action: 'wait',
                            delay: 300
                        },
                        function(next) {
                            var panel = Ext.WindowManager.getActive(),
                                grid;

                            if (panel.getView) {
                                grid = panel.getView();
                            } else {
                                grid = combo.getPicker();
                            }

                            if (grid) {
                                checker(next, win, grid, grid.getStore());
                            } else {
                                me.logFailed('Combo Box is not found');
                                next();
                            }
                        },
                        {
                            action: 'click',
                            target: trigger
                        },
                        function (next){
                            me.logSuccess('Successfully verified');
                            next();
                        },
                        next
                    ]);
                } else {
                    me.logFailed('Combo Box is not found');
                    next();
                }
            } else {
                me.logFailed('Combo Box  is not found');
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    /**
     * Checks if a component has a field label
     *
     * @param {String} type Type of control
     *
     * Form Panel = frm
     * Text Field = txt
     * Combo Box = cbo
     * Button = btn
     * Label = lbl
     * Check Box = chk
     * Date Field = dtm
     * Number Field = num
     * Grid = grd
     * Tab Panel = tab
     * Tab Page = pge
     * Panel = pnl
     * Container = con
     * Toolbar = tlb
     * Paging Toolbar = pgt
     * Separator = sep
     * Column = col
     * Grid View = grv
     *
     * @param {Object/Object[]} item
     *
     * @param {String} item.itemId ItemId (without prefix) of the component
     *
     * @param {String} item.label Label name for the component
     *
     * @returns {iRely.FunctionalTest}
     */
    verifyFieldLabel: function(type,item) {
        var me = this,
            chain = me.chain,
            items = Ext.isArray(item) ? item : [item];

        items.forEach(function(i){
            chain.push(
                function (next) {

                    me.logEvent('Checking Field Label for component ' + i);

                    var win = Ext.WindowManager.getActive(),
                        el = win.down(me.getControlId(type,i));
                    if (el) {
                        if (el.fieldLabel === i.label) {
                            me.logSuccess(el.fieldLabel + ' label is displayed in the screen');
                        }
                        else {
                            me.logFailed(el.fieldLabel + ' label is displayed in the screen');
                        }
                    }
                    next();
                }
            );
        });

        return this;
    },

    /**
     * Checks the message box.
     *
     * @param {String} title Title of the message box.
     *
     * @param {String} message Message of the message box.
     *
     * @param {String} buttons Buttons of the message box. ('ok', 'okcancel', 'yesno','yesnocancel').
     *
     * @param {String} icon Icon of the message box. ('error','information', 'question', 'warning')
     *
     * @returns {iRely.FunctionalTest}
     */
    verifyMessageBox: function(title, message, buttons, icon) {
        var me = this,
            chain = this.chain;

        buttons = buttons ? buttons : 'ok';
        icon    = icon ? icon : ''; //There should be changing of icon cls here

        var fn = function(next) {
            var t = this,
                msg = document.querySelector('.sweet-alert');

            me.logEvent('Verifying Message Box');

            if (msg){
                var btn = function(button){
                        return msg.querySelector('button.' + button).style.display === 'inline-block';
                    },
                    titleResult,
                    msgResult,
                    buttonResult,
                    iconCls = '',
                    iconResult;

                me.logSuccess('Message box is shown');
                t.ok(titleResult = (msg.querySelector('h2').innerHTML === title), titleResult ? 'Title is correct' : 'Title is incorrect');
                t.ok(msgResult = (msg.querySelector('p').innerHTML === message), msgResult ? 'Message is correct' : 'Message is incorrect');

                switch (buttons) {
                    case 'ok':
                        buttonResult =  (msg.querySelector('button.confirm').style.display === 'inline-block') && (msg.querySelector('button.cancel').style.display === 'none') && (msg.querySelector('button.cancel2').style.display === 'none');
                        break;
                    case 'okcancel':
                        buttonResult = (msg.querySelector('button.confirm').style.display === 'inline-block') && (msg.querySelector('button.cancel').style.display === 'inline-block') && (msg.querySelector('button.cancel2').style.display === 'none');
                        break;
                    case 'yesno':
                        buttonResult = (msg.querySelector('button.confirm').style.display === 'inline-block') && (msg.querySelector('button.cancel').style.display === 'inline-block') && (msg.querySelector('button.cancel2').style.display === 'none');
                        break;
                    case 'yesnocancel':
                        buttonResult = (msg.querySelector('button.confirm').style.display === 'inline-block') && (msg.querySelector('button.cancel').style.display === 'inline-block') && (msg.querySelector('button.cancel2').style.display === 'inline-block');
                        break;
                }

                switch (icon) {
                    case 'information':
                        iconResult = (msg.querySelector('.icon.info').style.display) === 'block';
                        break;
                    case 'question':
                        iconResult = (msg.querySelector('.icon.warning').style.display) === 'block';
                        break;
                    case 'error':
                        iconResult = (msg.querySelector('.icon.error').style.display) === 'block';
                        break;
                    case 'warning':
                        iconResult = (msg.querySelector('.icon.warning').style.display) === 'block';
                        break;
                }

                t.ok(buttonResult, buttonResult ? 'Button is correct' : 'Button is incorrect');
                t.ok(iconResult, iconResult ?  'Icon is correct' : 'Icon is incorrect');

            }
            else {
                me.logFailed('Message box is not shown');
            }
            next();
        };

        chain.push(fn);
        return this;
    },

    //endregion

    //region Data/Record/Value

    /**
     * Checks the control data if it matches the expected result.
     *
     * @param {String/[String]} items Item Id/Array of Item Ids of the control(s) to assert.
     *
     * @param {Object/[Object]} values Object/Array of Object to match with the control.
     *
     * @returns {iRely.FunctionalTest}
     */
    verifyData: function(type, items, values, condition) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();

            me.logEvent('Verifying Control Data');

            items = Ext.isArray(items) ? items : [items];
            values = Ext.isArray(values) ? values : [values];

            for (var i in items) {
                var item = items[i],
                    value = values[i];

                var control = win.down(me.getControlId(type,item));
                if (control) {
                    var fieldVal = control.rawValue;

                    if(control.xtype === 'numericfield' || control.xtype ===  'numeric' || control.xtype ===  'numberfield' || control.xtype === 'moneynumber'){
                        value = value.trim();
                        fieldVal = fieldVal.trim();
                    }

                    if(control.xtype === 'uxtagfield'){
                        fieldVal = control.getDisplayValue();
                    }

                    if(control.xtype === 'htmleditor'){
                        fieldVal = control.getValue();
                    }

                    var result = false;
                    if(!condition || condition === 'equal') {
                        result = fieldVal === value;
                    }
                    else if (condition === 'like'){
                        if(fieldVal.toLowerCase().indexOf(value.toLowerCase()) != -1){
                            result = true;
                        }
                    }
                    t.ok(result, result ? item + ' value is correct' : item + ' value is incorrect');
                } else {
                    me.logFailed(item + ' is not found');
                }
            }
            next();
        };

        chain.push(fn);
        return this;
    },

    /**
     * Checks the grid's data if it matches the expected result.
     *
     * @param {String} item Item Id (without prefix) of the grid.
     *
     * @param {Integer} row Index of the row in the grid.
     *
     * @param {Object} column Data Index or the Item Id of the column.
     *
     * @param {Object} data Data to match with the control.
     *
     * @returns {iRely.FunctionalTest}
     */
    verifyGridData: function(item, row, column, data) {
        var me = this,
            chain = this.chain;
        var row1 = row;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive() || me.getComponentByQuery('viewport').down('#pnlIntegratedDashboard');

            me.logEvent('Verifying ' + item + ' grid data');

            if (win) {
                var grid = item.editingPlugin ? item : win.down('#grd'+item);
                if (grid) {
                    var store = grid.store,
                        row = store.getAt(row1-1);

                    if(isNaN(column)) {
                        if (Ext.Array.indexOf(grid.columns, column) === -1) {
                            column = grid.columns[column] || grid.columnManager.getHeaderById(column) || grid.down('[dataIndex=' + column + ']');
                        }
                    }
                    else {
                        if (Ext.Array.indexOf(grid.columns, column-1) === -1) {
                            column = grid.columns[column-1] || grid.columnManager.getHeaderById(column) || grid.down('[dataIndex=' + (column-1) + ']');
                        }
                    }

                    if (row && column) {
                        var value = row.get(column.dataIndex),
                            result = (function() {
                                if(column.xtype === 'datecolumn') {
                                    value = new Date(value).toLocaleDateString();
                                    data = new Date(data).toLocaleDateString();
                                }
                                if(column.xtype === 'numbercolumn') {
                                    data = parseFloat(data);
                                }
                                return value === data;
                            })();
                        t.ok(result, result ? data + ' Cell data is correct' : data + ' Cell data is incorrect');

                        next();
                    } else {
                        me.logFailed('Cell is not found');
                        next();
                    }
                } else {
                    me.logFailed('Grid is not found');
                    next();
                }
            } else {
                me.logFailed('Grid is not found');
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    /**
     * Checks the grid's record count against the expected count.
     *
     * @param {String} item Item Id (without prefixe) of the grid.
     *
     * @param {Integer} expectedCount Record count to expect.
     *
     * @returns {iRely.FunctionalTest}
     */
    verifyGridRecordCount: function(item, expectedCount) {
        var me = this,
            chain = this.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive() || me.getComponentByQuery('viewport').down('#pnlIntegratedDashboard');

            me.logEvent('Verifying ' + item + ' grid record count');

            if (win) {
                var grid = item.editingPlugin ? item : win.down('#grd'+item);

                if (grid) {
                    var store = grid.store,
                        count = store.getCount(),
                        result;

                    if(grid.editingPlugin && !store.buffered && count > 0) {
                        if (store.data.items[store.data.length - 1].dummy) {
                            count--;
                        }
                    }

                    result = count === expectedCount;

                    t.ok(result, result ? 'Grid count is correct' : 'Grid count is incorrect');
                } else {
                    me.logFailed('Grid is not found');
                }
            } else {
                me.logFailed('Grid is not found');
            }
            next();
        };

        chain.push(fn);
        return this;
    },

    /**
     * Checks the value of the Paging Status Bar
     *
     * @param {Integer} currPage The expected current Page.
     *
     * @param {Integer} noOfPages The total number of records
     *
     * @returns {iRely.FunctionalTest}
     */
    verifyPagingStatusBarValue: function(currPage, noOfPages) {
        var me = this,
            chain = this.chain;

        var fn = function(next) {
            var t = this,
                w = Ext.WindowManager.getActive(),
                s = w.down('ipagingstatusbar');

            if(s) {
                var store = s.getStore(),
                    currPageCorrect = currPage === store.currentPage,
                    countCorrect = noOfPages === store.totalCount,
                    result = (function () {
                        var o =  {
                            value : false,
                            message : ''
                        };

                        if(!currPageCorrect && !countCorrect) {
                            o.message = 'error in current page value('+currPage+') and total page value ('+noOfPages+')';
                        }
                        else if(!currPageCorrect && countCorrect) {
                            o.message = 'error in current page value('+currPage+')';
                        }
                        else if(currPageCorrect && !countCorrect) {
                            o.message = 'error in total count value('+noOfPages+')';
                        }
                        else if(currPageCorrect && countCorrect) {
                            o.value = true;
                            o.message = 'paging values are correct';
                        }

                        return o;
                    })();

                t.ok(
                    result.value,
                    result.message
                );
            }
            else {
                me.logFailed(item + ' is not found');
            }

            next();
        };

        chain.push(fn);
        return this;
    },

    //endregion

    //region Report Viewer

    /**
     * @private
     * Gets and Checks Total Assets and Total Liability & Equity
     *
     * @param {String} item Class Name of the cell
     *
     * @returns {iRely.FunctionalTest}
     */
    checkBalanceSheetFRD : function(item) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this;

            t.waitForFn(function() {
                var iframe = window.parent.document.getElementsByClassName('tr-iframe')[window.parent.document.getElementsByClassName('tr-iframe').length-1];
                if (iframe){
                    if(iframe.contentWindow){
                        if(iframe.contentWindow.frames){
                            if(iframe.contentWindow.frames[0].frames){
                                if(iframe.contentWindow.frames[0].frames[0]){
                                    return true;
                                }
                            }
                        }
                    }
                }
            },function() {
                if (typeof item === "string") {
                    var iframe = window.parent.document.getElementsByClassName('tr-iframe')[window.parent.document.getElementsByClassName('tr-iframe').length-1];
                    if (iframe) {
                        var com = iframe.contentWindow.frames[0].frames[0].document.getElementsByClassName(item),
                            Assets = com[1].firstChild.innerHTML,
                            LiabilityAndEquity = com[21].firstChild.innerHTML;

                        if(parseFloat(Assets.replace(/,/g, '')) == parseFloat(LiabilityAndEquity.replace(/,/g, ''))){
                            me.logSuccess('Balance Sheet is balance');
                            next();
                        }
                        else{
                            me.logSuccess('Balance Sheet is not balance');
                            next();
                        }
                    }
                    else{
                        me.logSuccess('Balance Sheet is not balance');
                        next();
                    }
                }
                else{
                    me.logFailed('Component cannot be found');
                    next();
                }
            },this, 60000)
        };

        chain.push(fn);
        return this;
    },

    /**
     * @private
     * Gets and Checks Beginning Balance and Ending Balance
     *
     * @param {String} item Class Name of the cell
     *
     * @returns {iRely.FunctionalTest}
     */
    checkTrialBalanceFRD : function(item) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this;

            t.waitForFn(function() {
                var iframe = window.parent.document.getElementsByClassName('tr-iframe')[window.parent.document.getElementsByClassName('tr-iframe').length-1];
                if (iframe){
                    if(iframe.contentWindow){
                        if(iframe.contentWindow.frames){
                            if(iframe.contentWindow.frames[0].frames){
                                if(iframe.contentWindow.frames[0].frames[0]){
                                    return true;
                                }
                            }
                        }
                    }
                }
            },function() {
                if (typeof item === "string") {
                    var iframe = window.parent.document.getElementsByClassName('tr-iframe')[window.parent.document.getElementsByClassName('tr-iframe').length-1];
                    if (iframe) {
                        var com = iframe.contentWindow.frames[0].frames[0].document.getElementsByClassName(item),
                            BeginningBalance = com[1].firstChild.innerHTML,
                            EndingBalance = com[6].firstChild.innerHTML,
                            Debit = com[2].firstChild.innerHTML,
                            Credit = com[3].firstChild.innerHTML,
                            balance = true;

                        if(parseFloat(BeginningBalance.replace(/,/g, '')) == parseFloat(EndingBalance.replace(/,/g, ''))){
                            //me.logEvent('Beginning and Ending Balance matched');
                            balance = true
                        }
                        else{
                            //me.logEvent('Beginning and Ending Balance did not matched');
                            balance = false;
                        }

                        if(parseFloat(Debit.replace(/,/g, '')) == parseFloat(Credit.replace(/,/g, ''))){
                            //me.logEvent('Debit and Credit matched');
                            balance = true
                        }
                        else{
                            //me.logEvent('Debit and Credit did not matched');
                            balance = false;
                        }

                        if(balance) {
                            me.logSuccess('Trial Balance is balance');
                            next();
                        }
                        else{
                            me.logSuccess('Trial Balance is not balance');
                            next();
                        }
                    }
                    else{
                        me.logSuccess('Trial Balance is not balance');
                        next();
                    }
                }
                else{
                    me.logFailed('Component cannot be found');
                    next();
                }
            },this, 180000)
        };

        chain.push(fn);
        return this;
    },

    //endregion

    //endregion

    //region Enter Data

    /**
     * Enters data in the control.
     *
     * @param {String} type Type of control
     *
     * Form Panel = frm
     * Text Field = txt
     * Combo Box = cbo
     * Button = btn
     * Label = lbl
     * Check Box = chk
     * Date Field = dtm
     * Number Field = num
     * Grid = grd
     * Tab Panel = tab
     * Tab Page = pge
     * Panel = pnl
     * Container = con
     * Toolbar = tlb
     * Paging Toolbar = pgt
     * Separator = sep
     * Column = col
     * Grid View = grv
     *
     * @param {String} item Item Id (without prefix) of the control.
     *
     * @param {String} data Data to input in the control.
     *
     * @param {Integer} start Index of the text to be selected.
     *
     * @param {Integer} end Index of the text to be selected.
     *
     * @param {Integer} tab Index of the tab to be filtered.
     *
     * @returns {iRely.FunctionalTest}
     */
    enterData: function(type, item, data, start, end, tab) {
        var me = this,
            chain = this.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive() || me.getComponentByQuery('viewport').down('#pnlIntegratedDashboard');

            if (win) {
                var input = item.value ? item : win.down(me.getControlId(type,item));

                if (tab){
                    var tabPanel = win.down('tabpanel').items.items[tab-1];
                    input = item.value ? item : tabPanel.down(me.getControlId(type,item));
                }

                if (input) {
                    me.logEvent('Entering data on ' + item + ' ' + type);

                    var value = input.value;
                    start = start || 1;
                    end = value !== null ? (end || value.length) : (end || 1);

                    t.click(input);
                    t.selectText(input, start-1, end);
                    if(input.xtype === 'moneynumber') {
                        input.setValue(data);
                        me.logSuccess('Data successfully entered');
                        next();
                    }
                    else {
                        t.type(input, data, next);
                        me.logSuccess('Data successfully entered');
                    }
                } else {
                    me.logFailed('Control is not found');
                    next();
                }
            } else {
                me.logFailed('Control is not found');
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    /**
     * Enters data in the grid.
     *
     * @param {String} item Item Id (without prefix) of the grid.
     *
     * @param {Integer} row Index of the row in the grid.
     *
     * @param {String} column Data Index or the Item Id of the column.
     *
     * @param {String} data Data to input in the cell.
     *
     * @param {Integer} start Index of the text to be selected.
     *
     * @param {Integer} end Index of the text to be selected.
     *
     * @returns {iRely.FunctionalTest}
     */
    enterGridData: function(item, row, column, data, start, end) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();
            if (win) {
                var grid = item.editingPlugin ? item : win.down('#grd'+item);
                if (grid) {
                    var store = grid.store;
                    grid.editingPlugin.completeEdit();

                    if(row > 0) row = row - 1;
                    if(store.buffered) {
                        row = store.data.getAt(row);
                    }
                    else {
                        row = store.getAt(row);
                    }

                    if(isNaN(column)) {
                        if (Ext.Array.indexOf(grid.columns, column) === -1) {
                            column = grid.columns[column] || grid.columnManager.getHeaderById(column) || grid.down('[dataIndex=' + column + ']');
                        }
                    }
                    else{
                        if (Ext.Array.indexOf(grid.columns, column-1) === -1) {
                            column = grid.columns[column-1] || grid.columnManager.getHeaderById(column) || grid.down('[dataIndex=' + (column-1) + ']');
                        }
                    }

                    if (row && column) {
                        var plugin = grid.editingPlugin,
                            cell = plugin.getCell(row, column);

                        if (plugin.clicksToEdit === 1) {
                            t.click(cell);
                        } else {
                            t.doubleClick(cell);
                        }

                        if (plugin.activeEditor) {
                            var editor = plugin.activeEditor,
                                value = row.get(column.dataIndex);

                            me.logEvent('Entering data on ' + item + ' grid');

                            t.selectText(editor, 0, 50);
                            t.type(editor, data, function() {
                                editor.completeEdit();
                                me.logSuccess('Data successfully entered');
                                next();
                            });
                        } else {
                            me.logFailed('Editor is not found');
                            next();
                        }
                    } else {
                        me.logFailed('Cell is not found');
                        next();
                    }
                } else {
                    me.logFailed('Cell is not found');
                    next();
                }
            } else {
                me.logFailed('Cell is not found');
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    enterUOMGridData: function(item, row, column, comboColumn, quantity, uom) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();
            if (win) {
                var grid = item.editingPlugin ? item : win.down('#grd'+item);
                if (grid) {
                    var store = grid.store;
                    grid.editingPlugin.completeEdit();

                    if(row > 0) row = row - 1;
                    if(store.buffered) {
                        row = store.data.getAt(row);
                    }
                    else {
                        row = store.getAt(row);
                    }

                    if(isNaN(column)) {
                        if (Ext.Array.indexOf(grid.columns, column) === -1) {
                            column = grid.columns[column] || grid.columnManager.getHeaderById(column) || grid.down('[dataIndex=' + column + ']');
                        }
                    }
                    else{
                        if (Ext.Array.indexOf(grid.columns, column-1) === -1) {
                            column = grid.columns[column-1] || grid.columnManager.getHeaderById(column) || grid.down('[dataIndex=' + (column-1) + ']');
                        }
                    }

                    if (row && column) {
                        var plugin = grid.editingPlugin,
                            cell = plugin.getCell(row, column);

                        if (plugin.clicksToEdit === 1) {
                            t.click(cell);
                        } else {
                            t.doubleClick(cell);
                        }

                        if (plugin.activeEditor && plugin.activeEditor.field && plugin.activeEditor.field.xtype === 'griduomfield') {
                            var editor = plugin.activeEditor,
								field = editor.field,
                                value = row.get(column.dataIndex);

                            me.logEvent('Entering Quantity on ' + item + ' grid');
							
							//t.selectText(field.txtQuantity, 0, 50);
							var tsk = new Ext.util.DelayedTask(function() {
								t.type(field.txtQuantity, quantity, function() {
									row.set(column.dataIndex,quantity);
									//editor.completeEdit();
									me.logSuccess('Quantity successfully entered');
									//next();
									var task = new Ext.util.DelayedTask(function () {
										me.selectUom(me, next, chain, t, editor, item, comboColumn, field.cboUom, uom);
									});
									task.delay(1000);
								});
							});
							tsk.delay(1000);
                        } else {
                            me.logFailed('Editor is not found');
                            next();
                        }
                    } else {
                        me.logFailed('Cell is not found');
                        next();
                    }
                } else {
                    me.logFailed('Cell is not found');
                    next();
                }
            } else {
                me.logFailed('Cell is not found');
                next();
            }
        };

        chain.push(fn);
        return this;
    },
	
	selectUom: function(me, next, chain, t, editor, item, comboColumn, combo, uom) {
		if (combo) {
			var els = (function() {
					var cell = combo.el.query('.x-trigger-cell'),
						form = combo.el.query('.x-form-trigger');

					return (cell.length && cell) || (form.length && form);
				})(),
				length = els.length,
				trigger = els[length - 1],
				store = combo.store;

			me.logEvent('Selecting item on ' + item + ' combobox filtered by ' + uom);
			t.chain([
				{
					action: 'click',
					target: trigger
				},
				{
					action: 'click',
					target: combo
				},
				function (next) {
					t.selectText(combo, 0, 50);
					next();
				},
				function (next) {
					t.type(combo, uom, next);
				},
                function (next) {
                    t.type(combo, '[RETURN]', next);
                },
				function (next) {
					var store = combo.store;
					
					var filterRec = store.findExact(comboColumn, uom),
							record = store.getAt(filterRec),
							comboGrid1 = combo.picker || combo.getPicker();

					if (typeof(comboGrid1.getView) == "function") {
						var node1 = comboGrid1.getView().getNode(filterRec);
						t.click(node1, next);
					} else {
						next();
					}
				},
				function (next) {
					me.logSuccess('UOM has been successfully selected');
					editor.completeEdit();
					next();
				},
				next
			]);
		} else {
			me.logFailed('Combo Box is not found');
			next();
		}
	},

	verifyUOMGridData: function(item, row, column, quantity, uom, condition) {
        var me = this,
            chain = this.chain;
        var row1 = row;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive() || me.getComponentByQuery('viewport').down('#pnlIntegratedDashboard');

            me.logEvent('Verifying ' + item + ' grid data');

            if (win) {
                var grid = item.editingPlugin ? item : win.down('#grd'+item);
                if (grid) {

                    if(grid.editingPlugin) grid.editingPlugin.completeEdit();

                    var store = grid.store,
                        row = store.getAt(row1-1);

                    if(isNaN(column)) {
                        if (Ext.Array.indexOf(grid.columns, column) === -1) {
                            column = grid.columns[column] || grid.columnManager.getHeaderById(column) || grid.down('[dataIndex=' + column + ']');
                        }
                    }
                    else {
                        if (Ext.Array.indexOf(grid.columns, column-1) === -1) {
                            column = grid.columns[column-1] || grid.columnManager.getHeaderById(column) || grid.down('[dataIndex=' + (column-1) + ']');
                        }
                    }

                    if (row && column) {
                        var value = row.get(column.dataIndex);
						var uomValue = row.get(column.config.editor.displayField);
                        var result = false;
                        if(!condition || condition === 'equal') {
                            result = quantity === value;
                        }
                        else if (condition === 'like'){
                            if(value.toLowerCase().indexOf(quantity.toLowerCase()) != -1){
                                result = true;
                            }
                        }
                        t.ok(result, result ? quantity + ' Quantity is correct' : quantity + ' Quantity is incorrect');
						t.ok(uom === uomValue, uom === uomValue ? uom + ' UOM is correct': uom + ' UOM is incorrect');
                        next();
                    } else {
                        me.logFailed('Cell is not found');
                        next();
                    }
                } else {
                    me.logFailed('Grid is not found');
                    next();
                }
            } else {
                me.logFailed('Grid is not found');
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    /**
     * Enters data in the grid.
     *
     * @param {String} item Item Id (without prefix) of the grid.
     *
     * @param {Object[]} objs Data Index or the Item Id of the column.
     *
     * Object Definition
     *     {
     *          column : 'strDeviceType',
     *          data : 'Sample Data'
     *      }
     *
     * @returns {iRely.FunctionalTest}
     */
    enterDummyRowData : function(item,objs){
        var me = this,
            chain = me.chain;

        me.selectDummyRow(item);

        objs.forEach(function(d){
            var column = d.column,
                data = d.data,
                start = d.start,
                end = d.end;

            chain.push(function(next) {
                var t = this,
                    win = Ext.WindowManager.getActive();

                if (win) {
                    var grid = item.editingPlugin ? item : win.down('#grd'+item);

                    if (grid) {
                        var store = grid.getStore(),
                            sm = grid.getSelectionModel(),
                            selected,row;

                        if(!sm) me.logFailed('No Selected Record');

                        selected = sm.getSelection();
                        if(selected > 1){
                            me.logFailed('Only supports 1 data row entry at one time');
                        }

                        row = store.indexOf(selected[0]);
                        if (row !== -1) {
                            row = store.getAt(row);
                        }
                        else {
                            next();
                        }

                        if (Ext.Array.indexOf(grid.columns, column) === -1) {
                            column = grid.columns[column] || grid.columnManager.getHeaderById(column) || grid.down('[dataIndex=' + column + ']');
                        }

                        if (row && column) {
                            var plugin = grid.editingPlugin,
                                cell = plugin.getCell(row, column);

                            if (plugin.clicksToEdit === 1) {
                                t.click(cell);
                            } else {
                                t.doubleClick(cell);
                            }

                            if (plugin.activeEditor) {
                                var editor = plugin.activeEditor,
                                    value = row.get(column.dataIndex);

                                me.logEvent('Entering data on ' + item + ' grid');

                                t.selectText(editor, 0, 50);
                                t.type(editor, data, function() {
                                    editor.completeEdit();
                                    me.logSuccess('Data successfully entered');
                                    next();
                                });
                            } else {
                                me.logFailed('Editor is not found');
                                next();
                            }
                        } else {
                            me.logFailed('Cell is not found');
                            next();
                        }
                    } else {
                        me.logFailed('Cell is not found');
                        next();
                    }
                } else {
                    me.logFailed('Cell is not found');
                    next();
                }
            });
        });

        return this;
    },

    //endregion


    //region Continue If

    /**
     * Executes a function that checks whether the value passes the supplied condition
     * if it does the test chain continues and if it does not the test chain is terminated
     *
     * @param {Object} [config] Configuration object
     *
     * @param {Object/Function} [config.expected] The expected Value or a function to generate the expected value
     *
     * @param {Object/Function} [config.actual] The actual Value or a function to generate the actual value
     *
     * @param {Null/Function} [config.success] callback to execute when the assertion is succeeds
     *
     * @param {Null/Function} [config.failure] callback to execute when the assertion is fails. If no failure callback is supplied the test chain execution is terminated
     *
     * @param {Null/String} [config.successMessage] optional message to display when the assertion succeeds
     *
     * @param {Null/String} [config.failMessage] optional message to display when the assertion fails
     *
     * @param {Null/Boolean} [config.continueOnFail] Set to true to prevent the termination of the test chain on fail
     *
     * @returns {iRely.FunctionalTest}
     */
    continueIf : function (config) {
        var me = this,
            chain = me.chain;

        chain.push(
            function(next){
                var win = Ext.WindowManager.getActive() || me.getComponentByQuery('viewport').down('#pnlIntegratedDashboard'),
                    actual = typeof config.actual === 'function' ? config.actual(win) : config.actual,
                    expected = typeof config.expected === 'function' ? config.expected(win) : config.expected,
                    assertTrue = expected === actual;

                next(win, actual, expected, assertTrue);
            });

        chain.push(
            function(next, win, actual, expected, assertTrue) {
                var fn;

                if (assertTrue && typeof config.success === 'undefined') {
                    fn = function(next) {
                        if(config.successMessage)
                            me.logSuccess(config.successMessage);

                        next();
                    };
                }

                if (assertTrue && typeof config.success === 'function') {
                    fn = function(next) {
                        if(config.successMessage)
                            me.logSuccess(config.successMessage);

                        config.success.call(me, next);
                    }
                }

                if(!assertTrue && typeof config.failure === 'undefined') {
                    if(typeof config.continueOnFail === 'undefined' || !config.continueOnFail) {
                        fn = function(next) {
                            if(config.failMessage)
                                me.logFailed(config.failMessage);

                            me.logFailed('Test conditions not met. Terminating test execution.');
                            this.done();
                        }
                    }
                    else {
                        fn = function(next) {
                            if(config.failMessage)
                                me.logFailed(config.failMessage);

                            next();
                        }
                    }
                }

                if (!assertTrue && typeof config.failure === 'function') {
                    fn = function(next) {
                        if(config.failMessage)
                            me.logFailed(config.failMessage);

                        config.failure.call(me, next);
                    }
                }

                next(fn);
            }
        );

        chain.push({
            action : function(next, fn) {
                fn.call(me.t || me, next);
            },
            timeout : 360000
        });

        return this;
    },

    /**
     * Executes a function if alert/message box is shown, this checks whether the value passes the supplied condition
     * if it does the test chain continues and if it does not the test chain is terminated
     *
     * @param {Object} [config] Configuration object
     *
     * @param {Object/Function} [config.expected] The expected Value or a function to generate the expected value
     *
     * @param {Object/Function} [config.actual] The actual Value or a function to generate the actual value
     *
     * @param {Null/Function} [config.success] callback to execute when the assertion is succeeds
     *
     * @param {Null/Function} [config.failure] callback to execute when the assertion is fails. If no failure callback is supplied the test chain execution is terminated
     *
     * @param {Null/String} [config.successMessage] optional message to display when the assertion succeeds
     *
     * @param {Null/String} [config.failMessage] optional message to display when the assertion fails
     *
     * @param {Null/Boolean} [config.continueOnFail] Set to true to prevent the termination of the test chain on fail
     *
     * @returns {iRely.FunctionalTest}
     */
    continueIf_msgBox : function (config) {
        var me = this,
            chain = me.chain;

        chain.push(
            function(next){
                var alert = document.querySelector('.sweet-alert'),
                    actual = typeof config.actual === 'function' ? config.actual(alert) : config.actual,
                    expected = typeof config.expected === 'function' ? config.expected(alert) : config.expected,
                    assertTrue = expected === actual;

                next(alert, actual, expected, assertTrue);
            });

        chain.push(
            function(next, alert, actual, expected, assertTrue) {
                var fn;

                if (assertTrue && typeof config.success === 'undefined') {
                    fn = function(next) {
                        if(config.successMessage)
                            me.logSuccess(config.successMessage);

                        next();
                    };
                }

                if (assertTrue && typeof config.success === 'function') {
                    fn = function(next) {
                        if(config.successMessage)
                            me.logSuccess(config.successMessage);

                        config.success.call(me, next);
                    }
                }

                if(!assertTrue && typeof config.failure === 'undefined') {
                    if(typeof config.continueOnFail === 'undefined' || !config.continueOnFail) {
                        fn = function(next) {
                            if(config.failMessage)
                                me.logFailed(config.failMessage);

                            me.logFailed('Test conditions not met. Terminating test execution.');
                            this.done();
                        }
                    }
                    else {
                        fn = function(next) {
                            if(config.failMessage)
                                me.logFailed(config.failMessage);

                            next();
                        }
                    }
                }

                if (!assertTrue && typeof config.failure === 'function') {
                    fn = function(next) {
                        if(config.failMessage)
                            me.logFailed(config.failMessage);

                        config.failure.call(me, next);
                    }
                }

                next(fn);
            }
        );

        chain.push({
            action : function(next, fn) {
                fn.call(me.t || me, next);
            },
            timeout : 360000
        });

        return this;
    },

    //endregion

    //region Wait Functions

    /**
     * Continuously checks if the item becomes visible / ready
     *
     * @param {String} item Item Id of the control.
     *
     * @returns {iRely.FunctionalTest}
     */
    waitUntilVisibleReportViewer : function(item, msg) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                result = false;

            switch(item){
                case 'lastpage':
                    item = 'reportViewer_Splitter_RibbonToolbar_T0G2I4';
                    break;
                case 'find':
                    item = 'reportViewer_Splitter_RibbonToolbar_T0G3I0';
                    break;

                default:
                    item = 'reportViewer_Splitter_RibbonToolbar_T0G3I0';
            }

            t.waitForFn(function() {
                var iframe = window.parent.document.getElementsByClassName('tr-iframe');
                if (iframe){
                    iframe = iframe[iframe.length-1];
                    if(iframe.contentWindow){
                        if(iframe.contentWindow.frames){
                            if(iframe.contentWindow.frames.length > 0){
                                if(iframe.contentWindow.frames[0].frames){
                                    if(iframe.contentWindow.frames[0].frames[0]){
                                        if(iframe.contentWindow.frames[0].document.getElementById(item)) {
                                            return true;
                                        }
                                    }
                                }
                            }
                            else{
                                if(iframe.contentWindow.document){
                                    if(iframe.contentWindow.document.getElementById(item)) {
                                        return true;
                                    }
                                }
                            }
                        }
                    }
                }
            },function() {
                if(!msg) msg = 'Report Viewer is shown';
                me.logSuccess(msg);
                next();
            },this, 180000)
        };

        chain.push(fn);
        return this;
    },

    /**
     * Continuously checks if the main menu becomes visible / ready
     *
     *
     * @returns {iRely.FunctionalTest}
     */
    waitUntilMainMenuLoaded: function(){
        var me = this,
            t = me.t,
            chain = me.chain;

        chain.push(
            function(next) {
                var win = Ext.WindowManager.getActive();
                t.waitForCQVisible('viewport',
                    function () {
                        t.waitForRowsVisible('#tplMenu', function () {
                            next();
                        });
                    }, this, 60000);
            });
        return me;
    },

    /**
     * Waits until the Initializing, Loading, etc. dialog closed
     *
     *
     * @returns {iRely.FunctionalTest}
     */
    waitTillLoaded : function(msg,delay) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this;

            t.waitForFn(function() {
                var loadmaskOk = false,
                    messageboxOk = false;

                var loadmask = Ext.ComponentQuery.query('loadmask');
                if (loadmask){
                    for(var x = loadmask.length - 1; x >= 0; x--){
                        if(loadmask[x].isVisible() == true){
                            break;
                        }
                        else if(x == 0){
                            loadmaskOk = true;
                        }
                    }
                }
                var messagebox = Ext.ComponentQuery.query('messagebox');
                if (messagebox){
                    var current = messagebox[0];
                    if(current.isVisible() == false) messageboxOk = true;
                }
                if(loadmaskOk && messageboxOk) return true;
            },function() {
                if(!delay) delay = 1000;
                var task = new Ext.util.DelayedTask(function(){
                    if(msg) {
                        me.logSuccess(msg);
                    }
                    next();
                });
                task.delay(delay);
            },this, 60000)
        };

        chain.push(fn);
        return this;
    },

    /**
     * Waits until the Initializing, Loading, etc. dialog closes or when item shown
     *
     * @param {String} item Screen/Window item id or Alias.
     *
     * @returns {iRely.FunctionalTest}
     */
    waitUntilLoaded: function(item) {
        var me = this,
            chain = me.chain;

        if(item) {
            var fn = function (next) {
                var t = this,
                    itemFound = false;

                t.waitForFn(function () {
                    var com = me.getComponentByQuery(item);
                    if (com && !itemFound) {
                        itemFound = true;
                        return true;
                    }
                }, function () {
                    var task = new Ext.util.DelayedTask(function () {
                        next();
                    });
                    task.delay(1000);
                }, this, 120000)
            };
            chain.push(fn);
            return this;
        }
        else {
            var fn = function (next) {
                var t = this,
                    itemFound = false,
                    endWait = false;

                    t.waitForFn(function () {
                        if(!itemFound) {
                            var loadmaskOk = false,
                                messageboxOk = false;

                            var loadmask = Ext.ComponentQuery.query('loadmask');
                            if (loadmask) {
                                for (var x = loadmask.length - 1; x >= 0; x--) {
                                    if (loadmask[x].isVisible() == true) {
                                        break;
                                    }
                                    else if (x == 0) {
                                        loadmaskOk = true;
                                    }
                                }
                            }
                            var messagebox = Ext.ComponentQuery.query('messagebox');
                            if (messagebox) {
                                var current = messagebox[0];
                                if (current.isVisible() == false) messageboxOk = true;
                            }
                            if (loadmaskOk && messageboxOk && !itemFound) {
                                itemFound = true;
                                var task = new Ext.util.DelayedTask(function () {
                                    endWait = true;
                                    return true;
                                });
                                task.delay(1500);
                            }
                        }
                        else if (endWait){
                            return true;
                        }
                    }, function () {
                        next();
                    }, this, 120000)
            };

            chain.push(fn);
            return this;
        }
    },

    //endregion

    //region Log Functions

    /**
     * This method output the custom message
     *
     *
     * @returns {iRely.FunctionalTest}
     */
    displayText: function(msg) {
        var me = this,
            chain = me.chain;

        var fn = function(next){
            var t = this;
            t.diag(msg);
            next();
        };

        chain.push({action:fn,timeout:60000});

        return this;
    },

    /*
     * @private
     * This method output the event
     *
     * @param {String} msg Text to display.
     */
    logEvent: function(msg) {
        this.t.diag(msg);
        return this;
    },

    /*
     * @private
     * This method output a success event
     *
     * @param {String} msg Text to display.
     */
    logSuccess: function(msg) {
        this.t.ok(true,msg);
        return this;
    },

    /*
     * @private
     * This method output a failed event
     *
     * @param {String} msg Text to display.
     */
    logFailed: function(msg) {
        this.t.ok(false,msg);
        return this;
    },

    /**
     * This method output the custom message
     *
     *
     * @returns {iRely.FunctionalTest}
     */
    addScenario: function(number, msg, time) {
        var me = this,
            chain = me.chain;

        var fn = function(next){
            var t = this;
            t.diag('======== Scenario ' + number + ': ' + msg + ' ========');
            next();
        };

        if(!time) time = 1000;
        chain.push({action:fn,timeout:60000});

        return this;
    },

    /**
     * This method output the success mark and message
     *
     *
     * @returns {iRely.FunctionalTest}
     */
    addStep: function(number, msg, time) {
        var me = this,
            chain = me.chain;

        var fn = function(next){
            var t = this;
            t.diag(number + '.) ' + msg);
            next();
        };

        if(!time) time = 1000;
        chain.push({action:fn,timeout:60000});

        return this;
    },

    /**
     * This method output the success mark and message
     *
     *
     * @returns {iRely.FunctionalTest}
     */
    addResult: function(msg, time) {
        var me = this,
            chain = me.chain;

        var fn = function(next){
            var t = this;
            me.logSuccess(msg);
            next();
        };

        if(!time) time = 1000;
        chain.push({action:fn,timeout:60000});

        //chain.push({action:fn,timeout:60000},{action: 'delay',delay: time});

        return this;
    },

    //endregion

    //region Custom Functions

    /**
     * Custom codes that needs to be included in the test.
     *
     *     var engine = new iRely.FunctionalTest();
     *     engine.start(t)
     *           .addFunction(function(next) {
     *              var x = 1, y = 2;
     *              if ((x + y) === 3) {
     *                  me.logSuccess('Calculation is correct');
     *              } else {
     *                  me.logFailed('Calculation is incorrect');
     *              }

     *              next();
     *           })
     *           .done();
     *
     * @param {Function} fn Custom Function to be executed by the Engine.
     *
     * @returns {iRely.FunctionalTest}
     */
    addFunction: function(fn) {
        var me = this,
            chain = me.chain;

        if (typeof(fn) == "function") {
            chain.push({action:fn,timeout:180000});
        }

        return this;
    },

    /**
     * Filters the grid with the specified filter.
     *
     * @param {String} grid item Id of the grid.
     *
     * @param {String} item item Id of the filter field.
     *
     * @param {String} filter All column filter to apply.
     *
     * @param {Integer} tab Index of the tab to be filtered. Optional.
     *
     * @returns {iRely.FunctionalTest}
     */
    filterGridRecords: function(grid, item, filter, tab) {
        var me = this,
            chain = this.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive() || me.getComponentByQuery('viewport').down('#pnlIntegratedDashboard');

            me.logEvent('Searching For Record:' + filter);

            if(tab > 0) tab = tab - 1;

            if (win) {
                var grd = win.down('#grd'+grid);

                if (tab){
                    var tabPanel = win.down('tabpanel').items.items[tab];
                    grd = tabPanel.down(grid);
                }

                if (grd) {
                    var filterGrid = win.down('#txt'+item);

                    if (tab){
                        var tabPanel = win.down('tabpanel').items.items[tab];
                        filterGrid = tabPanel.down('#txt'+item);
                    }

                    if (filterGrid) {
                        t.chain([
                            {
                                action: 'click',
                                target: filterGrid
                            },
                            function(next) {
                                t.selectText(filterGrid, 0, 20);
                                next();
                            },
                            function(next) {
                                t.type(filterGrid, filter, next);
                            },
                            function(next) {
                                t.type(filterGrid, '[RETURN]', next);
                            },
                            next
                        ]);
                    } else {
                        me.logFailed(item + ' Filter field is not found');
                        next();
                    }
                } else {
                    me.logFailed(grid + ' Grid is not found');
                    next();
                }
            } else {
                me.logFailed('No active screen');
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    /*
     * @private
     * Gets the component based on the component query
     *
     * @param {String} type Type of menu ('Folder', 'Screen', 'Report').
     */
    getComponentByQuery: function(itemId) {
        return Ext.ComponentQuery.query(itemId)[0];
    },

    /*
     * @private
     * Sets prefix for control based on control type
     *
     * @param {String} type Control type.
     *
     * Form Panel = frm
     * Text Field = txt
     * Combo Box = cbo
     * Button = btn
     * Label = lbl
     * Check Box = chk
     * Date Field = dtm
     * Number Field = num
     * Grid = grd
     * Tab Panel = tab
     * Tab Page = pge
     * Panel = pnl
     * Container = con
     * Toolbar = tlb
     * Paging Toolbar = pgt
     * Separator = sep
     * Column = col
     * Grid View = grv
     *
     * @param {String} type Item Id (without prefix) of the control.
     */
    getControlId: function(type, item){
        var control = '';
        if(type === 'Text Field'){
            control = '#txt' + item;
        }
        else if(type === 'Combo Box') {
            control = '#cbo' + item;
        }
        else if(type === 'Date Field') {
            control = '#dtm' + item;
        }
        else if(type === 'Form Panel') {
            control = '#frm' + item;
        }
        else if(type === 'Button') {
            control = '#btn' + item;
        }
        else if(type === 'Label') {
            control = '#lbl' + item;
        }
        else if(type === 'Check Box') {
            control = '#chk' + item;
        }
        else if(type === 'Number Field') {
            control = '#num' + item;
        }
        else if(type === 'Grid') {
            control = '#grd' + item;
        }
        else if(type === 'Tab Panel') {
            control = '#tab' + item;
        }
        else if(type === 'Tab Page') {
            control = '#pge' + item;
        }
        else if(type === 'Panel') {
            control = '#pnl' + item;
        }
        else if(type === 'Container') {
            control = '#con' + item;
        }
        else if(type === 'Toolbar') {
            control = '#tlb' + item;
        }
        else if(type === 'Paging Toolbar') {
            control = '#pgt' + item;
        }
        else if(type === 'Separator') {
            control = '#sep' + item;
        }
        else if(type === 'Column') {
            control = '#col' + item;
        }
        else if(type === 'Grid View') {
            control = '#grv' + item;
        }
        return control;
    },

    /**
     * Login to i21.
     *
     * @param {String} userName Username.
     *
     * @param {String} password Password.
     *
     * @param {String} company Company.
     *
     * @returns {iRely.FunctionalTest}
     */
    login: function(userName, password, company) {
        var me = this,
            t = me.t,
            chain = me.chain;

        chain.push(
            function(next) {
                t.waitForCQVisible('#Login',
                    function () {
                        var win = me.getComponentByQuery('#Login'),
                            txtUserName = win.down('#txtUserName'),
                            txtPassword = win.down('#txtPassword'),
                            cboCompany = win.down('#cboCompany');

                        txtUserName.setValue('');
                        txtPassword.setValue('');
                        cboCompany.setValue('');

                        next(txtUserName,txtPassword,cboCompany);
                    }, this, 60000);
            },
            function(next,txtUserName,txtPassword,cboCompany) {
                next(txtUserName,txtPassword,cboCompany);
            },
            function(next,txtUserName,txtPassword,cboCompany) {
                t.click(txtUserName, function(txtUserName,txtPassword,cboCompany) { next(txtUserName,txtPassword,cboCompany);});
            }, function(next,txtUserName,txtPassword,cboCompany) {
                t.type(txtUserName, userName + '[TAB]', function(txtUserName,txtPassword,cboCompany) { next(txtUserName,txtPassword,cboCompany);});
            }, function(next,txtUserName,txtPassword,cboCompany) {
                t.type(txtPassword, password + '[TAB]', function(txtUserName,txtPassword,cboCompany) { next(txtUserName,txtPassword,cboCompany);});
            }, function(next,txtUserName,txtPassword,cboCompany) {
                t.type(cboCompany, company + '[TAB]', next);
            }, function(next) {
                var win = me.getComponentByQuery('#Login'),
                    btnLogin = win.down('#btnLogin');
                btnLogin.focus();
                t.click(btnLogin, next);
            },
            {
                action: 'wait',
                delay: 1000
            },
            function(next) {
                var win = Ext.WindowManager.getActive();
                if(win && win.xtype === 'messagebox') {
                    next();
                }
                else {
                    t.waitForCQVisible('viewport',
                        function () {
                            me.logSuccess('Viewport Shown');
                            t.waitForRowsVisible('#tplMenu', function () {
                                next();
                            });
                        }, this, 60000);
                }
            }
        );

        return me;
    },

    //endregion


});
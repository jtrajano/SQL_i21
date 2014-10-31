/**
 * Example on how to use the class.
 *
 *     var engine = new iRely.TestEngine();
 *     engine.start(t)
 *           .login('AGADMIN','AGADMIN','AG').wait(1500)
 *           .expandMenu('Tank Management').wait(100)
 *           .expandMenu('Maintenance').wait(100)
 *           .openScreen('Devices').wait(1000)
 *           .selectSearchRowByIndex(0)
 *           .clickButton('#btnOpenSelected').wait(100)
 *           .checkScreenWindow({
 *               alias: 'tmDevice',
 *               title: 'Devices',
 *               maximize: false,
 *               minimize: false,
 *               restore: false
 *           })
 *           .checkToolbarButton()
 *           .checkPagingStatusBar()
 *           .selectComboRowByFilter('#cboDeviceType', 'Tank')
 *           .enterData('#txtManufacturerId', 'Sample')
 *           .clickCheckBox('#chkUnderground')
 *           .clickEllipsisButton('#cboDeviceType')
 *           .done();
 */
Ext.define('iRely.TestEngine', {
    extend: 'Ext.util.Observable',
    alternateClassName: 'iTest',

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
     * @returns {iRely.TestEngine}
     */
    start: function(t, next) {
        var me = this;
        me.t = t;
        me.next = next;

        return me;
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
     * @returns {iRely.TestEngine}
     */
    login: function(userName, password, company) {
        var me = this,
            t = me.t,
            chain = me.chain;

        chain.push(
            function(next) {
                t.diag("Waiting for Login Screen");
                t.waitForCQVisible('#Login', 
                    function () { 
                        var win = me.getComponentByQuery('#Login'), 
                            txtUserName = win.down('#txtUserName'),
                            txtPassword = win.down('#txtPassword'),
                            txtCompany = win.down('#txtCompany');

                        next(txtUserName,txtPassword,txtCompany); 
                    }, this, 60000); 
            },
            function(next,txtUserName,txtPassword,txtCompany) {
                t.diag('System Login');
                next(txtUserName,txtPassword,txtCompany);
            },
            function(next,txtUserName,txtPassword,txtCompany) {
                t.click(txtUserName, function(txtUserName,txtPassword,txtCompany) { next(txtUserName,txtPassword,txtCompany);});
            }, function(next,txtUserName,txtPassword,txtCompany) {
                t.type(txtUserName, userName + '[TAB]', function(txtUserName,txtPassword,txtCompany) { next(txtUserName,txtPassword,txtCompany);});
            }, function(next,txtUserName,txtPassword,txtCompany) {
                t.type(txtPassword, password + '[TAB]', function(txtUserName,txtPassword,txtCompany) { next(txtUserName,txtPassword,txtCompany);});
            }, function(next,txtUserName,txtPassword,txtCompany) {
                t.type(txtCompany, company + '[TAB]', next);
            }, {
                action: 'wait',
                delay: 1000
            }, function(next) {
                var win = me.getComponentByQuery('#Login'),
                    btnLogin = win.down('#btnLogin');
                t.click(btnLogin, next);
            }, function(next) {
                t.waitForCQVisible('viewport', 
                    function () { 
                        t.ok(true, 'Viewport Shown'); 
                        next(); 
                    }, this, 60000);        
            }, function (next) {
                t.diag("Waiting for Menu");
                t.waitForRowsVisible('#tplMenu', function (){
                    next();
                });
            });

        return me;
    },

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
     * @returns {iRely.TestEngine}
     */
    continueIf : function (config) {
        var me = this,
            chain = me.chain;
            
        chain.push(
            function(next){
                var win = Ext.WindowManager.getActive(),
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
                            this.ok(true, config.successMessage);

                        next();
                    };
                }

                if (assertTrue && typeof config.success === 'function') {
                    fn = function(next) {
                        if(config.successMessage) 
                            this.ok(true, config.successMessage);

                        config.success.call(me, next);
                    }
                }

                if(!assertTrue && typeof config.failure === 'undefined') {
                    if(typeof config.continueOnFail === 'undefined' || !config.continueOnFail) {
                        fn = function(next) {
                            if(config.failMessage) 
                                this.ok(false, config.failMessage);

                            this.ok(false, 'Test conditions not met. Terminating test execution.');
                            this.done();    
                        }
                    }
                    else {
                        fn = function(next) {
                             if(config.failMessage) 
                                this.ok(false, config.failMessage);

                            next();
                        }
                    }
                }

                if (!assertTrue && typeof config.failure === 'function') {
                    fn = function(next) {
                        if(config.failMessage) 
                            this.ok(false, config.failMessage);

                        config.failure.call(me, next);
                    }
                }

                next(fn);
            }
        );

        chain.push({
            action : function(next, fn) {
                fn.call(me, next);
            },
            timeout : 360000
        });

        return this;
    },


    /**
     * Custom codes that needs to be included in the test.
     *
     *     var engine = new iRely.TestEngine();
     *     engine.start(t)
     *           .addFunction(function(next) {
     *              var x = 1, y = 2;
     *              if ((x + y) === 3) {
     *                  t.ok(true, 'Calculation is correct.');
     *              } else {
     *                  t.ok(false, 'Calculation is incorrect');
     *              }

     *              next();
     *           })
     *           .done();
     *
     * @param {Function} fn Custom Function to be executed by the Engine.
     *
     * @returns {iRely.TestEngine}
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
     * Expands folder in the menu.
     *
     * @param {String} folderName Folder name to expand in the menu.
     *
     * @returns {iRely.TestEngine}
     */
    expandMenu: function(folderName) {
        var me = this,
            t = me.t,
            chain = me.chain;

        var fn = function(next) {
            var record = me.getRecordFromMenu('folder', folderName),
                node = me.getNodeFromMenu('folder', folderName);

            if(!record.data.expanded) {
                t.diag('Expanding Folder ' + folderName);
                t.doubleClick(node, next);
            }
            else {
                t.diag('Folder ' + folderName + ' is already Expanded');
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    /**
     * Collapses folder in the menu.
     *
     * @param {String} folderName Folder name to collapse in the menu.
     *
     * @returns {iRely.TestEngine}
     */
    collapseMenu: function(folderName) {
        var me = this,
            t = me.t,
            chain = me.chain;

        var fn = function(next) {
            var record = me.getRecordFromMenu('folder', folderName),
                node = me.getNodeFromMenu('folder', folderName);

            if(record.data.expanded) {
                t.diag('Collapsing Folder ' + folderName);
                t.doubleClick(node, next);
            }
            else {
                t.diag('Folder ' + folderName + ' is already Collapased');
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    /**
     * Open screen in the menu.
     *
     * @param {String} screenName Screen to open in the menu.
     *
     * @returns {iRely.TestEngine}
     */
    openScreen: function(screenName) {
        var me = this,
            t = me.t,
            chain = me.chain;

        var fn = function(next) {
            var node = me.getNodeFromMenu('screen', screenName);

            t.diag('Opening Screen ' + screenName);

            if (node) {
                t.doubleClick(node, next);
            } else {
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    /**
     * Clicks a message box button.
     *
     * @param {String} item Name of the button. ('yes', 'no', 'cancel', 'ok').
     *
     * @returns {iRely.TestEngine}
     */
    clickMessageBoxButton: function(item) {
        var chain = this.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();
            if (win) {
                if (win.xtype === 'messagebox') {
                    var button = win.msgButtons[item];
                    if (button) {
                        t.click(button, next);
                    } else {
                        next();
                    }
                } else {
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
     * @param {String} item Item Id of the button.
     *
     * @returns {iRely.TestEngine}
     */
    clickButton: function(item) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();
            if (win) {
                var button = win.down(item);
                if (button) {
                    t.diag('Clicking button ' + item);

                    t.chain([
                        {
                            action: 'click',
                            target: button
                        },
                        {
                            action: 'wait',
                            delay: 10
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
     * Clicks an ellipsis button in the combo box.
     *
     * @param {String} item Item Id of the combo box.
     *
     * @returns {iRely.TestEngine}
     */
    clickEllipsisButton: function(item) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();
            if (win) {
                var combo = win.down(item);
                if (combo) {
                    var ellipsis = combo.el.query('.x-trigger-cell')[0];

                    t.diag('Clicking ellipsis button ' + item);
                    t.click(ellipsis, next);
                } else {
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
     * @param {String} item Item Id/Text of the tab.
     *
     * @returns {iRely.TestEngine}
     */
    clickTab: function(item) {
        var chain = this.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();
            if (win) {
                var tab = win.down(item);
                if (tab) {
                    t.click(tab, next);
                } else {
                    tab = win.down('tabpanel [text='+ item  +']');
                    if (tab) {
                        t.click(tab, next);
                    } else {
                        next();
                    }
                }
            } else {
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    /**
     * Clicks a check box.
     *
     * @param {String/DOMElement/Function} item Item Id / the DOM element or a function to return the DOM Element of the check box.
     *
     * @param {Boolean} [checked] Checked state of the checkbox
     *
     * @returns {iRely.TestEngine}
     */
    clickCheckBox: function(item, checked) {
        var chain = this.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();
            if (win) {
                var chkBox = typeof item === 'function' ? item(win) : (item.tagName || item.nodeName) ? item : win.down(item);
                
                if (chkBox) {
                    if(typeof checked !== 'undefined') {
                        if(typeof checked !== 'boolean') {
                            this.ok(false, 'checked value should be of type boolean found:' + typeof checked)
                            next();
                        }

                        if(chkBox.getValue) {
                            if(chkBox.getValue() !== checked) {
                                t.click(chkBox, next);  
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
                                    t.click(chkBox, next); 
                                }
                                else {
                                    next();
                                }
                            }
                            else {
                               if(chkBox.checked !== checked) {
                                   t.click(chkBox, next); 
                               }
                               else {
                                    next();
                               }
                            }
                        }
                    }
                    else {
                        t.click(chkBox, next);
                        next();
                    }
                } else {
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
     * Checks if the checkbox is checked
     *
     * @param {String} item Item Id of the check box.
     *
     * @param {Boolean} checked Expected value of the checkbox
     *
     * @returns {iRely.TestEngine}
     */
    checkCheckboxValue:function(item, checked) {
        var chain = this.chain;

        var fn = function(next) {
            if(typeof checked !== 'boolean') {
                this.ok(false, 'checked value should be of type boolean found:' + typeof checked)
                next();
            }

            var win = Ext.WindowManager.getActive();            
            
            if(win) {
                var chkBox = win.down(item);
                if(chkBox) {
                    if(checked === chkBox.getValue()) {
                        this.ok(true, 'Checkbox value is correct');
                    }
                    else {
                        this.ok(false, 'Checkbox value is incorrect');
                    }
                }
                else {
                    this.ok(false, item + ' is not found');
                }
            }

            next();
        }

        chain.push({action:fn,timeout:120000});
        return this;
    },

    /**
     * Enters data in the control.
     *
     * @param {String} item Item Id of the control.
     *
     * @param {String} data Data to input in the control.
     *
     * @returns {iRely.TestEngine}
     */
    enterData: function(item, data, start, end) {
        var me = this,
            chain = this.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();
            if (win) {
                var input = item.value ? item : win.down(item);
                if (input) {
                    var value = input.value;

                    t.diag('Entering data on control ' + item);

                    start = start || 0;
                    end = end || value.length;

                    t.click(input);
                    t.selectText(input, start, end);
                    if(input.xtype === 'moneynumber') {
                        input.setValue(data);
                        next();
                    }
                    else {
                        t.type(input, data, next);
                    }
                } else {
                    t.ok(false, 'Control is not existing.')
                    next();
                }
            } else {
                t.ok(false, 'Control is not existing.')
                next();
            }
        };

        chain.push(fn);
        return this;
    },


    /**
     * Enters data in the grid.
     *
     * @param {String} item Item Id of the grid.
     *
     * @param {Integer} row Index of the row in the grid.
     *
     * @param {String} column Data Index or the Item Id of the column.
     *
     * @param {String} data Data to input in the cell.
     *
     * @returns {iRely.TestEngine}
     */
    enterGridData: function(item, row, column, data, start, end) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();
            if (win) {
                var grid = item.editingPlugin ? item : win.down(item);
                if (grid) {
                    var store = grid.store;

                    if(store.buffered) {
                        row = store.data.getAt(row);
                    }
                    else {
                        row = store.getAt(row);
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

                            t.diag('Entering data on grid ' + item);

                            start = start || 0;
                            end = end || value ? value.length : 0;

                            t.selectText(editor, start, end);
                            t.type(editor, data, function() {
                                editor.completeEdit();
                                next();
                            });
                        } else {
                            t.ok(false, 'Editor is not existing.')
                            next();
                        }
                    } else {
                        t.ok(false, 'Cell is not existing.')
                        next();
                    }
                } else {
                    t.ok(false, 'Cell is not existing.')
                    next();
                }
            } else {
                t.ok(false, 'Cell is not existing.')
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
     * @returns {iRely.TestEngine}
     */
    selectSearchRowByIndex: function(index){
        var chain = this.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();

            t.diag('Selecting Search Record.');

            if (win) {
                if (win.xtype === 'search') {
                    var grid = win.down('#grdSearch'),
                        sm = grid.getSelectionModel(),
                        store = grid.getStore(),
                        indexArrs = Ext.isArray(index) ? index : [index],
                        selected = [], bufferedData;

                    if(store.buffered) {
                        bufferedData =  store.data.getRange(0, store.getCount());
                    }

                    for(var i = 0; i < indexArrs.length; i++) {
                        var idx = indexArrs[i];

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
                        next();
                    });
                }
                else {
                    t.ok(false, 'Grid is not existing.')
                    next();
                }
            }
            else {
                t.ok(false, 'Grid is not existing.')
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    // TODO: Test
    selectSearchRowByRange: function(start, end){
        var chain = this.chain;
        //index = index || 0;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();

            t.diag('Selecting Search Record.');

            if (win) {
                if (win.xtype === 'search') {
                    var grid = win.down('#grdSearch'),
                        sm = grid.getSelectionModel();

                    t.waitForRowsVisible(grid, function() {
                        sm.selectRange(start, end);
                        next();
                    });
                } else {
                    t.ok(false, 'Grid is not existing.')
                    next();
                }
            } else {
                t.ok(false, 'Grid is not existing.')
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
     * @returns {iRely.TestEngine}
     */
    selectSearchRowByFilter: function(filter) {
        var chain = this.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();

            t.diag('Selecting Search Record.');

            if (win) {
                if (win.xtype === 'search') {
                    var filterGrid = win.down('#txtFilterGrid');

                    if (filterGrid) {
                        t.chain([
                            {
                                action: 'click',
                                target: filterGrid
                            },
                            function(next) {
                                t.type(filterGrid, filter, next);
                            },
                            function(next) {
                                t.type(filterGrid, '[RETURN]', next);
                            },
                            {
                                action: 'wait',
                                delay: 500
                            },
                            function(next) {
                                var grid =  win.down('#grdSearch');
                                if (typeof(grid.getView) == "function") {
                                    t.waitForRowsVisible(grid, function(){
                                        var node = grid.getView().getNode(0);
                                        t.click(node, next);
                                    });
                                } else {
                                    next();
                                }
                            },
                            next
                        ]);
                    }
                } else {
                    t.ok(true, 'Grid is not existing.')
                    next();
                }
            } else {
                t.ok(true, 'Grid is not existing.')
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    /**
     * Select a row based on the grid and index specified.
     *
     * @param {String} item Item Id of the Grid.
     *
     * @param {Number[]/Number} index Array of indexes or index of the row to select.
     *
     * @returns {iRely.TestEngine}
     */
     selectGridRow: function(item, index){
        var chain = this.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();

            t.diag('Selecting Grid Record.');

            if (win) {
                var grid = iRely.Functions.getChildControl(item, win);

                if (grid) {
                    var sm = grid.getSelectionModel(),
                        store = grid.getStore(), 
                        indexArrs = Ext.isArray(index) ? index : [index],
                        selected = [], bufferedData;

                    if(store.buffered) {
                        bufferedData =  store.data.getRange(0, store.getCount());
                    }

                    for(var i = 0; i < indexArrs.length; i++) {
                        var idx = indexArrs[i];

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

                    sm.select(selected);

                    t.ok(true, 'Record has been successfully selected.')
                } else {
                    t.ok(true, 'Grid is not existing.')
                }
            } else {
                t.ok(true, 'Grid is not existing.')
            }

            next();
        };

        chain.push(fn);
        return this;
    },

    /**
     * Select a row on the grid based on a filter specified.
     *
     * @param {String} item Item Id of the Grid.
     *
     * @param {Object[]/Object} [filters] Array of filters or filter expression of the row to select.
     *
     * @param {String} [filters.dataIndex] dataIndex of a column to search
     *
     * @param {Object/Function} [filters.value] the search expression to match
     *
     * @param {Boolean} [filters.matchCase] match the data exactly. defaults to True, only applicable to Strings.
     *
     * @returns {iRely.TestEngine}
     */
     selectGridRowByFilter: function(item, filters){
        var chain = this.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();

            t.diag('Selecting Grid Record.');

            if (win) {
                var grid = iRely.Functions.getChildControl(item, win);

                if (grid) {
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

                    t.ok(true, 'Record has been successfully selected.')
                } else {
                    t.ok(true, 'Grid is not existing.')
                }
            } else {
                t.ok(true, 'Grid is not existing.')
            }

            next();
        };

        chain.push(fn);
        return this;
    },

    /**
     * Selects item in the combo box based in the index specified.
     *
     * @param {String} item Item Id of the combo box.
     *
     * @param {Integer} index Index of the row to select.
     *
     * @returns {iRely.TestEngine}
     */
    selectComboRowByIndex: function(item, index) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();
            if (win) {
                var combo = item.value ? item : win.down(item);
                if (combo) {
                    var length = combo.el.query('.x-trigger-cell').length,
                        trigger = combo.el.query('.x-trigger-cell')[length - 1];

                    t.diag('Selecting item on ' + item + ' index: ' + index);

                    t.chain([
                        {
                            action: 'click',
                            target: trigger
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
                                var node = grid.getNode(index);
                                t.click(node, next);
                            } else {
                                t.ok(false, 'Combo Box is not existing.')
                                next();
                            }
                        },
                        next
                    ]);
                } else {
                    t.ok(false, 'Combo Box is not existing.')
                    next();
                }
            } else {
                t.ok(false, 'Combo Box  is not existing.')
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    /**
     * Selects item in the combo box based on the filter specified.
     *
     * @param {String} item Item Id of the combo box.
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
     * @returns {iRely.TestEngine}
     */
    selectComboRowByFilter: function(item, filter) {
        var me = this,
            chain = this.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();
            if (win) {
                var combo = item.value ? item : win.down(item);
                if (combo) {
                    var length = combo.el.query('.x-trigger-cell').length,
                        trigger = combo.el.query('.x-trigger-cell')[length - 1],
                        store = combo.store;

                    t.diag('Selecting item on ' + item + ' filtered by: ' + filter);

                    if (Ext.isArray(filter)) {
                        combo.defaultFilters = filter;

                        t.chain([
                            {
                                action: 'click',
                                target: trigger
                            },
                            function(next) {
                                var comboGrid =  Ext.WindowManager.getActive();
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
                        function(next) {
                            var grid = Ext.WindowManager.getActive(),
                                filterGrid = grid.down('#txtFilterGrid');

                            if (filterGrid) {
                                t.chain([
                                    {
                                        action: 'click',
                                        target: filterGrid
                                    },
                                    function(next) {
                                        t.type(filterGrid, filter.value || filter, next);
                                    },
                                    function(next) {
                                        t.type(filterGrid, '[RETURN]', next);
                                    },
                                    {
                                        action: 'wait',
                                        delay: 500
                                    },
                                    function(next) {
                                        var comboGrid =  Ext.WindowManager.getActive();
                                        if (typeof(comboGrid.getView) == "function") {
                                            var node = comboGrid.getView().getNode(0);
                                            t.click(node, next);
                                        } else {
                                            next();
                                        }
                                    },
                                    next
                                ]);
                            } else {
                                var idx = store.findExact('field1', filter),
                                    picker = combo.getPicker(),
                                    node = picker.getNode(idx);

                                t.click(node, next);
                            }
                        },
                        next
                    ]);
                } else {
                    t.ok(false, 'Combo Box is not existing.')
                    next();
                }
            } else {
                t.ok(false, 'Combo Box  is not existing.')
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    /**
     * Enters data in the grid.
     *
     * @param {String} item Item Id of the grid.
     *
     * @param {Integer} row Index of the row in the grid.
     *
     * @param {String} column Data Index or the Item Id of the column.
     *
     * @param {Integer} index Index of the row to select.
     *
     * @returns {iRely.TestEngine}
     */
    selectGridComboRowByIndex: function(item, row, column, index) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();
            if (win) {
                var grid = item.editingPlugin ? item : win.down(item);
                if (grid) {
                    var store = grid.store;
                    if (store.indexOf(row) === -1) {
                        row = store.getAt(row);
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
                                length = editor.el.query('.x-trigger-cell').length,
                                trigger = editor.el.query('.x-trigger-cell')[length - 1];

                            t.diag('Entering data on grid ' + item);

                            t.chain([
                                {
                                    action: 'click',
                                    target: trigger
                                },
                                function(next) {
                                    var panel = Ext.WindowManager.getActive(),
                                        grid;

                                    if (panel.getView) {
                                        grid = panel.getView();
                                    } else {
                                        grid = editor.field.getPicker();
                                    }

                                    if (grid) {
                                        var node = grid.getNode(index);
                                        t.click(node, function() {
                                            editor.completeEdit();
                                            next();
                                        });
                                    } else {
                                        t.ok(false, 'Combo Box is not existing.')
                                        next();
                                    }
                                },
                                next
                            ]);
                        } else {
                            t.ok(false, 'Combo Box is not existing.')
                            next();
                        }
                    } else {
                        t.ok(false, 'Cell is not existing.')
                        next();
                    }
                } else {
                    t.ok(false, 'Cell is not existing.')
                    next();
                }
            } else {
                t.ok(false, 'Cell is not existing.')
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    /**
     * Enters data in the grid.
     *
     * @param {String} item Item Id of the grid.
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
     * @returns {iRely.TestEngine}
     */
    selectGridComboRowByFilter: function(item, row, column, filter) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();
            if (win) {
                var grid = item.editingPlugin ? item : win.down(item);
                if (grid) {
                    var store = grid.store;
                    if (store.indexOf(row) === -1) {
                        row = store.getAt(row);
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
                                length = editor.el.query('.x-trigger-cell').length,
                                trigger = editor.el.query('.x-trigger-cell')[length - 1];

                            t.diag('Entering data on grid ' + item);

                            if (Ext.isArray(filter)) {
                                editor.field.defaultFilters = filter;

                                t.chain([
                                    {
                                        action: 'click',
                                        target: trigger
                                    },
                                    function(next) {
                                        var comboGrid =  Ext.WindowManager.getActive();
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
                                function(next) {
                                    var grid = Ext.WindowManager.getActive(),
                                        filterGrid = grid.down('#txtFilterGrid');

                                    if (filterGrid) {
                                        t.chain([
                                            {
                                                action: 'click',
                                                target: filterGrid
                                            },
                                            function(next) {
                                                t.type(filterGrid, filter, next);
                                            },
                                            function(next) {
                                                t.type(filterGrid, '[RETURN]', next);
                                            },
                                            {
                                                action: 'wait',
                                                delay: 500
                                            },
                                            function(next) {
                                                var comboGrid =  Ext.WindowManager.getActive();
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
                                    } else {
                                        var idx = editor.field.store.findExact('field1', filter),
                                            picker = editor.field.getPicker(),
                                            node = picker.getNode(idx);

                                        t.click(node, function() {
                                            editor.completeEdit();
                                            next();
                                        });
                                    }
                                },
                                next
                            ]);
                        } else {
                            t.ok(false, 'Combo Box is not existing.')
                            next();
                        }
                    } else {
                        t.ok(false, 'Cell is not existing.')
                        next();
                    }
                } else {
                    t.ok(false, 'Cell is not existing.')
                    next();
                }
            } else {
                t.ok(false, 'Cell is not existing.')
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    /**
     * Moves to the first record by clicking the move first button of the paging toolbar
     *
     * @returns {iRely.TestEngine}
     */
    moveFirstRecord: function() {
        this.clickButton('#first');
        return this;
    },

    /**
     * Moves to the previous record by clicking the move previous button of the paging toolbar
     *
     * @returns {iRely.TestEngine}
     */
    movePreviousRecord: function() {
        this.clickButton('#prev');
        return this;
    },

    /**
     * Moves to the next record by clicking the move next button of the paging toolbar
     *
     * @returns {iRely.TestEngine}
     */
    moveNextRecord: function() {
        this.clickButton('#next');
        return this;
    },

    /**
     * Moves to the last record by clicking the move last button of the paging toolbar
     *
     * @returns {iRely.TestEngine}
     */
    moveLastRecord: function() {
        this.clickButton('#last');
        return this;
    },

    /**
     * Reloads the current record by clicking the refresh button of the toolbar.
     *
     * @returns {iRely.TestEngine}
     */
    reloadRecord: function() {
        this.clickButton('#refresh');
        return this;
    },

    /**
     * Checks the status bar message.
     *
     * @param {String} status Message of the status bar ('Ready', 'Edited', 'Saved').
     *
     * @returns {iRely.TestEngine}
     */
    checkStatusMessage: function(status) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive(),
                statusBar = win.down('ipagingstatusbar');

            t.diag('Checking Status Message.');

            if (!statusBar) {
                statusBar = win.down('istatusbar');
            }

            if (statusBar) {
                var label = statusBar.down('#lblStatus'),
                    result = label.el.dom.textContent === status;
                t.ok(result, result ? 'Status Message is correct.' : 'Status Message is incorrect.');
            }

            next();
        };

        chain.push(fn);
        return this;
    },

    /**
     * Checks the control if readonly/editable.
     *
     * @param {String/[String]} items Item Id/Array of Item Ids of the control(s) to assert.
     *
     * @param {Boolean} readOnly True to assert if the control is readonly otherwise editable.
     *
     * @returns {iRely.TestEngine}
     */
    checkControlReadOnly: function(items, readOnly) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive(),
                msg = readOnly ? 'readonly' : 'editable';

            items = Ext.isArray(items) ? items : [items];

            t.diag('Checking control ' + msg);

            for (var i in items) {
                var item = items[i],
                    control = win.down(item);

                if (control) {
                    var hidden = control.hidden;
                    if (hidden) {
                        t.ok(false, item + ' is not visible.');
                    } else {
                        var result = control.readOnly === readOnly;
                        t.ok(result, result ? (readOnly ? item + ' is read only.' : item + ' is editable.') : (readOnly ? item + ' is editable.' : item + ' is read only'));
                    }
                } else {
                    t.ok(false, item + ' is not existing.');
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
     * @param {String/[String]} items Item Id/Array of Item Ids of the control(s) to assert.
     *
     * @param {Boolean} visible True to assert if the control is visible otherwise hidden.
     *
     * @returns {iRely.TestEngine}
     */
    checkControlVisible: function(items, visible) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive(),
                msg = visible ? 'visible' : 'hidden';

            items = Ext.isArray(items) ? items : [items];

            t.diag('Checking control ' + msg);

            for (var i in items) {
                var item = items[i],
                    control = win.down(item);

                if (control) {
                    var result = control.hidden === !visible;
                    t.ok(result, result ? (visible ? item + ' is visible.' : item + ' is not visible.') : (visible ? item + ' is hidden.' : item + ' is not hidden.'));
                } else {
                    t.ok(false, item + ' is not existing.');
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
     * @param {String/[String]} items Item Id/Array of Item Ids of the control(s) to assert.
     *
     * @param {Boolean} disabled True to assert if the control is disabled otherwise enabled.
     *
     * @returns {iRely.TestEngine}
     */
    checkControlDisable: function(items, disabled) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive(),
                msg = disabled ? 'disabled' : 'enabled';

            items = Ext.isArray(items) ? items : [items];

            t.diag('Checking control ' + msg);

            for (var i in items) {
                var item = items[i],
                    control = win.down(item);

                if (control) {
                    var hidden = control.hidden;
                    if (hidden) {
                        t.ok(false, item + ' is not visible.');
                    } else {
                        var result = control.disabled === disabled;
                        t.ok(result, result ? (disabled ? item + ' is disabled.' : item + ' is enabled.') : (disabled ? item + ' is enabled.' : item + ' is disabled'));
                    }
                } else {
                    t.ok(false, item + ' is not existing.');
                }
            }

            next();
        };

        chain.push(fn);
        return this;
    },

    /**
     * Checks the control data if it matches the expected result.
     *
     * @param {String/[String]} items Item Id/Array of Item Ids of the control(s) to assert.
     *
     * @param {Object/[Object]} values Object/Array of Object to match with the control.
     *
     * @returns {iRely.TestEngine}
     */
    checkControlData: function(items, values) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();

            t.diag('Checking Control Data .');

            items = Ext.isArray(items) ? items : [items];
            values = Ext.isArray(values) ? values : [values];

            for (var i in items) {
                var item = items[i],
                    value = values[i],
                    control = win.down(item);

                if (control) {
                    var result = control.xtype === 'htmleditor' ?
                        control.getValue() === value :
                        control.rawValue === value;

                    t.ok(result, result ? item + ' value is correct.' : item + ' value is incorrect.');
                } else {
                    t.ok(false, item + ' is not existing.');
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
     * @param {String} items Item Id of the grid.
     *
     * @param {Integer} row Index of the row in the grid.
     *
     * @param {String} column Data Index or the Item Id of the column.
     *
     * @param {Object} data Data to match with the control.
     *
     * @returns {iRely.TestEngine}
     */
    checkGridData: function(item, row, column, data) {
        var chain = this.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();

            t.diag('Grid data checking.');

            if (win) {
                var grid = item.editingPlugin ? item : win.down(item);
                if (grid) {
                    var store = grid.store;
                    if (store.indexOf(row) === -1) {
                        row = store.getAt(row);
                    }

                    if (Ext.Array.indexOf(grid.columns, column) === -1) {
                        column = grid.columns[column] || grid.columnManager.getHeaderById(column) || grid.down('[dataIndex=' + column + ']');
                    }

                    if (row && column) {
                        var value = row.get(column.dataIndex),
                            result = value === data;
                        t.ok(result, result ? 'Cell data is correct.' : 'Cell data is incorrect.');

                        next();
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
     * Checks the grid's record count against the expected count.
     *
     * @param {String} items Item Id of the grid.
     *
     * @param {Integer} expectedCount Record count to expect.
     *
     * @returns {iRely.TestEngine}
     */
    checkGridRecordCount: function(item, expectedCount) {
        var chain = this.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();

            t.diag('Grid ' + item + ' count checking.');

            if (win) {
                var grid = item.editingPlugin ? item : win.down(item);
                
                if (grid) {
                    var store = grid.store,
                        count = store.getCount(),
                        result;
                        
                        if(grid.editingPlugin) {
                            count--;
                        }

                        result = count === expectedCount;

                    t.ok(result, result ? 'Grid count is correct.' : 'Grid count is incorrect.');
                } else {
                    t.ok(false, 'Grid is not existing.');
                }
            } else {
                t.ok(false, 'Grid is not existing.');
            }

            next();
        };

        chain.push(fn);
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
     * @param {Boolean} [options.undo] False to exclude undo button from checking. Defaults to true.
     *
     * @param {Boolean} [options.close] False to exclude close button from checking. Defaults to true.
     *
     * @returns {iRely.TestEngine}
     */
    checkToolbarButton: function(options) {
        options = options || {};

        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive(),
                newButton = options.new === undefined ? true : options.new,
                saveButton = options.save === undefined ? true : options.save,
                searchButton = options.search === undefined ? true : options.search,
                deleteButton = options.delete === undefined ? true : options.delete,
                undoButton = options.undo === undefined ? true : options.undo,
                closeButton = options.close === undefined ? true : options.close;

            t.diag('Checking toolbar buttons');

            if (newButton) {
                var button = win.down('#btnNew');
                if (button) {
                    var visible = button.hidden === false,
                        icon = button.iconCls === 'large-new',
                        text = button.text === 'New';

                    if (visible) {
                        t.ok(true, 'New button is visible.');
                        t.ok(icon, icon ? 'New button icon is correct.' : 'New button icon is incorrect.');
                        t.ok(text, text ? 'New button text is correct.' : 'New button text is incorrect.');
                    } else {
                        t.ok(false, 'New button is not visible.');
                    }
                } else {
                    t.ok(false, 'New button is not existing.');
                }
            }

            if (saveButton) {
                var button = win.down('#btnSave');
                if (button) {
                    var visible = button.hidden === false,
                        icon = button.iconCls === 'large-save',
                        text = button.text === 'Save';

                    if (visible) {
                        t.ok(true, 'Save button is visible.');
                        t.ok(icon, icon ? 'Save button icon is correct.' : 'Save button icon is incorrect.');
                        t.ok(text, text ? 'Save button text is correct.' : 'Save button text is incorrect.');
                    } else {
                        t.ok(false, 'Save button is not visible.');
                    }
                } else {
                    t.ok(false, 'Save button is not existing.');
                }
            }

            if (searchButton) {
                var button = win.down('#btnSearch') || win.down('#btnFind');
                if (button) {
                    var visible = button.hidden === false,
                        icon = button.iconCls === 'large-search',
                        text = button.text === 'Search';

                    if (visible) {
                        t.ok(true, 'Search button is visible.');
                        t.ok(icon, icon ? 'Search button icon is correct.' : 'Search button icon is incorrect.');
                        t.ok(text, text ? 'Search button text is correct.' : 'Search button text is incorrect.');
                    } else {
                        t.ok(false, 'Search button is not visible.');
                    }
                } else {
                    t.ok(false, 'Search button is not existing.');
                }
            }

            if (deleteButton) {
                var button = win.down('#btnDelete');
                if (button) {
                    var visible = button.hidden === false,
                        icon = button.iconCls === 'large-delete',
                        text = button.text === 'Delete';

                    if (visible) {
                        t.ok(true, 'Delete button is visible.');
                        t.ok(icon, icon ? 'Delete button icon is correct.' : 'Delete button icon is incorrect.');
                        t.ok(text, text ? 'Delete button text is correct.' : 'Delete button text is incorrect.');
                    } else {
                        t.ok(false, 'Delete button is not visible.');
                    }
                } else {
                    t.ok(false, 'Delete button is not existing.');
                }
            }

            if (undoButton) {
                var button = win.down('#btnUndo');
                if (button) {
                    var visible = button.hidden === false,
                        icon = button.iconCls === 'large-undo',
                        text = button.text === 'Undo';

                    if (visible) {
                        t.ok(true, 'Undo button is visible.');
                        t.ok(icon, icon ? 'Undo button icon is correct.' : 'Undo button icon is incorrect.');
                        t.ok(text, text ? 'Undo button text is correct.' : 'Undo button text is incorrect.');
                    } else {
                        t.ok(false, 'Undo button is not visible.');
                    }
                } else {
                    t.ok(false, 'Undo button is not existing.');
                }
            }

            if (closeButton) {
                var button = win.down('#btnClose');
                if (button) {
                    var visible = button.hidden === false,
                        icon = button.iconCls === 'large-close',
                        text = button.text === 'Close';

                    if (visible) {
                        t.ok(true, 'Close button is visible.');
                        t.ok(icon, icon ? 'Close button icon is correct.' : 'Close button icon is incorrect.');
                        t.ok(text, text ? 'Close button text is correct.' : 'Close button text is incorrect.');
                    } else {
                        t.ok(false, 'Close button is not visible.');
                    }
                } else {
                    t.ok(false, 'Close button is not existing.');
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
     * @returns {iRely.TestEngine}
     */
    checkStatusBar: function() {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();

            t.diag('Checking status bar');

            var result = win.down('istatusbar') !== undefined || win.down('istatusbar') !== null;
            t.ok(result, result ? 'Status bar is correct.' : 'Status bar is incorrect.');

            next();
        };

        chain.push(fn);
        return this;
    },

    /**
     * Checks if the active screen uses our standard paging status bar (ipagingstatusbar)
     *
     * @returns {iRely.TestEngine}
     */
    checkPagingStatusBar: function() {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();

            t.diag('Checking paging status bar');

            var result = win.down('ipagingstatusbar') !== undefined || win.down('ipagingstatusbar') !== null;
            t.ok(result, result ? 'Paging status bar is correct.' : 'Paging status bar is incorrect.');

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
     * @returns {iRely.TestEngine}
     */
    checkPagingStatusBarValue: function(currPage, noOfPages) {
        var chain = this.chain;

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
                t.ok(false, item + ' is not existing.');
            }

            next();
        }

        chain.push(fn);
        return this;
    },

    /**
     * Enters data in the grid.
     *
     * @param {String} item Item Id of the grid.
     *
     * @param {Object[]} objs Data Index or the Item Id of the column.
     *
     * Object Definition
     *     {
     *          column : 'strDeviceType',
     *          data : 'Sample Data'
     *      }
     *
     * @returns {iRely.TestEngine}
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
                    var grid = item.editingPlugin ? item : win.down(item);

                    if (grid) {
                        var store = grid.getStore(),
                            sm = grid.getSelectionModel(),
                            selected,row;

                        if(!sm) {
                            t.ok(false,'No Selected Record');
                        }

                        selected = sm.getSelection();

                        if(selected > 1){
                            t.ok(false,'Only supports 1 data row entry at one time');
                        }

                        row = store.indexOf(selected[0]);

                        if (store.indexOf(row) === -1) {
                            row = store.getAt(row);
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

                                t.diag('Entering data on grid ' + item);

                                start = start || 0;
                                end = end || value ? value.length : 0;

                                t.selectText(editor, start, end);
                                t.type(editor, data, function() {
                                    editor.completeEdit();
                                    next();
                                });
                            } else {
                                t.ok(false, 'Editor is not existing.')
                                next();
                            }
                        } else {
                            t.ok(false, 'Cell is not existing.')
                            next();
                        }
                    } else {
                        t.ok(false, 'Cell is not existing.')
                        next();
                    }
                } else {
                    t.ok(false, 'Cell is not existing.')
                    next();
                }
            });
        });

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
     * @returns {iRely.TestEngine}
     */
    checkScreenWindow: function(options) {
        options = options || {};

        var me = this,
            chain = me.chain;

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
                t.diag('Checking Screen Window');

                var icon = win.iconCls === 'small-icon-i21' || win.iconCls === 'small-irely-icon', //TODO: Verify this
                    titleResult = win.title === title;

                if (alias) {
                    var userAlias = win.alias[0];
                    if (userAlias.replace('widget.', '') === alias) {
                        t.ok(true, 'Screen is shown.');
                    } else {
                        t.ok(false, 'Screen is not shown.');
                        next();
                        return;
                    }
                }

                t.ok(icon, icon ? 'Screen icon is correct.' : 'Screen icon is incorrect.');
                t.ok(titleResult, titleResult ? 'Screen title is correct.' : 'Screen title is incorrect.');

                if (collapseButton) {
                    var result = win.tools['collapse-top'];
                    t.ok(result, result ? 'Collapse button is visible.' : 'Collapse button is not visible.');
                }

                if (maximizeButton) {
                    var result = win.tools['maximize'];
                    t.ok(result, result ? 'Maximize button is visible.' : 'Maximize button is not visible.');
                }

                if (minimizeButton) {
                    var result = win.tools['minimize'];
                    t.ok(result, result ? 'Minimize button is visible.' : 'Minimize button is not visible.');
                }

                if (restoreButton) {
                    var result = win.tools['restore'];
                    t.ok(result, result ? 'Restore button is visible.' : 'Restore button is not visible.');
                }

                if (closeButton) {
                    var result = win.tools['close'];
                    t.ok(result, result ? 'Close button is visible.' : 'Close button is not visible.');
                }
            }

            next();
        };

        chain.push(fn);
        return this;
    },

    /**
     * Checks if the screen is properly closed
     *
     * @param {String} item Item Id or alias of the window
     *
     * @returns {iRely.TestEngine}
     */
    checkIfScreenClosed : function(item) {
        var chain = this.chain;

        var fn = function(next) {
            var t = this,
                com = Ext.ComponentQuery.query(item)[0];

            if(com) {
                t.ok(false, item + ' screen is not closed');
                
            }
            else {
                t.ok(true, item + ' screen is closed');
            }

            next();
        }

        chain.push(fn);
        return this;
    },

    /**
     * Checks the message box.
     *
     * @param {String} title Title of the message box.
     *
     * @param {String} message Message of the message box.
     *
     * @param {String} buttons Buttons of the message box. ('ok','yesno','yesnocancel').
     *
     * @param {String} icon Icon of the message box. ('error','information', 'question', 'warning')
     *
     * @returns {iRely.TestEngine}
     */
    checkMessageBox: function(title, message, buttons, icon) {
        var chain = this.chain;

        buttons = buttons ? buttons : 'ok';
        icon    = icon ? icon : ''; //There should be changing of icon cls here

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();

            t.diag('Checking Message Box.');

            if (win) {
                if (win.xtype === 'messagebox') {
                    var iconCls = '',
                        titleResult,
                        msgResult,
                        buttonResult,
                        iconResult;

                    t.ok(true, 'Message box is shown.');

                    t.ok(titleResult = (win.title === title), titleResult ? 'Title is correct.' : 'Title is incorrect.');
                    t.ok(msgResult = (win.msg.value === message), msgResult ?  'Message is correct.' : 'Message is incorrect.');

                    switch (buttons) {
                        case 'ok':
                            buttonResult = win.msgButtons.yes.hidden && win.msgButtons.no.hidden && win.msgButtons.cancel.hidden;
                            break;
                        case 'yesno':
                            buttonResult = win.msgButtons.ok.hidden && win.msgButtons.cancel.hidden;
                            break;
                        case 'yesnocancel':
                            buttonResult = win.msgButtons.ok.hidden;
                            break;
                    }

                    switch (icon) {
                        case 'information':
                            iconCls = 'large-dialog-box-information image-no-repeat';
                            break;
                        case 'question':
                            iconCls = 'large-dialog-box-question image-no-repeat';
                            break;
                        case 'error':
                            iconCls = 'large-dialog-box-error image-no-repeat';
                            break;
                        case 'warning':
                            iconCls = 'large-dialog-box-warning image-no-repeat';
                            break;
                    }

                    t.ok(buttonResult, buttonResult ? 'Button is correct.' : 'Button is incorrect.');
                    t.ok(iconResult = (win.messageIconCls === iconCls), iconResult ?  'Icon is correct.' : 'Icon is incorrect.');
                } else {
                    t.ok(false, 'Message box is not shown.');
                }
            } else {
                t.ok(false, 'Message box is not shown.');
            }

            next();
        };

        chain.push(fn);
        return this;
    },

    /**
     * Checks the screen if it's shown.
     *
     * @param {String} alias User alias of the screen to check.
     *
     * @returns {iRely.TestEngine}
     */
    checkScreenShown: function(alias) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                shown = me.isComponentShown(alias);

            t.ok(shown, shown ? 'Screen is shown.' : 'Screen is not shown.');
            next();
        };

        chain.push(fn);
        return this;
    },

    /**
     * Function that opens the combo box and allows you to check its data
     *
     * @param {String} item Item Id of the check box.
     *
     * @param {Function} checker Function for the combo box
     *
     * @returns {iRely.TestEngine}
     */
    checkComboBox : function (item, checker) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var t = this,
                win = Ext.WindowManager.getActive();
            if (win) {
                var combo = item.value ? item : win.down(item);
                if (combo) {
                    var length = combo.el.query('.x-trigger-cell').length,
                        trigger = combo.el.query('.x-trigger-cell')[length - 1];

                    t.chain([
                        // toggle the combobox
                        {
                            action: 'click',
                            target: trigger
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
                                t.ok(false, 'Combo Box is not existing.')
                                next();
                            }
                        },
                        // untoggle the combobox
                        {
                            action: 'click',
                            target: trigger
                        },
                        next
                    ]);
                } else {
                    t.ok(false, 'Combo Box is not existing.')
                    next();
                }
            } else {
                t.ok(false, 'Combo Box  is not existing.')
                next();
            }
        };

        chain.push(fn);
        return this;
    },

    /**
     * Checks if a component has a field label
     *
     * @param {String} item Item Id or alias of the window
     *
     * @param {Boolean} hasLabel Defaults to True. Determines if the field lable exists
     *
     * @returns {iRely.TestEngine}
     */
    checkFieldLabel: function(item, hasLabel) {
        var me = this,
            chain = me.chain;

        var fn = function(next) {
            var win = Ext.WindowManager.getActive(),
                el = win.down(item),
                hl = typeof hasLabel === 'undefined' ? true : hasLabel;

            var result = !!el.fieldLabel;

            t.diag('Checking Field Label for component ' + item);
          
            if(hl && result) {
                t.ok(true, 'Field label Exists.')
            }
            else if((hl && !result) || (!hl && result)) {
                t.ok(false, 'Components label does not exist; expected: ' + hl + ' got: ' + result);
            }
            else {
                t.ok(true, 'Field Label does not exist');
            }
                    
            next();
        }

        chain.push(fn);
        return this;
    },

    /**
     * Delays the calling the next function.
     *
     * @param {Integer} howLong The delay value in millisecond.
     *
     * @returns {iRely.TestEngine}
     */
    wait: function(howLong) {
        var chain = this.chain;
        chain.push({
            action: 'wait',
            delay: howLong
        });

        return this;
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

    /*
     * @private
     * Gets the actual record on the main menu
     *
     * @param {String} type Type of menu ('Folder', 'Screen', 'Report').
     *
     * @param {String} menuName Menu Name.
     */
    getRecordFromMenu: function (type, menuName) {
        var mainMenu = this.getComponentByQuery('viewport'),
            treeView = mainMenu.down('#trvMenu'),
            treeStore = treeView.dataSource;

        var menus = treeStore.queryBy(function(record) {
            return record.get('strType').toLowerCase() === type.toLowerCase() &&
                record.get('strMenuName').toLowerCase() === menuName.toLowerCase();
        });

        return menus.items[0];
    },

    /**
     * @private
     * Selects the dummy row
     *
     * @param {String} item Item Id of the grid.
     *
     * @returns {iRely.TestEngine}
     */
    selectDummyRow : function(item) {
        var me = this,
            chain = me.chain,

            fn = function (next) {
                var w = Ext.WindowManager.getActive(),
                    grid = w.down(!item ? 'grid' : item),
                    store = grid.getStore(),
                    sm = grid.getSelectionModel(),
                    idx;

                for (var i = 0; i < store.data.items.length; i++) {
                    if (store.data.items[i].dummy) {
                        idx = i;
                        break;
                    }
                }
                sm.select(idx);

                next();
            };

        chain.push(fn);
        return this;
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
        var mainMenu = this.getComponentByQuery('viewport'),
            treeView = mainMenu.down('#trvMenu'),
            record = this.getRecordFromMenu(type, menuName);

        return treeView.getNodeByRecord(record);
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
    }
});
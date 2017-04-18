var months = [
    { intId: 1, strMonth: 'January' },
    { intId: 2, strMonth: 'February' },
    { intId: 3, strMonth: 'March' },
    { intId: 4, strMonth: 'April' },
    { intId: 5, strMonth: 'May' },
    { intId: 6, strMonth: 'June' },
    { intId: 7, strMonth: 'July' },
    { intId: 8, strMonth: 'August' },
    { intId: 9, strMonth: 'September' },
    { intId: 10, strMonth: 'October' },
    { intId: 11, strMonth: 'November' },
    { intId: 12, strMonth: 'December' }
];
Ext.define('Inventory.view.RebuildInventoryViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icrebuildinventory',

    config: {
        binding: {
            cboPostOrder: {
                store: '{postOrderTypes}',
                value: '{current.strPostOrder}',
                readOnly: '{isInProgress}'
            },
            cboFiscalMonth: {
                store: '{fiscalMonths}',
                value: '{current.strMonth}',
                readOnly: '{isInProgress}'
            },
            cboItem: {
                store: '{items}',
                value: '{current.strItemNo}',
                readOnly: '{isInProgress}',
                defaultFilters: [
                    {
                        column: 'strType',
                        value: 'Inventory|^|Raw Material|^|Finished Good|^|Bundle|^|Kit',
                        conjunction: 'and',
                        condition: 'eq'
                    }
                ]
            },
            btnPost: {
                disabled: '{!canPost}'
            }
        }
    },

    onItemSelect: function (combo, record) {
        this.getView().viewModel.setData({ selectedItem: record[0].data });
    },

    onMonthSelect: function (combo, record) {
        var current = this.getView().viewModel.data.current;
        current.set('intMonth', record[0].data.intStartMonth);
        current.set('dtmDate', record[0].data.dtmStartDate);
    },

    onRepostClick: function (e) {
        var me = this;
        var vm = me.getView().viewModel;
        var win = e.up('window');
        var cboFiscalMonth = win.down('#cboFiscalMonth');

        var jsondata = {
            dtmStartDate: moment(vm.data.current.data.dtmDate).format('l'),
            strItemNo: vm.data.current.data.strItemNo,
            isPeriodic: vm.data.current.data.strPostOrder === 'Periodic'
        };
        var callback = function (button) {
            if (button === 'yes') {
                me.repost(vm, jsondata);
            }
        };
        iRely.Functions.showCustomDialog('question', 'yesno', vm.data.prompt, callback);
    },

    verifyValuation: function (date) {
        return ic.utils.ajax({
            timeout: 120000,
            url: '../Inventory/api/InventoryValuation/CompareRebuiltValuationSnapshot',
            method: "GET",
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            },
            params: {
                dtmStartDate: date
            }
        });
    },

    rebuild: function (data) {
        return ic.utils.ajax({
            timeout: 0, //120000,
            url: '../Inventory/api/InventoryValuation/RebuildInventory',
            method: "post",
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            },
            params: data,
            processData: true
        });
    },

    downloadDiscrepancies: function (columns, data) {
        var alias = [
            { field: 'strAccountId', column: "Account Id" },
            { field: 'strDescription', column: "Description" },
            { field: 'strRebuildDate', column: "Rebuild Date" },
            { field: 'dblDebit_Snapshot', column: "Rebuild Debit" },
            { field: "dblDebit_ActualGLDetail", column: "Actual Debit" },
            { field: "DebitDiff", column: "Debit Diff" },
            { field: "dblCredit_Snapshot", column: "Rebuild Credit" },
            { field: "dblCredit_ActualGLDetail", column: "Actual Credit" },
            { field: "CreditDiff", column: "Credit Diff" }
        ];
        ic.utils.writeCSV(columns, data, alias, "disrepancies.csv");
    },

    repost: function (vm, data) {
        var me = this;
        iRely.Msg.showWait('In Progress');
        me.view.context.screenMgr.toolbarMgr.provideFeedBack({ text: 'In Progress', color: 'Red'});
        vm.setData({ inProgress: true });
        var rebuildObs = me.rebuild(data);
        var verifyObs = me.verifyValuation(data.dtmStartDate);
        rebuildObs
            .flatMap(verifyObs)
            .finally(function () { 
                iRely.Msg.close(); 
            })
            .subscribe(
            function (res) {
                var json = JSON.parse(res.responseText);
                if (json.success) {
                    if (res.status === 202)
                        iRely.Functions.showCustomDialog('warning', 'yesno', "Rebuild inventory completed but discrepancies were found. Do you want to download the logs to check discrepancies manually?", function (button) {
                            if (button === 'yes') {
                                ic.utils.ajax({
                                    url: '../Inventory/api/InventoryValuation/GetDiscrepancies',
                                    params: {
                                        dtmDate: data.dtmStartDate
                                    }
                                })
                                .map(function (x) {
                                    var json = JSON.parse(x.responseText);
                                    return {
                                        csv: ic.utils.jsonArrayToCSVMapping(json.data),
                                        success: true,
                                        message: 'Success'
                                    };
                                })
                                .subscribe(
                                    function (res) {
                                        if (res.success) {
                                            me.view.context.screenMgr.toolbarMgr.provideFeedBack({ text: 'Rebuild Complete', color: 'Blue'});
                                            vm.setData({ inProgress: false });
                                            me.downloadDiscrepancies(res.csv.columns, res.csv.data);
                                        } else {
                                            iRely.Functions.showErrorDialog("Error downloading." + res.message);
                                        }
                                    },
                                    function (error) {
                                        var json = JSON.parse(error.responseText);
                                        iRely.Functions.showErrorDialog(json.message);
                                    }
                                );
                            }
                        });
                    else {
                        iRely.Functions.showInfoDialog("Rebuild Complete.");
                        me.view.context.screenMgr.toolbarMgr.provideFeedBack({ text: 'Rebuild Complete', color: 'Blue'});
                        vm.setData({ inProgress: false });
                    }
                }
                else
                    iRely.Functions.showErrorDialog(json.message);
            },
            function (error) {
                if (error.timedout)
                    iRely.Functions.showErrorDialog("Looks like the server is taking too long to respond, this can be caused by either poor connectivity or an error with our servers. Please try again in a while.");
                else
                    iRely.Functions.showErrorDialog(JSON.parse(error.responseText).message);
            }
            );
    },

    onFiscalMonthBeforeQuery: function(obj) {
        if (obj.combo) {
            var store = obj.combo.store;
            var win = obj.combo.up('window');
            if (store) {
                store.remoteFilter = false;
                store.remoteSort = false;
            }

            if (obj.combo.itemId === 'cboFiscalMonth') {
                store.clearFilter();
                store.filterBy(function (rec, id) {
                    if(rec.get('strPeriod').toLowerCase().indexOf(obj.query.toLowerCase()) !== -1)
                        return true;
                    return false;
                });
            }
        }
    },

    init: function (cfg) {
        this.control({
            '#cboItem': {
                select: this.onItemSelect
            },
            '#cboFiscalMonth': {
                select: this.onMonthSelect,
                beforequery: this.onFiscalMonthBeforeQuery
            },
            '#btnPost': {
                click: this.onRepostClick
            }
        });
    },

    show: function (config) {
        "use strict";

        var me = this,
            win = this.getView(),
            vm = win.viewModel;

        if (config) {
            win.show();

            var context = me.setupContext({ window: win });
            me.setupAdditionalBinding({ window: win, context: context, viewModel: vm });
            context.data.addRecord();
        }

        //var cboFiscalMonth = win.down("#cboFiscalMonth");
        var d = new Date();
        var intMonth = d.getMonth() + 1;
        var strMonth = months[d.getMonth()].strMonth;
        var dtmDate = new Date(d.getFullYear(), d.getMonth(), 1);
        
        var store = Ext.create('Inventory.store.FiscalPeriod');
        store.load({
            callback: function(record) {
                if(record) {
                    var fy = _.filter(record, function(x) {
                        return x.data.intStartMonth === intMonth && d.getFullYear().toString() === x.data.strFiscalYear;
                    });
                    if(fy) {
                        var current = vm.data.current;
                        current.set('intMonth', fy[0].data.intStartMonth);
                        current.set('dtmDate', fy[0].data.dtmStartDate);
                        current.set('strMonth', fy[0].data.strStartMonth);
                    }
                }
            }
        });
        // ic.utils.ajax({
        //     url: '../Inventory/api/InventoryValuation/GetFiscalMonths',
        //     method: 'GET'
        // }).subscribe(function(success) {
        //     if(success.responseText !== "") {
        //         var res = JSON.parse(success.responseText);
        //         if(res && res.success === true) {
        //             var fy = _.filter(res.data, function(x) {
        //                 return x.intStartMonth === intMonth && d.getFullYear().toString() === x.strFiscalYear;
        //             });
        //             if(fy) {
        //                 var current = vm.data.current;
        //                 current.set('intMonth', fy[0].intStartMonth);
        //                 current.set('dtmDate', fy[0].dtmStartDate);
        //                 current.set('strMonth', fy[0].strStartMonth);
        //             }
        //         }
        //     }
        // }, function(failure) {

        // });
    },

    createRecord: function (config, action) {
        var record = Ext.create('Inventory.model.RebuildInventory');
        var d = new Date();
        // record.set('intMonth', d.getMonth() + 1);
        // record.set('strMonth', months[d.getMonth()].strMonth);
        // record.set('dtmDate', new Date(d.getFullYear(), d.getMonth(), 1));
        record.set('strPostOrder', 'Periodic');
        action(record);
    },

    setupAdditionalBinding: function (cfg) {
        var me = this;
        if (cfg) {
            var win = cfg.window;
            var btnPost = win.down('#btnPost');
            btnPost.setVisible(iRely.Configuration.Security.IsAdmin);
        }
    },

    setupContext: function (config) {
        "use strict";
        var me = this,
            win = config.window,
            store = Ext.create('Inventory.store.RebuildInventory', { pageSize: 1 });

        win.context = Ext.create('iRely.Engine', {
            window: win,
            store: store,
            createRecord: me.createRecord,
            binding: me.config.binding,
            checkChange: false
        });

        return win.context;
    }
});
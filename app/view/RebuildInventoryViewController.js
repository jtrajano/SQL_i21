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
            lblDescription: {
                value: '{description}'
            },
            cboPostOrder: {
                store: '{postOrderTypes}',
                value: '{current.strPostOrder}'
            },
            cboFiscalMonth: {
                store: '{fiscalMonths}',
                value: '{current.strMonth}'
            },
            cboFiscalDate: {
                value: '{current.dtmDate}'
            },
            cboItem: {
                store: '{items}',
                value: '{current.strItemNo}',
                defaultFilters: [
                    {
                        column: 'strType',
                        value: 'Inventory|^|Raw Material|^|Finished Good|^|Bundle|^|Kit',
                        conjunction: 'and',
                        condition: 'eq'
                    }
                ]
            },
            btnRepost: {
                disabled: '{!canPost}'
            }
        }
    },

    onItemSelect: function (combo, record) {
        this.getView().viewModel.setData({ selectedItem: record[0].data });
    },

    onMonthSelect: function (combo, record) {
        var current = this.getView().viewModel.data.current;
        current.set('intMonth', record.data.intStartMonth);
        current.set('dtmDate', record.data.dtmStartDate);
    },

    onRepostClick: function (e) {
        var me = this;
        var vm = me.getView().viewModel;
        var win = e.up('window');
        var combo = win.down('#cboFiscalDate');
        var cboFiscalMonth = win.down('#cboFiscalMonth');

        var jsondata = {
            dtmStartDate: moment(vm.data.current.data.dtmDate).format('l'),
            strItemNo: vm.data.current.data.strItemNo,
            isPeriodic: vm.data.current.data.strPostOrder === 'Periodic'
        };
        var callback = function (button) {
            if (button === 'yes') {
                me.repost(jsondata);
            }
        };
        iRely.Functions.showCustomDialog('question', 'yesno', vm.data.prompt, callback);
    },

    verifyValuation: function(date) {
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

    rebuild: function(data) {
        return ic.utils.ajax({
            timeout: 120000,
            url: '../Inventory/api/InventoryValuation/RebuildInventory',
            method: "post",
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            },
            params: data,
            processData: true
        });
    },

    repost: function (data) {
        var me = this;
        iRely.Msg.showWait('Rebuilding inventory...');
        var rebuildObs = me.rebuild(data);
        var verifyObs = me.verifyValuation(data.dtmStartDate);
        rebuildObs
        .flatMap(verifyObs)
        .finally(() => iRely.Msg.close())
        .subscribe(
            data => {
                var json = JSON.parse(data.responseText);
                if (json.success) {
                    if(data.status === 202)
                        iRely.Functions.showInfoDialog(json.message);
                }
                else
                    iRely.Functions.showErrorDialog(json.message);
            }, 
            error => {
                if(error.timedout)
                    iRely.Functions.showErrorDialog("Looks like the server is taking to long to respond, this can be caused by either poor connectivity or an error with our servers. Please try again in a while.");
                else
                    iRely.Functions.showErrorDialog(JSON.parse(error.responseText).message);
            }
        );
    },

    init: function (cfg) {
        this.control({
            '#cboItem': {
                select: this.onItemSelect
            },
            '#cboFiscalMonth': {
                select: this.onMonthSelect
            },
            '#btnRepost': {
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
    },

    createRecord: function (config, action) {
        var record = Ext.create('Inventory.model.RebuildInventory');
        var d = new Date();
        record.set('intMonth', d.getMonth() + 1);
        record.set('strMonth', months[d.getMonth()].strMonth);
        record.set('dtmDate', new Date(d.getFullYear(), d.getMonth(), 1));
        record.set('strPostOrder', 'Periodic');
        action(record);
    },

    setupAdditionalBinding: function (cfg) {
        var me = this;
        if (cfg) {
            var win = cfg.window;
            var btnRepost = win.down('#btnRepost');
            btnRepost.setVisible(iRely.Configuration.Security.IsAdmin);
        }
    },

    setupContext: function (config) {
        "use strict";
        var me = this,
            win = config.window,
            store = Ext.create('Inventory.store.RebuildInventory', { pageSize: 1 });

        win.context = Ext.create('iRely.mvvm.Engine', {
            window: win,
            store: store,
            createRecord: me.createRecord,
            binding: me.config.binding,
            checkChange: false
        });

        return win.context;
    }
});
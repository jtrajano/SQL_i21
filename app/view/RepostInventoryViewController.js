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
Ext.define('Inventory.view.RepostInventoryViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icrepostinventory',

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

    repost: function (jsondata) {
        jQuery.ajax({
            url: '../Inventory/api/InventoryValuation/RepostInventory',
            method: "post",
            headers: {
                'Authorization': iRely.Functions.createIdentityToken(app.UserName, app.Password, app.Company, app.UserId, app.EntityId),
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            },
            data: jsondata,
            processData: true,
            beforeSend: function (jqXHR, settings) {
                iRely.Msg.showWait('Reposting inventory...');
            },
            success: function (data, status, jqXHR) {
                if (data.success)
                    iRely.Functions.showInfoDialog(data.message);
                else
                    iRely.Functions.showErrorDialog(data.message);
                iRely.Msg.close();
            },
            error: function (jqXHR, status, error) {
                iRely.Msg.close();
                iRely.Functions.showErrorDialog(JSON.parse(jqXHR.responseText).message);
            }
        });
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
        var record = Ext.create('Inventory.model.RepostInventory');
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
            store = Ext.create('Inventory.store.RepostInventory', { pageSize: 1 });

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
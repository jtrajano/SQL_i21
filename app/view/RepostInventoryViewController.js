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
            }
        }
    },

    onItemSelect: function(combo, record) {
        this.getView().viewModel.setData({ selectedItem: record[0].data });
    },

    onMonthSelect: function(combo, record) {
        var current = this.getView().viewModel.data.current;
        var month = _.findWhere(months, { strMonth: record.data.strMonth });  
        var date = current.get('dtmDate');
        var newDate = new Date(date.getFullYear(), month.intId-1, date.getDate());
        current.set('intMonth', month.intId);
        current.set('dtmDate', newDate);
    },

    onRepostClick: function(e) {
        var vm = this.getView().viewModel;
        console.log(vm.data.current);
        console.log(vm.data.selectedItem);
        Ext.Ajax.request({
            url: '../Inventory/api/Rebuild',
            method: 'post',
            successFn: function(res) {
                console.log(res);
            }
        });
    },

    onDateSelect: function(picker, date) {
        var current = this.getView().viewModel.data.current;
        current.set('intMonth', date.getMonth()+1);
        var month = _.findWhere(months, { intId: date.getMonth()+1 });
        current.set('strMonth', month.strMonth);    
    },

    init: function(cfg) {
        this.control({
            '#cboItem': {
                select: this.onItemSelect
            },
            '#cboFiscalMonth': {
                select: this.onMonthSelect
            },
            '#cboFiscalDate': {
                select: this.onDateSelect
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

    createRecord: function(config, action) {
        var record = Ext.create('Inventory.model.RepostInventory');
        var d = new Date();
        record.set('intMonth', d.getMonth()+1);
        record.set('strMonth', months[d.getMonth()].strMonth);
        record.set('dtmDate', new Date(d.getFullYear(), d.getMonth(), 1));
        record.set('strPostOrder', 'Perpetual');
        action(record);
    },

    setupAdditionalBinding: function(cfg) {
        var me = this;
        if(cfg) {
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
            binding: me.config.binding
        });

        return win.context;
    }
});